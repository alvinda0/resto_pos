// controllers/category_controller.dart
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

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final RxBool isActive = true.obs;
  final RxInt position = 1.obs;

  // Selected category for operations
  final Rxn<Category> selectedCategory = Rxn<Category>();

  @override
  void onInit() {
    super.onInit();
    print('🎯 CategoryController initialized');
    loadCategories();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  // Load all categories
  Future<void> loadCategories({String? storeId}) async {
    try {
      print('🔄 Loading categories...');
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _categoryService.getCategories(storeId: storeId);

      print(
          '📊 Load categories response: success=${response.success}, message=${response.message}');

      // Fix: Check if we have data even if success is false
      if (response.data != null && response.data!.categories.isNotEmpty) {
        categories.value = response.data!.categories;
        print('✅ Categories loaded successfully: ${categories.length} items');

        // Debug: Print first few categories
        if (categories.isNotEmpty) {
          print('📋 First category: ${categories.first.name}');
        }
      } else if (response.success && response.data != null) {
        categories.value = response.data!.categories;
        print('✅ Categories loaded successfully: ${categories.length} items');
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Failed to load categories';
        errorMessage.value = errorMsg;
        print('❌ Load categories failed: $errorMsg');

        _showErrorSnackbar('Load Categories Failed', errorMsg);
      }
    } catch (e, stackTrace) {
      final errorMsg = 'Error loading categories: $e';
      errorMessage.value = errorMsg;
      print('💥 Exception in loadCategories: $e');
      print('📍 Stack trace: $stackTrace');

      _showErrorSnackbar('Load Categories Error', errorMsg);
    } finally {
      isLoading.value = false;
      print('🏁 Load categories completed');
    }
  }

  // Create new category
  Future<void> createCategory({String? storeId}) async {
    if (!_validateForm()) return;

    try {
      print('🔄 Creating category: ${nameController.text}');
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

      print('📊 Create category response: success=${response.success}');

      if (response.success && response.data != null) {
        categories.add(response.data!);
        _resetForm();
        print('✅ Category created successfully: ${response.data!.name}');

        _showSuccessSnackbar('Success', 'Category created successfully');
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Failed to create category';
        errorMessage.value = errorMsg;
        print('❌ Create category failed: $errorMsg');

        _showErrorSnackbar('Create Category Failed', errorMsg);
      }
    } catch (e, stackTrace) {
      final errorMsg = 'Error creating category: $e';
      errorMessage.value = errorMsg;
      print('💥 Exception in createCategory: $e');
      print('📍 Stack trace: $stackTrace');

      _showErrorSnackbar('Create Category Error', errorMsg);
    } finally {
      isCreating.value = false;
      print('🏁 Create category completed');
    }
  }

  // Update category
  Future<void> updateCategory({String? storeId}) async {
    if (selectedCategory.value == null || !_validateForm()) return;

    try {
      print('🔄 Updating category: ${selectedCategory.value!.id}');
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

      print('📊 Update category response: success=${response.success}');

      if (response.success && response.data != null) {
        final index = categories
            .indexWhere((cat) => cat.id == selectedCategory.value!.id);
        if (index != -1) {
          categories[index] = response.data!;
          print('✅ Category updated successfully at index: $index');
        } else {
          print('⚠️ Warning: Category not found in list for update');
        }

        _resetForm();
        _showSuccessSnackbar('Success', 'Category updated successfully');
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Failed to update category';
        errorMessage.value = errorMsg;
        print('❌ Update category failed: $errorMsg');

        _showErrorSnackbar('Update Category Failed', errorMsg);
      }
    } catch (e, stackTrace) {
      final errorMsg = 'Error updating category: $e';
      errorMessage.value = errorMsg;
      print('💥 Exception in updateCategory: $e');
      print('📍 Stack trace: $stackTrace');

      _showErrorSnackbar('Update Category Error', errorMsg);
    } finally {
      isUpdating.value = false;
      print('🏁 Update category completed');
    }
  }

  // Delete category
  Future<void> deleteCategory(String categoryId, {String? storeId}) async {
    try {
      print('🔄 Deleting category: $categoryId');
      isDeleting.value = true;
      errorMessage.value = '';

      final response = await _categoryService.deleteCategory(
        categoryId: categoryId,
        storeId: storeId,
      );

      print('📊 Delete category response: success=${response.success}');

      if (response.success) {
        final removedCount = categories.length;
        categories.removeWhere((cat) => cat.id == categoryId);
        print(
            '✅ Category deleted successfully. Removed: ${removedCount - categories.length} items');

        _showSuccessSnackbar('Success', 'Category deleted successfully');
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Failed to delete category';
        errorMessage.value = errorMsg;
        print('❌ Delete category failed: $errorMsg');

        _showErrorSnackbar('Delete Category Failed', errorMsg);
      }
    } catch (e, stackTrace) {
      final errorMsg = 'Error deleting category: $e';
      errorMessage.value = errorMsg;
      print('💥 Exception in deleteCategory: $e');
      print('📍 Stack trace: $stackTrace');

      _showErrorSnackbar('Delete Category Error', errorMsg);
    } finally {
      isDeleting.value = false;
      print('🏁 Delete category completed');
    }
  }

  // Toggle category active status
  Future<void> toggleCategoryStatus(String categoryId, bool newStatus,
      {String? storeId}) async {
    try {
      print('🔄 Toggling category status: $categoryId -> $newStatus');

      final response = await _categoryService.toggleCategoryStatus(
        categoryId: categoryId,
        isActive: newStatus,
        storeId: storeId,
      );

      print('📊 Toggle status response: success=${response.success}');

      if (response.success && response.data != null) {
        final index = categories.indexWhere((cat) => cat.id == categoryId);
        if (index != -1) {
          categories[index] = response.data!;
          print('✅ Category status toggled successfully at index: $index');
        } else {
          print('⚠️ Warning: Category not found in list for status toggle');
        }

        _showSuccessSnackbar('Success', 'Category status updated successfully');
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Failed to toggle category status';
        print('❌ Toggle status failed: $errorMsg');

        _showErrorSnackbar('Toggle Status Failed', errorMsg);
      }
    } catch (e, stackTrace) {
      final errorMsg = 'Error toggling category status: $e';
      print('💥 Exception in toggleCategoryStatus: $e');
      print('📍 Stack trace: $stackTrace');

      _showErrorSnackbar('Toggle Status Error', errorMsg);
    }
  }

  // Show delete confirmation dialog
  Future<void> showDeleteConfirmation(Category category,
      {String? storeId}) async {
    print('🗑️ Showing delete confirmation for: ${category.name}');

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
    print('📝 Preparing form for edit: ${category.name}');

    selectedCategory.value = category;
    nameController.text = category.name;
    isActive.value = category.isActive;
    position.value = category.position;

    print('✅ Form prepared for editing');
  }

  // Reset form
  void _resetForm() {
    print('🔄 Resetting form');

    nameController.clear();
    isActive.value = true;
    position.value = 1;
    selectedCategory.value = null;
    errorMessage.value = '';

    print('✅ Form reset completed');
  }

  // Validate form
  bool _validateForm() {
    print('🔍 Validating form...');

    if (nameController.text.trim().isEmpty) {
      errorMessage.value = 'Category name is required';
      print('❌ Validation failed: Category name is required');

      _showWarningSnackbar('Validation Error', 'Category name is required');
      return false;
    }

    if (position.value < 1) {
      errorMessage.value = 'Position must be greater than 0';
      print('❌ Validation failed: Position must be greater than 0');

      _showWarningSnackbar(
          'Validation Error', 'Position must be greater than 0');
      return false;
    }

    print('✅ Form validation passed');
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

  // Get categories by status
  List<Category> getCategoriesByStatus(bool isActive) {
    final filtered =
        categories.where((cat) => cat.isActive == isActive).toList();
    print('📊 Categories by status ($isActive): ${filtered.length}');
    return filtered;
  }

  // Get active categories
  List<Category> get activeCategories => getCategoriesByStatus(true);

  // Get inactive categories
  List<Category> get inactiveCategories => getCategoriesByStatus(false);

  // Sort categories by position
  List<Category> get sortedCategories {
    final sortedList = List<Category>.from(categories);
    sortedList.sort((a, b) => a.position.compareTo(b.position));
    print('📊 Categories sorted by position: ${sortedList.length}');
    return sortedList;
  }

  // Get category by ID
  Category? getCategoryById(String id) {
    try {
      final category = categories.firstWhere((cat) => cat.id == id);
      print('🔍 Category found by ID ($id): ${category.name}');
      return category;
    } catch (e) {
      print('❌ Category not found by ID: $id');
      return null;
    }
  }

  // Refresh categories
  Future<void> refreshCategories({String? storeId}) async {
    print('🔄 Refreshing categories...');
    await loadCategories(storeId: storeId);
  }

  // Debug method to print current state
  void debugPrintState() {
    print('🐛 CategoryController Debug State:');
    print('   - Categories count: ${categories.length}');
    print('   - Is loading: ${isLoading.value}');
    print('   - Is creating: ${isCreating.value}');
    print('   - Is updating: ${isUpdating.value}');
    print('   - Is deleting: ${isDeleting.value}');
    print('   - Error message: ${errorMessage.value}');
    print('   - Selected category: ${selectedCategory.value?.name ?? 'None'}');
  }
}
