import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:convert';
import 'package:shao_kao/storage_service.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart'
    if (dart.library.html) 'package:pos/bluetooth_stub.dart'
    if (dart.library.io) 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Model untuk menyimpan info printer
class PrinterInfo {
  final String id;
  final String name;
  final String role; // 'admin', 'dapur1', 'dapur2'
  BluetoothDevice? device;
  BluetoothCharacteristic? writeCharacteristic;
  bool isConnected;
  int mtu;
  int maxChunkSize;

  PrinterInfo({
    required this.id,
    required this.name,
    required this.role,
    this.device,
    this.writeCharacteristic,
    this.isConnected = false,
    this.mtu = 23,
    this.maxChunkSize = 50,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
      };

  factory PrinterInfo.fromJson(Map<String, dynamic> json) => PrinterInfo(
        id: json['id'],
        name: json['name'],
        role: json['role'],
      );
}

// Singleton class untuk manage multiple printers
class BluetoothPrinterManager {
  static final BluetoothPrinterManager _instance =
      BluetoothPrinterManager._internal();
  factory BluetoothPrinterManager() => _instance;
  BluetoothPrinterManager._internal();

  // Map untuk menyimpan semua printer berdasarkan role
  final Map<String, PrinterInfo> _printers = {};
  bool _isReconnecting = false;
  bool _isBluetoothSupported = false;

  static const int _defaultMaxChunkSize = 200;
  static const int _minChunkSize = 50;

  // Notifiers untuk UI updates
  final ValueNotifier<Map<String, PrinterInfo>> printersNotifier =
      ValueNotifier<Map<String, PrinterInfo>>({});
  final ValueNotifier<int> connectedCountNotifier = ValueNotifier<int>(0);

  final StorageService _storage = StorageService.instance;
  static const String _printersKey = 'saved_printers_list';

  // Getters
  bool get isBluetoothSupported => _isBluetoothSupported;
  bool get isReconnecting => _isReconnecting;
  Map<String, PrinterInfo> get printers => Map.from(_printers);
  int get connectedCount => _printers.values.where((p) => p.isConnected).length;

  // Get printer by role
  PrinterInfo? getPrinterByRole(String role) => _printers[role];

  // Check if specific role is connected
  bool isRoleConnected(String role) => _printers[role]?.isConnected ?? false;

  bool _checkBluetoothSupport() {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  void _calculateChunkSize(PrinterInfo printer) {
    try {
      if (printer.mtu <= 23) {
        printer.maxChunkSize = _minChunkSize;
      } else {
        int usableSpace = ((printer.mtu - 23) * 0.7).round();
        printer.maxChunkSize = (usableSpace + _minChunkSize)
            .clamp(_minChunkSize, _defaultMaxChunkSize);
      }
      print(
          'Printer ${printer.role}: MTU ${printer.mtu}, Chunk ${printer.maxChunkSize}');
    } catch (e) {
      printer.maxChunkSize = _minChunkSize;
    }
  }

  Future<void> initialize() async {
    print('MultiPrinterManager: Initializing...');
    _isBluetoothSupported = _checkBluetoothSupport();

    if (!_isBluetoothSupported) {
      print('MultiPrinterManager: Bluetooth not supported');
      return;
    }

    // Load saved printers
    await _loadSavedPrinters();

    // Attempt auto reconnect
    await _attemptAutoReconnect();

    // Listen to Bluetooth state
    try {
      FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        if (state == BluetoothAdapterState.on) {
          _attemptAutoReconnect();
        } else {
          _disconnectAll();
        }
      });
    } catch (e) {
      print('MultiPrinterManager: Failed to listen adapter state: $e');
    }
  }

  Future<void> _loadSavedPrinters() async {
    try {
      String? savedData = _storage.getString(_printersKey);
      if (savedData != null) {
        List<dynamic> jsonList = jsonDecode(savedData);
        for (var json in jsonList) {
          PrinterInfo printer = PrinterInfo.fromJson(json);
          _printers[printer.role] = printer;
        }
        print('MultiPrinterManager: Loaded ${_printers.length} saved printers');
        _updateNotifiers();
      }
    } catch (e) {
      print('MultiPrinterManager: Error loading saved printers: $e');
    }
  }

