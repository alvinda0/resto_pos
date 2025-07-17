import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  static StorageService get instance {
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService());
    }
    return Get.find<StorageService>();
  }

  late GetStorage _box;
  bool _isInitialized = false;

  Future<StorageService> init() async {
    if (!_isInitialized) {
      await GetStorage.init();
      _box = GetStorage();
      _isInitialized = true;
    }
    return this;
  }

  Future<void> clearUserData() async {
    clearAuthData();
  }

  // Cek apakah sudah diinisialisasi
  bool get isInitialized => _isInitialized;

  // Token management
  void saveToken(String token) {
    if (!_isInitialized) return;
    _box.write('jwt_token', token);
  }

  String? getToken() {
    if (!_isInitialized) return null;
    return _box.read('jwt_token');
  }

  void removeToken() {
    if (!_isInitialized) return;
    _box.remove('jwt_token');
  }

  bool get isLoggedIn => getToken() != null;

  // User data management
  void saveUserData(Map<String, dynamic> userData) {
    if (!_isInitialized) return;
    _box.write('user_data', userData);
  }

  Map<String, dynamic>? getUserData() {
    if (!_isInitialized) return null;
    return _box.read('user_data');
  }

  void removeUserData() {
    if (!_isInitialized) return;
    _box.remove('user_data');
  }

  // Store ID management
  void saveStoreId(String storeId) {
    if (!_isInitialized) return;
    _box.write('store_id', storeId);
  }

  String? getStoreId() {
    if (!_isInitialized) return null;
    return _box.read('store_id');
  }

  void removeStoreId() {
    if (!_isInitialized) return;
    _box.remove('store_id');
  }

  // Extract store ID from JWT token
  String? extractStoreIdFromToken(String token) {
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
      return decodedPayload['store_id']?.toString() ??
          decodedPayload['storeId']?.toString() ??
          decodedPayload['store']?.toString() ??
          decodedPayload['store_uuid']?.toString();
    } catch (e) {
      print('Error extracting store ID from token: $e');
      return null;
    }
  }

  // Get store ID with fallback to token extraction
  String? getStoreIdWithFallback() {
    String? storeId = getStoreId();

    if (storeId == null || storeId.isEmpty) {
      final token = getToken();
      if (token != null) {
        storeId = extractStoreIdFromToken(token);
        if (storeId != null && storeId.isNotEmpty) {
          saveStoreId(storeId);
        }
      }
    }

    return storeId;
  }

  // Generic storage
  void setString(String key, String value) {
    if (!_isInitialized) return;
    _box.write(key, value);
  }

  String? getString(String key) {
    if (!_isInitialized) return null;
    return _box.read(key);
  }

  void removeKey(String key) {
    if (!_isInitialized) return;
    _box.remove(key);
  }

  void setData(String key, dynamic value) {
    if (!_isInitialized) return;
    _box.write(key, value);
  }

  T? getData<T>(String key) {
    if (!_isInitialized) return null;
    return _box.read<T>(key);
  }

  bool hasKey(String key) {
    if (!_isInitialized) return false;
    return _box.hasData(key);
  }

  // Clear all data (logout)
  void clearAll() {
    if (!_isInitialized) return;
    _box.erase();
  }

  // Clear authentication data
  void clearAuthData() {
    if (!_isInitialized) return;
    removeToken();
    removeUserData();
    removeStoreId();
  }

  // Debug method
  void debugStorage() {
    if (!_isInitialized) {
      print('Storage not initialized');
      return;
    }

    print('=== Storage Debug Info ===');
    print('Token: ${getToken()?.substring(0, 20)}...');
    print('Store ID: ${getStoreId()}');
    print('User Data: ${getUserData()}');
    print('========================');
  }
}
