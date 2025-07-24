// controllers/user_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/user/user_model.dart';
import 'package:pos/models/role/role_model.dart';
import 'package:pos/services/user/user_service.dart';
import 'package:pos/services/role/role_service.dart';

class UserController extends GetxController {
  final UserService _userService = UserService.instance;
  final RoleService _roleService = RoleService.instance;

  // Observable variables
  final _users = <User>[].obs;
  final _filteredUsers = <User>[].obs;
  final _availableRoles = <Role>[].obs;
  final _isLoading = false.obs;
  final _isCreating = false.obs;
  final _isUpdating = false.obs;
  final _isDeleting = false.obs;
  final _searchQuery = ''.obs;
  final _selectedUser = Rxn<User>();
  final _currentPage = 1.obs;
  final _itemsPerPage = 10.obs;
  final _totalPages = 0.obs;
  final _totalUsers = 0.obs;

  // Text controllers
  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Form variables
  final _selectedRoleId = ''.obs;
  final _isStaff = false.obs;
  final _isEditMode = false.obs;

  // Getters
  List<User> get users => _users;
  List<User> get filteredUsers => _filteredUsers;
  List<Role> get availableRoles => _availableRoles;
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;
  String get searchQuery => _searchQuery.value;
  User? get selectedUser => _selectedUser.value;
  int get currentPage => _currentPage.value;
  int get itemsPerPage => _itemsPerPage.value;
  int get totalPages => _totalPages.value;
  int get totalUsers => _totalUsers.value;
  String get selectedRoleId => _selectedRoleId.value;
  bool get isStaff => _isStaff.value;
  bool get isEditMode => _isEditMode.value;

  // Computed properties
  List<User> get paginatedUsers => _filteredUsers;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    loadAvailableRoles();

    // Listen to search query changes
    searchController.addListener(() {
      _searchQuery.value = searchController.text;
      _currentPage.value = 1; // Reset to first page when searching
      loadUsers(search: _searchQuery.value);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Load all users with pagination
  Future<void> loadUsers({
    String? storeId,
    int? page,
    int? limit,
    String? search,
  }) async {
    try {
      _isLoading.value = true;

      final response = await _userService.getUsers(
        storeId: storeId,
        page: page ?? _currentPage.value,
        limit: limit ?? _itemsPerPage.value,
        search: search,
      );

      _users.value = response.data;
      _filteredUsers.value = response.data;

      if (response.metadata != null) {
        _totalPages.value = response.metadata!.totalPages;
        _totalUsers.value = response.metadata!.total;
        _currentPage.value = response.metadata!.page;
        _itemsPerPage.value = response.metadata!.limit;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load users: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load available roles
  Future<void> loadAvailableRoles({String? storeId}) async {
    try {
      final roles = await _roleService.getRoles(storeId: storeId);
      _availableRoles.value = roles;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load roles: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get users by role
  Future<void> loadUsersByRole(String roleId, {String? storeId}) async {
    try {
      _isLoading.value = true;

      final users = await _userService.getUsersByRole(roleId, storeId: storeId);
      _users.value = users;
      _filteredUsers.value = users;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load users by role: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Create new user
  Future<void> createUser({String? storeId}) async {
    if (!_validateForm()) return;

    try {
      _isCreating.value = true;

      final userRequest = CreateUserRequest(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        isStaff: _isStaff.value,
        roleId: _selectedRoleId.value,
      );

      final newUser =
          await _userService.createUser(userRequest, storeId: storeId);

      // Reload users to get updated list
      await loadUsers(storeId: storeId);

      // Clear form
      clearForm();

      Get.snackbar(
        'Success',
        'User created successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create user: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isCreating.value = false;
    }
  }

  // Update user
  Future<void> updateUser(String userId, {String? storeId}) async {
    if (!_validateForm(isUpdate: true)) return;

    try {
      _isUpdating.value = true;

      final userRequest = UpdateUserRequest(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password:
            passwordController.text.isNotEmpty ? passwordController.text : null,
        isStaff: _isStaff.value,
        roleId: _selectedRoleId.value,
      );

      final updatedUser =
          await _userService.updateUser(userId, userRequest, storeId: storeId);

      // Reload users to get updated list
      await loadUsers(storeId: storeId);

      // Clear form
      clearForm();

      Get.snackbar(
        'Success',
        'User updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update user: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  // Delete user
  Future<void> deleteUser(String userId, {String? storeId}) async {
    try {
      _isDeleting.value = true;

      await _userService.deleteUser(userId, storeId: storeId);

      // Reload users to get updated list
      await loadUsers(storeId: storeId);

      Get.snackbar(
        'Success',
        'User deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete user: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isDeleting.value = false;
    }
  }

  // Change user password
  Future<void> changePassword(String userId, String newPassword,
      {String? storeId}) async {
    try {
      await _userService.changePassword(userId, newPassword, storeId: storeId);

      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change password: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Toggle staff status
  Future<void> toggleStaffStatus(String userId, bool isStaff,
      {String? storeId}) async {
    try {
      await _userService.toggleStaffStatus(userId, isStaff, storeId: storeId);

      // Reload users to get updated list
      await loadUsers(storeId: storeId);

      Get.snackbar(
        'Success',
        'Staff status updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update staff status: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Navigate to next page
  void nextPage({String? storeId}) {
    if (_currentPage.value < _totalPages.value) {
      _currentPage.value++;
      loadUsers(storeId: storeId, page: _currentPage.value);
    }
  }

  // Navigate to previous page
  void previousPage({String? storeId}) {
    if (_currentPage.value > 1) {
      _currentPage.value--;
      loadUsers(storeId: storeId, page: _currentPage.value);
    }
  }

  // Go to specific page
  void goToPage(int page, {String? storeId}) {
    if (page >= 1 && page <= _totalPages.value) {
      _currentPage.value = page;
      loadUsers(storeId: storeId, page: page);
    }
  }

  // Set form for editing
  void setEditMode(User user) {
    _isEditMode.value = true;
    _selectedUser.value = user;
    nameController.text = user.name;
    emailController.text = user.email;
    _selectedRoleId.value = user.role.id;
    _isStaff.value = user.isStaff;
    passwordController.clear(); // Don't populate password for security
    confirmPasswordController.clear();
  }

  // Clear form
  void clearForm() {
    _isEditMode.value = false;
    _selectedUser.value = null;
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _selectedRoleId.value = '';
    _isStaff.value = false;
  }

  // Set selected role
  void setSelectedRole(String roleId) {
    _selectedRoleId.value = roleId;
  }

  // Toggle staff status
  void toggleIsStaff() {
    _isStaff.value = !_isStaff.value;
  }

  // Form validation
  bool _validateForm({bool isUpdate = false}) {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Name is required',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Email is required',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (!isUpdate && passwordController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Password is required',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (passwordController.text.isNotEmpty &&
        passwordController.text.length < 6) {
      Get.snackbar(
        'Validation Error',
        'Password must be at least 6 characters long',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Validation Error',
        'Passwords do not match',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (_selectedRoleId.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a role',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }
}
