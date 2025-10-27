import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shao_kao/controller/return/return_controller.dart';
import 'package:shao_kao/widgets/pagination_widget.dart';

class WasteScreen extends StatelessWidget {
  const WasteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WasteController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manajemen Waste'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshData,
            tooltip: 'Muat Ulang',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add waste screen
              Get.snackbar(
                'Info',
                'Fitur tambah waste segera hadir',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            tooltip: 'Tambah Waste',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(controller),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.wastes.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.errorMessage.isNotEmpty &&
                  controller.wastes.isEmpty) {
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
                        'Gagal memuat data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: controller.refreshData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.wastes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada data waste',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mulai tambahkan data waste untuk melacak inventori',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    return isMobile
                        ? _buildMobileList(controller)
                        : _buildDesktopTable(controller);
                  },
                ),
              );
            }),
          ),

          // Pagination
          Obx(() => PaginationWidget(
                currentPage: controller.currentPage.value,
                totalItems: controller.totalItems.value,
                itemsPerPage: controller.itemsPerPage.value,
                availablePageSizes: controller.availablePageSizes,
                startIndex: controller.startIndex,
                endIndex: controller.endIndex,
                hasPreviousPage: controller.hasPreviousPage,
                hasNextPage: controller.hasNextPage,
                pageNumbers: controller.pageNumbers,
                onPageSizeChanged: controller.onPageSizeChanged,
                onPreviousPage: controller.onPreviousPage,
                onNextPage: controller.onNextPage,
                onPageSelected: controller.onPageSelected,
              )),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WasteController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: controller.clearSearch,
                      )
                    : const SizedBox.shrink()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: controller.onSearch,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () =>
                controller.onSearch(controller.searchController.text),
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(WasteController controller) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.wastes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final waste = controller.wastes[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () {
              _showWasteDetails(context, controller, waste);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          waste.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.deleteWaste(waste.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${waste.product.sku}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Divider(height: 16),
                  _buildInfoRow('Jumlah', '${waste.quantity} ${waste.unit}'),
                  _buildInfoRow('Biaya', controller.formatCurrency(waste.cost)),
                  _buildInfoRow(
                      'Alasan', controller.getReasonLabel(waste.reason)),
                  _buildInfoRow('Tanggal', controller.formatDate(waste.date)),
                  if (waste.notes != null && waste.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Catatan: ${waste.notes}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(WasteController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
              columns: [
                const DataColumn(label: Text('Nama Produk')),
                const DataColumn(label: Text('SKU')),
                DataColumn(
                  label: const Text('Jumlah'),
                  numeric: true,
                ),
                const DataColumn(label: Text('Satuan')),
                DataColumn(
                  label: const Text('Biaya'),
                  numeric: true,
                ),
                const DataColumn(label: Text('Alasan')),
                const DataColumn(label: Text('Tanggal')),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text('Dibuat Oleh'),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 200,
                    child: Text('Catatan'),
                  ),
                ),
              ],
              rows: controller.wastes.map((waste) {
                return DataRow(
                  cells: [
                    DataCell(Text(waste.product.name)),
                    DataCell(Text(waste.product.sku)),
                    DataCell(Text(waste.quantity.toString())),
                    DataCell(Text(waste.unit)),
                    DataCell(Text(controller.formatCurrency(waste.cost))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getReasonColor(waste.reason).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _getReasonColor(waste.reason),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          controller.getReasonLabel(waste.reason),
                          style: TextStyle(
                            color: _getReasonColor(waste.reason),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(controller.formatDate(waste.date))),
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: Text(
                          waste.createdByName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          waste.notes ?? '-',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showWasteDetails(
      BuildContext context, WasteController controller, waste) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Waste'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Produk', waste.product.name),
              _buildDetailRow('SKU', waste.product.sku),
              _buildDetailRow('Jumlah', '${waste.quantity} ${waste.unit}'),
              _buildDetailRow('Biaya', controller.formatCurrency(waste.cost)),
              _buildDetailRow(
                  'Alasan', controller.getReasonLabel(waste.reason)),
              _buildDetailRow('Tanggal', controller.formatDate(waste.date)),
              _buildDetailRow('Dibuat Oleh', waste.createdByName),
              _buildDetailRow(
                  'Dibuat Pada', controller.formatDate(waste.createdAt)),
              if (waste.notes != null && waste.notes!.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Catatan:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  waste.notes!,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteWaste(waste.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Color _getReasonColor(String reason) {
    switch (reason) {
      case 'EXPIRED':
        return Colors.orange;
      case 'DAMAGED':
        return Colors.red;
      case 'CUSTOMER_RETURN':
        return Colors.blue;
      case 'OTHER':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
