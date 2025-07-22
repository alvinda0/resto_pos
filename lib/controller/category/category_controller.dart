import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pos/models/category/category_model.dart';
import 'package:pos/services/category/category_service.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find<CategoryController>();

  final CategoryService _categoryService = CategoryService.instance;

  // Observable lists and variables
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final Rxn<PaginationMetadata> paginationMetadata = Rxn<PaginationMetadata>();

  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'Semua'.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final RxBool isActive = true.obs;
  final RxInt position = 1.obs;

  // Selected category for operations
  final Rxn<Category> selectedCategory = Rxn<Category>();

  // Available page sizes
  final List<int> availablePageSizes = [5, 10, 20, 50];

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  // Load categories with pagination
  Future<void> loadCategories({
    String? storeId,
    int? page,
    int? limit,
    String? search,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final response = await _categoryService.getCategories(
        storeId: storeId,
        page: page ?? currentPage.value,
        limit: limit ?? itemsPerPage.value,
        search:
            search ?? (searchQuery.value.isNotEmpty ? searchQuery.value : null),
      );

      if (response.data != null && response.data!.categories.isNotEmpty) {
        categories.value = response.data!.categories;

        // Update pagination metadata
        if (response.metadata != null) {
          paginationMetadata.value = response.metadata!;
          currentPage.value = response.metadata!.page;
          totalItems.value = response.metadata!.total;
          totalPages.value = response.metadata!.totalPages;
        }
      } else if (response.success && response.data != null) {
        categories.value = response.data!.categories;

        // Handle empty results
        if (response.metadata != null) {
          paginationMetadata.value = response.metadata!;
          currentPage.value = response.metadata!.page;
          totalItems.value = response.metadata!.total;
          totalPages.value = response.metadata!.totalPages;
        }
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Failed to load categories';
        errorMessage.value = errorMsg;
        _showErrorSnackbar('Load Categories Failed', errorMsg);
      }
    } catch (e) {
      final errorMsg = 'Error loading categories: $e';
      errorMessage.value = errorMsg;
      _showErrorSnackbar('Load Categories Error', errorMsg);
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  // Navigate to specific page
  Future<void> goToPage(int page, {String? storeId}) async {
    if (page < 1 || page > totalPages.value) return;

    currentPage.value = page;
    await loadCategories(
      storeId: storeId,
      page: page,
      showLoading: false,
    );
  }

  // Go to next page
  Future<void> nextPage({String? storeId}) async {
    if (currentPage.value < totalPages.value) {
      await goToPage(currentPage.value + 1, storeId: storeId);
    }
  }

  // Go to previous page
  Future<void> previousPage({String? storeId}) async {
    if (currentPage.value > 1) {
      await goToPage(currentPage.value - 1, storeId: storeId);
    }
  }

  // Change items per page
  Future<void> changeItemsPerPage(int newLimit, {String? storeId}) async {
    itemsPerPage.value = newLimit;
    currentPage.value = 1; // Reset to first page
    await loadCategories(
      storeId: storeId,
      page: 1,
      limit: newLimit,
    );
  }

  // Search categories
  Future<void> searchCategories(String query, {String? storeId}) async {
    searchQuery.value = query;
    currentPage.value = 1; // Reset to first page
    await loadCategories(
      storeId: storeId,
      page: 1,
      search: query.isNotEmpty ? query : null,
    );
  }

  // Filter categories and reload
  Future<void> filterCategories(String filter, {String? storeId}) async {
    selectedFilter.value = filter;
    currentPage.value = 1; // Reset to first page
    await loadCategories(storeId: storeId, page: 1);
  }

  // Create new category
  Future<void> createCategory({String? storeId}) async {
    if (!_validateForm()) return;

    try {
      isCreating.value = true;
      errorMessage.value = '';

      final categoryRequest = CategoryRequest(
        name: nameController.text.trim(),
        isActive: isActive.value,
        position: position.value,
      );

      final response = await _categoryService.createCategory(
        categoryRequest: categoryRequest,
        storeId: storeId,
      );

      if (response.success && response.data != null) {
        _resetForm();
        _showSuccessSnackbar('Success', 'Category created successfully');

        // Reload current page to reflect changes
        await loadCategories(storeId: storeId, showLoading: false);
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Failed to create category';
        errorMessage.value = errorMsg;
        _showErrorSnackbar('Create Category Failed', errorMsg);
      }
    } catch (e) {
      final errorMsg = 'Error creating category: $e';
      errorMessage.value = errorMsg;
      _showErrorSnackbar('Create Category Error', errorMsg);
    } finally {
      isCreating.value = false;
    }
  }

  // Update category
  Future<void> updateCategory({String? storeId}) async {
    if (selectedCategory.value == null || !_validateForm()) return;

    try {
      isUpdating.value = true;
      errorMessage.value = '';

      final categoryRequest = CategoryRequest(
        name: nameController.text.trim(),
        isActive: isActive.value,
        position: position.value,
      );

      final response = await _categoryService.updateCategory(
        categoryId: selectedCategory.value!.id,
        categoryRequest: categoryRequest,
        storeId: storeId,
      );

      if (response.success && response.data != null) {
        _resetForm();
        _showSuccessSnackbar('Success', 'Category updated successfully');

        // Reload current page to reflect changes
        await loadCategories(storeId: storeId, showLoading: false);
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Failed to update category';
        errorMessage.value = errorMsg;
        _showErrorSnackbar('Update Category Failed', errorMsg);
      }
    } catch (e) {
      final errorMsg = 'Error updating category: $e';
      errorMessage.value = errorMsg;
      _showErrorSnackbar('Update Category Error', errorMsg);
    } finally {
      isUpdating.value = false;
    }
  }

  // Delete category
  Future<void> deleteCategory(String categoryId, {String? storeId}) async {
    try {
      isDeleting.value = true;
      errorMessage.value = '';

      final response = await _categoryService.deleteCategory(
        categoryId: categoryId,
        storeId: storeId,
      );

      if (response.success) {
        _showSuccessSnackbar('Success', 'Category deleted successfully');

        // Reload current page to reflect changes
        await loadCategories(storeId: storeId, showLoading: false);

        // If current page is empty and not the first page, go to previous page
        if (categories.isEmpty && currentPage.value > 1) {
          await previousPage(storeId: storeId);
        }
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Failed to delete category';
        errorMessage.value = errorMsg;
        _showErrorSnackbar('Delete Category Failed', errorMsg);
      }
    } catch (e) {
      final errorMsg = 'Error deleting category: $e';
      errorMessage.value = errorMsg;
      _showErrorSnackbar('Delete Category Error', errorMsg);
    } finally {
      isDeleting.value = false;
    }
  }

  // Toggle category active status
  Future<void> toggleCategoryStatus(String categoryId, bool newStatus,
      {String? storeId}) async {
    try {
      final response = await _categoryService.toggleCategoryStatus(
        categoryId: categoryId,
        isActive: newStatus,
        storeId: storeId,
      );

      if (response.success && response.data != null) {
        _showSuccessSnackbar('Success', 'Category status updated successfully');

        // Reload current page to reflect changes
        await loadCategories(storeId: storeId, showLoading: false);
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Failed to toggle category status';
        _showErrorSnackbar('Toggle Status Failed', errorMsg);
      }
    } catch (e) {
      final errorMsg = 'Error toggling category status: $e';
      _showErrorSnackbar('Toggle Status Error', errorMsg);
    }
  }

  // Show delete confirmation dialog
  Future<void> showDeleteConfirmation(Category category,
      {String? storeId}) async {
    Get.defaultDialog(
      title: 'Delete Category',
      middleText: 'Are you sure you want to delete "${category.name}"?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        deleteCategory(category.id, storeId: storeId);
      },
    );
  }

  // Prepare form for editing
  void prepareForEdit(Category category) {
    selectedCategory.value = category;
    nameController.text = category.name;
    isActive.value = category.isActive;
    position.value = category.position;
  }

  // Reset form
  void _resetForm() {
    nameController.clear();
    isActive.value = true;
    position.value = 1;
    selectedCategory.value = null;
    errorMessage.value = '';
  }

  // Validate form
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      errorMessage.value = 'Category name is required';
      _showWarningSnackbar('Validation Error', 'Category name is required');
      return false;
    }

    if (position.value < 1) {
      errorMessage.value = 'Position must be greater than 0';
      _showWarningSnackbar(
          'Validation Error', 'Position must be greater than 0');
      return false;
    }

    return true;
  }

  // Helper methods for snackbars
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  void _showWarningSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // Get filtered categories based on current filter
  List<Category> getFilteredCategories() {
    List<Category> filteredList = categories;

    // Filter by status
    if (selectedFilter.value == 'Aktif') {
      filteredList =
          filteredList.where((category) => category.isActive).toList();
    } else if (selectedFilter.value == 'Tidak Aktif') {
      filteredList =
          filteredList.where((category) => !category.isActive).toList();
    }

    return filteredList;
  }

  // Get active categories
  List<Category> get activeCategories =>
      categories.where((cat) => cat.isActive).toList();

  // Get inactive categories
  List<Category> get inactiveCategories =>
      categories.where((cat) => !cat.isActive).toList();

  // Get category by ID
  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Refresh categories
  Future<void> refreshCategories({String? storeId}) async {
    currentPage.value = 1;
    searchQuery.value = '';
    selectedFilter.value = 'Semua';
    await loadCategories(storeId: storeId);
  }

  // Get page numbers for pagination UI
  List<int> getPageNumbers() {
    List<int> pages = [];
    int start = (currentPage.value - 2).clamp(1, totalPages.value);
    int end = (start + 4).clamp(1, totalPages.value);

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    return pages;
  }

  // Check if has next page
  bool get hasNextPage => currentPage.value < totalPages.value;

  // Check if has previous page
  bool get hasPreviousPage => currentPage.value > 1;

  // Get start index for current page
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value + 1;

  // Get end index for current page
  int get endIndex =>
      (startIndex + categories.length - 1).clamp(startIndex, totalItems.value);
}
