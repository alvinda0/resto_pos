import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:convert';
import 'package:pos/storage_service.dart';

// Import bluetooth package only on supported platforms
import 'package:flutter_blue_plus/flutter_blue_plus.dart'
    if (dart.library.html) 'package:pos/bluetooth_stub.dart'
    if (dart.library.io) 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Singleton class untuk manage koneksi printer dengan persistent connection
class BluetoothPrinterManager {
  static final BluetoothPrinterManager _instance =
      BluetoothPrinterManager._internal();
  factory BluetoothPrinterManager() => _instance;
  BluetoothPrinterManager._internal();

  BluetoothDevice? _selectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  bool _isConnected = false;
  bool _isReconnecting = false;
  bool _isBluetoothSupported = false;

  // NEW: MTU and chunk size management
  int _mtu = 23; // Default BLE MTU
  int _maxChunkSize = 200; // Conservative default, will be updated based on MTU
  static const int _defaultMaxChunkSize = 200;
  static const int _minChunkSize = 50;

  // Stream controllers untuk notify perubahan state
  final ValueNotifier<bool> connectionStatus = ValueNotifier<bool>(false);
  final ValueNotifier<BluetoothDevice?> selectedDeviceNotifier =
      ValueNotifier<BluetoothDevice?>(null);

  // Storage service untuk menyimpan data printer
  final StorageService _storage = StorageService.instance;

  // Keys untuk storage
  static const String _printerIdKey = 'saved_printer_id';
  static const String _printerNameKey = 'saved_printer_name';

  // Getters
  BluetoothDevice? get selectedDevice => _selectedDevice;
  BluetoothCharacteristic? get writeCharacteristic => _writeCharacteristic;
  bool get isConnected => _isConnected;
  bool get isReconnecting => _isReconnecting;
  bool get isBluetoothSupported => _isBluetoothSupported;
  int get maxChunkSize => _maxChunkSize;

