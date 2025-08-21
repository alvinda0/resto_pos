import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/role/role_model.dart';
import 'package:pos/services/role/role_service.dart';

class RoleController extends GetxController {
  final RoleService _roleService = RoleService();

  // Observable variables
  final RxList<Role> roles = <Role>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxBool hasNextPage = false.obs;
  final RxBool hasPreviousPage = false.obs;

  // Available page sizes
  final List<int> availablePageSizes = [5, 10, 20, 50, 100];

  // Text controller untuk search
  final TextEditingController searchController = TextEditingController();

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  // Timer untuk debounce search
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    loadRoles();

    // Setup search listener dengan debounce
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    positionController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (searchQuery.value != searchController.text) {
        searchQuery.value = searchController.text;
        onSearchChanged(searchController.text);
      }
    });
  }

  /// Load roles dengan pagination
  Future<void> loadRoles({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      error.value = '';

      final response = await _roleService.getRoles(
        page: currentPage.value,
        limit: itemsPerPage.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (response.success) {
        roles.value = response.data;
        totalItems.value = response.metadata.total;
        totalPages.value = response.metadata.totalPages;

        // Update pagination status
        _updatePaginationStatus();
      } else {
        error.value = response.message;
      }
    } catch (e) {
      error.value = 'Terjadi kesalahan saat memuat data role: $e';
      roles.clear();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Refresh data
  Future<void> refreshRoles() async {
    currentPage.value = 1;
    await loadRoles();
  }

  /// Search roles
  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    loadRoles();
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    loadRoles();
  }

  /// Change page size
  void onPageSizeChanged(int newSize) {
    if (itemsPerPage.value != newSize) {
      itemsPerPage.value = newSize;
      currentPage.value = 1;
      loadRoles();
    }
  }

  /// Go to previous page
  void onPreviousPage() {
    if (hasPreviousPage.value && currentPage.value > 1) {
      currentPage.value--;
      loadRoles();
    }
  }

  /// Go to next page
  void onNextPage() {
    if (hasNextPage.value && currentPage.value < totalPages.value) {
      currentPage.value++;
      loadRoles();
    }
  }

  /// Go to specific page
  void onPageSelected(int page) {
    if (page != currentPage.value && page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadRoles();
    }
  }

  /// Update pagination status
  void _updatePaginationStatus() {
    hasPreviousPage.value = currentPage.value > 1;
    hasNextPage.value = currentPage.value < totalPages.value;
  }

  /// Get page numbers untuk pagination widget
  List<int> get pageNumbers {
    List<int> pages = [];

    if (totalPages.value <= 7) {
      // Jika total halaman <= 7, tampilkan semua
      for (int i = 1; i <= totalPages.value; i++) {
        pages.add(i);
      }
    } else {
      // Logic untuk pagination dengan ellipsis
      if (currentPage.value <= 4) {
        // Halaman awal
        pages = [1, 2, 3, 4, 5];
      } else if (currentPage.value >= totalPages.value - 3) {
        // Halaman akhir
        for (int i = totalPages.value - 4; i <= totalPages.value; i++) {
          pages.add(i);
        }
      } else {
        // Halaman tengah
        for (int i = currentPage.value - 2; i <= currentPage.value + 2; i++) {
          pages.add(i);
        }
      }
    }

    return pages;
  }

  /// Get start index untuk display
  int get startIndex {
    if (totalItems.value == 0) return 0;
    return ((currentPage.value - 1) * itemsPerPage.value) + 1;
  }

  /// Get end index untuk display
  int get endIndex {
    final end = currentPage.value * itemsPerPage.value;
    return end > totalItems.value ? totalItems.value : end;
  }

  /// Get role by ID
  Future<Role?> getRoleById(String roleId) async {
    try {
      return await _roleService.getRoleById(roleId);
    } catch (e) {
      error.value = 'Terjadi kesalahan saat memuat detail role: $e';
      return null;
    }
  }

  /// Create new role
  Future<bool> createRole({
    required String name,
    required String description,
    int? position,
    List<String>? permissionIds,
  }) async {
    try {
      isSubmitting.value = true;
      error.value = '';

      final response = await _roleService.createRole(
        name: name,
        description: description,
        position: position,
        permissionIds: permissionIds,
      );

      if (response.success) {
        showSuccessMessage(response.message);
        await refreshRoles(); // Refresh the list after creating
        return true;
      } else {
        showErrorMessage(response.message);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Gagal membuat role: $e';
      error.value = errorMessage;
      showErrorMessage(errorMessage);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update existing role
  Future<bool> updateRole({
    required String roleId,
    required String name,
    required String description,
    int? position,
    List<String>? permissionIds,
  }) async {
    try {
      isSubmitting.value = true;
      error.value = '';

      final response = await _roleService.updateRole(
        roleId: roleId,
        name: name,
        description: description,
        position: position,
        permissionIds: permissionIds,
      );

      if (response.success) {
        showSuccessMessage(response.message);
        await refreshRoles(); // Refresh the list after updating
        return true;
      } else {
        showErrorMessage(response.message);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Gagal mengupdate role: $e';
      error.value = errorMessage;
      showErrorMessage(errorMessage);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete role
  Future<bool> deleteRole(String roleId) async {
    try {
      isSubmitting.value = true;
      error.value = '';

      final response = await _roleService.deleteRole(roleId);

      if (response.success) {
        showSuccessMessage(response.message);
        await refreshRoles(); // Refresh the list after deleting
        return true;
      } else {
        showErrorMessage(response.message);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Gagal menghapus role: $e';
      error.value = errorMessage;
      showErrorMessage(errorMessage);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Reset form controllers
  void resetForm() {
    nameController.clear();
    descriptionController.clear();
    positionController.clear();
    error.value = '';
  }

  /// Validate form
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama role tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama role minimal 3 karakter';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi tidak boleh kosong';
    }
    if (value.trim().length < 10) {
      return 'Deskripsi minimal 10 karakter';
    }
    return null;
  }

  String? validatePosition(String? value) {
    if (value != null && value.isNotEmpty) {
      final position = int.tryParse(value);
      if (position == null) {
        return 'Posisi harus berupa angka';
      }
      if (position < 1 || position > 1000) {
        return 'Posisi harus antara 1-1000';
      }
    }
    return null;
  }

  /// Show success message
  void showSuccessMessage(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show error message
  void showErrorMessage(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
