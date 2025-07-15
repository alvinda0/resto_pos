import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/tables/tables_qr_code_controller.dart';
import 'package:pos/models/tables/model_tables.dart';

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

  Future<void> _initializeData() async {
    await _qrCodeController.fetchQrCodes();
    // Tunggu sebentar untuk memastikan data sudah dimuat
    await Future.delayed(Duration(milliseconds: 100));
    _filterTables();
  }

  void _filterTables() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // Gunakan _qrCodeController.qrCodes.value untuk akses data terbaru
      _filteredTables = _qrCodeController.qrCodes.where((qrCode) {
        return qrCode.tableNumber.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header dengan search bar dan controls
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Search bar
                Expanded(
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
                ),
                const SizedBox(width: 12),
                // Filter button
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _showFilterDialog();
                    },
                    icon: Icon(
                      Icons.tune,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Grid view button
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Handle view change
                    },
                    icon: Icon(
                      Icons.grid_view,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // QR Code button
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Handle QR code action
                    },
                    icon: Icon(
                      Icons.qr_code,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grid content
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Obx(() {
                if (_qrCodeController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  );
                }

                if (_qrCodeController.error.value.isNotEmpty) {
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
                          onPressed: () {
                            _qrCodeController.refreshData();
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                // Update filtered tables setiap kali ada perubahan data
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _filterTables();
                });

                if (_filteredTables.isEmpty &&
                    _qrCodeController.qrCodes.isEmpty) {
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
                          'Tambahkan meja pertama Anda',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredTables.isEmpty &&
                    _qrCodeController.qrCodes.isNotEmpty) {
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

                return RefreshIndicator(
                  onRefresh: () async {
                    await _qrCodeController.refreshData();
                    _filterTables();
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _filteredTables.length,
                    itemBuilder: (context, index) {
                      final qrCode = _filteredTables[index];
                      final isExpired = _qrCodeController.isExpired(qrCode);

                      return GestureDetector(
                        onTap: () {
                          _showTableDetails(qrCode);
                        },
                        onLongPress: () {
                          _showTableOptions(qrCode);
                        },
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
                              // Table number - large and prominent
                              Text(
                                qrCode.tableNumber,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isExpired
                                      ? Colors.red[400]
                                      : Colors.red[500],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Status indicator
                              if (isExpired)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Expired',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTableDialog();
        },
        backgroundColor: Colors.red[500],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Meja',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Meja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Semua'),
              onTap: () {
                setState(() {
                  _filteredTables = _qrCodeController.qrCodes.toList();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Aktif'),
              onTap: () {
                setState(() {
                  _filteredTables = _qrCodeController.qrCodes
                      .where((qr) => !_qrCodeController.isExpired(qr))
                      .toList();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Expired'),
              onTap: () {
                setState(() {
                  _filteredTables = _qrCodeController.qrCodes
                      .where((qr) => _qrCodeController.isExpired(qr))
                      .toList();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTableDetails(QrCodeModel qrCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Meja ${qrCode.tableNumber}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ID: ${qrCode.id}'),
            const SizedBox(height: 8),
            Text('Tipe: ${qrCode.type}'),
            const SizedBox(height: 8),
            Text('URL Menu: ${qrCode.menuUrl}'),
            const SizedBox(height: 8),
            Text('Expired: ${qrCode.expiresAt.toString().split('.')[0]}'),
            const SizedBox(height: 8),
            Text(
                'Status: ${_qrCodeController.isExpired(qrCode) ? 'Expired' : 'Aktif'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditTableDialog(qrCode);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showTableOptions(QrCodeModel qrCode) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Meja'),
              onTap: () {
                Navigator.pop(context);
                _showEditTableDialog(qrCode);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title:
                  const Text('Hapus Meja', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _qrCodeController.deleteQrCode(qrCode.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTableDialog() {
    _qrCodeController.tableNumberController.clear();
    _qrCodeController.menuUrlController.clear();
    _qrCodeController.selectedType.value = 'menu';
    _qrCodeController.selectedExpiresAt.value = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Meja Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _qrCodeController.tableNumberController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Meja',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _qrCodeController.menuUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Menu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                    value: _qrCodeController.selectedType.value,
                    decoration: const InputDecoration(
                      labelText: 'Tipe',
                      border: OutlineInputBorder(),
                    ),
                    items: ['menu', 'order', 'payment'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _qrCodeController.selectedType.value = value;
                      }
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          Obx(() => ElevatedButton(
                onPressed: _qrCodeController.isLoading.value
                    ? null
                    : () async {
                        await _qrCodeController.createQrCode(
                          storeId: 'your_store_id',
                        );
                        _filterTables();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                child: _qrCodeController.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Tambah'),
              )),
        ],
      ),
    );
  }

  void _showEditTableDialog(QrCodeModel qrCode) {
    _qrCodeController.setFormData(qrCode);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Meja ${qrCode.tableNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _qrCodeController.tableNumberController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Meja',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _qrCodeController.menuUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Menu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                    value: _qrCodeController.selectedType.value,
                    decoration: const InputDecoration(
                      labelText: 'Tipe',
                      border: OutlineInputBorder(),
                    ),
                    items: ['menu', 'order', 'payment'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _qrCodeController.selectedType.value = value;
                      }
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          Obx(() => ElevatedButton(
                onPressed: _qrCodeController.isLoading.value
                    ? null
                    : () async {
                        await _qrCodeController.updateQrCode(qrCode.id);
                        _filterTables();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                child: _qrCodeController.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update'),
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
