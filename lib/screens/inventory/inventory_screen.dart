// screens/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/inventory/inventory_controller.dart';
import 'package:pos/models/inventory/inventory_model.dart';
import 'package:pos/widgets/pagination_widget.dart';
import 'package:pos/screens/inventory/create_inventory_dialog.dart';
import 'package:pos/screens/inventory/edit_inventory_dialog.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final InventoryController controller = Get.put(InventoryController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          _buildHeader(controller),

          // Search and Filter Section
          _buildSearchAndFilter(controller),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.inventories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty &&
                  controller.inventories.isEmpty) {
                return _buildErrorState(controller);
              }

              if (controller.inventories.isEmpty) {
                return _buildEmptyState(controller);
              }

              return Column(
                children: [
                  // Data Table
                  Expanded(
                    child: _buildDataTable(controller),
                  ),

                  // Pagination
                  PaginationWidget(
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
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(InventoryController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Manajemen Bahan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => CreateInventoryDialog.show(controller),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Tambah Bahan',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(InventoryController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          // Search Field
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari Bahan',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: controller.clearSearch,
                      )
                    : const SizedBox.shrink()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue.shade600),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Status Filter
          Expanded(
            flex: 1,
            child: Obx(() => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.statusFilter.value,
                      hint: const Text('Filter Status'),
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      items: const [
                        DropdownMenuItem(
                            value: 'all', child: Text('Semua Status')),
                        DropdownMenuItem(
                            value: 'available', child: Text('Tersedia')),
                        DropdownMenuItem(
                            value: 'low_stock', child: Text('Stok Rendah')),
                        DropdownMenuItem(
                            value: 'out_of_stock', child: Text('Stok Habis')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.onStatusFilterChanged(value);
                        }
                      },
                    ),
                  ),
                )),
          ),

          const SizedBox(width: 16),

          // Refresh Button
          ElevatedButton.icon(
            onPressed: controller.refreshInventories,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(InventoryController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final double padding = 32;
          final double spacing = 16 * 7;
          final double workingWidth = availableWidth - padding - spacing;

          const Map<String, double> minWidths = {
            'name': 150,
            'stock': 80,
            'minStock': 100,
            'price': 120,
            'vendor': 160,
            'paymentStatus': 120,
            'status': 100,
            'actions': 80,
          };

          final double totalMinWidth = minWidths.values.reduce((a, b) => a + b);
          final bool needsHorizontalScroll = workingWidth < totalMinWidth;

          late Map<String, double> columnWidths;

          if (needsHorizontalScroll) {
            columnWidths = Map.from(minWidths);
          } else {
            final double extraSpace = workingWidth - totalMinWidth;
            columnWidths = {
              'name': minWidths['name']! + (extraSpace * 0.20),
              'stock': minWidths['stock']! + (extraSpace * 0.08),
              'minStock': minWidths['minStock']! + (extraSpace * 0.10),
              'price': minWidths['price']! + (extraSpace * 0.18),
              'vendor': minWidths['vendor']! + (extraSpace * 0.25),
              'paymentStatus':
                  minWidths['paymentStatus']! + (extraSpace * 0.12),
              'status': minWidths['status']! + (extraSpace * 0.05),
              'actions': minWidths['actions']! + (extraSpace * 0.02),
            };
          }

          return Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: needsHorizontalScroll
                      ? totalMinWidth + padding + spacing
                      : availableWidth,
                  child: DataTable(
                    columnSpacing: 16,
                    horizontalMargin: 16,
                    headingRowHeight: 56,
                    dataRowHeight: 64,
                    headingRowColor:
                        MaterialStateProperty.all(Colors.grey.shade50),
                    dividerThickness: 1,
                    columns: [
                      DataColumn(
                        label: SizedBox(
                          width: columnWidths['name'],
                          child: Text('NAMA BAHAN', style: _headerTextStyle()),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: columnWidths['stock'],
                          child: Text('STOK', style: _headerTextStyle()),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: columnWidths['minStock'],
                          child: Text('MIN. STOK', style: _headerTextStyle()),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: columnWidths['price'],
                          child: Text('HARGA/UNIT', style: _headerTextStyle()),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: columnWidths['vendor'],
                          child: Text('VENDOR', style: _headerTextStyle()),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: columnWidths['paymentStatus'],
                          child:
                              Text('STATUS BAYAR', style: _headerTextStyle()),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: columnWidths['status'],
                          child: Text('STATUS', style: _headerTextStyle()),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: columnWidths['actions'],
                          child: Text('AKSI', style: _headerTextStyle()),
                        ),
                      ),
                    ],
                    rows: controller.inventories.map((inventory) {
                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: columnWidths['name'],
                              child: Text(
                                inventory.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: columnWidths['stock'],
                              child: Text(
                                inventory.stockDisplay,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: columnWidths['minStock'],
                              child: Text(
                                inventory.minimumStockDisplay,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: columnWidths['price'],
                              child: Text(
                                inventory.formattedPrice,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: columnWidths['vendor'],
                              child: Text(
                                inventory.vendorName.isEmpty
                                    ? '-'
                                    : inventory.vendorName,
                                style: const TextStyle(color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: columnWidths['paymentStatus'],
                              child: _buildStatusBadge(
                                inventory.paymentStatusDisplay,
                                _getPaymentStatusColor(
                                    inventory.paymentStatusDisplay),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: columnWidths['status'],
                              child: _buildStatusBadge(
                                inventory.statusDisplay,
                                _getInventoryStatusColor(inventory),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: columnWidths['actions'],
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.grey),
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      EditInventoryDialog.show(
                                          controller, inventory);
                                      break;
                                    case 'delete':
                                      controller.deleteInventory(inventory);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Hapus'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Loading overlay for operations
              Obx(() {
                if (controller.isOperationLoading.value) {
                  return Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          );
        },
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'lunas':
        return Colors.green;
      case 'pending':
      case 'tertunda':
        return Colors.orange;
      case 'unpaid':
      case 'belum bayar':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getInventoryStatusColor(dynamic inventory) {
    if (inventory.isAvailable) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEmptyState(InventoryController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data bahan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan bahan pertama Anda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => CreateInventoryDialog.show(controller),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Bahan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(InventoryController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage.value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshInventories,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  TextStyle _headerTextStyle() {
    return TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 11,
      color: Colors.grey.shade700,
      letterSpacing: 0.8,
    );
  }
}
