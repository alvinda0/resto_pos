// controllers/product_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/product/product_model.dart';
import 'package:pos/services/product/product_service.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService.instance;

  // Observable variables
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxInt itemsPerPage =
      12.obs; // Default 12 items per page for grid layout
  final RxList<int> availablePageSizes = <int>[12, 24, 48].obs;

  // Filter variables
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Load products with pagination
  Future<void> loadProducts({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        products.clear();
      }

      isLoading.value = true;
      error.value = '';

      final response = await _productService.getProducts(
        page: currentPage.value,
        limit: itemsPerPage.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        category:
            selectedCategory.value.isEmpty ? null : selectedCategory.value,
      );

      if (response.success) {
        if (refresh) {
          products.assignAll(response.data);
        } else {
          products.addAll(response.data);
        }

        totalItems.value = response.metadata.total;
        totalPages.value = response.metadata.totalPages;
      } else {
        error.value = response.message;
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);
  }

  // Search products
  void searchProducts(String query) {
    searchQuery.value = query;
    loadProducts(refresh: true);
  }

  // Filter by category
  void filterByCategory(String category) {
    selectedCategory.value = category;
    loadProducts(refresh: true);
  }

  // Clear filters
  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = '';
    searchController.clear();
    loadProducts(refresh: true);
  }

  // Pagination methods
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      currentPage.value = page;
      loadProducts(refresh: true);
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadProducts(refresh: true);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadProducts(refresh: true);
    }
  }

  void changePageSize(int newSize) {
    itemsPerPage.value = newSize;
    currentPage.value = 1; // Reset to first page
    loadProducts(refresh: true);
  }

  // Getters for pagination
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
    if (totalPages.value <= 7) {
      return List.generate(totalPages.value, (index) => index + 1);
    }

    List<int> pages = [];
    int current = currentPage.value;
    int total = totalPages.value;

    if (current <= 4) {
      pages = [1, 2, 3, 4, 5];
      if (total > 5) pages.addAll([0, total]); // 0 represents "..."
    } else if (current >= total - 3) {
      pages = [1, 0]; // 0 represents "..."
      pages.addAll(List.generate(5, (index) => total - 4 + index));
    } else {
      pages = [1, 0, current - 1, current, current + 1, 0, total];
    }

    return pages;
  }

  // Format currency
  String formatCurrency(int amount) {
    return 'Rp${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }
}
