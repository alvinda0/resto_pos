// controllers/redemption_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/redemption/redemption_model.dart';
import 'package:pos/services/redemption/redemption_service.dart';

class RedemptionController extends GetxController {
  final RedemptionService _redemptionService = RedemptionService.instance;

  // Observable variables
  final RxList<Redemption> redemptions = <Redemption>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString error = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final List<int> availablePageSizes = [5, 10, 25, 50, 100];

  // Filter variables
  final RxString statusFilter = ''.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // Selection variables
  final RxList<String> selectedRedemptionIds = <String>[].obs;
  final RxBool isSelectAll = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRedemptions();
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
  int get endIndex =>
      (currentPage.value * itemsPerPage.value).clamp(0, totalItems.value);
  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => currentPage.value < totalPages.value;

  List<int> get pageNumbers {
    if (totalPages.value <= 1) return [1];

    List<int> pages = [];
    for (int i = 1; i <= totalPages.value; i++) {
      pages.add(i);
    }
    return pages;
  }

  /// Fetch redemptions with current filters and pagination
  Future<void> fetchRedemptions({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      error.value = '';

      final response = await _redemptionService.getRedemptions(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
      );

      redemptions.value = response.data;
      totalItems.value = response.metadata.total;
      totalPages.value = response.metadata.totalPages;

      // Clear selections when data changes
      selectedRedemptionIds.clear();
      isSelectAll.value = false;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to fetch redemptions: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Search redemptions
  Future<void> searchRedemptions() async {
    if (searchQuery.value.trim().isEmpty) {
      await fetchRedemptions();
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final response = await _redemptionService.searchRedemptions(
        query: searchQuery.value.trim(),
        page: currentPage.value,
        limit: itemsPerPage.value,
      );

      redemptions.value = response.data;
      totalItems.value = response.metadata.total;
      totalPages.value = response.metadata.totalPages;

      selectedRedemptionIds.clear();
      isSelectAll.value = false;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to search redemptions: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update redemption status
  Future<void> updateRedemptionStatus(
      String redemptionId, RedemptionStatus status) async {
    try {
      isUpdating.value = true;

      final success =
          await _redemptionService.updateRedemptionStatus(redemptionId, status);

      if (success) {
        // Update local data
        final index = redemptions.indexWhere((r) => r.id == redemptionId);
        if (index != -1) {
          redemptions[index] = redemptions[index].copyWith(
            status: status,
            updatedAt: DateTime.now(),
          );
        }

        Get.snackbar(
          'Success',
          'Redemption status updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update redemption status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Bulk update redemption status
  Future<void> bulkUpdateRedemptionStatus(RedemptionStatus status) async {
    if (selectedRedemptionIds.isEmpty) {
      Get.snackbar(
        'Warning',
        'Please select redemptions to update',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isUpdating.value = true;

      final success = await _redemptionService.bulkUpdateRedemptionStatus(
        selectedRedemptionIds.toList(),
        status,
      );

      if (success) {
        // Update local data
        for (String id in selectedRedemptionIds) {
          final index = redemptions.indexWhere((r) => r.id == id);
          if (index != -1) {
            redemptions[index] = redemptions[index].copyWith(
              status: status,
              updatedAt: DateTime.now(),
            );
          }
        }

        selectedRedemptionIds.clear();
        isSelectAll.value = false;

        Get.snackbar(
          'Success',
          'Redemption status updated successfully for ${selectedRedemptionIds.length} items',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to bulk update redemption status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Pagination methods
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      currentPage.value = page;
      fetchRedemptions();
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      currentPage.value--;
      fetchRedemptions();
    }
  }

  void nextPage() {
    if (hasNextPage) {
      currentPage.value++;
      fetchRedemptions();
    }
  }

  void changePageSize(int newSize) {
    if (newSize != itemsPerPage.value) {
      itemsPerPage.value = newSize;
      currentPage.value = 1; // Reset to first page
      fetchRedemptions();
    }
  }

  /// Filter methods
  void filterByStatus(String status) {
    if (status != statusFilter.value) {
      statusFilter.value = status;
      currentPage.value = 1; // Reset to first page
      fetchRedemptions();
    }
  }

  void clearFilters() {
    statusFilter.value = '';
    searchQuery.value = '';
    searchController.clear();
    currentPage.value = 1;
    fetchRedemptions();
  }

  /// Selection methods
  void toggleSelection(String redemptionId) {
    if (selectedRedemptionIds.contains(redemptionId)) {
      selectedRedemptionIds.remove(redemptionId);
    } else {
      selectedRedemptionIds.add(redemptionId);
    }

    // Update select all state
    isSelectAll.value = selectedRedemptionIds.length == redemptions.length;
  }

  void toggleSelectAll() {
    if (isSelectAll.value) {
      selectedRedemptionIds.clear();
      isSelectAll.value = false;
    } else {
      selectedRedemptionIds.clear();
      selectedRedemptionIds.addAll(redemptions.map((r) => r.id));
      isSelectAll.value = true;
    }
  }

  void clearSelection() {
    selectedRedemptionIds.clear();
    isSelectAll.value = false;
  }

  /// Search methods
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void performSearch() {
    currentPage.value = 1; // Reset to first page
    searchRedemptions();
  }

  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
    currentPage.value = 1;
    fetchRedemptions();
  }

  /// Refresh data
  Future<void> refreshData() async {
    currentPage.value = 1;
    await fetchRedemptions();
  }

  /// Show status update dialog
  void showStatusUpdateDialog(
      String redemptionId, RedemptionStatus currentStatus) {
    Get.dialog(
      AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RedemptionStatus.values.map((status) {
            return RadioListTile<RedemptionStatus>(
              title: Text(status.displayName),
              value: status,
              groupValue: currentStatus,
              onChanged: (RedemptionStatus? value) {
                if (value != null) {
                  Get.back();
                  updateRedemptionStatus(redemptionId, value);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
