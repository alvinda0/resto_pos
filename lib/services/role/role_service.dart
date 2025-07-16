// services/role_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/role/role_model.dart';

class RoleService extends GetxService {
  static RoleService get instance {
    if (!Get.isRegistered<RoleService>()) {
      Get.put(RoleService());
    }
    return Get.find<RoleService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  // Get all roles
  Future<List<Role>> getRoles({String? storeId}) async {
    try {
      print('=== ROLE SERVICE: GET ROLES ===');
      print('🏪 Store ID: ${storeId ?? 'using default'}');

      final response = await _httpClient.get(
        '/roles',
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final roleResponse = RoleResponse.fromJson(jsonDecode(response.body));
        print(
            '✅ Roles retrieved successfully: ${roleResponse.data.length} roles');
        return roleResponse.data;
      } else {
        print('❌ Error response: ${response.body}');
        throw Exception('Failed to load roles: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting roles: $e');
      throw Exception('Error getting roles: $e');
    }
  }

  // Get role by ID
  Future<Role> getRoleById(String roleId, {String? storeId}) async {
    try {
      print('=== ROLE SERVICE: GET ROLE BY ID ===');
      print('🆔 Role ID: $roleId');
      print('🏪 Store ID: ${storeId ?? 'using default'}');

      final response = await _httpClient.get(
        '/roles/$roleId',
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final role = Role.fromJson(responseData['data']);
        print('✅ Role retrieved successfully: ${role.name}');
        return role;
      } else {
        print('❌ Error response: ${response.body}');
        throw Exception('Failed to load role: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting role: $e');
      throw Exception('Error getting role: $e');
    }
  }

  // Create new role
  Future<Role> createRole(Map<String, dynamic> roleData,
      {String? storeId}) async {
    try {
      print('=== ROLE SERVICE: CREATE ROLE ===');
      print('📝 Role data: $roleData');
      print('🏪 Store ID: ${storeId ?? 'using default'}');

      final response = await _httpClient.post(
        '/roles',
        roleData,
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final role = Role.fromJson(responseData['data']);
        print('✅ Role created successfully: ${role.name}');
        return role;
      } else {
        print('❌ Error response: ${response.body}');
        throw Exception('Failed to create role: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating role: $e');
      throw Exception('Error creating role: $e');
    }
  }

  // Update role
  Future<Role> updateRole(String roleId, Map<String, dynamic> roleData,
      {String? storeId}) async {
    try {
      print('=== ROLE SERVICE: UPDATE ROLE ===');
      print('🆔 Role ID: $roleId');
      print('📝 Role data: $roleData');
      print('🏪 Store ID: ${storeId ?? 'using default'}');

      final response = await _httpClient.put(
        '/roles/$roleId',
        roleData,
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final role = Role.fromJson(responseData['data']);
        print('✅ Role updated successfully: ${role.name}');
        return role;
      } else {
        print('❌ Error response: ${response.body}');
        throw Exception('Failed to update role: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating role: $e');
      throw Exception('Error updating role: $e');
    }
  }

  // Delete role
  Future<void> deleteRole(String roleId, {String? storeId}) async {
    try {
      print('=== ROLE SERVICE: DELETE ROLE ===');
      print('🆔 Role ID: $roleId');
      print('🏪 Store ID: ${storeId ?? 'using default'}');

      final response = await _httpClient.delete(
        '/roles/$roleId',
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Role deleted successfully');
      } else {
        print('❌ Error response: ${response.body}');
        throw Exception('Failed to delete role: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting role: $e');
      throw Exception('Error deleting role: $e');
    }
  }

  // Get available permissions
  Future<List<Permission>> getPermissions({String? storeId}) async {
    try {
      print('=== ROLE SERVICE: GET PERMISSIONS ===');
      print('🏪 Store ID: ${storeId ?? 'using default'}');

      final response = await _httpClient.get(
        '/permissions',
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final permissions = (responseData['data'] as List<dynamic>?)
                ?.map((permission) => Permission.fromJson(permission))
                .toList() ??
            [];
        print(
            '✅ Permissions retrieved successfully: ${permissions.length} permissions');
        return permissions;
      } else {
        print('❌ Error response: ${response.body}');
        throw Exception('Failed to load permissions: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting permissions: $e');
      throw Exception('Error getting permissions: $e');
    }
  }

  // Get users by role
  Future<List<Map<String, dynamic>>> getUsersByRole(String roleId,
      {String? storeId}) async {
    try {
      print('=== ROLE SERVICE: GET USERS BY ROLE ===');
      print('🆔 Role ID: $roleId');
      print('🏪 Store ID: ${storeId ?? 'using default'}');

      final response = await _httpClient.get(
        '/roles/$roleId/users',
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final users = (responseData['data'] as List<dynamic>?)
                ?.map((user) => user as Map<String, dynamic>)
                .toList() ??
            [];
        print('✅ Users retrieved successfully: ${users.length} users');
        return users;
      } else {
        print('❌ Error response: ${response.body}');
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting users by role: $e');
      throw Exception('Error getting users by role: $e');
    }
  }
}
