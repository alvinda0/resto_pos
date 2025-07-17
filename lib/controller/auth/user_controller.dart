// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:pos/services/auth_service.dart';

import '../../models/auth/user_model.dart';

class UserController extends GetxController {
  final AuthService _authService = AuthService.instance;

  // Observable states
  final _isLoading = false.obs;
  final _isAuthenticated = false.obs;
  final _currentUser = Rxn<CurrentUser>();
  final _userPermissions = <String>[].obs;
  final _errorMessage = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;
  CurrentUser? get currentUser => _currentUser.value;
  List<String> get userPermissions => _userPermissions.toList();
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  /// Check if user is authenticated and load user data
  Future<void> _checkAuthStatus() async {
    try {
      _isAuthenticated.value = _authService.isAuthenticated();

      if (_isAuthenticated.value) {
        // Load stored user data
        final storedUser = _authService.getStoredUser();
        if (storedUser != null) {
          _currentUser.value = storedUser;
        }

        // Refresh user data from server
        await getCurrentUser();
      }
    } catch (e) {
      _isAuthenticated.value = false;
      _currentUser.value = null;
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _authService.login(email, password);

      if (result.success) {
        _isAuthenticated.value = true;

        // Get current user data after login
        await getCurrentUser();

        return true;
      } else {
        _errorMessage.value = result.message;
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get current user data from server
  Future<bool> getCurrentUser() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _authService.getCurrentUser();

      if (result.success && result.data != null) {
        _currentUser.value = result.data!.user;
        _userPermissions.value = result.data!.permissions;
        _isAuthenticated.value = true;
        return true;
      } else {
        _errorMessage.value = result.message;
        // If getting current user fails, user might be logged out
        if (result.status == 401) {
          await logout();
        }
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Failed to get user data: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    await getCurrentUser();
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _isLoading.value = true;

      await _authService.logout();

      _isAuthenticated.value = false;
      _currentUser.value = null;
      _userPermissions.clear();
      _errorMessage.value = '';

      // Navigate to login page
      Get.offAllNamed('/login');
    } catch (e) {
      _errorMessage.value = 'Logout failed: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Check if user has specific permission
  bool hasPermission(String permission) {
    return _userPermissions.contains(permission) ||
        _userPermissions.contains('full:access');
  }

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((permission) => hasPermission(permission));
  }

  /// Check if user has all of the specified permissions
  bool hasAllPermissions(List<String> permissions) {
    return permissions.every((permission) => hasPermission(permission));
  }

  /// Get user's store ID
  String? get userStoreId => _currentUser.value?.storeId;

  /// Get user's role name
  String? get userRole => _currentUser.value?.role?.name;

  /// Check if user is staff
  bool get isStaff => _currentUser.value?.isStaff ?? false;

  /// Clear error message
  void clearError() {
    _errorMessage.value = '';
  }
}
