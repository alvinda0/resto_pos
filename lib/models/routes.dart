import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pos/screens/account/account_screen.dart';
import 'package:pos/screens/role/role_screen.dart';
import 'package:pos/screens/auth/login_screen.dart';
import 'package:pos/screens/dashboard/sidebar.dart';
import 'package:pos/screens/inventory/inventory_screen.dart';
import 'package:pos/screens/kitchen/kitchen_screen.dart';
import 'package:pos/screens/product/product_screen.dart';
import 'package:pos/screens/recipe/recipe_screen.dart';
import 'package:pos/screens/splash_screen/splash_screen.dart';
import 'package:pos/screens/dashboard/dashboard_screen.dart';
import 'package:pos/screens/dashboard/customers_screen.dart';
import 'package:pos/screens/dashboard/promo_screen.dart';
import 'package:pos/screens/dashboard/order_screen.dart';
import 'package:pos/screens/category/category_screen.dart';
import 'package:pos/screens/table/tables_screen.dart';

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

  // Product and Material Routes (Produk dan Bahan)
  static const String product = '/product';
  static const String categories = '/categories';
  static const String material = '/material';
  static const String recipe = '/recipe';

  // Other Main Routes
  static const String promos = '/promos';
  static const String orders = '/orders';
  static const String kitchen = '/kitchen';

  // Account and Role Routes (Akun dan Role)
  static const String manageAccount = '/manage-account';
  static const String account = '/account';

  // Report Routes (Laporan)
  static const String report = '/report';
  static const String wallet = '/wallet';

  // New Standalone Routes
  static const String assets = '/assets';
  static const String income = '/income';
  static const String disbursement = '/disbursement';
  static const String password = '/password';
  static const String customers = '/customers';

  // Referral Routes
  static const String referral = '/referral';
  static const String withdraw = '/withdraw';

  // Points Routes (Poin)
  static const String pointsRewards = '/points/rewards';
  static const String pointsRedemptionsHistory = '/points/redemptions-history';
  static const String pointsConfiguration = '/points/configuration';

  // Settings Routes (Pengaturan)
  static const String settingsThemes = '/settings/themes';
  static const String settingsTax = '/settings/tax';
  static const String settingsCredentials = '/settings/credentials';
  static const String settingsLogsViewer = '/settings/logs-viewer';

  // Legacy routes (for backward compatibility)
  static const String products = '/products'; // maps to /product
  static const String ingredients = '/ingredients'; // maps to /material
  static const String sales = '/sales'; // maps to /orders
  static const String promo = '/promo'; // maps to /promos

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

      // Product and Material Routes (Produk dan Bahan)
      GetPage(
          name: product,
          page: () => _wrapWithMainLayout(ProductManagementScreen(), product)),
      GetPage(
        name: categories,
        page: () =>
            _wrapWithMainLayout(const CategoryManagementScreen(), categories),
      ),
      GetPage(
        name: material,
        page: () => _wrapWithMainLayout(const InventoryScreen(), material),
      ),
      GetPage(
        name: recipe,
        page: () => _wrapWithMainLayout(const RecipeManagementScreen(), recipe),
      ),

      // Other Main Routes
      GetPage(
          name: promos,
          page: () => _wrapWithMainLayout(const PromoScreen(), promos)),
      GetPage(
          name: orders,
          page: () => _wrapWithMainLayout(const OrderScreen(), orders)),
      GetPage(
        name: kitchen,
        page: () => _wrapWithMainLayout(const KitchenScreen(), kitchen),
      ),

      // Account and Role Routes (Akun dan Role)
      GetPage(
        name: manageAccount,
        page: () => _wrapWithMainLayout(const RoleScreen(), manageAccount),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: account,
        page: () => _wrapWithMainLayout(const UserManagementScreen(), account),
      ),

      // Report Routes (Laporan)
      GetPage(
        name: report,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Laporan Transaksi'), report),
      ),
      GetPage(
        name: wallet,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Dompet'), wallet),
      ),

      // New Standalone Routes
      GetPage(
        name: assets,
        page: () =>
            _wrapWithMainLayout(const PlaceholderScreen(title: 'Aset'), assets),
      ),
      GetPage(
        name: income,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Pendapatan'), income),
      ),
      GetPage(
        name: disbursement,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Pencairan'), disbursement),
      ),
      GetPage(
        name: password,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Ganti Password'), password),
      ),
      GetPage(
          name: customers,
          page: () => _wrapWithMainLayout(const CustomersScreen(), customers)),

      // Referral Routes
      GetPage(
        name: referral,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Kelola Referral'), referral),
      ),
      GetPage(
        name: withdraw,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Pencairan Referral'), withdraw),
      ),

      // Points Routes (Poin)
      GetPage(
        name: pointsRewards,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Hadiah'), pointsRewards),
      ),
      GetPage(
        name: pointsRedemptionsHistory,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Riwayat Penukaran'),
            pointsRedemptionsHistory),
      ),
      GetPage(
        name: pointsConfiguration,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Konfigurasi Poin'),
            pointsConfiguration),
      ),

      // Settings Routes (Pengaturan)
      GetPage(
        name: settingsThemes,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Tema'), settingsThemes),
      ),
      GetPage(
        name: settingsTax,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Konfigurasi Pajak'), settingsTax),
      ),
      GetPage(
        name: settingsCredentials,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Konfigurasi QRIS'),
            settingsCredentials),
      ),
      GetPage(
        name: settingsLogsViewer,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Logs'), settingsLogsViewer),
      ),

      // Legacy Routes (for backward compatibility)
      GetPage(
        name: products,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Logs'), product),
      ),
      GetPage(
        name: ingredients,
        page: () => _wrapWithMainLayout(
            const PlaceholderScreen(title: 'Logs'), material),
      ),
      GetPage(
        name: sales,
        page: () =>
            _wrapWithMainLayout(const PlaceholderScreen(title: 'Logs'), orders),
      ),
      GetPage(
        name: promo,
        page: () =>
            _wrapWithMainLayout(const PlaceholderScreen(title: 'Logs'), promos),
      ),

      // Product List Route (existing functionality)
      GetPage(
        name: '/product',
        page: () => _wrapWithMainLayout(ProductManagementScreen(), '/product'),
        transition: Transition.rightToLeft,
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

  // Product and Material navigation helpers (Produk dan Bahan)
  static void toProduct() => Get.toNamed(product);
  static void toCategories() => Get.toNamed(categories);
  static void toMaterial() => Get.toNamed(material);
  static void toRecipe() => Get.toNamed(recipe);

  // Other main navigation helpers
  static void toPromos() => Get.toNamed(promos);
  static void toOrders() => Get.toNamed(orders);
  static void toKitchen() => Get.toNamed(kitchen);

  // Account and Role navigation helpers (Akun dan Role)
  static void toManageAccount() => Get.toNamed(manageAccount);
  static void toAccount() => Get.toNamed(account);

  // Report navigation helpers (Laporan)
  static void toReport() => Get.toNamed(report);
  static void toWallet() => Get.toNamed(wallet);

  // New standalone navigation helpers
  static void toAssets() => Get.toNamed(assets);
  static void toIncome() => Get.toNamed(income);
  static void toDisbursement() => Get.toNamed(disbursement);
  static void toPassword() => Get.toNamed(password);
  static void toCustomers() => Get.toNamed(customers);

  // Referral navigation helpers
  static void toReferral() => Get.toNamed(referral);
  static void toWithdraw() => Get.toNamed(withdraw);

  // Points navigation helpers (Poin)
  static void toPointsRewards() => Get.toNamed(pointsRewards);
  static void toPointsRedemptionsHistory() =>
      Get.toNamed(pointsRedemptionsHistory);
  static void toPointsConfiguration() => Get.toNamed(pointsConfiguration);

  // Settings navigation helpers (Pengaturan)
  static void toSettingsThemes() => Get.toNamed(settingsThemes);
  static void toSettingsTax() => Get.toNamed(settingsTax);
  static void toSettingsCredentials() => Get.toNamed(settingsCredentials);
  static void toSettingsLogsViewer() => Get.toNamed(settingsLogsViewer);

  // Legacy navigation helpers (for backward compatibility)
  static void toProducts() => Get.toNamed(product); // Redirect to new route
  static void toIngredients() => Get.toNamed(material); // Redirect to new route
  static void toSales() => Get.toNamed(orders); // Redirect to new route
  static void toPromo() => Get.toNamed(promos); // Redirect to new route

  // Product List navigation (existing functionality)
  static void toProductList(dynamic category) =>
      Get.toNamed('/product-list', arguments: category);

  // Method untuk navigasi ke screen akun role users dengan arguments
  static void toAccountRoleUsers(dynamic role) =>
      Get.toNamed(manageAccount, arguments: role);
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
                  onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
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
