// controllers/role_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/role/role_model.dart';
import 'package:pos/services/role/role_service.dart';

class RoleController extends GetxController {
  final RoleService _roleService = RoleService.instance;

  // Observable variables
  final _roles = <Role>[].obs;
  final _filteredRoles = <Role>[].obs;
  final _availablePermissions = <Permission>[].obs;
  final _isLoading = false.obs;
  final _isCreating = false.obs;
  final _isUpdating = false.obs;
  final _isDeleting = false.obs;
  final _searchQuery = ''.obs;
  final _selectedRole = Rxn<Role>();
  final _currentPage = 1.obs;
  final _itemsPerPage = 10.obs;

  // Text controllers
  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  // Getters
  List<Role> get roles => _roles;
  List<Role> get filteredRoles => _filteredRoles;
  List<Permission> get availablePermissions => _availablePermissions;
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;
  String get searchQuery => _searchQuery.value;
  Role? get selectedRole => _selectedRole.value;
  int get currentPage => _currentPage.value;
  int get itemsPerPage => _itemsPerPage.value;

  // Computed properties
  int get totalPages => (_filteredRoles.length / _itemsPerPage.value).ceil();
  List<Role> get paginatedRoles {
    final startIndex = (_currentPage.value - 1) * _itemsPerPage.value;
    final endIndex = startIndex + _itemsPerPage.value;
    return _filteredRoles.sublist(
      startIndex,
      endIndex > _filteredRoles.length ? _filteredRoles.length : endIndex,
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadRoles();
    loadAvailablePermissions();

    // Listen to search query changes
    searchController.addListener(() {
      _searchQuery.value = searchController.text;
      filterRoles();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Load all roles
  Future<void> loadRoles({String? storeId}) async {
    try {
      _isLoading.value = true;
      print('=== ROLE CONTROLLER: LOAD ROLES ===');

      final roles = await _roleService.getRoles(storeId: storeId);
      _roles.value = roles;
      filterRoles();

      print('✅ Roles loaded successfully: ${roles.length} roles');
    } catch (e) {
      print('❌ Error loading roles: $e');
      Get.snackbar(
        'Error',
        'Failed to load roles: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load available permissions
  Future<void> loadAvailablePermissions({String? storeId}) async {
    try {
      print('=== ROLE CONTROLLER: LOAD PERMISSIONS ===');

      final permissions = await _roleService.getPermissions(storeId: storeId);
      _availablePermissions.value = permissions;

      print(
          '✅ Permissions loaded successfully: ${permissions.length} permissions');
    } catch (e) {
      print('❌ Error loading permissions: $e');
      Get.snackbar(
        'Error',
        'Failed to load permissions: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Filter roles based on search query
  void filterRoles() {
    if (_searchQuery.value.isEmpty) {
      _filteredRoles.value = _roles;
    } else {
      _filteredRoles.value = _roles.where((role) {
        return role.name
                .toLowerCase()
                .contains(_searchQuery.value.toLowerCase()) ||
            role.description
                .toLowerCase()
                .contains(_searchQuery.value.toLowerCase());
      }).toList();
    }

    // Reset to first page when filtering
    _currentPage.value = 1;

    print('🔍 Filtered roles: ${_filteredRoles.length} results');
  }

  // Create new role
  Future<void> createRole(Map<String, dynamic> roleData,
      {String? storeId}) async {
    try {
      _isCreating.value = true;
      print('=== ROLE CONTROLLER: CREATE ROLE ===');

      final newRole = await _roleService.createRole(roleData, storeId: storeId);
      _roles.add(newRole);
      filterRoles();

      Get.snackbar(
        'Success',
        'Role created successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('✅ Role created successfully: ${newRole.name}');
    } catch (e) {
      print('❌ Error creating role: $e');
      Get.snackbar(
        'Error',
        'Failed to create role: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isCreating.value = false;
    }
  }

  // Update role
  Future<void> updateRole(String roleId, Map<String, dynamic> roleData,
      {String? storeId}) async {
    try {
      _isUpdating.value = true;
      print('=== ROLE CONTROLLER: UPDATE ROLE ===');

      final updatedRole =
          await _roleService.updateRole(roleId, roleData, storeId: storeId);

      final index = _roles.indexWhere((role) => role.id == roleId);
      if (index != -1) {
        _roles[index] = updatedRole;
        filterRoles();
      }

      Get.snackbar(
        'Success',
        'Role updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('✅ Role updated successfully: ${updatedRole.name}');
    } catch (e) {
      print('❌ Error updating role: $e');
      Get.snackbar(
        'Error',
        'Failed to update role: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  // Delete role
  Future<void> deleteRole(String roleId, {String? storeId}) async {
    try {
      _isDeleting.value = true;
      print('=== ROLE CONTROLLER: DELETE ROLE ===');

      await _roleService.deleteRole(roleId, storeId: storeId);

      _roles.removeWhere((role) => role.id == roleId);
      filterRoles();

      Get.snackbar(
        'Success',
        'Role deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('✅ Role deleted successfully');
    } catch (e) {
      print('❌ Error deleting role: $e');
      Get.snackbar(
        'Error',
        'Failed to delete role: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isDeleting.value = false;
    }
  }
}
