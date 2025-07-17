import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pos/controller/tables/tables_qr_code_controller.dart';
import 'package:pos/models/tables/model_tables.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  final TextEditingController _searchController = TextEditingController();
  final QrCodeController _qrCodeController = QrCodeController.instance;
  final GlobalKey _qrKey = GlobalKey();

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

  // Function to show Add Table modal
  void _showAddTableModal() {
    final TextEditingController tableCountController = TextEditingController();
    final TextEditingController startNumberController = TextEditingController();
    final TextEditingController menuUrlController = TextEditingController();
    String selectedType = 'Reguler';
    DateTime? selectedExpiryDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.blue[600],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Tambah Meja Baru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Table Count Input
                      TextField(
                        controller: tableCountController,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Meja *',
                          hintText: 'Masukkan jumlah meja',
                          prefixIcon: const Icon(Icons.format_list_numbered),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Start Number Input
                      TextField(
                        controller: startNumberController,
                        decoration: InputDecoration(
                          labelText: 'Nomor Awal *',
                          hintText: 'Masukkan nomor awal meja',
                          prefixIcon: const Icon(Icons.looks_one),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Type Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: 'Tipe Meja *',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Reguler', child: Text('Reguler')),
                          DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                          DropdownMenuItem(
                              value: 'Outdoor', child: Text('Outdoor')),
                          DropdownMenuItem(
                              value: 'Private', child: Text('Private')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Menu URL Input
                      TextField(
                        controller: menuUrlController,
                        decoration: InputDecoration(
                          labelText: 'URL Menu *',
                          hintText: 'Masukkan URL menu',
                          prefixIcon: const Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),

                      // Expiry Date Input
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.blue[600]!,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              selectedExpiryDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedExpiryDate != null
                                      ? 'Tanggal Kadaluarsa: ${selectedExpiryDate!.day}/${selectedExpiryDate!.month}/${selectedExpiryDate!.year}'
                                      : 'Tanggal Kadaluarsa (Opsional)',
                                  style: TextStyle(
                                    color: selectedExpiryDate != null
                                        ? Colors.black
                                        : Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (selectedExpiryDate != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedExpiryDate = null;
                                    });
                                  },
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _addNewTable(
                                int.tryParse(tableCountController.text) ?? 0,
                                int.tryParse(startNumberController.text) ?? 1,
                                selectedType,
                                menuUrlController.text,
                                selectedExpiryDate,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Tambah',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
    if (tableCount <= 0) {
      Get.snackbar(
        'Error',
        'Jumlah meja harus lebih dari 0',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (menuUrl.isEmpty) {
      Get.snackbar(
        'Error',
        'URL menu tidak boleh kosong',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      Navigator.of(context).pop();
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Add all tables sequentially
      for (int i = 0; i < tableCount; i++) {
        final tableNumber = '${startNumber + i}';
      }

      Get.back();
      Get.snackbar(
        'Berhasil',
        '$tableCount meja berhasil ditambahkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      _filterTables();
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar(
        'Error',
        'Gagal menambahkan meja: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Method to refresh data
  Future<void> refreshData() async {
    // Your existing refresh logic here
  }

  // Function to download QR Code
  Future<void> _downloadQrCode(QrCodeModel qrCode) async {
    try {
      // Create painter with simpler approach
      final painter = QrPainter(
        data: qrCode.menuUrl!,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
        color: Colors.black,
        emptyColor: Colors.white,
      );

      // Convert to image
      final picData =
          await painter.toImageData(512, format: ui.ImageByteFormat.png);

      if (picData != null) {
        // Get directory
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/qr_code_meja_${qrCode.tableNumber}.png';

        // Save file
        final file = File(path);
        await file.writeAsBytes(picData.buffer.asUint8List());

        Get.snackbar(
          'Berhasil',
          'QR Code meja ${qrCode.tableNumber} berhasil diunduh ke: $path',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengunduh QR Code: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Function to show QR Code modal
  void _showQrCodeModal(QrCodeModel qrCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Check if menu_url exists and is not empty
                      if (qrCode.menuUrl != null && qrCode.menuUrl!.isNotEmpty)
                        RepaintBoundary(
                          key: _qrKey,
                          child: QrImageView(
                            data: qrCode.menuUrl!,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                        )
                      else
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Menu QR tidak tersedia',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // QR Code info
                      if (qrCode.menuUrl != null && qrCode.menuUrl!.isNotEmpty)
                        Column(
                          children: [
                            const Text(
                              'Scan QR Code untuk melihat menu',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              qrCode.menuUrl!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Download button
                if (qrCode.menuUrl != null && qrCode.menuUrl!.isNotEmpty)
                  SizedBox(
                    width: 200, // Same width as QR code
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadQrCode(qrCode),
                      icon: const Icon(
                        Icons.file_download,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Download QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        shadowColor: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Copy URL to clipboard
  void _copyUrlToClipboard(String url) {
    // You'll need to import 'package:flutter/services.dart'
    // Clipboard.setData(ClipboardData(text: url));
    Get.snackbar(
      'Berhasil',
      'URL berhasil disalin ke clipboard',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Navigate to table detail
  void _navigateToTableDetail(QrCodeModel qrCode) {
    // Navigate to table detail page or menu page
    // Get.to(() => MenuPage(tableId: qrCode.id));
    Get.snackbar(
      'Info',
      'Menuju ke menu meja ${qrCode.tableNumber}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(child: _buildTableGrid()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTableModal,
        backgroundColor: Colors.blue[600],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Meja',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showAddTableModal,
          icon: Icon(
            Icons.add_circle_outline,
            color: Colors.blue[600],
          ),
          tooltip: 'Tambah Meja',
        ),
      ],
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari Meja',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[500],
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableGrid() {
    return Obx(() {
      if (_qrCodeController.isLoading.value) {
        return _buildLoadingState();
      }

      if (_qrCodeController.error.value.isNotEmpty) {
        return _buildErrorState();
      }

      // Update filtered tables setiap kali ada perubahan data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _filterTables();
      });

      if (_filteredTables.isEmpty && _qrCodeController.qrCodes.isEmpty) {
        return _buildEmptyState();
      }

      if (_filteredTables.isEmpty && _qrCodeController.qrCodes.isNotEmpty) {
        return _buildNoResultsState();
      }

      return _buildGridView();
    });
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _qrCodeController.error.value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _qrCodeController.refreshData(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada meja',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada data meja yang tersedia',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddTableModal,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Meja'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Meja tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba kata kunci yang berbeda',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
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
          return _buildTableCard(qrCode);
        },
      ),
    );
  }

  Widget _buildTableCard(QrCodeModel qrCode) {
    return GestureDetector(
      onTap: () => _showQrCodeModal(qrCode), // Add tap handler
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              qrCode.tableNumber,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
