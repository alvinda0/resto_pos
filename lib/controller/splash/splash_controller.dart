import 'package:get/get.dart';
import 'package:pos/screens/auth/login_screen.dart';
import 'package:pos/screens/dashboard/dashboard_screen.dart'; // Import your dashboard screen
import 'package:pos/screens/dashboard/sidebar.dart';
import 'package:pos/services/auth_service.dart';

class SplashController extends GetxController {
  /// Check authentication status and navigate accordingly
  Future<void> checkAuthenticationStatus() async {
    // Wait for animation to complete (2 seconds) plus a small delay
    await Future.delayed(Duration(seconds: 3));

    try {
      final authService = AuthService.instance;

      // First check if user has a valid token locally
      if (!authService.isAuthenticated()) {
        // No valid token, go to login
        navigateToLogin();
        return;
      }

      // Token exists locally, verify with server
      final response = await authService.getCurrentUser();

      if (response.success) {
        // Token is valid, user is authenticated
        navigateToSidebar();
      } else {
        // Token is invalid or expired, go to login
        await authService.logout(); // Clear invalid token
        navigateToLogin();
      }
    } catch (e) {
      // Error occurred, go to login for safety
      print('Error during auth check: $e');
      navigateToLogin();
    }
  }

  /// Navigate to login screen
  void navigateToLogin() {
    Get.offAll(() => LoginScreen());
  }

  /// Navigate to sidebar screen (main app)
  void navigateToSidebar() {
    Get.offAll(() => const MainLayout(
          currentRoute: '/dashboard',
          child: DashboardScreen(), // Provide the required child widget
        ));

    // Alternative: Use named route if you have it set up
    // Get.offAllNamed('/dashboard');
  }
}
