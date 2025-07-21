import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pos/controller/tables/tables_qr_code_controller.dart';
import 'package:pos/models/tables/model_tables.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  final TextEditingController _searchController = TextEditingController();
  final QrCodeController _qrCodeController = QrCodeController.instance;
  List<QrCodeModel> _filteredTables = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_filterTables);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _qrCodeController.fetchQrCodes();
    await Future.delayed(const Duration(milliseconds: 100));
    _filterTables();
  }

  void _filterTables() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTables = _qrCodeController.qrCodes.where((qrCode) {
        return qrCode.tableNumber.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddTableModal() {
    final tableCountController = TextEditingController();
    final startNumberController = TextEditingController();
    final menuUrlController = TextEditingController();
    String selectedType = 'menu';
    DateTime? selectedExpiryDate;

    startNumberController.text =
        _qrCodeController.getNextAvailableTableNumber().toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Tambah Meja Baru',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: tableCountController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Meja *',
                          prefixIcon: Icon(Icons.format_list_numbered),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: startNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Awal *',
                          prefixIcon: Icon(Icons.looks_one),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Tipe Meja *',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'menu', child: Text('Menu')),
                          DropdownMenuItem(
                              value: 'table', child: Text('Table')),
                        ],
                        onChanged: (value) =>
                            setModalState(() => selectedType = value!),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: menuUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL Menu *',
                          hintText: 'https://...',
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null)
                            setModalState(() => selectedExpiryDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedExpiryDate != null
                                ? 'Tanggal Kadaluarsa: ${selectedExpiryDate!.day}/${selectedExpiryDate!.month}/${selectedExpiryDate!.year}'
                                : 'Tanggal Kadaluarsa (Opsional)',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StreamBuilder<bool>(
                              stream: _qrCodeController.isCreatingBulk.stream,
                              initialData:
                                  _qrCodeController.isCreatingBulk.value,
                              builder: (context, snapshot) {
                                final isCreating = snapshot.data ?? false;
                                return ElevatedButton(
                                  onPressed: isCreating
                                      ? null
                                      : () => _addNewTable(
                                            int.tryParse(tableCountController
                                                    .text) ??
                                                0,
                                            int.tryParse(startNumberController
                                                    .text) ??
                                                1,
                                            selectedType,
                                            menuUrlController.text,
                                            selectedExpiryDate,
                                          ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[600]),
                                  child: isCreating
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Text('Tambah',
                                          style:
                                              TextStyle(color: Colors.white)),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addNewTable(int tableCount, int startNumber, String type,
      String menuUrl, DateTime? expiryDate) async {
    if (tableCount <= 0 || startNumber <= 0 || menuUrl.isEmpty) {
      Get.snackbar('Error', 'Harap isi semua field yang diperlukan',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (!menuUrl.startsWith('http://') && !menuUrl.startsWith('https://')) {
      Get.snackbar('Error', 'URL harus dimulai dengan http:// atau https://',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      Navigator.pop(context);
      final success = await _qrCodeController.createBulkQrCodes(
        tableCount: tableCount,
        startNumber: startNumber,
        type: type,
        menuUrl: menuUrl,
        expiresAt: expiryDate,
      );
      if (success) _filterTables();
    } catch (e) {
      print('Error in _addNewTable: $e');
    }
  }

  Future<void> _downloadQrCode(QrCodeModel qrCode) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      final painter = QrPainter(
        data: qrCode.menuUrl!,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
        color: Colors.black,
        emptyColor: Colors.white,
      );

      final picData =
          await painter.toImageData(512, format: ui.ImageByteFormat.png);
      if (picData != null) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/qr_code_meja_${qrCode.tableNumber}.png';
        final file = File(path);
        await file.writeAsBytes(picData.buffer.asUint8List());

        Get.back();
        Get.snackbar('Berhasil', 'QR Code berhasil diunduh ke: $path',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar('Error', 'Gagal mengunduh QR Code: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showQrCodeModal(QrCodeModel qrCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Meja ${qrCode.tableNumber}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: qrCode.menuUrl != null && qrCode.menuUrl!.isNotEmpty
                      ? QrImageView(
                          data: qrCode.menuUrl!,
                          version: QrVersions.auto,
                          size: 200.0)
                      : Container(
                          width: 200,
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_2,
                                  size: 48, color: Colors.grey[400]),
                              const Text('Menu QR tidak tersedia',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                if (qrCode.menuUrl != null && qrCode.menuUrl!.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _copyUrlToClipboard(qrCode.menuUrl!),
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy URL'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _downloadQrCode(qrCode);
                          },
                          icon: const Icon(Icons.file_download,
                              color: Colors.white),
                          label: const Text('Download',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600]),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copyUrlToClipboard(String url) {
    Clipboard.setData(ClipboardData(text: url));
    Get.snackbar('Berhasil', 'URL berhasil disalin',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Meja'),
        actions: [
          IconButton(
              onPressed: _showAddTableModal,
              icon: const Icon(Icons.add_circle_outline)),
          IconButton(
              onPressed: () => _qrCodeController.refreshData(),
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Meja',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total: ${_qrCodeController.qrCodesCount} meja'),
                        if (_searchController.text.isNotEmpty)
                          Text('Ditemukan: ${_filteredTables.length} meja'),
                      ],
                    )),
              ],
            ),
          ),
          Expanded(child: _buildTableGrid()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTableModal,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTableGrid() {
    return Obx(() {
      if (_qrCodeController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_qrCodeController.error.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const Text('Terjadi kesalahan'),
              ElevatedButton(
                onPressed: () => _qrCodeController.refreshData(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) => _filterTables());

      if (_filteredTables.isEmpty && _qrCodeController.qrCodes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.table_restaurant, size: 64, color: Colors.grey),
              const Text('Belum ada meja'),
              ElevatedButton.icon(
                onPressed: _showAddTableModal,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Meja'),
              ),
            ],
          ),
        );
      }

      if (_filteredTables.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              Text('Meja tidak ditemukan'),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await _qrCodeController.refreshData();
          _filterTables();
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _filteredTables.length,
          itemBuilder: (context, index) {
            final qrCode = _filteredTables[index];
            return GestureDetector(
              onTap: () => _showQrCodeModal(qrCode),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Center(
                  child: Text(qrCode.tableNumber,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
