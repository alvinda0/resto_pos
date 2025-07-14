// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/auth/auth_model.dart';
import 'package:pos/services/auth_service.dart';
import 'package:pos/models/routes.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  late final AuthService _authService;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _passwordVisible = false.obs;
  final RxBool _isInitialized = false.obs;

  // Form key
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get passwordVisible => _passwordVisible.value;
  bool get isInitialized => _isInitialized.value;
  bool get isLoggedIn => _isInitialized.value ? _authService.isLoggedIn : false;
  User? get currentUser =>
      _isInitialized.value ? _authService.currentUser : null;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  /// Initialize auth service safely
  void _initializeService() {
    try {
      _authService = AuthService.instance;
      _isInitialized.value = true;

      // Auto-fill untuk development (hapus di production)
      if (Get.arguments != null && Get.arguments['autoFill'] == true) {
        emailController.text = 'system+alpha@siresto.com';
        passwordController.text = 'siresto@123';
      }

      print('AuthController initialized successfully');
    } catch (e) {
      print('Error initializing AuthController: $e');
      _isInitialized.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _passwordVisible.value = !_passwordVisible.value;
  }

  /// Login function
  Future<void> login() async {
    if (!_isInitialized.value) {
      Get.snackbar(
        'Error',
        'Service not initialized. Please restart the app.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

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
        // Bersihkan form
        _clearForm();

        // Show success message
        Get.snackbar(
          'Success',
          result.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigate to dashboard
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Login error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Logout function
  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// Perform logout
  void _performLogout() {
    if (_isInitialized.value) {
      _authService.logout();
    }
    _clearForm();

    Get.snackbar(
      'Success',
      'Logged out successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
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
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Check if user has specific permission
  bool hasPermission(String permission) {
    return _isInitialized.value
        ? _authService.hasPermission(permission)
        : false;
  }

  /// Check if user is staff
  bool get isStaff => _isInitialized.value ? _authService.isStaff : false;

  /// Get user role name
  String get roleName => _isInitialized.value ? _authService.roleName : '';

  /// Get user store ID
  String get storeId => _isInitialized.value ? _authService.storeId : '';

  /// Validate current session
  Future<bool> validateSession() async {
    if (!_isInitialized.value) return false;
    return await _authService.validateSession();
  }

  /// Auto login check on app start
  Future<void> checkAuthStatus() async {
    try {
      if (!_isInitialized.value) {
        await Future.delayed(const Duration(milliseconds: 500));
        _initializeService();
      }

      await Future.delayed(const Duration(seconds: 1)); // Splash delay

      if (isLoggedIn) {
        final isValid = await validateSession();
        if (isValid) {
          Get.offAllNamed(AppRoutes.dashboard);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      print('Error checking auth status: $e');
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Refresh token if needed
  Future<void> refreshToken() async {
    if (!_isInitialized.value) return;

    final success = await _authService.refreshToken();
    if (!success) {
      logout();
    }
  }
}
