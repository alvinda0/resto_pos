import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pos/screens/auth/login_screen.dart';
import 'package:pos/screens/dashboard/sidebar.dart';
import 'package:pos/screens/kitchen/kitchen_screen.dart';
import 'package:pos/screens/splash_screen/splash_screen.dart';
import 'package:pos/screens/dashboard/dashboard_screen.dart';
import 'package:pos/screens/dashboard/customers_screen.dart';
import 'package:pos/screens/dashboard/promo_screen.dart';
import 'package:pos/screens/dashboard/order_screen.dart';
import 'package:pos/screens/menu/products_screen.dart';
import 'package:pos/screens/menu/product_list_screen.dart';
import 'package:pos/screens/table/tables_screen.dart';
import 'package:pos/screens/akun/akun_role_users_screen.dart';

class AppRoutes {
  // Route Names - Dikelompokkan untuk clarity
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';

  // Main App Routes
  static const String home = '/home';
  static const String sidebar = '/sidebar';

  // Dashboard Routes
  static const String dashboard = '/dashboard';
  static const String tables = '/tables';
  static const String customers = '/customers';
  static const String promo = '/promo';
  static const String sales = '/sales';
  static const String settings = '/settings';

  // Menu Routes
  static const String products = '/products';
  static const String productList = '/product-list';
  static const String ingredients = '/ingredients';

  // Kitchen Routes
  static const String kitchen = '/kitchen';

  // Account Routes
  static const String account = '/account';
  static const String accountRoleUsers = '/account/role-users';

  // Referral Routes
  static const String referral = '/referral';
  static const String referralManagement = '/referral/management';
  static const String referralWithdrawal = '/referral/withdrawal';

  // Points Routes
  static const String points = '/points';
  static const String pointsGifts = '/points/gifts';
  static const String pointsHistory = '/points/history';
  static const String pointsConfiguration = '/points/configuration';

  // Settings Routes
  static const String theme = '/settings/theme';
  static const String taxConfiguration = '/settings/tax';
  static const String qrisConfiguration = '/settings/qris';
  static const String logs = '/settings/logs';

  // Helper method untuk wrap screen dengan MainLayout
  static Widget _wrapWithMainLayout(Widget child, [String? routeName]) {
    return MainLayout(
      child: child,
      currentRoute: routeName,
    );
  }

  // Single source of truth untuk GetX routing
  static List<GetPage> getPages() {
    return [
      // Core App Flow
      GetPage(name: splash, page: () => const SplashScreen()),

      // Authentication (tidak perlu MainLayout)
      GetPage(
        name: login,
        page: () => LoginScreen(),
        transition: Transition.rightToLeft,
      ),

      // Main Layout - semua route di bawah ini akan dibungkus MainLayout

      // Dashboard Routes
      GetPage(
          name: dashboard,
          page: () => _wrapWithMainLayout(const DashboardScreen(), dashboard)),
      GetPage(
          name: tables,
          page: () => _wrapWithMainLayout(const TableScreen(), tables)),
      GetPage(
          name: customers,
          page: () => _wrapWithMainLayout(const CustomersScreen(), customers)),
      GetPage(
          name: promo,
          page: () => _wrapWithMainLayout(const PromoScreen(), promo)),
      GetPage(
          name: sales,
          page: () => _wrapWithMainLayout(const OrderScreen(), sales)),

      // Product List Route
      GetPage(
        name: productList,
        page: () => _wrapWithMainLayout(const ProductListScreen(), productList),
        transition: Transition.rightToLeft,
      ),

      // Menu Routes
      GetPage(
          name: products,
          page: () => _wrapWithMainLayout(const ProductScreen(), products)),
      GetPage(
        name: ingredients,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Bahan'), ingredients),
      ),

      // Kitchen Routes
      GetPage(
        name: kitchen,
        page: () => _wrapWithMainLayout(const KitchenScreen(), kitchen),
      ),

      // Account Routes
      GetPage(
        name: account,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Akun'), account),
      ),
      GetPage(
        name: accountRoleUsers,
        page: () =>
            _wrapWithMainLayout(const AkunRoleUsersScreen(), accountRoleUsers),
        transition: Transition.rightToLeft,
      ),

      // Referral Routes
      GetPage(
        name: referral,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Referral'), referral),
      ),
      GetPage(
        name: referralManagement,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Kelola Referral'),
            referralManagement),
      ),
      GetPage(
        name: referralWithdrawal,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Pencairan'), referralWithdrawal),
      ),

      // Points Routes
      GetPage(
        name: points,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Points'), points),
      ),
      GetPage(
        name: pointsGifts,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Hadiah'), pointsGifts),
      ),
      GetPage(
        name: pointsHistory,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Riwayat Penukaran'), pointsHistory),
      ),
      GetPage(
        name: pointsConfiguration,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Konfigurasi Point'),
            pointsConfiguration),
      ),

