import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/debt/debt_model.dart';
import 'package:pos/services/debt/debt_service.dart';

class DebtController extends GetxController {
  final DebtService _debtService = DebtService.instance;

  // Observable variables
  var isLoading = false.obs;
  var debts = <Debt>[].obs;
  var filteredDebts = <Debt>[].obs;

  // Pagination
  var currentPage = 1.obs;
  var itemsPerPage = 10.obs;
  var totalItems = 0.obs;
  var availablePageSizes = [5, 10, 25, 50].obs;

  // Search and filter
  var searchQuery = ''.obs;
  var statusFilter = 'ALL'.obs;
  final TextEditingController searchController = TextEditingController();

  // Error handling
  var errorMessage = ''.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDebts();

    // Listen to search changes with debounce
    debounce(searchQuery, (_) => _performSearch(),
        time: Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Computed properties for pagination
  int get totalPages => (totalItems.value / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value + 1;
  int get endIndex =>
      (currentPage.value * itemsPerPage.value).clamp(0, totalItems.value);
  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => currentPage.value < totalPages;

  List<int> get pageNumbers {
    List<int> pages = [];
    for (int i = 1; i <= totalPages; i++) {
      pages.add(i);
    }
    return pages;
  }

  // Get displayed debts for current page
  List<Debt> get displayedDebts {
    final start = (currentPage.value - 1) * itemsPerPage.value;
    final end = start + itemsPerPage.value;
    return filteredDebts.take(end).skip(start).toList();
  }

  /// Load debts from API
  Future<void> loadDebts({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _debtService.getDebts(
        page: currentPage.value,
        limit: 1000, // Load all data for local pagination
        status: statusFilter.value == 'ALL' ? null : statusFilter.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (response.success) {
        debts.value = response.data;
        _applyFilters();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load debts: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  /// Apply search and filter to debts
  void _applyFilters() {
    List<Debt> filtered = List.from(debts);

    // Apply status filter
    if (statusFilter.value != 'ALL') {
      if (statusFilter.value == 'PAID') {
        filtered = filtered.where((debt) => debt.isPaid).toList();
      } else if (statusFilter.value == 'UNPAID') {
        filtered = filtered.where((debt) => debt.isUnpaid).toList();
      } else if (statusFilter.value == 'OVERDUE') {
        filtered = filtered.where((debt) => debt.isOverdue).toList();
      }
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((debt) {
        return debt.inventoryName.toLowerCase().contains(query) ||
            debt.vendorName.toLowerCase().contains(query);
      }).toList();
    }

    filteredDebts.value = filtered;
    totalItems.value = filtered.length;

    // Reset to first page if current page is out of bounds
    if (currentPage.value > totalPages && totalPages > 0) {
      currentPage.value = 1;
    }
  }

  /// Search debts
  void searchDebts(String query) {
    searchQuery.value = query;
  }

  void _performSearch() {
    currentPage.value = 1;
    _applyFilters();
  }

  /// Filter debts by status
  void filterByStatus(String status) {
    statusFilter.value = status;
    currentPage.value = 1;
    _applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    searchController.clear();
    statusFilter.value = 'ALL';
    currentPage.value = 1;
    _applyFilters();
  }

  /// Pagination methods
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void goToPreviousPage() {
    if (hasPreviousPage) {
      currentPage.value--;
    }
  }

  void goToNextPage() {
    if (hasNextPage) {
      currentPage.value++;
    }
  }

  void changePageSize(int newSize) {
    itemsPerPage.value = newSize;
    currentPage.value = 1;
  }

  /// Update debt
  Future<void> updateDebt(Debt debt) async {
    try {
      isLoading.value = true;

      final response = await _debtService.updateDebt(debt.id, debt);

      if (response.success && response.data != null) {
        // Update the debt in the list
        final index = debts.indexWhere((d) => d.id == debt.id);
        if (index != -1) {
          debts[index] = response.data!;
          _applyFilters();
        }

        Get.snackbar(
          'Success',
          'Debt updated successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update debt: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete debt
  Future<void> deleteDebt(String debtId) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this debt?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isLoading.value = true;

      final response = await _debtService.deleteDebt(debtId);

      if (response['success'] == true) {
        // Remove the debt from the list
        debts.removeWhere((debt) => debt.id == debtId);
        _applyFilters();

        Get.snackbar(
          'Success',
          'Debt deleted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete debt: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle payment status
  Future<void> togglePaymentStatus(Debt debt) async {
    try {
      isLoading.value = true;

      DebtSingleResponse response;
      if (debt.isPaid) {
        response = await _debtService.markAsUnpaid(debt.id);
      } else {
        response = await _debtService.markAsPaid(debt.id);
      }

      if (response.success && response.data != null) {
        // Update the debt in the list
        final index = debts.indexWhere((d) => d.id == debt.id);
        if (index != -1) {
          debts[index] = response.data!;
          _applyFilters();
        }

        Get.snackbar(
          'Success',
          'Payment status updated successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update payment status: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadDebts(showLoading: true);
  }

  /// Get status color
  Color getStatusColor(Debt debt) {
    if (debt.isPaid) return Colors.green;
    if (debt.isOverdue) return Colors.red;
    return Colors.orange;
  }

  /// Get status text
  String getStatusText(Debt debt) {
    if (debt.isPaid) return 'PAID';
    if (debt.isOverdue) return 'OVERDUE';
    return 'UNPAID';
  }
}