  Future<void> _savePrinters() async {
    try {
      List<Map<String, dynamic>> jsonList =
          _printers.values.map((p) => p.toJson()).toList();
      _storage.setString(_printersKey, jsonEncode(jsonList));
      print('MultiPrinterManager: Saved ${_printers.length} printers');
    } catch (e) {
      print('MultiPrinterManager: Error saving printers: $e');
    }
  }

  Future<void> _attemptAutoReconnect() async {
    if (!_isBluetoothSupported || _isReconnecting || _printers.isEmpty) return;

    _isReconnecting = true;
    print(
        'MultiPrinterManager: Auto reconnecting to ${_printers.length} printers...');

    try {
      BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
      if (state != BluetoothAdapterState.on) {
        _isReconnecting = false;
        return;
      }

      List<BluetoothDevice> systemDevices =
          await FlutterBluePlus.systemDevices([]);

      for (var entry in _printers.entries) {
        PrinterInfo printer = entry.value;

        BluetoothDevice? targetDevice = systemDevices.firstWhere(
          (device) => device.remoteId.toString() == printer.id,
          orElse: () => null as BluetoothDevice,
        );

        if (targetDevice == null) {
          try {
            targetDevice = BluetoothDevice.fromId(printer.id);
          } catch (e) {
            print(
                'MultiPrinterManager: Failed to create device for ${printer.role}');
            continue;
          }
        }

        await _connectToDeviceInternal(targetDevice, printer.role, printer.name,
            isAutoReconnect: true);
        await Future.delayed(Duration(milliseconds: 500));
      }
    } catch (e) {
      print('MultiPrinterManager: Auto reconnect error: $e');
    }

    _isReconnecting = false;
  }

  // Connect to device with role assignment
  Future<bool> connectToDevice(
      BluetoothDevice device, String role, String name) async {
    if (!_isBluetoothSupported) return false;
    return await _connectToDeviceInternal(device, role, name,
        isAutoReconnect: false);
  }

