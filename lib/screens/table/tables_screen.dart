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
      ),
      body: Column(
        children: [
          // Header dengan search bar dan controls
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar dan controls
                Row(
                  children: [
                    // Search bar
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
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
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter button
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
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
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
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
                  ],
                ),
                const SizedBox(height: 12),
                // Stats row
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          'Total Meja',
                          _qrCodeController.qrCodesCount.toString(),
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Aktif',
                          _qrCodeController.activeQrCodesCount.toString(),
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Expired',
                          _qrCodeController.expiredQrCodesCount.toString(),
                          Colors.red,
                        ),
                      ],
                    )),
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
                    child: CircularProgressIndicator(),
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
                      ],
                    ),
                  );
                }

                if (_filteredTables.isEmpty) {
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
                          _searchController.text.isEmpty
                              ? 'Belum ada meja'
                              : 'Meja tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
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
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
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
                              color: isExpired
                                  ? Colors.red[300]!
                                  : Colors.grey[300]!,
                              width: 1.5,
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
                              Icon(
                                Icons.table_restaurant,
                                size: 32,
                                color: isExpired
                                    ? Colors.red[400]
                                    : Colors.blue[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Meja ${qrCode.tableNumber}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isExpired
                                      ? Colors.red[400]
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isExpired
                                      ? Colors.red[100]
                                      : Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isExpired ? 'Expired' : 'Aktif',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isExpired
                                        ? Colors.red[700]
                                        : Colors.green[700],
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
        backgroundColor: Colors.red[400],
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

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
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
                _filteredTables = _qrCodeController.qrCodes;
                setState(() {});
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Aktif'),
              onTap: () {
                _filteredTables = _qrCodeController.qrCodes
                    .where((qr) => !_qrCodeController.isExpired(qr))
                    .toList();
                setState(() {});
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Expired'),
              onTap: () {
                _filteredTables = _qrCodeController.qrCodes
                    .where((qr) => _qrCodeController.isExpired(qr))
                    .toList();
                setState(() {});
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
                          storeId:
                              'your_store_id', // Replace with actual store ID
                        );
                        _filterTables();
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
