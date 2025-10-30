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
    {'role': 'dapur1', 'name': 'Printer Dapur 1'},
    {'role': 'dapur2', 'name': 'Printer Dapur 2'},
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi Printer Manager'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: _printerManager.connectedCountNotifier,
            builder: (context, count, child) {
              return Container(
                margin: EdgeInsets.only(right: 16),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: count > 0 ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.print, size: 16),
                    SizedBox(width: 4),
                    Text('$count/3',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.blue[50]!],
          ),
        ),
        child: Column(
          children: [
            // Connected Printers Status
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
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
                          Text(
                            'Printer Terhubung',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (printers.isNotEmpty)
                            TextButton.icon(
                              onPressed: _testPrintAll,
                              icon: Icon(Icons.print, size: 16),
                              label: Text('Test All'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue[700],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12),
                      if (printers.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Belum ada printer terhubung',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      else
                        ..._availableRoles.map((roleData) {
                          String role = roleData['role']!;
                          PrinterInfo? printer = printers[role];

                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: printer?.isConnected == true
                                  ? Colors.green[50]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: printer?.isConnected == true
                                    ? Colors.green[300]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _getRoleColor(role),
                                  child: Icon(
                                    _getRoleIcon(role),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        roleData['name']!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (printer != null) ...[
                                        Text(
                                          printer.device?.platformName ??
                                              'Unknown',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ] else
                                        Text(
                                          'Tidak terhubung',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (printer?.isConnected == true) ...[
                                  IconButton(
                                    icon: Icon(Icons.print, size: 20),
                                    color: Colors.blue[700],
                                    onPressed: () => _testPrintRole(role),
                                    tooltip: 'Test Print',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, size: 20),
                                    color: Colors.red,
                                    onPressed: () => _disconnectPrinter(role),
                                    tooltip: 'Putuskan',
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  );
                },
              ),
            ),

            // Control Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isScanning ? null : _scanForDevices,
                      icon: _isScanning
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(Icons.search),
                      label: Text(_isScanning ? 'Scanning...' : 'Scan Printer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ValueListenableBuilder<Map<String, PrinterInfo>>(
                    valueListenable: _printerManager.printersNotifier,
                    builder: (context, printers, child) {
                      return ElevatedButton.icon(
                        onPressed: printers.isNotEmpty ? _disconnectAll : null,
                        icon: Icon(Icons.delete_sweep),
                        label: Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Device List
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.devices, color: Colors.blue[600]),
                          SizedBox(width: 10),
                          Text(
                            'Daftar Perangkat',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _devicesList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bluetooth_searching,
                                      size: 80, color: Colors.grey[400]),
                                  SizedBox(height: 20),
                                  Text(
                                    'Tidak ada perangkat ditemukan',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Tekan tombol scan untuk mencari',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _devicesList.length,
                              itemBuilder: (context, index) {
                                BluetoothDevice device = _devicesList[index];

                                return Card(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue[600],
                                      child: Icon(Icons.print,
                                          color: Colors.white),
                                    ),
                                    title: Text(
                                      device.platformName.isNotEmpty
                                          ? device.platformName
                                          : 'Unknown Device',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(device.remoteId.toString()),
                                    trailing: ElevatedButton(
                                      onPressed: () =>
                                          _showRoleSelectionDialog(device),
                                      child: Text('Hubungkan'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[600],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
