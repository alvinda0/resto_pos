import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/recipe/recipe_controller.dart';
import 'package:pos/models/recipe/recipe_model.dart';

class EditRecipeDialog extends StatelessWidget {
  final RecipeController controller;
  final Recipe recipe;

  const EditRecipeDialog({
    Key? key,
    required this.controller,
    required this.recipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Edit Resep',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Name
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Nama Resep',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.nameController,
                    decoration: InputDecoration(
                      hintText: 'Cth: Nasi Goreng Spesial',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.blue.shade500),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recipe Description
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Deskripsi',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Deskripsi resep...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.blue.shade500),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bahan-bahan Section
                  const Text(
                    'Bahan-bahan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recipe Items List
                  Obx(() {
                    return Column(
                      children: [
                        ...List.generate(
                          controller.recipeItems.length,
                          (index) => _buildRecipeItemRow(index),
                        ),
                        // Add ingredient button
                        Container(
                          width: double.infinity,
                          height: 44,
                          margin: const EdgeInsets.only(top: 8),
                          child: OutlinedButton.icon(
                            onPressed: () => controller.addRecipeItem(),
                            icon: Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.blue.shade600,
                            ),
                            label: Text(
                              'Tambah Bahan',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontSize: 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blue.shade600),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          // Footer with buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() => ElevatedButton(
                      onPressed: controller.isOperationLoading.value
                          ? null
                          : () async {
                              final success =
                                  await controller.updateRecipe(recipe.id);
                              if (success) {
                                Get.back();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: controller.isOperationLoading.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(fontSize: 14),
                            ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeItemRow(int index) {
    final item = controller.recipeItems[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Pilih Bahan dropdown
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0) ...[
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Pilih Bahan',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Obx(() {
                    // Get unique available inventories to avoid duplicates
                    final uniqueInventories = <String, dynamic>{};
                    for (var inventory in controller.availableInventories) {
                      uniqueInventories[inventory.id] = inventory;
                    }
                    final availableInventories =
                        uniqueInventories.values.toList();

                    // Check if the current value exists in available inventories
                    final currentValue =
                        item.inventoryId.isEmpty ? null : item.inventoryId;
                    final valueExists = currentValue == null ||
                        availableInventories
                            .any((inv) => inv.id == currentValue);

                    return DropdownButtonFormField<String>(
                      value: valueExists ? currentValue : null,
                      decoration: InputDecoration(
                        hintText: 'Pilih bahan',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        suffixIcon: (valueExists && currentValue != null)
                            ? IconButton(
                                onPressed: () {
                                  final updatedItem = RecipeItem(
                                    inventoryId: '',
                                    inventoryName: '',
                                    inventorySku: '',
                                    inventoryUnit: '',
                                    requiredQuantity: 0,
                                    requiredUnit: '',
                                    costPerUnit: 0,
                                    totalCost: 0,
                                    notes: '',
                                    hpp: 0,
                                  );
                                  controller.updateRecipeItem(
                                      index, updatedItem);
                                },
                                icon: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey.shade500,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                padding: EdgeInsets.zero,
                              )
                            : null,
                      ),
                      items: availableInventories
                          .map((inventory) => DropdownMenuItem<String>(
                                value: inventory.id,
                                child: Text(
                                  '${inventory.name}',
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          final selectedInventory = availableInventories
                              .firstWhere((inv) => inv.id == value);

                          final updatedItem = RecipeItem(
                            inventoryId: selectedInventory.id,
                            inventoryName: selectedInventory.name,
                            inventorySku: selectedInventory.sku,
                            inventoryUnit: selectedInventory.unit,
                            requiredQuantity: item.requiredQuantity,
                            requiredUnit: selectedInventory.unit,
                            costPerUnit: selectedInventory.price,
                            totalCost:
                                item.requiredQuantity * selectedInventory.price,
                            notes: item.notes,
                            hpp:
                                item.requiredQuantity * selectedInventory.price,
                          );

                          controller.updateRecipeItem(index, updatedItem);
                        }
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Jumlah Diperlukan
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0) ...[
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Jumlah Diperlukan',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Container(
                  height: 40,
                  child: TextFormField(
                    initialValue: item.requiredQuantity == 0
                        ? ''
                        : item.requiredQuantity.toString(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '1',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.blue.shade500),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      final quantity = double.tryParse(value) ?? 0;

                      // Get unique available inventories to avoid duplicates
                      final uniqueInventories = <String, dynamic>{};
                      for (var inventory in controller.availableInventories) {
                        uniqueInventories[inventory.id] = inventory;
                      }
                      final availableInventories =
                          uniqueInventories.values.toList();

                      final selectedInventory = availableInventories
                          .where((inv) => inv.id == item.inventoryId)
                          .firstOrNull;

                      if (selectedInventory != null) {
                        final updatedItem = RecipeItem(
                          inventoryId: item.inventoryId,
                          inventoryName: item.inventoryName,
                          inventorySku: item.inventorySku,
                          inventoryUnit: item.inventoryUnit,
                          requiredQuantity: quantity,
                          requiredUnit: selectedInventory.unit,
                          costPerUnit: selectedInventory.price,
                          totalCost: quantity * selectedInventory.price,
                          notes: item.notes,
                          hpp: quantity * selectedInventory.price,
                        );

                        controller.updateRecipeItem(index, updatedItem);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Delete button
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            child: IconButton(
              onPressed: () => controller.removeRecipeItem(index),
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red.shade500,
                size: 18,
              ),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
