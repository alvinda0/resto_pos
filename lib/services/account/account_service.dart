// services/user_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/account/account_model.dart';

class UserService extends GetxService {
  final HttpClient _httpClient = HttpClient.instance;

  static UserService get instance {
    if (!Get.isRegistered<UserService>()) {
      Get.put(UserService());
    }
    return Get.find<UserService>();
  }

  /// Get users with pagination and search
  Future<UserListResponse> getUsers({
    int page = 1,
    int limit = 10,
    String search = '',
    String? storeId,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Add search parameter if not empty
      if (search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _httpClient.get(
        '/users',
        requireAuth: true,
        storeId: storeId,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Empty response from server');
        }

        final Map<String, dynamic> jsonResponse = json.decode(responseBody);

        // Debug print untuk melihat structure response
        print('API Response: $jsonResponse');

        return UserListResponse.fromJson(jsonResponse);
      } else {
        // Handle error responses
        String errorMessage = 'Failed to get users (${response.statusCode})';

        try {
          if (response.body.isNotEmpty) {
            final errorResponse = json.decode(response.body);
            errorMessage = errorResponse['message']?.toString() ?? errorMessage;
          }
        } catch (e) {
          // If JSON parsing fails, use default message
          print('Error parsing error response: $e');
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('UserService error: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Get user by ID
  Future<User> getUserById(String userId, {String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '/users/$userId',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final userData = jsonResponse['data'] as Map<String, dynamic>;
        return User.fromJson(userData);
      } else {
        String errorMessage = 'Failed to get user';

        try {
          final errorResponse = json.decode(response.body);
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (e) {
          // If JSON parsing fails, use default message
        }

        throw Exception('Error ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Create new user
  Future<ApiResponse<User>> createUser({
    required String name,
    required String email,
    required String password,
    required bool isStaff,
    required String roleId,
    String? storeId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'email': email,
        'password': password,
        'is_staff': isStaff,
        'role_id': roleId,
      };

      final response = await _httpClient.post(
        '/users',
        requestBody, // Pass as positional argument
        requireAuth: true,
        storeId: storeId,
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final user = User.fromJson(jsonResponse['data']);
        return ApiResponse<User>(
          success: jsonResponse['success'] ?? true,
          message: jsonResponse['message'] ?? 'User created successfully',
          data: user,
          status: jsonResponse['status'] ?? response.statusCode,
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to create user',
          status: jsonResponse['status'] ?? response.statusCode,
        );
      }
    } catch (e) {
      print('Create user error: $e');
      return ApiResponse<User>(
        success: false,
        message: 'Network error: $e',
        status: 500,
      );
    }
  }

  /// Update user
  Future<ApiResponse<User>> updateUser({
    required String userId,
    required String name,
    required String email,
    String? password,
    required bool isStaff,
    required String roleId,
    String? storeId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'email': email,
        'is_staff': isStaff,
        'role_id': roleId,
      };

      // Only include password if provided
      if (password != null && password.isNotEmpty) {
        requestBody['password'] = password;
      }

      final response = await _httpClient.put(
        '/users/$userId',
        requestBody, // Pass as positional argument, not named parameter
        requireAuth: true,
        storeId: storeId,
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonResponse['data']);
        return ApiResponse<User>(
          success: jsonResponse['success'] ?? true,
          message: jsonResponse['message'] ?? 'User updated successfully',
          data: user,
          status: jsonResponse['status'] ?? response.statusCode,
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to update user',
          status: jsonResponse['status'] ?? response.statusCode,
        );
      }
    } catch (e) {
      print('Update user error: $e');
      return ApiResponse<User>(
        success: false,
        message: 'Network error: $e',
        status: 500,
      );
    }
  }

  /// Delete user
  Future<ApiResponse<void>> deleteUser(String userId, {String? storeId}) async {
    try {
      final response = await _httpClient.delete(
        '/users/$userId',
        requireAuth: true,
        storeId: storeId,
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: jsonResponse['success'] ?? true,
          message: jsonResponse['message'] ?? 'User deleted successfully',
          status: jsonResponse['status'] ?? response.statusCode,
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to delete user',
          status: jsonResponse['status'] ?? response.statusCode,
        );
      }
    } catch (e) {
      print('Delete user error: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Network error: $e',
        status: 500,
      );
    }
  }

  /// Search users
  Future<UserListResponse> searchUsers({
    required String query,
    int page = 1,
    int limit = 10,
    String? storeId,
  }) async {
    return getUsers(
      page: page,
      limit: limit,
      search: query,
      storeId: storeId,
    );
  }
}

/// Generic API Response class
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int status;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.status,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      status: json['status'] ?? 0,
    );
  }
}
