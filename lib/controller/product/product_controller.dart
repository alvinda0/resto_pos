// controllers/product/product_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/product/product_model.dart';
import 'package:pos/services/product/product_service.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService.instance;

  // Observable variables
  final RxList<Product> products = <Product>[].obs;
  final RxList<ProductCategory> categories = <ProductCategory>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString error = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxInt itemsPerPage = 12.obs;
  final RxList<int> availablePageSizes = <int>[12, 24, 48].obs;

  // Filter variables
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadCategories();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Load products with pagination
  Future<void> loadProducts({bool refresh = false}) async {
    try {
      if (isLoading.value && !refresh) return; // Prevent multiple calls

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
      print(
          'Error loading products: $e'); // Use print instead of snackbar in init
    } finally {
      isLoading.value = false;
    }
  }

  // Load categories for dropdown
  Future<void> loadCategories() async {
    try {
      final categoryList = await _productService.getCategories();
      categories.assignAll(categoryList);
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  // Create new product
  Future<bool> createProduct({
    required String name,
    required String description,
    required int basePrice,
    required String categoryId,
    required bool isAvailable,
    required int position,
    String? recipeId,
    File? imageFile,
  }) async {
    try {
      isSaving.value = true;

      final response = await _productService.createProduct(
        name: name,
        description: description,
        basePrice: basePrice,
        categoryId: categoryId,
        isAvailable: isAvailable,
        position: position,
        recipeId: recipeId,
        imageFile: imageFile,
      );

      if (response.success) {
        _showSuccessSnackbar('Product created successfully');
        await refreshProducts();
        return true;
      } else {
        _showErrorSnackbar('Failed to create product: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error creating product: ${e.toString()}');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Update product
  Future<bool> updateProduct({
    required String id,
    required String name,
    required String description,
    required int basePrice,
    required String categoryId,
    required bool isAvailable,
    required int position,
    String? recipeId,
    File? imageFile,
  }) async {
    try {
      isSaving.value = true;

      final response = await _productService.updateProduct(
        id: id,
        name: name,
        description: description,
        basePrice: basePrice,
        categoryId: categoryId,
        isAvailable: isAvailable,
        position: position,
        recipeId: recipeId,
        imageFile: imageFile,
      );

      if (response.success) {
        _showSuccessSnackbar('Product updated successfully');
        await refreshProducts();
        return true;
      } else {
        _showErrorSnackbar('Failed to update product: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error updating product: ${e.toString()}');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    try {
      isDeleting.value = true;

      final success = await _productService.deleteProduct(id);

      if (success) {
        _showSuccessSnackbar('Product deleted successfully');
        await refreshProducts();
        return true;
      } else {
        _showErrorSnackbar('Failed to delete product');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error deleting product: ${e.toString()}');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final product = await _productService.getProductById(id);
      return product;
    } catch (e) {
      _showErrorSnackbar('Error loading product: ${e.toString()}');
      return null;
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
    currentPage.value = 1;
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
      if (total > 5) pages.addAll([0, total]);
    } else if (current >= total - 3) {
      pages = [1, 0];
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

  // Helper methods for showing notifications
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      icon: Icon(Icons.check_circle, color: Colors.green.shade800),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      icon: Icon(Icons.error, color: Colors.red.shade800),
    );
  }
}
