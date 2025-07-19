// controllers/inventory_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/inventory/inventory_model.dart';
import 'package:pos/services/inventory/inventory_service.dart';

class InventoryController extends GetxController {
  final InventoryService _inventoryService = InventoryService.instance;

  // Observable variables
  final RxList<InventoryModel> inventories = <InventoryModel>[].obs;
  final RxList<InventoryModel> filteredInventories = <InventoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'Semua'.obs;

  // Text editing controllers for form
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController minimumStockController = TextEditingController();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Unit options
  final List<String> unitOptions = ['kg', 'gram', 'liter', 'mili', 'pcs'];

  // Status filter options
  final List<String> statusOptions = ['Semua', 'CUKUP', 'MENIPIS'];

  @override
  void onInit() {
    super.onInit();
    loadInventories();

    // Listen to search query changes
    debounce(searchQuery, (_) => filterInventories(),
        time: const Duration(milliseconds: 500));

    // Listen to status filter changes
    ever(selectedStatus, (_) => filterInventories());
  }

  @override
  void onClose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    minimumStockController.dispose();
    super.onClose();
  }

  // Load all inventories
  Future<void> loadInventories() async {
    try {
      isLoading.value = true;
      final result = await _inventoryService.getInventories();
      inventories.value = result;
      filteredInventories.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filter inventories based on search query and status
  void filterInventories() {
    List<InventoryModel> result = inventories;

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      result = result
          .where((inventory) => inventory.name
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    // Filter by status
    if (selectedStatus.value != 'Semua') {
      if (selectedStatus.value == 'MENIPIS') {
        result = result.where((inventory) => inventory.isLowStock).toList();
      } else if (selectedStatus.value == 'CUKUP') {
        result = result.where((inventory) => !inventory.isLowStock).toList();
      }
    }

    filteredInventories.value = result;
  }

  // Create new inventory
  Future<void> createInventory() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final request = CreateInventoryRequest(
        name: nameController.text.trim(),
        quantity: double.parse(quantityController.text),
        unit: unitController.text,
        minimumStock: double.parse(minimumStockController.text),
      );

      await _inventoryService.createInventory(request);

      Get.back(); // Close form dialog
      Get.snackbar(
        'Berhasil',
        'Inventori berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearForm();
      loadInventories(); // Reload data
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update inventory
  Future<void> updateInventory(String id) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final request = UpdateInventoryRequest(
        name: nameController.text.trim(),
        quantity: double.parse(quantityController.text),
        unit: unitController.text,
        minimumStock: double.parse(minimumStockController.text),
      );

      await _inventoryService.updateInventory(id, request);

      Get.back(); // Close form dialog
      Get.snackbar(
        'Berhasil',
        'Inventori berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearForm();
      loadInventories(); // Reload data
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete inventory
  Future<void> deleteInventory(String id, String name) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      isLoading.value = true;
      await _inventoryService.deleteInventory(id);

      Get.snackbar(
        'Berhasil',
        'Inventori berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      loadInventories(); // Reload data
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load inventory data for editing
  void loadInventoryForEdit(InventoryModel inventory) {
    nameController.text = inventory.name;
    quantityController.text = inventory.quantity.toString();
    unitController.text = inventory.unit;
    minimumStockController.text = inventory.minimumStock.toString();
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    quantityController.clear();
    unitController.text = unitOptions.isNotEmpty ? unitOptions.first : 'pcs';
    minimumStockController.clear();
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Update status filter
  void updateStatusFilter(String status) {
    selectedStatus.value = status;
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadInventories();
  }

  // Validators
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    return null;
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jumlah tidak boleh kosong';
    }
    if (double.tryParse(value) == null || double.parse(value) < 0) {
      return 'Jumlah harus berupa angka positif';
    }
    return null;
  }

  String? validateMinimumStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Stok minimum tidak boleh kosong';
    }
    if (double.tryParse(value) == null || double.parse(value) < 0) {
      return 'Stok minimum harus berupa angka positif';
    }
    return null;
  }
}
