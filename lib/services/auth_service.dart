// lib/services/auth_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/auth/auth_model.dart';
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
  final RxString _currentStoreId =
      ''.obs; // Tambahkan observable untuk store ID

  bool get isLoggedIn => _isLoggedIn.value;
  User? get currentUser => _currentUser.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Pastikan storage diinisialisasi terlebih dahulu
    await _ensureStorageInitialized();
    _checkAuthStatus();
  }

  /// Pastikan storage sudah diinisialisasi
  Future<void> _ensureStorageInitialized() async {
    if (!_storage.isInitialized) {
      print('=== INITIALIZING STORAGE ===');
      await _storage.init();
      print('✅ Storage initialized');
      print('============================');
    }
  }

  /// Cek status autentikasi saat aplikasi dimulai
  void _checkAuthStatus() {
    final token = _storage.getToken();
    print('=== AUTH STATUS CHECK ===');
    print('Token exists: ${token != null}');
    if (token != null) {
      print('Token: ${token.substring(0, 50)}...');
      print('Token expired: ${_isTokenExpired(token)}');
    }

    if (token != null && !_isTokenExpired(token)) {
      _isLoggedIn.value = true;
      _loadUserFromToken(token);

      // Load store ID dengan fallback
      _loadStoreId();
    } else {
      logout();
    }
    print('=========================');
  }

  /// Load store ID dengan fallback
  void _loadStoreId() {
    print('=== LOADING STORE ID ===');

    // Coba ambil dari storage dulu
    String? storeId = _storage.getStoreId();
    print('Store ID from storage: $storeId');

    // Jika tidak ada, coba extract dari token
    if (storeId == null || storeId.isEmpty) {
      final token = _storage.getToken();
      if (token != null) {
        storeId = _extractStoreIdFromToken(token);
        print('Store ID extracted from token: $storeId');

        // Simpan ke storage jika berhasil diextract
        if (storeId != null && storeId.isNotEmpty) {
          _storage.saveStoreId(storeId);
          print('Store ID saved to storage: $storeId');
        }
      }
    }

    // Update observable
    _currentStoreId.value = storeId ?? '';
    print('Final store ID: ${_currentStoreId.value}');
    print('========================');
  }

  /// Login dengan email dan password
  Future<ApiResponse<LoginData>> login(String email, String password) async {
    try {
      // Pastikan storage diinisialisasi
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

        print('=== LOGIN SUCCESS ===');
        print(
            'Token received: ${loginResponse.data.token.substring(0, 50)}...');

        // Simpan token
        _storage.saveToken(loginResponse.data.token);
        print('Token saved to storage');

        // Decode token untuk mendapatkan user data
        final userData = _decodeToken(loginResponse.data.token);
        if (userData != null) {
          _storage.saveUserData(userData.toJson());
          _currentUser.value = userData;
          print('User data saved: ${userData.toJson()}');
        }

        // Extract dan simpan store_id dari token dengan delay untuk memastikan storage ready
        await Future.delayed(Duration(milliseconds: 100));
        final storeId = _extractStoreIdFromToken(loginResponse.data.token);
        if (storeId != null && storeId.isNotEmpty) {
          _storage.saveStoreId(storeId);
          _currentStoreId.value = storeId; // Update observable
          print('Store ID extracted and saved: $storeId');
          print('Store ID observable updated: ${_currentStoreId.value}');

          // Verifikasi penyimpanan
          await Future.delayed(Duration(milliseconds: 50));
          final savedStoreId = _storage.getStoreId();
          print('Verification - Store ID from storage: $savedStoreId');
        } else {
          print('WARNING: Store ID not found in token');
        }

        _isLoggedIn.value = true;
        print('Login status updated: ${_isLoggedIn.value}');
        print('=====================');

        return ApiResponse<LoginData>(
          message: loginResponse.message,
          status: loginResponse.status,
          data: loginResponse.data,
          success: true,
        );
      } else {
        print('=== LOGIN FAILED ===');
        print('Status code: ${response.statusCode}');
        print('Response: ${jsonResponse['message']}');
        print('====================');

        return ApiResponse<LoginData>(
          message: jsonResponse['message'] ?? 'Login failed',
          status: response.statusCode,
          success: false,
        );
      }
    } catch (e) {
      print('=== LOGIN ERROR ===');
      print('Error: $e');
      print('===================');

      return ApiResponse<LoginData>(
        message: 'Error during login: ${e.toString()}',
        status: 500,
        success: false,
      );
    }
  }

  /// Extract store_id dari JWT token
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

      print('=== TOKEN PAYLOAD ===');
      print('Decoded payload: $decodedPayload');

      // Try different possible field names for store ID
      final storeId = decodedPayload['store_id']?.toString() ??
          decodedPayload['storeId']?.toString() ??
          decodedPayload['store']?.toString() ??
          decodedPayload['store_uuid']?.toString();

      print('Store ID found: $storeId');
      print('Available keys: ${decodedPayload.keys.toList()}');
      print('====================');

      return storeId;
    } catch (e) {
      print('Error extracting store ID from token: $e');
      return null;
    }
  }

  /// Logout user
  void logout() {
    print('=== LOGOUT ===');
    print('Clearing token and user data...');

    _storage.removeToken();
    _storage.removeUserData();
    _storage.removeStoreId();
    _isLoggedIn.value = false;
    _currentUser.value = null;
    _currentStoreId.value = ''; // Reset observable

    print('Logout completed');
    print('===============');
  }

  /// Refresh token (jika diperlukan)
  Future<bool> refreshToken() async {
    try {
      final response = await _httpClient.post('/auth/refresh', {});

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final newToken = jsonResponse['data']['token'];

        print('=== TOKEN REFRESH ===');
        print('New token: ${newToken.substring(0, 50)}...');

        _storage.saveToken(newToken);
        _loadUserFromToken(newToken);

        // Extract dan simpan store_id dari token baru
        final storeId = _extractStoreIdFromToken(newToken);
        if (storeId != null) {
          _storage.saveStoreId(storeId);
          _currentStoreId.value = storeId; // Update observable
          print('Store ID updated: $storeId');
        }

        print('Token refresh completed');
        print('=====================');

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
      print('User loaded from token: ${userData.toJson()}');
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

  /// Mendapatkan store ID user dengan fallback yang lebih robust
  String get storeId {
    print('=== GET STORE ID (GETTER) ===');

    // 1. Coba dari observable
    if (_currentStoreId.value.isNotEmpty) {
      print('Store ID from observable: ${_currentStoreId.value}');
      return _currentStoreId.value;
    }

    // 2. Coba dari user data
    final userStoreId = _currentUser.value?.storeId;
    if (userStoreId != null && userStoreId.isNotEmpty) {
      print('Store ID from user data: $userStoreId');
      _currentStoreId.value = userStoreId; // Update observable
      return userStoreId;
    }

    // 3. Coba dari storage dengan fallback
    final storeId = _storage.getStoreIdWithFallback();
    if (storeId != null && storeId.isNotEmpty) {
      print('Store ID from storage with fallback: $storeId');
      _currentStoreId.value = storeId; // Update observable
      return storeId;
    }

    print('No store ID found from any source');
    print('=============================');
    return '';
  }

  /// Method untuk force refresh store ID
  void refreshStoreId() {
    print('=== FORCE REFRESH STORE ID ===');
    _loadStoreId();
    print('Store ID after refresh: ${_currentStoreId.value}');
    print('===============================');
  }

  /// Validate current session
  Future<bool> validateSession() async {
    final token = _storage.getToken();
    final storeId = _storage.getStoreId();

    print('=== SESSION VALIDATION ===');
    print('Token exists: ${token != null}');
    print('Store ID exists: ${storeId != null}');
    print('Store ID value: $storeId');
    print('Observable store ID: ${_currentStoreId.value}');

    if (token == null || _isTokenExpired(token)) {
      print('Session invalid - token missing or expired');
      print('===========================');
      logout();
      return false;
    }

    // Refresh store ID jika tidak ada
    if ((storeId == null || storeId.isEmpty) && _currentStoreId.value.isEmpty) {
      print('Refreshing store ID...');
      _loadStoreId();
    }

    print('Session valid');
    print('===========================');
    return true;
  }

  /// Debug method untuk mencetak informasi auth
  void debugAuthInfo() {
    print('=== AUTH DEBUG INFO ===');
    print('Is logged in: $_isLoggedIn');
    print('Current user: ${_currentUser.value?.toJson()}');
    print('Token: ${_storage.getToken()?.substring(0, 50)}...');
    print('Store ID from storage: ${_storage.getStoreId()}');
    print('Store ID from observable: ${_currentStoreId.value}');
    print('Store ID from getter: $storeId');
    print('Is staff: $isStaff');
    print('Role name: $roleName');
    print('=======================');
  }
}
