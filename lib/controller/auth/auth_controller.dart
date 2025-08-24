// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/auth/permission_controller.dart';
import 'package:pos/screens/dashboard/dashboard_screen.dart';
import 'package:pos/screens/dashboard/sidebar.dart';
import 'package:pos/services/auth_service.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  late final AuthService _authService;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _passwordVisible = false.obs;
  final RxBool _isLoggedIn = false.obs;

  // Form key
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get passwordVisible => _passwordVisible.value;
  bool get isLoggedIn => _isLoggedIn.value;

  @override
  void onInit() {
    super.onInit();
    _authService = AuthService.instance;
    _checkAuthStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Check if user is already authenticated
  void _checkAuthStatus() {
    _isLoggedIn.value = _authService.isAuthenticated();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _passwordVisible.value = !_passwordVisible.value;
  }

  /// Login function
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    _isLoading.value = true;

    try {
      final result = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (result.success) {
        // Update login status
        _isLoggedIn.value = true;

        // Clear form
        _clearForm();

        // Initialize Permission Controller setelah login berhasil
        final permissionController = Get.put(PermissionController());

        // Load permissions dari server
        await permissionController.loadUserPermissions();

        // Wait for permissions to be loaded
        while (permissionController.isLoading) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        // Show success message
        Get.snackbar(
          'Success',
          result.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        );

        // Navigate to dashboard dengan MainLayout
        Get.offAll(() => const MainLayout(
              currentRoute: '/dashboard',
              child: DashboardScreen(),
            ));

        // Alternative: Use named route if you have it set up
        // Get.offAllNamed('/dashboard');
      } else {
        // Show error message
        Get.snackbar(
          'Login Failed',
          result.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Logout function
  Future<void> logout() async {
    try {
      _isLoading.value = true;

      // Clear auth service data
      await _authService.logout();

      // Update login status
      _isLoggedIn.value = false;

      // Clear permission controller data
      if (Get.isRegistered<PermissionController>()) {
        final permissionController = PermissionController.instance;
        permissionController.clearPermissions();
        Get.delete<PermissionController>();
      }

      // Clear form data
      _clearForm();

      // Navigate to login
      Get.offAllNamed('/login');

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error during logout: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Force logout (for token expiry or unauthorized access)
  Future<void> forceLogout([String? message]) async {
    try {
      // Clear auth service data
      await _authService.logout();

      // Update login status
      _isLoggedIn.value = false;

      // Clear permission controller data
      if (Get.isRegistered<PermissionController>()) {
        final permissionController = PermissionController.instance;
        permissionController.clearPermissions();
        Get.delete<PermissionController>();
      }

      // Clear form data
      _clearForm();

      // Navigate to login
      Get.offAllNamed('/login');

      if (message != null && message.isNotEmpty) {
        Get.snackbar(
          'Session Expired',
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      print('Error during force logout: $e');
    }
  }

  /// Refresh user data and permissions
  Future<void> refreshUserData() async {
    try {
      if (!_authService.isAuthenticated()) {
        await forceLogout('Session expired. Please login again.');
        return;
      }

      // Refresh permissions
      if (Get.isRegistered<PermissionController>()) {
        final permissionController = PermissionController.instance;
        await permissionController.refreshPermissions();
      }

      Get.snackbar(
        'Success',
        'User data refreshed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh user data: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Check if user is authenticated and redirect accordingly
  Future<void> checkAuthAndRedirect() async {
    if (_authService.isAuthenticated()) {
      // User is authenticated, initialize permissions and go to dashboard
      final permissionController = Get.put(PermissionController());
      await permissionController.loadUserPermissions();

      Get.offAll(() => const MainLayout(
            currentRoute: '/dashboard',
            child: DashboardScreen(),
          ));
    } else {
      // User is not authenticated, go to login
      Get.offAllNamed('/login');
    }
  }

  /// Clear form
  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    _passwordVisible.value = false;
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  /// Get current user data
  Future<void> getCurrentUserData() async {
    try {
      final result = await _authService.getCurrentUser();
      if (result.success) {
        // User data retrieved successfully
        print('Current user: ${result.data?.user.name}');
      } else {
        // Failed to get current user, might be unauthorized
        if (result.status == 401) {
          await forceLogout('Your session has expired. Please login again.');
        }
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
  }

  /// Handle API errors globally
  void handleApiError(int statusCode, String message) {
    switch (statusCode) {
      case 401:
        forceLogout('Your session has expired. Please login again.');
        break;
      case 403:
        Get.snackbar(
          'Access Denied',
          'You do not have permission to access this resource',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
        break;
      case 500:
        Get.snackbar(
          'Server Error',
          'Internal server error. Please try again later.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
        break;
      default:
        Get.snackbar(
          'Error',
          message.isEmpty ? 'An error occurred' : message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
    }
  }
}
