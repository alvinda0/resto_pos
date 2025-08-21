// controllers/user_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/account/account_model.dart';
import 'package:pos/services/account/account_service.dart';

class UserController extends GetxController {
  final UserService _userService = UserService.instance;

  // Observable variables
  final RxList<User> users = <User>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxList<int> availablePageSizes = [5, 10, 20, 50].obs;

  // Search controller and debounce timer
  final TextEditingController searchController = TextEditingController();
  Timer? _debounceTimer;

  // Form controllers for create/edit user
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RxBool isStaff = false.obs;
  final RxString selectedRoleId = ''.obs;

  // Loading flag to prevent multiple simultaneous requests
  bool _isLoadingData = false;

  // Computed properties for pagination
  int get startIndex => ((currentPage.value - 1) * itemsPerPage.value) + 1;
  int get endIndex {
    final end = currentPage.value * itemsPerPage.value;
    return end > totalItems.value ? totalItems.value : end;
  }

  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => currentPage.value < totalPages.value;

  List<int> get pageNumbers {
    const maxVisiblePages = 5;
    final List<int> pages = [];

    if (totalPages.value == 0) return pages;

    int start =
        (currentPage.value - (maxVisiblePages ~/ 2)).clamp(1, totalPages.value);
    int end = (start + maxVisiblePages - 1).clamp(1, totalPages.value);

    // Adjust start if we're near the end
    if (end - start + 1 < maxVisiblePages) {
      start = (end - maxVisiblePages + 1).clamp(1, totalPages.value);
    }

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    return pages;
  }

  @override
  void onInit() {
    super.onInit();

    // Initialize search controller with current search query
    searchController.text = searchQuery.value;

    // Setup search listener with debounce
    searchQuery.listen((value) {
      if (searchController.text != value) {
        searchController.text = value;
      }
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        onSearchChanged();
      });
    });

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadUsers();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Load users with current pagination and search settings
  Future<void> loadUsers({bool showLoading = true}) async {
    // Prevent multiple simultaneous requests
    if (_isLoadingData) {
      print('Already loading data, skipping request');
      return;
    }

    _isLoadingData = true;

    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      print(
          'Loading users - Page: ${currentPage.value}, Limit: ${itemsPerPage.value}, Search: "${searchQuery.value}"');

      final response = await _userService.getUsers(
        page: currentPage.value,
        limit: itemsPerPage.value,
        search: searchQuery.value,
      );

      users.value = response.data;
      totalItems.value = response.metadata.total;
      totalPages.value = response.metadata.totalPages;

      // Validate current page
      if (currentPage.value > totalPages.value && totalPages.value > 0) {
        currentPage.value = totalPages.value;
        // Reload with corrected page
        _isLoadingData = false;
        return loadUsers(showLoading: false);
      }

      print('Loaded ${users.length} users successfully');
    } catch (e) {
      print('Error loading users: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      users.clear();
      totalItems.value = 0;
      totalPages.value = 0;
    } finally {
      isLoading.value = false;
      isSearching.value = false;
      _isLoadingData = false;
    }
  }

  /// Create new user
  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required bool isStaff,
    required String roleId,
  }) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final response = await _userService.createUser(
        name: name,
        email: email,
        password: password,
        isStaff: isStaff,
        roleId: roleId,
      );

      if (response.success) {
        showSuccessMessage(response.message);
        await refreshUsers();
        resetForm();
        return true;
      } else {
        errorMessage.value = response.message;
        showErrorMessage(response.message);
        return false;
      }
    } catch (e) {
      final errorMsg = 'Gagal membuat user: $e';
      errorMessage.value = errorMsg;
      showErrorMessage(errorMsg);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update existing user
  Future<bool> updateUser({
    required String userId,
    required String name,
    required String email,
    String? password,
    required bool isStaff,
    required String roleId,
  }) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final response = await _userService.updateUser(
        userId: userId,
        name: name,
        email: email,
        password: password,
        isStaff: isStaff,
        roleId: roleId,
      );

      if (response.success) {
        showSuccessMessage(response.message);
        await refreshUsers();
        resetForm();
        return true;
      } else {
        errorMessage.value = response.message;
        showErrorMessage(response.message);
        return false;
      }
    } catch (e) {
      final errorMsg = 'Gagal mengupdate user: $e';
      errorMessage.value = errorMsg;
      showErrorMessage(errorMsg);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final response = await _userService.deleteUser(userId);

      if (response.success) {
        showSuccessMessage(response.message);
        await refreshUsers();
        return true;
      } else {
        errorMessage.value = response.message;
        showErrorMessage(response.message);
        return false;
      }
    } catch (e) {
      final errorMsg = 'Gagal menghapus user: $e';
      errorMessage.value = errorMsg;
      showErrorMessage(errorMsg);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Refresh users list
  Future<void> refreshUsers() async {
    currentPage.value = 1;
    await loadUsers();
  }

  /// Handle search input change
  void onSearchChanged() {
    print('Search changed to: "${searchQuery.value}"');
    if (currentPage.value != 1) {
      currentPage.value = 1;
    }
    isSearching.value = true;
    loadUsers(showLoading: false);
  }

  /// Update search query
  void updateSearchQuery(String query) {
    if (searchQuery.value != query) {
      searchQuery.value = query;
    }
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    loadUsers();
  }

  /// Go to previous page
  void goToPreviousPage() {
    if (hasPreviousPage && !_isLoadingData) {
      currentPage.value--;
      loadUsers();
    }
  }

  /// Go to next page
  void goToNextPage() {
    if (hasNextPage && !_isLoadingData) {
      currentPage.value++;
      loadUsers();
    }
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page != currentPage.value &&
        page >= 1 &&
        page <= totalPages.value &&
        !_isLoadingData) {
      currentPage.value = page;
      loadUsers();
    }
  }

  /// Change page size
  void changePageSize(int newSize) {
    if (availablePageSizes.contains(newSize) && !_isLoadingData) {
      itemsPerPage.value = newSize;
      currentPage.value = 1; // Reset to first page
      loadUsers();
    }
  }

  /// Reset form controllers
  void resetForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isStaff.value = false;
    selectedRoleId.value = '';
    errorMessage.value = '';
  }

  /// Fill form with user data for editing
  void fillForm(User user) {
    nameController.text = user.name;
    emailController.text = user.email;
    passwordController.clear(); // Don't fill password for security
    confirmPasswordController.clear();
    isStaff.value = user.isStaff;
    selectedRoleId.value = user.role.id;
  }

  /// Form validation methods
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      return 'Password tidak boleh kosong';
    }
    if (value != null && value.isNotEmpty) {
      if (value.length < 8) {
        return 'Password minimal 8 karakter';
      }
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return 'Konfirmasi password tidak sama';
    }
    return null;
  }

  String? validateRole(String? value) {
    if (value == null || value.isEmpty) {
      return 'Role harus dipilih';
    }
    return null;
  }

  /// Get user type display text
  String getUserTypeText(User user) {
    return user.isStaff ? 'STAFF' : 'USER';
  }

  /// Get user type color
  Color getUserTypeColor(User user) {
    return user.isStaff ? Colors.blue : Colors.grey;
  }

  /// Format creation date
  String formatCreationDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
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
      icon: const Icon(Icons.check_circle, color: Colors.white),
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
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  /// Show confirmation dialog for delete
  Future<bool> showDeleteConfirmation(User user) async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apakah Anda yakin ingin menghapus user berikut?'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama: ${user.name}',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('Email: ${user.email}'),
                      Text('Role: ${user.role.name}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tindakan ini tidak dapat dibatalkan.',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child:
                    const Text('Hapus', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
