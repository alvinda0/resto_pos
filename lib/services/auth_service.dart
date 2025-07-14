// lib/services/auth_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/auth/auth_model.dart';

import 'package:pos/models/routes.dart';
import 'package:pos/storage_service.dart';

class AuthService extends GetxService {
  static AuthService get instance {
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService());
    }
    return Get.find<AuthService>();
  }

  final HttpClient _httpClient = HttpClient.instance;
  final StorageService _storage = StorageService.instance;

  // Observable untuk status login
  final RxBool _isLoggedIn = false.obs;
  final Rx<User?> _currentUser = Rx<User?>(null);

  bool get isLoggedIn => _isLoggedIn.value;
  User? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  /// Cek status autentikasi saat aplikasi dimulai
  void _checkAuthStatus() {
    final token = _storage.getToken();
    if (token != null && !_isTokenExpired(token)) {
      _isLoggedIn.value = true;
      _loadUserFromToken(token);
    } else {
      logout();
    }
  }

  /// Login dengan email dan password
  Future<ApiResponse<LoginData>> login(String email, String password) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);

      final response = await _httpClient.post(
        '/auth/login',
        loginRequest.toJson(),
        requireAuth: false,
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonResponse);

        // Simpan token
        _storage.saveToken(loginResponse.data.token);

        // Decode token untuk mendapatkan user data
        final userData = _decodeToken(loginResponse.data.token);
        if (userData != null) {
          _storage.saveUserData(userData.toJson());
          _currentUser.value = userData;
        }

        _isLoggedIn.value = true;

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

  /// Logout user
  void logout() {
    _storage.removeToken();
    _storage.removeUserData();
    _isLoggedIn.value = false;
    _currentUser.value = null;
  }

  /// Refresh token (jika diperlukan)
  Future<bool> refreshToken() async {
    try {
      final response = await _httpClient.post('/auth/refresh', {});

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final newToken = jsonResponse['data']['token'];

        _storage.saveToken(newToken);
        _loadUserFromToken(newToken);

        return true;
      }

      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  /// Decode JWT token untuk mendapatkan user data
  User? _decodeToken(String token) {
    try {
      final Map<String, dynamic> payload = Jwt.parseJwt(token);
      return User.fromJson(payload);
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  /// Load user data dari token
  void _loadUserFromToken(String token) {
    final userData = _decodeToken(token);
    if (userData != null) {
      _currentUser.value = userData;
    }
  }

  /// Cek apakah token sudah expired
  bool _isTokenExpired(String token) {
    try {
      return Jwt.isExpired(token);
    } catch (e) {
      return true;
    }
  }

  /// Mendapatkan user data dari storage
  User? getUserFromStorage() {
    final userData = _storage.getUserData();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  /// Cek apakah user memiliki permission tertentu
  bool hasPermission(String permission) {
    return _currentUser.value?.permissions.contains(permission) ?? false;
  }

  /// Cek apakah user adalah staff
  bool get isStaff => _currentUser.value?.isStaff ?? false;

  /// Mendapatkan role name user
  String get roleName => _currentUser.value?.roleName ?? '';

  /// Mendapatkan store ID user
  String get storeId => _currentUser.value?.storeId ?? '';

  /// Validate current session
  Future<bool> validateSession() async {
    final token = _storage.getToken();
    if (token == null || _isTokenExpired(token)) {
      logout();
      return false;
    }
    return true;
  }
}
