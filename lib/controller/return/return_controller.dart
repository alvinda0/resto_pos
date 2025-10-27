import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shao_kao/models/return/return_model.dart';
import 'package:shao_kao/services/return/return_service.dart';

class WasteController extends GetxController {
  final WasteService _wasteService = WasteService.instance;

  // Observable variables
  final RxList<WasteRecord> wastes = <WasteRecord>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxList<int> availablePageSizes = [5, 10, 25, 50].obs;

  // Search
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchWastes();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Computed properties for pagination
  int get startIndex => totalItems.value == 0
      ? 0
      : (currentPage.value - 1) * itemsPerPage.value + 1;

  int get endIndex => (currentPage.value * itemsPerPage.value)
      .clamp(0, totalItems.value)
      .toInt();

  bool get hasPreviousPage => currentPage.value > 1;

  bool get hasNextPage => currentPage.value < totalPages.value;

  List<int> get pageNumbers {
    List<int> pages = [];
    for (int i = 1; i <= totalPages.value; i++) {
      pages.add(i);
    }
    return pages;
  }

  /// Fetch wastes from API
  Future<void> fetchWastes({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final response = await _wasteService.getWastes(
        page: currentPage.value,
        limit: itemsPerPage.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      wastes.value = response.data;
      totalItems.value = response.metadata.total;
      totalPages.value = response.metadata.totalPages;
      currentPage.value = response.metadata.page;
      itemsPerPage.value = response.metadata.limit;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load wastes: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  /// Change page size
  void onPageSizeChanged(int newSize) {
    itemsPerPage.value = newSize;
    currentPage.value = 1;
    fetchWastes();
  }

  /// Go to previous page
  void onPreviousPage() {
    if (hasPreviousPage) {
      currentPage.value--;
      fetchWastes();
    }
  }

  /// Go to next page
  void onNextPage() {
    if (hasNextPage) {
      currentPage.value++;
      fetchWastes();
    }
  }

  /// Go to specific page
  void onPageSelected(int page) {
    if (page != currentPage.value && page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchWastes();
    }
  }

  /// Handle search
  void onSearch(String query) {
    searchQuery.value = query;
    currentPage.value = 1; // Reset to first page when searching
    fetchWastes();
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    fetchWastes();
  }

  /// Refresh data
  Future<void> refreshData() async {
    currentPage.value = 1;
    await fetchWastes(showLoading: false);
  }

  /// Delete waste record
  Future<void> deleteWaste(String id) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this waste record?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isLoading.value = true;

        await _wasteService.deleteWaste(id);

        Get.snackbar(
          'Success',
          'Waste record deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        await fetchWastes();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete waste: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Format currency
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  /// Format date
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Get reason label
  String getReasonLabel(String reason) {
    switch (reason) {
      case 'EXPIRED':
        return 'Expired';
      case 'DAMAGED':
        return 'Damaged';
      case 'CUSTOMER_RETURN':
        return 'Customer Return';
      case 'OTHER':
        return 'Other';
      default:
        return reason;
    }
  }
}
