import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shao_kao/screens/printer/BluetoothPrinterManager.dart';
import 'dart:convert';

class BluetoothPrinterPage extends StatefulWidget {
  @override
  _BluetoothPrinterPageState createState() => _BluetoothPrinterPageState();
}

class _BluetoothPrinterPageState extends State<BluetoothPrinterPage> {
  List<BluetoothDevice> _devicesList = [];
  bool _isScanning = false;
  bool _bluetoothEnabled = false;

  final BluetoothPrinterManager _printerManager = BluetoothPrinterManager();

  // Available printer roles
  final List<Map<String, String>> _availableRoles = [
    {'role': 'admin', 'name': 'Printer Admin'},
    {'role': 'dapur1', 'name': 'Printer Makanan'},
    {'role': 'dapur2', 'name': 'Printer Minuman'},
  ];

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    await _requestPermissions();
    await _checkBluetoothState();
    await _printerManager.initialize();

    if (_printerManager.hasSavedPrinters()) {
      List<Map<String, String>> savedInfo =
          _printerManager.getSavedPrintersInfo();
      _showSnackBar('Tersimpan ${savedInfo.length} printer');
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = permissions.values.every((status) => status.isGranted);
    if (!allGranted) {
      _showSnackBar('Beberapa permission tidak diberikan');
    }
  }