      // Settings Sub-routes
      GetPage(
        name: theme,
        page: () =>
            _wrapWithMainLayout(const PlaceholderScreen(title: 'Tema'), theme),
      ),
      GetPage(
        name: taxConfiguration,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Konfigurasi Pajak'),
            taxConfiguration),
      ),
      GetPage(
        name: qrisConfiguration,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Konfigurasi QRIS'),
            qrisConfiguration),
      ),
      GetPage(
        name: logs,
        page: () =>
            _wrapWithMainLayout(const PlaceholderScreen(title: 'Logs'), logs),
      ),
    ];
  }

  // 404 Handler
  static GetPage get unknownRoute {
    return GetPage(name: '/not-found', page: () => const NotFoundScreen());
  }

  // Helper methods untuk navigation yang sering dipakai
  static void toSplash() => Get.offAllNamed(splash);
  static void toLogin() => Get.offAllNamed(login);
  static void toHome() => Get.offAllNamed(home);
  static void toDashboard() => Get.toNamed(dashboard);
  static void toTables() => Get.toNamed(tables);
  static void toCustomers() => Get.toNamed(customers);
  static void toPromo() => Get.toNamed(promo);
  static void toSales() => Get.toNamed(sales);
  static void toSettings() => Get.toNamed(settings);
  static void toProducts() => Get.toNamed(products);
  static void toProductList(dynamic category) =>
      Get.toNamed(productList, arguments: category);
  static void toIngredients() => Get.toNamed(ingredients);
  static void toKitchen() => Get.toNamed(kitchen);
  static void toAccount() => Get.toNamed(account);

  // Method baru untuk navigasi ke screen akun role users
  static void toAccountRoleUsers(dynamic role) =>
      Get.toNamed(accountRoleUsers, arguments: role);

  // Referral navigation helpers
  static void toReferral() => Get.toNamed(referral);
  static void toReferralManagement() => Get.toNamed(referralManagement);
  static void toReferralWithdrawal() => Get.toNamed(referralWithdrawal);

  // Points navigation helpers
  static void toPoints() => Get.toNamed(points);
  static void toPointsGifts() => Get.toNamed(pointsGifts);
  static void toPointsHistory() => Get.toNamed(pointsHistory);
  static void toPointsConfiguration() => Get.toNamed(pointsConfiguration);

  // Settings navigation helpers
  static void toTheme() => Get.toNamed(theme);
  static void toTaxConfiguration() => Get.toNamed(taxConfiguration);
  static void toQrisConfiguration() => Get.toNamed(qrisConfiguration);
  static void toLogs() => Get.toNamed(logs);
}

// Placeholder Screen untuk screens yang belum dibuat
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                LucideIcons.construction,
                size: 48,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '$title Page',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Halaman ini sedang dalam pengembangan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(LucideIcons.arrowLeft, size: 18),
              label: const Text('Kembali'),
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
    );
  }
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
