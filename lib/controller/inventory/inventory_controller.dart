// controllers/inventory_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/inventory/inventory_model.dart';
import 'package:pos/services/inventory/inventory_service.dart';

class InventoryController extends GetxController {
  final InventoryService _inventoryService = InventoryService.instance;

  // Observable variables
  final RxList<InventoryModel> inventories = <InventoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isOperationLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxList<int> availablePageSizes = [5, 10, 25, 50].obs;

  // Search and filter variables
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final TextEditingController searchController = TextEditingController();

  // Form controllers for create/edit
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController minimumStockController = TextEditingController();
  final TextEditingController vendorNameController = TextEditingController();

  // Computed properties for pagination
  int get startIndex {
    if (totalItems.value == 0) return 0;
    return ((currentPage.value - 1) * itemsPerPage.value) + 1;
  }

  int get endIndex {
    final end = currentPage.value * itemsPerPage.value;
    return end > totalItems.value ? totalItems.value : end;
  }

  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => currentPage.value < totalPages.value;

  List<int> get pageNumbers {
    if (totalPages.value <= 5) {
      return List.generate(totalPages.value, (index) => index + 1);
    }

    final current = currentPage.value;
    final total = totalPages.value;

    if (current <= 3) {
      return [1, 2, 3, 4, 5];
    } else if (current >= total - 2) {
      return [total - 4, total - 3, total - 2, total - 1, total];
    } else {
      return [current - 2, current - 1, current, current + 1, current + 2];
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadInventories();
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    priceController.dispose();
    minimumStockController.dispose();
    vendorNameController.dispose();
    super.onClose();
  }

  Future<void> loadInventories({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final response = await _inventoryService.getInventories(
        page: currentPage.value,
        limit: itemsPerPage.value,
        search: searchQuery.value,
        status: statusFilter.value,
      );

      inventories.value = response.data;
      totalItems.value = response.metadata.total;
      totalPages.value = response.metadata.totalPages;
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = errorMsg;

      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );

      if (inventories.isEmpty) {
        totalItems.value = 0;
        totalPages.value = 0;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshInventories() async {
    currentPage.value = 1;
    await loadInventories();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    currentPage.value = 1;
    _debounceSearch();
  }

  void _debounceSearch() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchController.text == searchQuery.value) {
        loadInventories();
      }
    });
  }

  void onStatusFilterChanged(String status) {
    statusFilter.value = status;
    currentPage.value = 1;
    loadInventories();
  }

  void onPageSizeChanged(int newSize) {
    itemsPerPage.value = newSize;
    currentPage.value = 1;
    loadInventories();
  }

  void onPreviousPage() {
    if (hasPreviousPage) {
      currentPage.value = currentPage.value - 1;
      loadInventories();
    }
  }

  void onNextPage() {
    if (hasNextPage) {
      currentPage.value = currentPage.value + 1;
      loadInventories();
    }
  }

  void onPageSelected(int page) {
    if (page != currentPage.value && page > 0 && page <= totalPages.value) {
      currentPage.value = page;
      loadInventories();
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    loadInventories();
  }

  void clearFormControllers() {
    nameController.clear();
    quantityController.clear();
    unitController.clear();
    priceController.clear();
    minimumStockController.clear();
    vendorNameController.clear();
  }

  void populateFormControllers(InventoryModel inventory) {
    nameController.text = inventory.name;
    quantityController.text = inventory.quantity.toString();
    unitController.text = inventory.unit;
    priceController.text = inventory.price.toString();
    minimumStockController.text = inventory.minimumStock.toString();
    vendorNameController.text = inventory.vendorName;
  }

  Future<bool> createInventory() async {
    try {
      if (nameController.text.trim().isEmpty ||
          quantityController.text.trim().isEmpty ||
          unitController.text.trim().isEmpty ||
          priceController.text.trim().isEmpty ||
          minimumStockController.text.trim().isEmpty ||
          vendorNameController.text.trim().isEmpty) {
        Get.snackbar(
          'Validasi Error',
          'Semua field harus diisi',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.warning_outlined, color: Colors.orange),
        );
        return false;
      }

      final double quantity = double.tryParse(quantityController.text) ?? 0;
      final double price = double.tryParse(priceController.text) ?? 0;
      final double minimumStock =
          double.tryParse(minimumStockController.text) ?? 0;

      if (quantity <= 0 || price <= 0 || minimumStock < 0) {
        Get.snackbar(
          'Validasi Error',
          'Quantity dan price harus lebih dari 0, minimum stock tidak boleh negatif',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.warning_outlined, color: Colors.orange),
        );
        return false;
      }

      isOperationLoading.value = true;

      final newInventory = await _inventoryService.createInventory(
        name: nameController.text.trim(),
        quantity: quantity,
        unit: unitController.text.trim(),
        price: price,
        minimumStock: minimumStock,
        vendorName: vendorNameController.text.trim(),
      );

      Get.snackbar(
        'Berhasil',
        'Inventory "${newInventory.name}" berhasil dibuat',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      );

      clearFormControllers();
      await refreshInventories();
      return true;
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        'Gagal membuat inventory: $errorMsg',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
      return false;
    } finally {
      isOperationLoading.value = false;
    }
  }

  Future<bool> updateInventory(String id) async {
    try {
      if (nameController.text.trim().isEmpty) {
        Get.snackbar(
          'Validasi Error',
          'Nama tidak boleh kosong',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.warning_outlined, color: Colors.orange),
        );
        return false;
      }

      isOperationLoading.value = true;

      double? quantity;
      double? price;
      double? minimumStock;

      if (quantityController.text.trim().isNotEmpty) {
        quantity = double.tryParse(quantityController.text);
        if (quantity == null || quantity <= 0) {
          throw Exception('Quantity harus berupa angka positif');
        }
      }

      if (priceController.text.trim().isNotEmpty) {
        price = double.tryParse(priceController.text);
        if (price == null || price <= 0) {
          throw Exception('Price harus berupa angka positif');
        }
      }

      if (minimumStockController.text.trim().isNotEmpty) {
        minimumStock = double.tryParse(minimumStockController.text);
        if (minimumStock == null || minimumStock < 0) {
          throw Exception('Minimum stock tidak boleh negatif');
        }
      }

      final updatedInventory = await _inventoryService.updateInventory(
        id: id,
        name: nameController.text.trim().isNotEmpty
            ? nameController.text.trim()
            : null,
        quantity: quantity,
        unit: unitController.text.trim().isNotEmpty
            ? unitController.text.trim()
            : null,
        price: price,
        minimumStock: minimumStock,
        vendorName: vendorNameController.text.trim().isNotEmpty
            ? vendorNameController.text.trim()
            : null,
      );

      Get.snackbar(
        'Berhasil',
        'Inventory "${updatedInventory.name}" berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      );

      clearFormControllers();
      await loadInventories(showLoading: false);
      return true;
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        'Gagal memperbarui inventory: $errorMsg',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
      return false;
    } finally {
      isOperationLoading.value = false;
    }
  }

  Future<void> deleteInventory(InventoryModel inventory) async {
    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
            'Apakah Anda yakin ingin menghapus inventory "${inventory.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isOperationLoading.value = true;

      await _inventoryService.deleteInventory(inventory.id);

      Get.snackbar(
        'Berhasil',
        'Inventory "${inventory.name}" berhasil dihapus',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      );

      await loadInventories(showLoading: false);
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        'Gagal menghapus inventory: $errorMsg',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    } finally {
      isOperationLoading.value = false;
    }
  }

  void showInventoryDetails(InventoryModel inventory) {
    Get.snackbar(
      'Info',
      'Detail untuk ${inventory.name}',
      snackPosition: SnackPosition.TOP,
    );
  }

  void showInventoryActions(InventoryModel inventory) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Bahan'),
              onTap: () {
                Get.back();
                populateFormControllers(inventory);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Lihat Detail'),
              onTap: () {
                Get.back();
                showInventoryDetails(inventory);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus Bahan',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                deleteInventory(inventory);
              },
            ),
          ],
        ),
      ),
    );
  }

  void showCreateInventoryForm() {
    clearFormControllers();
  }

  void showEditInventoryForm(InventoryModel inventory) {
    populateFormControllers(inventory);
  }
}
