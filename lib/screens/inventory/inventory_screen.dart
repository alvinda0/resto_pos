import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/inventory/inventory_controller.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InventoryController controller = Get.put(InventoryController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Manajemen Inventori',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            // Search and Filter Row
            Row(
              children: [
                // Search Field
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      onChanged: controller.updateSearchQuery,
                      decoration: const InputDecoration(
                        hintText: 'Cari Bahan',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Status Filter Dropdown
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedStatus.value,
                          decoration: const InputDecoration(
                            prefixIcon:
                                Icon(Icons.filter_list, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          hint: const Text('Filter Status'),
                          items: controller.statusOptions.map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.updateStatusFilter(value);
                            }
                          },
                        )),
                  ),
                ),
                const SizedBox(width: 16),

                // Add Item Button
                ElevatedButton.icon(
                  onPressed: () => _showAddItemDialog(context, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Tambah Bahan',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Data Table - FULL WIDTH MODIFICATIONS
            Expanded(
              child: Container(
                width: double.infinity, // Force full width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refreshData,
                    child: SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal, // Allow horizontal scroll if needed
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width -
                              48, // Full width minus padding
                        ),
                        child: DataTable(
                          columnSpacing: 30, // Increased spacing
                          horizontalMargin: 20,
                          headingRowHeight: 60,
                          dataRowHeight: 70,
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          columns: const [
                            DataColumn(
                              label: Expanded(
                                child: Row(
                                  children: [
                                    Text('NAMA'),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_upward, size: 16),
                                  ],
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text('STOK'),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text('MIN. STOK'),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text('STATUS'),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text('AKSI'),
                              ),
                            ),
                          ],
                          rows: controller.filteredInventories.map((item) {
                            return DataRow(
                              cells: [
                                // Name and SKU
                                DataCell(
                                  SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'SKU: ${item.id}', // Using id as SKU placeholder
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Stock
                                DataCell(
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      '${item.quantity.toInt()} ${item.unit}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),

                                // Minimum Stock
                                DataCell(
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      '${item.minimumStock.toInt()} ${item.unit}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),

                                // Status Badge
                                DataCell(
                                  SizedBox(
                                    width: double.infinity,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item.isLowStock
                                            ? Colors.orange
                                            : Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item.isLowStock ? 'MENIPIS' : 'CUKUP',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),

                                // Action Menu
                                DataCell(
                                  SizedBox(
                                    width: double.infinity,
                                    child: PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'edit':
                                            controller
                                                .loadInventoryForEdit(item);
                                            _showEditItemDialog(
                                                context, controller, item);
                                            break;
                                          case 'delete':
                                            controller.deleteInventory(
                                                item.id, item.name);
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 16),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  size: 16, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Hapus',
                                                  style: TextStyle(
                                                      color: Colors.red)),
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
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(
      BuildContext context, InventoryController controller) {
    controller.clearForm();
    _showItemDialog(context, controller, 'Tambah Bahan Baru', null);
  }

  void _showEditItemDialog(
      BuildContext context, InventoryController controller, item) {
    _showItemDialog(context, controller, 'Edit Bahan', item);
  }

  void _showItemDialog(
    BuildContext context,
    InventoryController controller,
    String title,
    dynamic item,
  ) {
    // Create a local unit selection variable
    String selectedUnit = controller.unitController.text.isEmpty
        ? controller.unitOptions.first
        : controller.unitController.text;

    // Set initial unit value
    controller.unitController.text = selectedUnit;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 400,
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name Field
                  TextFormField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Bahan',
                      border: OutlineInputBorder(),
                    ),
                    validator: controller.validateName,
                  ),
                  const SizedBox(height: 16),

                  // Quantity Field
                  TextFormField(
                    controller: controller.quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Stok',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: controller.validateQuantity,
                  ),
                  const SizedBox(height: 16),

                  // Unit Dropdown - Using StatefulBuilder instead of Obx
                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Satuan',
                      border: OutlineInputBorder(),
                    ),
                    items: controller.unitOptions.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedUnit = value;
                        });
                        controller.unitController.text = value;
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Minimum Stock Field
                  TextFormField(
                    controller: controller.minimumStockController,
                    decoration: const InputDecoration(
                      labelText: 'Stok Minimum',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: controller.validateMinimumStock,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Batal'),
            ),
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          if (item == null) {
                            // Add new item
                            await controller.createInventory();
                          } else {
                            // Update existing item
                            await controller.updateInventory(item.id);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Simpan'),
                )),
          ],
        ),
      ),
    );
  }
}
