import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pos/screens/auth/login_screen.dart';
import 'package:pos/screens/splash_screen/splash_screen.dart';

class AppRoutes {
  // Route Names - Dikelompokkan untuk clarity
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';

  // Main App Routes
  static const String home = '/home';

  // Single source of truth untuk GetX routing
  static List<GetPage> getPages() {
    return [
      // Core App Flow
      GetPage(name: splash, page: () => const SplashScreen()),

      // Authentication
      GetPage(name: login, page: () => const LoginScreen()),
    ];
  }

  // 404 Handler
  static GetPage get unknownRoute {
    return GetPage(name: '/not-found', page: () => const NotFoundScreen());
  }

  // Helper methods untuk navigation yang sering dipakai
  static void toSplash() => Get.offAllNamed(splash);
  static void toLogin() => Get.offAllNamed(login);
}

// Simple 404 Screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    LucideIcons.mapPin,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Halaman Tidak Ditemukan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Halaman yang Anda cari tidak tersedia',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  icon: const Icon(LucideIcons.home, size: 18),
                  label: const Text('Kembali ke Beranda'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
