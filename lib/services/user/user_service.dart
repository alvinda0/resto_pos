// services/user/user_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/user/user_model.dart';

class UserService extends GetxService {
  static UserService get instance {
    if (!Get.isRegistered<UserService>()) {
      Get.put(UserService());
    }
    return Get.find<UserService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  // Get all users with pagination and search
  Future<UserResponse> getUsers({
    String? storeId,
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _httpClient.get(
        '/users?$queryString',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final userResponse = UserResponse.fromJson(jsonDecode(response.body));
        return userResponse;
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting users: $e');
    }
  }

  // Get user by ID
  Future<User> getUserById(String userId, {String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '/users/$userId',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final userResponse =
            SingleUserResponse.fromJson(jsonDecode(response.body));
        return userResponse.data;
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  // Get users by role ID
  Future<List<User>> getUsersByRole(String roleId, {String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '/users/role/$roleId',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final userResponse = UserResponse.fromJson(jsonDecode(response.body));
        return userResponse.data;
      } else {
        throw Exception('Failed to load users by role: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting users by role: $e');
    }
  }

  // Create new user
  Future<User> createUser(CreateUserRequest userRequest,
      {String? storeId}) async {
    try {
      final response = await _httpClient.post(
        '/users',
        userRequest.toJson(),
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userResponse =
            SingleUserResponse.fromJson(jsonDecode(response.body));
        return userResponse.data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  // Update user
  Future<User> updateUser(String userId, UpdateUserRequest userRequest,
      {String? storeId}) async {
    try {
      final response = await _httpClient.put(
        '/users/$userId',
        userRequest.toJson(),
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final userResponse =
            SingleUserResponse.fromJson(jsonDecode(response.body));
        return userResponse.data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId, {String? storeId}) async {
    try {
      final response = await _httpClient.delete(
        '/users/$userId',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - no content to return
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // Change user password
  Future<void> changePassword(String userId, String newPassword,
      {String? storeId}) async {
    try {
      final response = await _httpClient.put(
        '/users/$userId/password',
        {'password': newPassword},
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        // Success - password changed
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to change password: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
  }

  // Toggle user staff status
  Future<User> toggleStaffStatus(String userId, bool isStaff,
      {String? storeId}) async {
    try {
      final response = await _httpClient.put(
        '/users/$userId/staff-status',
        {'is_staff': isStaff},
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final userResponse =
            SingleUserResponse.fromJson(jsonDecode(response.body));
        return userResponse.data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to update staff status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating staff status: $e');
    }
  }
}
