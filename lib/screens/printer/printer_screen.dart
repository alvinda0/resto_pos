import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:pos/screens/printer/BluetoothPrinterManager.dart';

class BluetoothPrinterPage extends StatefulWidget {
  @override
  _BluetoothPrinterPageState createState() => _BluetoothPrinterPageState();
}

class _BluetoothPrinterPageState extends State<BluetoothPrinterPage> {
  List<BluetoothDevice> _devicesList = [];
  bool _isScanning = false;
  bool _bluetoothEnabled = false;

  // Instance dari singleton manager
  final BluetoothPrinterManager _printerManager = BluetoothPrinterManager();

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  @override
  void dispose() {
    // TIDAK memanggil disconnect() di sini agar koneksi tetap aktif
    super.dispose();
  }

  Future<void> _initBluetooth() async {
    await _requestPermissions();
    await _checkBluetoothState();

    // Initialize printer manager untuk auto reconnect
    await _printerManager.initialize();

    // Show saved printer info if available
    if (_printerManager.hasSavedPrinter()) {
      Map<String, String?> savedInfo = _printerManager.getSavedPrinterInfo();
      _showSnackBar('Printer tersimpan: ${savedInfo['name']}');
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

      if (!_bluetoothEnabled) {
        _showSnackBar('Bluetooth tidak aktif');
      } else {
        _showSnackBar('Bluetooth aktif');
      }
    });

    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    setState(() {
      _bluetoothEnabled = state == BluetoothAdapterState.on;
    });
  }

  Future<void> _scanForDevices() async {
    if (!_bluetoothEnabled) {
      _showSnackBar(
          'Bluetooth tidak aktif. Silakan aktifkan Bluetooth terlebih dahulu.');
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
        print('System devices found: ${systemDevices.length}');

        for (var device in systemDevices) {
          print('System device: ${device.platformName} - ${device.remoteId}');
          if (!allDevices.any((d) => d.remoteId == device.remoteId)) {
            allDevices.add(device);
          }
        }
      } catch (e) {
        print('Error getting system devices: $e');
      }

      print('Starting BLE scan...');
      await FlutterBluePlus.startScan(
        timeout: Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      var scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        print('Scan results received: ${results.length} devices');

        for (ScanResult result in results) {
          String deviceName = result.device.platformName;
          String deviceId = result.device.remoteId.toString();

          print('Found device: $deviceName ($deviceId) - RSSI: ${result.rssi}');

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
              name.contains('citizen') ||
              name.contains('xprinter') ||
              name.contains('bluetooth') ||
              name.contains('bt-') ||
              name.contains('rpp') ||
              name.contains('mtp') ||
              name.contains('esc') ||
              name.isNotEmpty;
        }).toList();

        setState(() {
          _devicesList = printers;
        });
      });

      await Future.delayed(Duration(seconds: 15));
      await scanSubscription.cancel();
      await FlutterBluePlus.stopScan();

      print('Scan completed. Total devices found: ${allDevices.length}');
      print('Printer devices found: ${_devicesList.length}');

      setState(() {
        _isScanning = false;
      });

      if (_devicesList.isEmpty) {
        _showSnackBar('Tidak ada printer ditemukan.\n'
            'Tips:\n'
            '1. Pastikan printer dalam mode pairing\n'
            '2. Printer sudah dipair di pengaturan Bluetooth\n'
            '3. Printer dekat dengan perangkat\n'
            '4. Coba restart printer dan scan ulang');
      } else {
        _showSnackBar('Ditemukan ${_devicesList.length} perangkat');
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      _showSnackBar('Error scanning: $e');
      print('Scan error: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      _showSnackBar('Menghubungkan ke ${device.platformName}...');

      bool connected = await _printerManager.connectToDevice(device);

      if (connected) {
        _showSnackBar(
            'Berhasil terhubung ke ${device.platformName}\nPrinter akan otomatis terhubung saat buka aplikasi');
      } else {
        _showSnackBar('Gagal terhubung ke ${device.platformName}');
      }
    } catch (e) {
      _showSnackBar('Gagal terhubung: $e');
    }
  }

  Future<void> _testPrint() async {
    bool success = await _printerManager.testPrint();
    if (success) {
      _showSnackBar('Test print berhasil dikirim');
    } else {
      _showSnackBar('Gagal print: Tidak ada printer yang terhubung');
    }
  }

  Future<void> _disconnect() async {
    await _printerManager.disconnect();
    _showSnackBar('Printer telah diputuskan dan dihapus dari memori');
  }

  Future<void> _reconnect() async {
    if (_printerManager.isReconnecting) {
      _showSnackBar('Sedang mencoba menghubungkan...');
      return;
    }

    _showSnackBar('Mencoba menghubungkan ulang...');
    bool success = await _printerManager.reconnect();

    if (success) {
      _showSnackBar('Berhasil terhubung ulang');
    } else {
      _showSnackBar(
          'Gagal menghubungkan ulang. Coba scan dan hubungkan manual.');
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

  void _showDebugInfo() {
    _printerManager.debugInfo();

    Map<String, String?> savedInfo = _printerManager.getSavedPrinterInfo();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Debug Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Status: ${_printerManager.isConnected ? "Terhubung" : "Terputus"}'),
            Text(
                'Reconnecting: ${_printerManager.isReconnecting ? "Ya" : "Tidak"}'),
            Text('Saved Printer: ${savedInfo["name"] ?? "Tidak ada"}'),
            Text('Saved ID: ${savedInfo["id"] ?? "Tidak ada"}'),
            Text(
                'Current Device: ${_printerManager.selectedDevice?.platformName ?? "Tidak ada"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Status Card - menggunakan ValueListenableBuilder untuk realtime update
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
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
              child: ValueListenableBuilder<bool>(
                valueListenable: _printerManager.connectionStatus,
                builder: (context, isConnected, child) {
                  return ValueListenableBuilder<BluetoothDevice?>(
                    valueListenable: _printerManager.selectedDeviceNotifier,
                    builder: (context, selectedDevice, child) {
                      Map<String, String?> savedInfo =
                          _printerManager.getSavedPrinterInfo();
                      bool hasReconnecting = _printerManager.isReconnecting;

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status Koneksi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  if (hasReconnecting)
                                    Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.orange),
                                        ),
                                      ),
                                    ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: hasReconnecting
                                          ? Colors.orange
                                          : (isConnected
                                              ? Colors.green
                                              : Colors.red),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      hasReconnecting
                                          ? 'Menghubungkan...'
                                          : (isConnected
                                              ? 'Terhubung'
                                              : 'Terputus'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (selectedDevice != null) ...[
                            SizedBox(height: 10),
                            Text(
                              'Printer: ${selectedDevice.platformName}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'ID: ${selectedDevice.remoteId}',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                          ] else if (savedInfo['name'] != null) ...[
                            SizedBox(height: 10),
                            Text(
                              'Printer tersimpan: ${savedInfo['name']}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),
                            Text(
                              'ID: ${savedInfo['id']}',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                          if (!isConnected && savedInfo['name'] != null) ...[
                            SizedBox(height: 10),
                            Text(
                              'Printer akan otomatis terhubung jika tersedia',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.blue[700]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // Control Buttons Row
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
                      label: Text(_isScanning ? 'Scan...' : 'Scan'),
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
                  ValueListenableBuilder<bool>(
                    valueListenable: _printerManager.connectionStatus,
                    builder: (context, isConnected, child) {
                      return Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (!isConnected &&
                                  _printerManager.hasSavedPrinter())
                              ? _reconnect
                              : null,
                          icon: Icon(Icons.refresh),
                          label: Text('Reconnect'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Printer List
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
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.print, color: Colors.blue[600]),
                          SizedBox(width: 10),
                          Text(
                            'Daftar Printer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                                  Icon(
                                    Icons.print_disabled,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Tidak ada printer ditemukan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Pastikan printer sudah dipair\ndan tekan tombol scan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ValueListenableBuilder<BluetoothDevice?>(
                              valueListenable:
                                  _printerManager.selectedDeviceNotifier,
                              builder: (context, selectedDevice, child) {
                                return ValueListenableBuilder<bool>(
                                  valueListenable:
                                      _printerManager.connectionStatus,
                                  builder: (context, isConnected, child) {
                                    return ListView.builder(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      itemCount: _devicesList.length,
                                      itemBuilder: (context, index) {
                                        BluetoothDevice device =
                                            _devicesList[index];
                                        bool isSelected =
                                            selectedDevice?.remoteId ==
                                                device.remoteId;

                                        // Check if this is the saved printer
                                        Map<String, String?> savedInfo =
                                            _printerManager
                                                .getSavedPrinterInfo();
                                        bool isSaved = savedInfo['id'] ==
                                            device.remoteId.toString();

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.blue[50]
                                                : (isSaved
                                                    ? Colors.green[50]
                                                    : Colors.grey[50]),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.blue[300]!
                                                  : (isSaved
                                                      ? Colors.green[300]!
                                                      : Colors.grey[300]!),
                                            ),
                                          ),
                                          child: ListTile(
                                            leading: Stack(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: isSelected
                                                      ? Colors.blue[600]
                                                      : (isSaved
                                                          ? Colors.green[600]
                                                          : Colors.grey[600]),
                                                  child: Icon(
                                                    Icons.print,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                if (isSaved)
                                                  Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 16,
                                                      height: 16,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.star,
                                                        color: Colors.white,
                                                        size: 12,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            title: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    device.platformName
                                                            .isNotEmpty
                                                        ? device.platformName
                                                        : 'Unknown Device',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                if (isSaved)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Text(
                                                      'Tersimpan',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            subtitle: Text(
                                                device.remoteId.toString()),
                                            trailing: ElevatedButton(
                                              onPressed: () =>
                                                  _connectToDevice(device),
                                              child: Text(
                                                isSelected && isConnected
                                                    ? 'Terhubung'
                                                    : 'Hubungkan',
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    isSelected && isConnected
                                                        ? Colors.green
                                                        : Colors.blue[600],
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
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(16),
              child: ValueListenableBuilder<bool>(
                valueListenable: _printerManager.connectionStatus,
                builder: (context, isConnected, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isConnected ? _testPrint : null,
                          icon: Icon(Icons.print),
                          label: Text('Test Print'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isConnected ? _disconnect : null,
                          icon: Icon(Icons.bluetooth_disabled),
                          label: Text('Putuskan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
