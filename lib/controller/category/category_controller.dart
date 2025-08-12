import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/category/category_model.dart';
import 'package:pos/services/category/category_service.dart';

class CategoryController extends GetxController {
  final CategoryService _categoryService = CategoryService();

  // Observable variables
  var categories = <Category>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Pagination variables
  var currentPage = 1.obs;
  var itemsPerPage = 10.obs;
  var totalItems = 0.obs;
  var totalPages = 0.obs;
  var availablePageSizes = [5, 10, 20, 50].obs;

  // Filter variables
  var searchQuery = ''.obs;
  var statusFilter = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // Status filter options
  var statusOptions = [
    {'value': '', 'label': 'Semua Status'},
    {'value': 'active', 'label': 'Aktif'},
    {'value': 'inactive', 'label': 'Tidak Aktif'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadCategories({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading(true);
      }
      errorMessage('');

      final response = await _categoryService.getCategories(
        page: currentPage.value,
        limit: itemsPerPage.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
      );

      categories.value = response.data;
      totalItems.value = response.metadata.total;
      totalPages.value = response.metadata.totalPages;
      currentPage.value = response.metadata.page;
      itemsPerPage.value = response.metadata.limit;
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar(
        'Error',
        'Gagal memuat data kategori: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  void onPageChanged(int page) {
    currentPage.value = page;
    loadCategories();
  }

  void onPageSizeChanged(int size) {
    itemsPerPage.value = size;
    currentPage.value = 1; // Reset to first page when changing page size
    loadCategories();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentPage.value = 1; // Reset to first page when searching
    loadCategories();
  }

  void onStatusFilterChanged(String status) {
    statusFilter.value = status;
    currentPage.value = 1; // Reset to first page when filtering
    loadCategories();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    loadCategories();
  }

  void refreshData() {
    loadCategories(showLoading: false);
  }

  // Pagination helper methods
  bool get hasPreviousPage => currentPage.value > 1;

  bool get hasNextPage => currentPage.value < totalPages.value;

  int get startIndex {
    if (totalItems.value == 0) return 0;
    return ((currentPage.value - 1) * itemsPerPage.value) + 1;
  }

  int get endIndex {
    final end = currentPage.value * itemsPerPage.value;
    return end > totalItems.value ? totalItems.value : end;
  }

  List<int> get pageNumbers {
    if (totalPages.value <= 0) return [];

    const maxVisiblePages = 5;
    final pages = <int>[];

    if (totalPages.value <= maxVisiblePages) {
      // Show all pages if total pages is less than max visible
      for (int i = 1; i <= totalPages.value; i++) {
        pages.add(i);
      }
    } else {
      // Calculate start and end pages
      int start = (currentPage.value - (maxVisiblePages ~/ 2))
          .clamp(1, totalPages.value);
      int end = (start + maxVisiblePages - 1).clamp(1, totalPages.value);

      // Adjust start if end is at maximum
      if (end == totalPages.value) {
        start = (end - maxVisiblePages + 1).clamp(1, totalPages.value);
      }

      for (int i = start; i <= end; i++) {
        pages.add(i);
      }
    }

    return pages;
  }

  void goToPreviousPage() {
    if (hasPreviousPage) {
      onPageChanged(currentPage.value - 1);
    }
  }

  void goToNextPage() {
    if (hasNextPage) {
      onPageChanged(currentPage.value + 1);
    }
  }

  // Helper method to get product count for a category
  int getProductCount(Category category) {
    return category.products.length;
  }

  // Helper method to get status display text
  String getStatusText(bool isActive) {
    return isActive ? 'AKTIF' : 'TIDAK AKTIF';
  }

  // Helper method to get status color
  Color getStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.red;
  }
}