  Future<bool> _connectToDeviceInternal(
    BluetoothDevice device,
    String role,
    String name, {
    required bool isAutoReconnect,
  }) async {
    if (!_isBluetoothSupported) return false;

    try {
      // Check if already connected
      if (_printers[role]?.isConnected == true &&
          _printers[role]?.id == device.remoteId.toString()) {
        print('MultiPrinterManager: $role already connected');
        return true;
      }

      print('MultiPrinterManager: Connecting to $name as $role...');

      bool alreadyConnected = await device.connectionState.first
          .then((state) => state == BluetoothConnectionState.connected)
          .catchError((_) => false);

      if (!alreadyConnected) {
        await device.connect(timeout: Duration(seconds: 15));
      }

      // Get MTU
      int mtu = 23;
      try {
        mtu = await device.mtu.first;
        if (mtu < 200) {
          int newMtu = await device.requestMtu(250);
          mtu = newMtu;
        }
      } catch (e) {
        print('MultiPrinterManager: MTU error for $role: $e');
      }

      // Discover services
      List<BluetoothService> services = await device.discoverServices();

      BluetoothCharacteristic? writeChar;
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.write ||
              characteristic.properties.writeWithoutResponse) {
            writeChar = characteristic;
            break;
          }
        }
        if (writeChar != null) break;
      }

      if (writeChar == null) {
        throw Exception('No writable characteristic found');
      }

      // Create or update printer info
      PrinterInfo printer = PrinterInfo(
        id: device.remoteId.toString(),
        name: name,
        role: role,
        device: device,
        writeCharacteristic: writeChar,
        isConnected: true,
        mtu: mtu,
      );

      _calculateChunkSize(printer);
      _printers[role] = printer;

      if (!isAutoReconnect) {
        await _savePrinters();
      }

      _updateNotifiers();

      // Listen to disconnection
      device.connectionState.listen((BluetoothConnectionState state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection(role);
        }
      });

      print('MultiPrinterManager: Successfully connected $role');
      return true;
    } catch (e) {
      print('MultiPrinterManager: Connection error for $role: $e');
      return false;
    }
  }

  void _handleDisconnection(String role) {
    PrinterInfo? printer = _printers[role];
    if (printer != null) {
      printer.isConnected = false;
      printer.device = null;
      printer.writeCharacteristic = null;
      _updateNotifiers();

      print('MultiPrinterManager: $role disconnected, attempting reconnect...');
      Future.delayed(Duration(seconds: 3), () {
        _attemptAutoReconnect();
      });
    }
  }

  // Disconnect specific printer
  Future<void> disconnectPrinter(String role) async {
    PrinterInfo? printer = _printers[role];
    if (printer?.device != null) {
      try {
        await printer!.device!.disconnect();
      } catch (e) {
        print('MultiPrinterManager: Error disconnecting $role: $e');
      }
    }

    _printers.remove(role);
    await _savePrinters();
    _updateNotifiers();
    print('MultiPrinterManager: $role removed');
  }

  // Disconnect all printers
  Future<void> disconnectAll() async {
    await _disconnectAll();
    _printers.clear();
    await _savePrinters();
    _updateNotifiers();
  }

  Future<void> _disconnectAll() async {
    for (var printer in _printers.values) {
      if (printer.device != null) {
        try {
          await printer.device!.disconnect();
        } catch (e) {
          print('MultiPrinterManager: Error disconnecting ${printer.role}: $e');
        }
      }
      printer.isConnected = false;
    }
    _updateNotifiers();
  }

  void _updateNotifiers() {
    printersNotifier.value = Map.from(_printers);
    connectedCountNotifier.value = connectedCount;
  }

  // Print to specific printer with role-specific header and content
  Future<bool> printToRole(String role, List<int> data) async {
    PrinterInfo? printer = _printers[role];
    if (printer == null ||
        !printer.isConnected ||
        printer.writeCharacteristic == null) {
      print('MultiPrinterManager: Cannot print to $role - not connected');
      return false;
    }

    // Add role-specific header to the data
    List<int> dataWithHeader = _addRoleHeader(role, data);
    return await _printDataChunked(printer, dataWithHeader);
  }

  // Print with role-specific content filtering
  Future<bool> printToRoleWithContent(String role, Map<String, dynamic> orderData) async {
    print('MultiPrinterManager: ===== PRINT TO ROLE WITH CONTENT DEBUG =====');
    print('MultiPrinterManager: Requested role: $role');
    print('MultiPrinterManager: All available printers: ${_printers.keys.toList()}');
    
    PrinterInfo? printer = _printers[role];
    if (printer == null ||
        !printer.isConnected ||
        printer.writeCharacteristic == null) {
      print('MultiPrinterManager: Cannot print to $role - not connected');
      print('MultiPrinterManager: Printer exists: ${printer != null}');
      print('MultiPrinterManager: Printer connected: ${printer?.isConnected}');
      print('MultiPrinterManager: Write characteristic exists: ${printer?.writeCharacteristic != null}');
      return false;
    }

    print('MultiPrinterManager: Printing ONLY to role: $role');
    print('MultiPrinterManager: NOT printing to other roles: ${_printers.keys.where((k) => k != role).toList()}');

    // Generate role-specific print data
    List<int> printData = _generateRoleSpecificPrintData(role, orderData);
    bool result = await _printDataChunked(printer, printData);
    
    print('MultiPrinterManager: Print result for $role: $result');
    print('MultiPrinterManager: ===== END PRINT TO ROLE WITH CONTENT DEBUG =====');
    
    return result;
  }

  // Add role-specific header to print data
  List<int> _addRoleHeader(String role, List<int> originalData) {
    List<int> headerCommands = [];

    // Initialize printer
    headerCommands.addAll([0x1B, 0x40]); // ESC @

    // Center align and bold
    headerCommands.addAll([0x1B, 0x61, 0x01]); // Center align
    headerCommands.addAll([0x1B, 0x45, 0x01]); // Bold on

    // Add role-specific label
    String roleLabel = _getRoleLabel(role);
    headerCommands.addAll(utf8.encode("$roleLabel\n"));
    headerCommands.addAll(utf8.encode("${'-' * roleLabel.length}\n"));

    // Reset formatting
    headerCommands.addAll([0x1B, 0x45, 0x00]); // Bold off
    headerCommands.addAll([0x1B, 0x61, 0x00]); // Left align
    headerCommands.addAll(utf8.encode("\n"));

    // Combine header with original data
    return [...headerCommands, ...originalData];
  }

  // Get role-specific label
  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'BY ADMIN';
      case 'dapur1':
        return 'KITCHEN MAKANAN';
      case 'dapur2':
        return 'KITCHEN MINUMAN';
      default:
        return 'PRINTER $role';
    }
  }

  // Generate role-specific print data
  List<int> _generateRoleSpecificPrintData(String role, Map<String, dynamic> orderData) {
    List<int> commands = [];

    // Initialize printer
    commands.addAll([0x1B, 0x40]); // ESC @

    // Add role-specific header
    commands.addAll([0x1B, 0x61, 0x01]); // Center align
    commands.addAll([0x1B, 0x45, 0x01]); // Bold on
    String roleLabel = _getRoleLabel(role);
    commands.addAll(utf8.encode("$roleLabel\n"));
    commands.addAll(utf8.encode("${'-' * roleLabel.length}\n\n"));

    // Restaurant header
    commands.addAll([0x1D, 0x21, 0x11]); // Double size
    commands.addAll(utf8.encode("== SHAOKAO ==\n\n"));

    // Reset formatting
    commands.addAll([0x1D, 0x21, 0x00]); // Normal size
    commands.addAll([0x1B, 0x45, 0x00]); // Bold off
    commands.addAll([0x1B, 0x61, 0x00]); // Left align

    // Order details
    commands.addAll(utf8.encode("ID Pesanan: ${orderData['displayId']}\n"));
    commands.addAll(utf8.encode("Tanggal: ${orderData['date']}\n"));
    commands.addAll(utf8.encode("Customer: ${orderData['customerName']}\n"));
    
    // Only include phone for admin printer, not for kitchen printers
    if (role == 'admin') {
      commands.addAll(utf8.encode("Phone: ${orderData['customerPhone']}\n"));
    }
    
    commands.addAll(utf8.encode("Meja: ${orderData['tableNumber']}\n"));
    commands.addAll(utf8.encode("Status: ${orderData['status']}\n"));
    commands.addAll(utf8.encode("Status Masakan: ${orderData['dishStatus']}\n"));
    
    // Only show order notes for all printers (not item notes)
    if (orderData['notes'] != null && orderData['notes'].toString().isNotEmpty) {
      commands.addAll(utf8.encode("Notes: ${orderData['notes']}\n"));
    }
    
    commands.addAll(utf8.encode("--------------------------------\n"));

    // Items header
    commands.addAll([0x1B, 0x45, 0x01]); // Bold on
    commands.addAll(utf8.encode("ITEMS:\n"));
    commands.addAll([0x1B, 0x45, 0x00]); // Bold off

    // Filter items based on role and category
    List<dynamic> allItems = orderData['items'] ?? [];
    List<dynamic> filteredItems = _filterItemsByRole(role, allItems);
    
    // If no items match the filter, show a message
    if (filteredItems.isEmpty) {
      commands.addAll(utf8.encode("(Tidak ada item untuk kategori ini)\n\n"));
    } else {
      // List filtered items with role-specific content and checkbox
      for (var item in filteredItems) {
        // Product name with checkbox on the right
        String productLine = _formatLineWithCheckbox(item['productName']);
        commands.addAll(utf8.encode("$productLine\n"));
        
        // Quantity and price
        commands.addAll(utf8.encode("  ${item['quantity']}x @ Rp${item['unitPrice'].toStringAsFixed(0)}\n"));
        
        // Only include item notes for kitchen printers (dapur1, dapur2), not admin
        if (role != 'admin' && item['note'] != null && item['note'].toString().isNotEmpty) {
          commands.addAll(utf8.encode("  Note: ${item['note']}\n"));
        }
        
        commands.addAll(utf8.encode("\n"));
      }
    }

    commands.addAll(utf8.encode("--------------------------------\n"));

    // Total (only for admin, kitchen printers don't need total)
    if (role == 'admin') {
      commands.addAll([0x1B, 0x45, 0x01]); // Bold on
      commands.addAll(utf8.encode("TOTAL: ${orderData['formattedTotal']}\n"));
      commands.addAll([0x1B, 0x45, 0x00]); // Bold off
    } else {
      // For kitchen printers, show item count
      commands.addAll([0x1B, 0x45, 0x01]); // Bold on
      commands.addAll(utf8.encode("TOTAL ITEM: ${filteredItems.length}\n"));
      commands.addAll([0x1B, 0x45, 0x00]); // Bold off
    }

    // Footer
    commands.addAll(utf8.encode("\n\n"));
    commands.addAll([0x1B, 0x61, 0x01]); // Center align
    commands.addAll(utf8.encode("Terima kasih!\n"));
    commands.addAll(utf8.encode("${DateTime.now().toString().split('.')[0]}\n"));

    // Cut paper
    commands.addAll(utf8.encode("\n\n\n"));
    commands.addAll([0x1D, 0x56, 0x00]); // Cut paper

    return commands;
  }

  // Format line with checkbox on the right (for thermal printer 32 chars width)
  String _formatLineWithCheckbox(String text) {
    try {
      const int maxWidth = 32; // Standard thermal printer width
      const String checkbox = "[ ]"; // Checkbox symbol
      
      // Calculate available space for text (total width - checkbox - 1 space)
      int availableSpace = maxWidth - checkbox.length - 1;
      
      // Truncate text if too long
      String displayText = text.length > availableSpace 
          ? text.substring(0, availableSpace) 
          : text;
      
      // Calculate padding needed
      int padding = maxWidth - displayText.length - checkbox.length;
      padding = padding.clamp(0, maxWidth);
      
      // Create padding string
      String spaces = List.filled(padding, ' ').join();
      
      // Return formatted line: "Product Name          [ ]"
      return displayText + spaces + checkbox;
    } catch (e) {
      // Fallback: return text with checkbox without formatting
      print('MultiPrinterManager: Error formatting checkbox line: $e');
      return '$text [ ]';
    }
  }

  // Filter items based on printer role and category
  List<dynamic> _filterItemsByRole(String role, List<dynamic> items) {
    print('MultiPrinterManager: Filtering items for role: $role, total items: ${items.length}');
    
    // Admin printer gets all items
    if (role == 'admin') {
      print('MultiPrinterManager: Admin role - returning all ${items.length} items');
      return items;
    }
    
    // dapur1 = Makanan (food items)
    // dapur2 = Minuman (beverage items)
    List<dynamic> filtered = items.where((item) {
      String categoryName = (item['categoryName'] ?? '').toString().toLowerCase();
      
      print('MultiPrinterManager: Item: ${item['productName']}, Category: "$categoryName"');
      
      if (role == 'dapur1') {
        // Makanan: exclude items with "minuman" in category name
        bool isFood = categoryName != 'minuman' && 
                      !categoryName.contains('beverage') &&
                      !categoryName.contains('drink');
        print('MultiPrinterManager: dapur1 check - isFood: $isFood');
        return isFood;
      } else if (role == 'dapur2') {
        // Minuman: only items with "minuman" in category name
        bool isBeverage = categoryName == 'minuman' || 
                         categoryName.contains('beverage') ||
                         categoryName.contains('drink');
        print('MultiPrinterManager: dapur2 check - isBeverage: $isBeverage');
        return isBeverage;
      }
      
      // Default: include all items
      return true;
    }).toList();
    
    print('MultiPrinterManager: Filtered result for $role: ${filtered.length} items');
    return filtered;
  }

  // Print to all connected printers with role-specific content
  Future<Map<String, bool>> printToAllWithContent(Map<String, dynamic> orderData) async {
    Map<String, bool> results = {};
    
    for (var entry in _printers.entries) {
      String role = entry.key;
      PrinterInfo printer = entry.value;
      
      if (printer.isConnected) {
        results[role] = await printToRoleWithContent(role, orderData);
        await Future.delayed(Duration(milliseconds: 100));
      }
    }

    return results;
  }

  // Print to multiple printers with role-specific headers
  Future<Map<String, bool>> printToMultiple(
      List<String> roles, List<int> data) async {
    Map<String, bool> results = {};

    for (String role in roles) {
      PrinterInfo? printer = _printers[role];
      if (printer != null && printer.isConnected) {
        // Add role-specific header for each printer
        List<int> dataWithHeader = _addRoleHeader(role, data);
        results[role] = await _printDataChunked(printer, dataWithHeader);
        await Future.delayed(Duration(milliseconds: 100));
      } else {
        results[role] = false;
      }
    }

    return results;
  }

  // Print to all connected printers with role-specific headers
  Future<Map<String, bool>> printToAll(List<int> data) async {
    Map<String, bool> results = {};

    for (var entry in _printers.entries) {
      String role = entry.key;
      PrinterInfo printer = entry.value;

      if (printer.isConnected) {
        // Add role-specific header for each printer
        List<int> dataWithHeader = _addRoleHeader(role, data);
        results[role] = await _printDataChunked(printer, dataWithHeader);
        await Future.delayed(Duration(milliseconds: 100));
      }
    }

    return results;
  }

  Future<bool> _printDataChunked(PrinterInfo printer, List<int> data) async {
    if (!printer.isConnected || printer.writeCharacteristic == null) {
      return false;
    }

    try {
      int chunkSize = printer.maxChunkSize;
      int totalChunks = (data.length / chunkSize).ceil();

      print(
          'MultiPrinterManager: Printing to ${printer.role} - ${data.length} bytes in $totalChunks chunks');

      for (int i = 0; i < data.length; i += chunkSize) {
        int end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
        List<int> chunk = data.sublist(i, end);

        try {
          Uint8List chunkData = Uint8List.fromList(chunk);
          await printer.writeCharacteristic!
              .write(chunkData, withoutResponse: true);

          if (i + chunkSize < data.length) {
            await Future.delayed(Duration(milliseconds: 50));
          }
        } catch (e) {
          if (e.toString().contains('data longer than allowed')) {
            int smallerChunkSize = (chunkSize / 2).floor();
            if (smallerChunkSize < _minChunkSize) {
              throw Exception('Chunk too large');
            }

            for (int j = i; j < end; j += smallerChunkSize) {
              int smallEnd =
                  (j + smallerChunkSize < end) ? j + smallerChunkSize : end;
              List<int> smallChunk = data.sublist(j, smallEnd);
              Uint8List smallChunkData = Uint8List.fromList(smallChunk);

              await printer.writeCharacteristic!
                  .write(smallChunkData, withoutResponse: true);
              if (j + smallerChunkSize < end) {
                await Future.delayed(Duration(milliseconds: 50));
              }
            }
          } else {
            throw e;
          }
        }
      }

      print('MultiPrinterManager: Print to ${printer.role} successful');
      return true;
    } catch (e) {
      print('MultiPrinterManager: Print error to ${printer.role}: $e');
      return false;
    }
  }

  // Test print for specific printer
  Future<bool> testPrint(String role) async {
    PrinterInfo? printer = _printers[role];
    if (printer == null || !printer.isConnected) {
      return false;
    }

    try {
      List<int> commands = [];

      commands.addAll([0x1B, 0x40]); // Initialize
      commands.addAll([0x1B, 0x61, 0x01]); // Center align
      commands.addAll([0x1B, 0x45, 0x01]); // Bold on

      // Add role-specific label
      String roleLabel = _getRoleLabel(role);
      commands.addAll(utf8.encode("$roleLabel\n"));
      commands.addAll(utf8.encode("${'-' * roleLabel.length}\n\n"));

      commands.addAll([0x1D, 0x21, 0x11]); // Double size
      String testText = "=== TES PRINTER ===\n\n";
      commands.addAll(utf8.encode(testText));

      commands.addAll([0x1D, 0x21, 0x00]); // Normal size
      commands.addAll([0x1B, 0x45, 0x00]); // Bold off
      commands.addAll([0x1B, 0x61, 0x00]); // Left align

      String detailText = "";
      detailText += "Nama: ${printer.name}\n";
      detailText += "Role: ${printer.role}\n";
      detailText += "Label: $roleLabel\n";
      detailText += "Status: Terhubung\n";
      detailText += "MTU: ${printer.mtu}, Chunk: ${printer.maxChunkSize}\n";
      detailText += "Waktu: ${DateTime.now().toString().split('.')[0]}\n\n";
      detailText += "Test print berhasil!\n\n";

      commands.addAll(utf8.encode(detailText));
      commands.addAll([0x0A, 0x0A, 0x0A]);
      commands.addAll([0x1D, 0x56, 0x00]); // Cut paper

      return await _printDataChunked(printer, commands);
    } catch (e) {
      print('MultiPrinterManager: Test print error for $role: $e');
      return false;
    }
  }

  // Get saved printers info
  List<Map<String, String>> getSavedPrintersInfo() {
    return _printers.values
        .map((p) => {
              'role': p.role,
              'name': p.name,
              'id': p.id,
              'connected': p.isConnected.toString(),
            })
        .toList();
  }

  bool hasSavedPrinters() => _printers.isNotEmpty;
}
