// lib/services/auth_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/auth/auth_model.dart' hide ApiResponse;
import 'package:pos/storage_service.dart';

import '../models/auth/user_model.dart';

class AuthService extends GetxService {
  static AuthService get instance {
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService());
    }
    return Get.find<AuthService>();
  }

  final HttpClient _httpClient = HttpClient.instance;
  final StorageService _storage = StorageService.instance;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _ensureStorageInitialized();
  }

  /// Ensure storage is initialized
  Future<void> _ensureStorageInitialized() async {
    if (!_storage.isInitialized) {
      await _storage.init();
    }
  }

  /// Login with email and password
  Future<ApiResponse<LoginData>> login(String email, String password) async {
    try {
      await _ensureStorageInitialized();

      final loginRequest = LoginRequest(email: email, password: password);

      final response = await _httpClient.post(
        '/auth/login',
        loginRequest.toJson(),
        requireAuth: false,
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonResponse);

        // Save token
        _storage.saveToken(loginResponse.data.token);

        // Decode token to get user data
        final userData = _decodeToken(loginResponse.data.token);
        if (userData != null) {
          _storage.saveUserData(userData.toJson());
        }

        // Extract and save store_id from token
        final storeId = _extractStoreIdFromToken(loginResponse.data.token);
        if (storeId != null && storeId.isNotEmpty) {
          _storage.saveStoreId(storeId);
        }

        return ApiResponse<LoginData>(
          message: loginResponse.message,
          status: loginResponse.status,
          data: loginResponse.data,
          success: true,
        );
      } else {
        return ApiResponse<LoginData>(
          message: jsonResponse['message'] ?? 'Login failed',
          status: response.statusCode,
          success: false,
        );
      }
    } catch (e) {
      return ApiResponse<LoginData>(
        message: 'Error during login: ${e.toString()}',
        status: 500,
        success: false,
      );
    }
  }

  /// Get current user data from server
  Future<ApiResponse<CurrentUserData>> getCurrentUser() async {
    try {
      await _ensureStorageInitialized();

      final response = await _httpClient.get(
        '/auth/me',
        requireAuth: true,
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final currentUserResponse = CurrentUserResponse.fromJson(jsonResponse);

        // Update local storage with fresh user data
        _storage.saveUserData(currentUserResponse.data.user.toJson());

        // Update store_id if it exists
        if (currentUserResponse.data.user.storeId != null) {
          _storage.saveStoreId(currentUserResponse.data.user.storeId!);
        }

        return ApiResponse<CurrentUserData>(
          message: currentUserResponse.message,
          status: currentUserResponse.status,
          data: currentUserResponse.data,
          success: true,
        );
      } else {
        return ApiResponse<CurrentUserData>(
          message: jsonResponse['message'] ?? 'Failed to get current user',
          status: response.statusCode,
          success: false,
        );
      }
    } catch (e) {
      return ApiResponse<CurrentUserData>(
        message: 'Error getting current user: ${e.toString()}',
        status: 500,
        success: false,
      );
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    final token = _storage.getToken();
    if (token == null || token.isEmpty) return false;

    try {
      final isExpired = Jwt.isExpired(token);
      return !isExpired;
    } catch (e) {
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _ensureStorageInitialized();
    await _storage.clearUserData();
  }

  /// Get stored user data
  CurrentUser? getStoredUser() {
    final userData = _storage.getUserData();
    if (userData != null) {
      return CurrentUser.fromJson(userData);
    }
    return null;
  }

  /// Extract store_id from JWT token
  String? _extractStoreIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      String normalizedPayload = payload;

      // Add padding if needed
      switch (payload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final Map<String, dynamic> decodedPayload = jsonDecode(decodedString);

      // Try different possible field names for store ID
      final storeId = decodedPayload['store_id']?.toString() ??
          decodedPayload['storeId']?.toString() ??
          decodedPayload['store']?.toString() ??
          decodedPayload['store_uuid']?.toString();

      return storeId;
    } catch (e) {
      return null;
    }
  }

  /// Decode JWT token to get user data
  User? _decodeToken(String token) {
    try {
      final Map<String, dynamic> payload = Jwt.parseJwt(token);
      return User.fromJson(payload);
    } catch (e) {
      return null;
    }
  }
}
