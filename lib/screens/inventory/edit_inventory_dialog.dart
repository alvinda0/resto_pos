import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pos/controller/inventory/inventory_controller.dart';
import 'package:pos/models/inventory/inventory_model.dart';

class EditInventoryDialog {
  static void show(InventoryController controller, InventoryModel inventory) {
    controller.populateFormControllers(inventory);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Bahan: ${inventory.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInventoryForm(controller),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isOperationLoading.value
                            ? null
                            : () async {
                                try {
                                  final success = await controller
                                      .updateInventory(inventory.id);
                                  if (success) {
                                    // Tutup dialog secara eksplisit
                                    if (Get.isDialogOpen ?? false) {
                                      Get.back();
                                    }
                                    // Tampilkan success message
                                    Get.snackbar(
                                      'Berhasil',
                                      'Bahan berhasil diupdate',
                                      backgroundColor: Colors.green.shade600,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.TOP,
                                      duration: const Duration(seconds: 2),
                                    );
                                  }
                                } catch (e) {
                                  // Handle error jika diperlukan
                                  Get.snackbar(
                                    'Error',
                                    'Gagal mengupdate bahan: $e',
                                    backgroundColor: Colors.red.shade600,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.TOP,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                        ),
                        child: controller.isOperationLoading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Update'),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildInventoryForm(InventoryController controller) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Bahan *',
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan nama bahan',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller.unitController,
                  decoration: const InputDecoration(
                    labelText: 'Satuan *',
                    border: OutlineInputBorder(),
                    hintText: 'kg, pcs, liter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Stok *',
                    border: OutlineInputBorder(),
                    hintText: '0',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller.minimumStockController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Minimum Stok *',
                    border: OutlineInputBorder(),
                    hintText: '0',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Harga per Unit *',
                    border: OutlineInputBorder(),
                    hintText: '0',
                    prefixText: 'Rp ',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller.vendorNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Vendor *',
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan nama vendor',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '* Field wajib diisi',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
