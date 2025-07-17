// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // Form key
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get passwordVisible => _passwordVisible.value;

  @override
  void onInit() {
    super.onInit();
    _authService = AuthService.instance;

    // Auto-fill untuk development (hapus di production)
    if (Get.arguments != null && Get.arguments['autoFill'] == true) {
      emailController.text = 'system+alpha@siresto.com';
      passwordController.text = 'siresto@123';
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
        // Clear form
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
        Get.offAll(() => const SideBarScreen());
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
}
