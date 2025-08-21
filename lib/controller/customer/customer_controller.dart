import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/customer/customer_model.dart';
import 'package:pos/services/customer/customer_service.dart';

class CustomerController extends GetxController {
  final CustomerService _customerService = CustomerService.instance;

  // Observables
  var customers = <Customer>[].obs;
  var isLoading = false.obs;
  var isDeleting = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Pagination properties
  var currentPage = 1.obs;
  var itemsPerPage = 10.obs;
  var totalItems = 0.obs;
  var totalPages = 0.obs;
  var availablePageSizes = [5, 10, 20, 50, 100].obs;

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
    if (totalPages.value <= 7) {
      return List.generate(totalPages.value, (index) => index + 1);
    }

    final current = currentPage.value;
    final total = totalPages.value;

    if (current <= 4) {
      return [1, 2, 3, 4, 5, -1, total]; // -1 represents ellipsis
    } else if (current >= total - 3) {
      return [1, -1, total - 4, total - 3, total - 2, total - 1, total];
    } else {
      return [1, -1, current - 1, current, current + 1, -1, total];
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  /// Fetch customers with pagination
  Future<void> fetchCustomers({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      hasError.value = false;
      errorMessage.value = '';

      final response = await _customerService.getAllCustomers(
        page: currentPage.value,
        limit: itemsPerPage.value,
      );

      customers.value = response.data;
      totalItems.value = response.metadata.total;
      totalPages.value = response.metadata.totalPages;
      currentPage.value = response.metadata.page;
      itemsPerPage.value = response.metadata.limit;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');

      // Show error snackbar
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete customer
  Future<void> deleteCustomer(String customerId, String customerName) async {
    try {
      // Show confirmation dialog
      final confirmed = await _showDeleteConfirmation(customerName);
      if (!confirmed) return;

      isDeleting.value = true;

      await _customerService.deleteCustomer(customerId);

      // Show success message
      Get.snackbar(
        'Success',
        'Customer "$customerName" has been deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      );

      // Refresh the list
      await fetchCustomers(showLoading: false);

      // If current page becomes empty and it's not page 1, go to previous page
      if (customers.isEmpty && currentPage.value > 1) {
        currentPage.value--;
        await fetchCustomers(showLoading: false);
      }
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      Get.snackbar(
        'Delete Failed',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    } finally {
      isDeleting.value = false;
    }
  }

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmation(String customerName) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            Text('Are you sure you want to delete customer "$customerName"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }

  /// Handle page size change
  void onPageSizeChanged(int newPageSize) {
    itemsPerPage.value = newPageSize;
    currentPage.value = 1; // Reset to first page
    fetchCustomers();
  }

  /// Go to previous page
  void onPreviousPage() {
    if (hasPreviousPage) {
      currentPage.value--;
      fetchCustomers();
    }
  }

  /// Go to next page
  void onNextPage() {
    if (hasNextPage) {
      currentPage.value++;
      fetchCustomers();
    }
  }

  /// Go to specific page
  void onPageSelected(int page) {
    if (page != currentPage.value && page > 0 && page <= totalPages.value) {
      currentPage.value = page;
      fetchCustomers();
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    await fetchCustomers();
  }

  /// Search customers (if needed in the future)
  void searchCustomers(String query) {
    // Implementation for search functionality
    // This can be added later if needed
  }

  /// Clear search (if needed in the future)
  void clearSearch() {
    // Implementation to clear search
    // This can be added later if needed
  }
}