  // Check if current platform supports Bluetooth
  bool _checkBluetoothSupport() {
    if (kIsWeb) {
      print('BluetoothPrinterManager: Web platform - Bluetooth not supported');
      return false;
    }

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        print(
            'BluetoothPrinterManager: Mobile platform detected - Bluetooth supported');
        return true;
      } else {
        print(
            'BluetoothPrinterManager: Desktop platform - Bluetooth not supported');
        return false;
      }
    } catch (e) {
      print('BluetoothPrinterManager: Platform check error: $e');
      return false;
    }
  }

  // NEW: Calculate optimal chunk size based on MTU
  void _calculateChunkSize() {
    try {
      if (_mtu <= 23) {
        // Default BLE MTU
        _maxChunkSize = _minChunkSize;
      } else {
        // Conservative approach: use 70% of available space
        // MTU - 3 (ATT header) - 20 (safety margin) = usable space
        int usableSpace = ((_mtu - 23) * 0.7).round();
        _maxChunkSize = (usableSpace + _minChunkSize)
            .clamp(_minChunkSize, _defaultMaxChunkSize);
      }

      print('BluetoothPrinterManager: MTU: $_mtu, Chunk size: $_maxChunkSize');
    } catch (e) {
      print('BluetoothPrinterManager: Error calculating chunk size: $e');
      _maxChunkSize = _minChunkSize;
    }
  }

  // Initialize - dipanggil saat app start
  Future<void> initialize() async {
    print('BluetoothPrinterManager: Initializing...');

    _isBluetoothSupported = _checkBluetoothSupport();

    if (!_isBluetoothSupported) {
      print(
          'BluetoothPrinterManager: Bluetooth not supported on this platform');
      return;
    }

    // Check if there's a saved printer to reconnect
    await _attemptAutoReconnect();

    // Listen to Bluetooth state changes
    try {
      FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        if (state == BluetoothAdapterState.on && !_isConnected) {
          _attemptAutoReconnect();
        } else if (state != BluetoothAdapterState.on && _isConnected) {
          _updateConnectionStatus(false);
        }
      });
    } catch (e) {
      print('BluetoothPrinterManager: Failed to listen to adapter state: $e');
    }
  }

  // Attempt to reconnect to saved printer
  Future<void> _attemptAutoReconnect() async {
    if (!_isBluetoothSupported) {
      print(
          'BluetoothPrinterManager: Auto reconnect skipped - Bluetooth not supported');
      return;
    }

    if (_isReconnecting) return;

    String? savedPrinterId = _storage.getString(_printerIdKey);
    String? savedPrinterName = _storage.getString(_printerNameKey);

    if (savedPrinterId == null) {
      print('BluetoothPrinterManager: No saved printer found');
      return;
    }

    print(
        'BluetoothPrinterManager: Attempting to reconnect to saved printer: $savedPrinterName ($savedPrinterId)');
    _isReconnecting = true;

    try {
      // Check if bluetooth is available
      BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
      if (state != BluetoothAdapterState.on) {
        print('BluetoothPrinterManager: Bluetooth not available');
        _isReconnecting = false;
        return;
      }

      // Try to find the device in system devices first
      List<BluetoothDevice> systemDevices =
          await FlutterBluePlus.systemDevices([]);
      BluetoothDevice? targetDevice = systemDevices.firstWhere(
        (device) => device.remoteId.toString() == savedPrinterId,
        orElse: () => null as BluetoothDevice,
      );

      if (targetDevice == null) {
        print(
            'BluetoothPrinterManager: Saved printer not found in system devices');
        try {
          targetDevice = BluetoothDevice.fromId(savedPrinterId);
        } catch (e) {
          print('BluetoothPrinterManager: Failed to create device from ID: $e');
          _clearSavedPrinter();
          _isReconnecting = false;
          return;
        }
      }

      // Attempt to connect
      bool connected =
          await _connectToDeviceInternal(targetDevice, isAutoReconnect: true);

      if (connected) {
        print(
            'BluetoothPrinterManager: Successfully reconnected to saved printer');
      } else {
        print('BluetoothPrinterManager: Failed to reconnect to saved printer');
      }
    } catch (e) {
      print('BluetoothPrinterManager: Auto reconnect error: $e');
    }

    _isReconnecting = false;
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (!_isBluetoothSupported) {
      print(
          'BluetoothPrinterManager: Connect failed - Bluetooth not supported');
      return false;
    }
    return await _connectToDeviceInternal(device, isAutoReconnect: false);
  }

  Future<bool> _connectToDeviceInternal(BluetoothDevice device,
      {required bool isAutoReconnect}) async {
    if (!_isBluetoothSupported) return false;

    try {
      if (_isConnected && _selectedDevice?.remoteId == device.remoteId) {
        print('BluetoothPrinterManager: Already connected to this device');
        return true;
      }

      // Disconnect from current device if connected to different one
      if (_isConnected && _selectedDevice?.remoteId != device.remoteId) {
        await _disconnectInternal(clearStorage: false);
      }

      print(
          'BluetoothPrinterManager: Connecting to ${device.platformName} (${device.remoteId})...');

      // Check if device is already connected
      bool alreadyConnected = await device.connectionState.first
          .then((state) => state == BluetoothConnectionState.connected)
          .catchError((_) => false);

      if (!alreadyConnected) {
        await device.connect(timeout: Duration(seconds: 15));
      }

      // NEW: Get and update MTU
      try {
        _mtu = await device.mtu.first;
        print('BluetoothPrinterManager: Current MTU: $_mtu');

        // Try to request larger MTU if possible
        if (_mtu < 200) {
          try {
            int newMtu = await device.requestMtu(250);
            _mtu = newMtu;
            print('BluetoothPrinterManager: MTU updated to: $_mtu');
          } catch (e) {
            print('BluetoothPrinterManager: Could not increase MTU: $e');
          }
        }

        _calculateChunkSize();
      } catch (e) {
        print('BluetoothPrinterManager: Error handling MTU: $e');
        _mtu = 23; // Default
        _calculateChunkSize();
      }

      // Discover services
      List<BluetoothService> services = await device.discoverServices();

      // Find writable characteristic
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
        throw Exception(
            'Tidak dapat menemukan characteristic yang dapat ditulis');
      }

      _selectedDevice = device;
      _writeCharacteristic = writeChar;

      // Save printer info for future reconnection
      if (!isAutoReconnect) {
        _storage.setString(_printerIdKey, device.remoteId.toString());
        _storage.setString(_printerNameKey, device.platformName);
        print(
            'BluetoothPrinterManager: Printer info saved for future reconnection');
      }

      _updateConnectionStatus(true);

      // Listen to connection state changes
      device.connectionState.listen((BluetoothConnectionState state) {
        print('BluetoothPrinterManager: Connection state changed: $state');

        if (state == BluetoothConnectionState.disconnected) {
          _selectedDevice = null;
          _writeCharacteristic = null;
          _updateConnectionStatus(false);

          if (!_isManualDisconnect) {
            print(
                'BluetoothPrinterManager: Unexpected disconnection, attempting to reconnect...');
            Future.delayed(Duration(seconds: 3), () {
              _attemptAutoReconnect();
            });
          }
          _isManualDisconnect = false;
        }
      });

      print(
          'BluetoothPrinterManager: Successfully connected to ${device.platformName}');
      return true;
    } catch (e) {
      print('BluetoothPrinterManager: Connection error: $e');
      _selectedDevice = null;
      _writeCharacteristic = null;
      _updateConnectionStatus(false);
      rethrow;
    }
  }

  bool _isManualDisconnect = false;

  Future<void> disconnect() async {
    await _disconnectInternal(clearStorage: true);
  }

  Future<void> _disconnectInternal({required bool clearStorage}) async {
    if (!_isBluetoothSupported) return;

    _isManualDisconnect = clearStorage;

    if (_selectedDevice != null) {
      try {
        print(
            'BluetoothPrinterManager: Disconnecting from ${_selectedDevice!.platformName}...');
        await _selectedDevice!.disconnect();
      } catch (e) {
        print('BluetoothPrinterManager: Error disconnecting: $e');
      }
    }

    _selectedDevice = null;
    _writeCharacteristic = null;
    _updateConnectionStatus(false);

    if (clearStorage) {
      _clearSavedPrinter();
      print('BluetoothPrinterManager: Saved printer info cleared');
    }
  }

  void _updateConnectionStatus(bool connected) {
    _isConnected = connected;
    connectionStatus.value = connected;
    selectedDeviceNotifier.value = connected ? _selectedDevice : null;
    print('BluetoothPrinterManager: Connection status updated: $connected');
  }

  void _clearSavedPrinter() {
    _storage.removeKey(_printerIdKey);
    _storage.removeKey(_printerNameKey);
  }

  // Get saved printer info
  Map<String, String?> getSavedPrinterInfo() {
    return {
      'id': _storage.getString(_printerIdKey),
      'name': _storage.getString(_printerNameKey),
    };
  }

  // Check if there's a saved printer
  bool hasSavedPrinter() {
    return _storage.getString(_printerIdKey) != null;
  }

  Future<bool> testPrint() async {
    if (!_isBluetoothSupported) {
      print(
          'BluetoothPrinterManager: Test print failed - Bluetooth not supported');
      return false;
    }

    if (!_isConnected || _writeCharacteristic == null) {
      print('BluetoothPrinterManager: Cannot test print - not connected');
      return false;
    }

    try {
      List<int> commands = [];

      // Initialize printer
      commands.addAll([0x1B, 0x40]);
      commands.addAll([0x1B, 0x61, 0x01]);
      commands.addAll([0x1D, 0x21, 0x11]);

      String testText = "=== TES PRINTER ===\n\n";
      commands.addAll(utf8.encode(testText));

      commands.addAll([0x1D, 0x21, 0x00]);
      commands.addAll([0x1B, 0x61, 0x00]);

      String detailText = "";
      detailText += "Printer: ${_selectedDevice?.platformName}\n";
      detailText +=
          "Platform: ${_isBluetoothSupported ? 'Mobile' : 'Unsupported'}\n";
      detailText += "Status: Terhubung\n";
      detailText += "MTU: $_mtu, Chunk: $_maxChunkSize\n";
      detailText += "Waktu: ${DateTime.now().toString().split('.')[0]}\n\n";
      detailText +=
          "Test karakter:\n1234567890\nABCDEFGHIJK\nabcdefghijk\n\nTest print berhasil!\n\n";

      commands.addAll(utf8.encode(detailText));
      commands.addAll([0x0A, 0x0A, 0x0A]);
      commands.addAll([0x1D, 0x56, 0x00]);

      // Use the new chunked print method
      return await _printDataChunked(commands);
    } catch (e) {
      print('BluetoothPrinterManager: Test print error: $e');
      return false;
    }
  }

  // NEW: Chunked data printing method
  Future<bool> _printDataChunked(List<int> data) async {
    if (!_isConnected || _writeCharacteristic == null) {
      print('BluetoothPrinterManager: Cannot print - not connected');
      return false;
    }

    try {
      print(
          'BluetoothPrinterManager: Printing ${data.length} bytes in chunks of $_maxChunkSize');

      int totalChunks = (data.length / _maxChunkSize).ceil();
      print('BluetoothPrinterManager: Total chunks to send: $totalChunks');

      for (int i = 0; i < data.length; i += _maxChunkSize) {
        int end =
            (i + _maxChunkSize < data.length) ? i + _maxChunkSize : data.length;
        List<int> chunk = data.sublist(i, end);

        int chunkNumber = (i / _maxChunkSize).floor() + 1;
        print(
            'BluetoothPrinterManager: Sending chunk $chunkNumber/$totalChunks (${chunk.length} bytes)');

        try {
          Uint8List chunkData = Uint8List.fromList(chunk);
          await _writeCharacteristic!.write(chunkData, withoutResponse: true);

          // Small delay between chunks to prevent overwhelming the printer
          if (i + _maxChunkSize < data.length) {
            await Future.delayed(Duration(milliseconds: 50));
          }
        } catch (e) {
          print(
              'BluetoothPrinterManager: Error sending chunk $chunkNumber: $e');

          // If chunk still too large, try smaller size
          if (e.toString().contains('data longer than allowed')) {
            print(
                'BluetoothPrinterManager: Chunk too large, reducing size and retrying...');
            int smallerChunkSize = (_maxChunkSize / 2).floor();
            if (smallerChunkSize < _minChunkSize) {
              throw Exception('Data chunk too large even at minimum size');
            }

            // Temporarily reduce chunk size and retry this chunk
            for (int j = i; j < end; j += smallerChunkSize) {
              int smallEnd =
                  (j + smallerChunkSize < end) ? j + smallerChunkSize : end;
              List<int> smallChunk = data.sublist(j, smallEnd);
              Uint8List smallChunkData = Uint8List.fromList(smallChunk);

              print(
                  'BluetoothPrinterManager: Sending smaller chunk (${smallChunk.length} bytes)');
              await _writeCharacteristic!
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

      print('BluetoothPrinterManager: All chunks sent successfully');
      return true;
    } catch (e) {
      print('BluetoothPrinterManager: Chunked print error: $e');
      return false;
    }
  }

  // Updated printData method to use chunking
  Future<bool> printData(List<int> data) async {
    if (!_isBluetoothSupported) {
      print('BluetoothPrinterManager: Print failed - Bluetooth not supported');
      return false;
    }

    return await _printDataChunked(data);
  }

  Future<bool> reconnect() async {
    if (!_isBluetoothSupported) {
      print(
          'BluetoothPrinterManager: Reconnect failed - Bluetooth not supported');
      return false;
    }

    if (_isReconnecting) {
      print('BluetoothPrinterManager: Reconnection already in progress');
      return false;
    }

    print('BluetoothPrinterManager: Manual reconnect requested');
    await _attemptAutoReconnect();
    return _isConnected;
  }

  void debugInfo() {
    Map<String, String?> savedInfo = getSavedPrinterInfo();
  }
}
