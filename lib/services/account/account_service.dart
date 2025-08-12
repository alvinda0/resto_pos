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
