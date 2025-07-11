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
}
