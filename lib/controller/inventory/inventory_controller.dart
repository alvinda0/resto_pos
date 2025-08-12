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

      // Show user-friendly error message
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

      // Reset data on error
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
    // Simple debounce implementation
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

  void showInventoryDetails(InventoryModel inventory) {
    // Navigate to inventory details or show dialog
    // This can be implemented based on your navigation requirements
    Get.snackbar(
      'Info',
      'Detail untuk ${inventory.name}',
      snackPosition: SnackPosition.TOP,
    );
  }

  void showInventoryActions(InventoryModel inventory) {
    // Show bottom sheet or dialog with inventory actions
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
                // Navigate to edit screen
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
                // Show delete confirmation
              },
            ),
          ],
        ),
      ),
    );
  }
}
