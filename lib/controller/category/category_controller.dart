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

  // Loading states for CRUD operations
  var isCreating = false.obs;
  var isUpdating = false.obs;
  var isDeleting = false.obs;

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

  // Form controllers for create/edit
  final TextEditingController nameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  var isActiveForm = true.obs;

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
    nameController.dispose();
    positionController.dispose();
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
      _showErrorSnackbar('Gagal memuat data kategori', e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Creates a new category
  Future<bool> createCategory({
    required String name,
    bool isActive = true,
    int? position,
    String? storeId,
  }) async {
    try {
      isCreating(true);
      errorMessage('');

      final newCategory = await _categoryService.createCategory(
        name: name,
        isActive: isActive,
        position: position,
        storeId: storeId,
      );

      // Refresh the list to show the new category
      await loadCategories(showLoading: false);

      _showSuccessSnackbar('Berhasil', 'Kategori "$name" berhasil dibuat');
      return true;
    } catch (e) {
      errorMessage(e.toString());
      _showErrorSnackbar('Gagal membuat kategori', e.toString());
      return false;
    } finally {
      isCreating(false);
    }
  }

  /// Updates an existing category
  Future<bool> updateCategory(
    String id, {
    String? name,
    bool? isActive,
    int? position,
    String? storeId,
  }) async {
    try {
      isUpdating(true);
      errorMessage('');

      final updatedCategory = await _categoryService.updateCategory(
        id,
        name: name,
        isActive: isActive,
        position: position,
        storeId: storeId,
      );

      // Update the category in the local list
      final index = categories.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        categories[index] = updatedCategory;
        categories.refresh();
      }

      _showSuccessSnackbar('Berhasil', 'Kategori berhasil diperbarui');
      return true;
    } catch (e) {
      errorMessage(e.toString());
      _showErrorSnackbar('Gagal memperbarui kategori', e.toString());
      return false;
    } finally {
      isUpdating(false);
    }
  }

  /// Deletes a category
  Future<bool> deleteCategory(String id, {String? storeId}) async {
    try {
      isDeleting(true);
      errorMessage('');

      final success =
          await _categoryService.deleteCategory(id, storeId: storeId);

      if (success) {
        // Remove from local list
        categories.removeWhere((cat) => cat.id == id);

        // Adjust pagination if needed
        if (categories.isEmpty && currentPage.value > 1) {
          currentPage.value = currentPage.value - 1;
          await loadCategories(showLoading: false);
        } else {
          // Update totals
          totalItems.value = totalItems.value - 1;
          if (totalItems.value > 0) {
            totalPages.value = (totalItems.value / itemsPerPage.value).ceil();
          }
        }

        _showSuccessSnackbar('Berhasil', 'Kategori berhasil dihapus');
        return true;
      } else {
        _showErrorSnackbar(
            'Gagal menghapus kategori', 'Terjadi kesalahan saat menghapus');
        return false;
      }
    } catch (e) {
      errorMessage(e.toString());
      _showErrorSnackbar('Gagal menghapus kategori', e.toString());
      return false;
    } finally {
      isDeleting(false);
    }
  }

  /// Shows confirmation dialog before deleting
  Future<void> confirmDelete(Category category) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
            'Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result == true) {
      await deleteCategory(category.id);
    }
  }

  /// Prepares form for creating new category
  void prepareCreateForm() {
    nameController.clear();
    positionController.clear();
    isActiveForm.value = true;
  }

  /// Prepares form for editing existing category
  void prepareEditForm(Category category) {
    nameController.text = category.name;
    positionController.text = category.position?.toString() ?? '';
    isActiveForm.value = category.isActive;
  }

  /// Submits create form
  Future<void> submitCreateForm() async {
    if (_validateForm()) {
      final success = await createCategory(
        name: nameController.text.trim(),
        isActive: isActiveForm.value,
        position: _parsePosition(),
      );

      if (success) {
        Get.back(); // Close dialog/form
        prepareCreateForm(); // Reset form
      }
    }
  }

  /// Submits edit form
  Future<void> submitEditForm(String categoryId) async {
    if (_validateForm()) {
      final success = await updateCategory(
        categoryId,
        name: nameController.text.trim(),
        isActive: isActiveForm.value,
        position: _parsePosition(),
      );

      if (success) {
        Get.back(); // Close dialog/form
      }
    }
  }

  /// Validates form inputs
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackbar('Validasi Error', 'Nama kategori tidak boleh kosong');
      return false;
    }
    return true;
  }

  /// Parses position from text controller
  int? _parsePosition() {
    final text = positionController.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  /// Gets a single category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      return await _categoryService.getCategoryById(id);
    } catch (e) {
      _showErrorSnackbar('Gagal memuat kategori', e.toString());
      return null;
    }
  }

  // Pagination and filter methods (unchanged)
  void onPageChanged(int page) {
    currentPage.value = page;
    loadCategories();
  }

  void onPageSizeChanged(int size) {
    itemsPerPage.value = size;
    currentPage.value = 1;
    loadCategories();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    loadCategories();
  }

  void onStatusFilterChanged(String status) {
    statusFilter.value = status;
    currentPage.value = 1;
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

  // Pagination helper methods (unchanged)
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
      for (int i = 1; i <= totalPages.value; i++) {
        pages.add(i);
      }
    } else {
      int start = (currentPage.value - (maxVisiblePages ~/ 2))
          .clamp(1, totalPages.value);
      int end = (start + maxVisiblePages - 1).clamp(1, totalPages.value);

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

  // Helper methods (unchanged)
  int getProductCount(Category category) {
    return category.products.length;
  }

  String getStatusText(bool isActive) {
    return isActive ? 'AKTIF' : 'TIDAK AKTIF';
  }

  Color getStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.red;
  }

  // Private helper methods for notifications
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }
}