  Future<void> _checkBluetoothState() async {
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      setState(() {
        _bluetoothEnabled = state == BluetoothAdapterState.on;
      });
    });

    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    setState(() {
      _bluetoothEnabled = state == BluetoothAdapterState.on;
    });
  }

  Future<void> _scanForDevices() async {
    if (!_bluetoothEnabled) {
      _showSnackBar('Bluetooth tidak aktif');
      return;
    }

    setState(() {
      _isScanning = true;
      _devicesList.clear();
    });

    try {
      await FlutterBluePlus.stopScan();
      List<BluetoothDevice> allDevices = [];

      try {
        List<BluetoothDevice> systemDevices =
            await FlutterBluePlus.systemDevices([]);
        allDevices.addAll(systemDevices);
      } catch (e) {
        print('Error getting system devices: $e');
      }

      await FlutterBluePlus.startScan(
        timeout: Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      var scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!allDevices
              .any((device) => device.remoteId == result.device.remoteId)) {
            allDevices.add(result.device);
          }
        }

        List<BluetoothDevice> printers = allDevices.where((device) {
          String name = device.platformName.toLowerCase();
          return name.contains('printer') ||
              name.contains('pos') ||
              name.contains('thermal') ||
              name.contains('receipt') ||
              name.contains('epson') ||
              name.contains('canon') ||
              name.contains('hp') ||
              name.contains('star') ||
              name.contains('xprinter') ||
              name.isNotEmpty;
        }).toList();

        setState(() {
          _devicesList = printers;
        });
      });

      await Future.delayed(Duration(seconds: 15));
      await scanSubscription.cancel();
      await FlutterBluePlus.stopScan();

      setState(() {
        _isScanning = false;
      });

      if (_devicesList.isEmpty) {
        _showSnackBar('Tidak ada printer ditemukan');
      } else {
        _showSnackBar('Ditemukan ${_devicesList.length} perangkat');
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      _showSnackBar('Error scanning: $e');
    }
  }

  Future<void> _showRoleSelectionDialog(BluetoothDevice device) async {
    Map<String, PrinterInfo>? currentPrinters = _printerManager.printers;

    // Filter available roles (belum terpakai)
    List<Map<String, String>> availableRoles =
        _availableRoles.where((roleData) {
      return !currentPrinters.containsKey(roleData['role']);
    }).toList();

    if (availableRoles.isEmpty) {
      _showSnackBar(
          'Semua slot printer sudah terpakai.\nHapus printer yang tidak digunakan terlebih dahulu.');
      return;
    }

    String? selectedRole = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Role Printer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hubungkan "${device.platformName}" sebagai:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              ...availableRoles.map((roleData) {
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      _getRoleIcon(roleData['role']!),
                      color: _getRoleColor(roleData['role']!),
                    ),
                    title: Text(
                      roleData['name']!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Role: ${roleData['role']}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).pop(roleData['role']);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
          ],
        );
      },
    );

    if (selectedRole != null) {
      await _connectToDevice(device, selectedRole);
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device, String role) async {
    try {
      _showSnackBar('Menghubungkan ke ${device.platformName}...');

      String name = _availableRoles.firstWhere(
        (r) => r['role'] == role,
        orElse: () => {'name': device.platformName},
      )['name']!;

      bool connected =
          await _printerManager.connectToDevice(device, role, name);

      if (connected) {
        _showSnackBar('Berhasil terhubung ke $name');
      } else {
        _showSnackBar('Gagal terhubung ke ${device.platformName}');
      }
    } catch (e) {
      _showSnackBar('Gagal terhubung: $e');
    }
  }

  Future<void> _testPrintRole(String role) async {
    bool success = await _printerManager.testPrint(role);
    String name = _printerManager.getPrinterByRole(role)?.name ?? role;

    if (success) {
      _showSnackBar('Test print ke $name berhasil');
    } else {
      _showSnackBar('Gagal print ke $name');
    }
  }

  Future<void> _testPrintAll() async {
    Map<String, bool> results =
        await _printerManager.printToAll(_getTestPrintData());

    int success = results.values.where((v) => v).length;
    int total = results.length;

    _showSnackBar('Print ke $success dari $total printer berhasil');
  }

  List<int> _getTestPrintData() {
    List<int> commands = [];
    commands.addAll([0x1B, 0x40]);
    commands.addAll([0x1B, 0x61, 0x01]);
    commands.addAll([0x1D, 0x21, 0x11]);
    commands.addAll(utf8.encode("=== TEST PRINT ===\n\n"));
    commands.addAll([0x1D, 0x21, 0x00]);
    commands.addAll([0x1B, 0x61, 0x00]);
    commands.addAll(utf8.encode("Multi Printer System\n"));
    commands.addAll(
        utf8.encode("Waktu: ${DateTime.now().toString().split('.')[0]}\n\n"));
    commands.addAll([0x0A, 0x0A, 0x0A]);
    commands.addAll([0x1D, 0x56, 0x00]);
    return commands;
  }

  Future<void> _disconnectPrinter(String role) async {
    await _printerManager.disconnectPrinter(role);
    String name = _availableRoles.firstWhere((r) => r['role'] == role)['name']!;
    _showSnackBar('$name telah diputuskan');
  }

  Future<void> _disconnectAll() async {
    await _printerManager.disconnectAll();
    _showSnackBar('Semua printer telah diputuskan');
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'dapur1':
        return Icons.restaurant;
      case 'dapur2':
        return Icons.restaurant_menu;
      default:
        return Icons.print;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.blue;
      case 'dapur1':
        return Colors.orange;
      case 'dapur2':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: SizedBox.shrink(),
        title: Text(
          isMobile ? 'Printer Manager' : 'Multi Printer Manager',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: _printerManager.connectedCountNotifier,
            builder: (context, count, child) {
              return Container(
                margin: EdgeInsets.only(right: 16),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: count > 0 ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: count > 0 ? Colors.green.shade300 : Colors.red.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.print,
                      size: 16,
                      color: count > 0 ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '$count/3',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: count > 0 ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isMobile) {
            return _buildMobileLayout();
          } else {
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Connected Printers Section
        _buildConnectedPrintersSection(isMobile: true),
        
        // Control Buttons
        _buildControlButtons(isMobile: true),
        
        SizedBox(height: 12),
        
        // Device List
        Expanded(
          child: _buildDeviceList(isMobile: true),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel - Connected Printers
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildConnectedPrintersSection(isMobile: false),
              _buildControlButtons(isMobile: false),
            ],
          ),
        ),
        
        SizedBox(width: 16),
        
        // Right Panel - Device List
        Expanded(
          flex: 3,
          child: _buildDeviceList(isMobile: false),
        ),
      ],
    );
  }

  Widget _buildConnectedPrintersSection({required bool isMobile}) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ValueListenableBuilder<Map<String, PrinterInfo>>(
        valueListenable: _printerManager.printersNotifier,
        builder: (context, printers, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.print, color: Colors.blue.shade600, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Printer Terhubung',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  if (printers.isNotEmpty)
                    TextButton.icon(
                      onPressed: _testPrintAll,
                      icon: Icon(Icons.print_outlined, size: 16),
                      label: Text('Test All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 12,
                          vertical: 4,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),
              if (printers.isEmpty)
                _buildEmptyPrintersState(isMobile: isMobile)
              else
                ..._availableRoles.map((roleData) {
                  String role = roleData['role']!;
                  PrinterInfo? printer = printers[role];
                  return _buildPrinterCard(
                    roleData: roleData,
                    printer: printer,
                    isMobile: isMobile,
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyPrintersState({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.print_disabled,
              size: isMobile ? 48 : 64,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 12),
            Text(
              'Belum ada printer terhubung',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Scan untuk menemukan printer',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: isMobile ? 11 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrinterCard({
    required Map<String, String> roleData,
    required PrinterInfo? printer,
    required bool isMobile,
  }) {
    String role = roleData['role']!;
    bool isConnected = printer?.isConnected == true;
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isConnected ? Colors.green.shade200 : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 36 : 40,
            height: isMobile ? 36 : 40,
            decoration: BoxDecoration(
              color: _getRoleColor(role),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getRoleIcon(role),
              color: Colors.white,
              size: isMobile ? 18 : 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleData['name']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 13 : 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                if (printer != null) ...[
                  Text(
                    printer.device?.platformName ?? 'Unknown',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else
                  Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: Colors.grey.shade400),
                      SizedBox(width: 4),
                      Text(
                        'Tidak terhubung',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (isConnected) ...[
            if (!isMobile) SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.print_outlined, size: isMobile ? 18 : 20),
              color: Colors.blue.shade700,
              onPressed: () => _testPrintRole(role),
              tooltip: 'Test Print',
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              constraints: BoxConstraints(),
            ),
            IconButton(
              icon: Icon(Icons.close, size: isMobile ? 18 : 20),
              color: Colors.red.shade600,
              onPressed: () => _disconnectPrinter(role),
              tooltip: 'Putuskan',
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              constraints: BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButtons({required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isScanning ? null : _scanForDevices,
              icon: _isScanning
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.bluetooth_searching, size: isMobile ? 18 : 20),
              label: Text(
                _isScanning ? 'Scanning...' : 'Scan Printer',
                style: TextStyle(fontSize: isMobile ? 13 : 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
          SizedBox(width: 8),
          ValueListenableBuilder<Map<String, PrinterInfo>>(
            valueListenable: _printerManager.printersNotifier,
            builder: (context, printers, child) {
              return ElevatedButton.icon(
                onPressed: printers.isNotEmpty ? _disconnectAll : null,
                icon: Icon(Icons.delete_sweep, size: isMobile ? 18 : 20),
                label: isMobile
                    ? SizedBox.shrink()
                    : Text('Clear', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 10 : 12,
                    horizontal: isMobile ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList({required bool isMobile}) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 12 : 0,
        isMobile ? 0 : 16,
        isMobile ? 12 : 16,
        isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.devices, color: Colors.blue.shade600, size: 20),
                SizedBox(width: 8),
                Text(
                  'Daftar Perangkat',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (_devicesList.isNotEmpty) ...[
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_devicesList.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _devicesList.isEmpty
                ? _buildEmptyDeviceState(isMobile: isMobile)
                : ListView.builder(
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    itemCount: _devicesList.length,
                    itemBuilder: (context, index) {
                      BluetoothDevice device = _devicesList[index];
                      return _buildDeviceCard(device: device, isMobile: isMobile);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDeviceState({required bool isMobile}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_searching,
              size: isMobile ? 64 : 80,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada perangkat ditemukan',
              style: TextStyle(
                fontSize: isMobile ? 15 : 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tekan tombol scan untuk mencari printer',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard({
    required BluetoothDevice device,
    required bool isMobile,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 4 : 8,
        ),
        leading: Container(
          width: isMobile ? 36 : 40,
          height: isMobile ? 36 : 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.print,
            color: Colors.blue.shade600,
            size: isMobile ? 18 : 20,
          ),
        ),
        title: Text(
          device.platformName.isNotEmpty
              ? device.platformName
              : 'Unknown Device',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 13 : 14,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          device.remoteId.toString(),
          style: TextStyle(
            fontSize: isMobile ? 10 : 11,
            color: Colors.grey.shade600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: ElevatedButton(
          onPressed: () => _showRoleSelectionDialog(device),
          child: Text(
            'Hubungkan',
            style: TextStyle(fontSize: isMobile ? 11 : 13),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 6 : 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
