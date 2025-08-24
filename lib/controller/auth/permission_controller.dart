import 'package:get/get.dart';
import 'package:pos/services/auth_service.dart';

class PermissionController extends GetxService {
  static PermissionController get instance {
    if (!Get.isRegistered<PermissionController>()) {
      Get.put(PermissionController());
    }
    return Get.find<PermissionController>();
  }

  final AuthService _authService = AuthService.instance;
  final RxList<String> _userPermissions = <String>[].obs;
  final RxBool _isLoading = true.obs; // Start with true
  final RxBool _isInitialized = false.obs; // Track initialization

  // Getters
  List<String> get userPermissions => _userPermissions;
  bool get isLoading => _isLoading.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadUserPermissions();
  }

  /// Load user permissions from server
  Future<void> loadUserPermissions() async {
    try {
      _isLoading.value = true;

      final result = await _authService.getCurrentUser();

      if (result.success && result.data != null) {
        // Update permissions dari response API /auth/me
        _userPermissions.value = result.data!.permissions;
      } else {
        // Fallback to stored user data jika ada
        final storedUser = _authService.getStoredUser();
        if (storedUser != null) {
          // Coba load dari server sekali lagi
          await _loadFromServer();
        } else {
          _userPermissions.value = [];
        }
      }
    } catch (e) {
      print('Error loading user permissions: $e');
      _userPermissions.value = [];
    } finally {
      _isLoading.value = false;
      _isInitialized.value = true;
    }
  }

  /// Force reload permissions from server
  Future<void> _loadFromServer() async {
    try {
      final result = await _authService.getCurrentUser();
      if (result.success && result.data != null) {
        _userPermissions.value = result.data!.permissions;
      }
    } catch (e) {
      print('Error loading from server: $e');
    }
  }

  /// Check if user has specific permission
  bool hasAllPermissions(List<String> permissions) {
    // Jika user memiliki full:access, berikan akses ke semua
    if (_userPermissions.contains('full:access')) {
      return true;
    }

    return permissions
        .every((permission) => _userPermissions.contains(permission));
  }

  /// Check if user has any of the given permissions
  bool hasAnyPermission(List<String> permissions) {
    // Jika user memiliki full:access, berikan akses ke semua
    if (_userPermissions.contains('full:access')) {
      return true;
    }

    return permissions
        .any((permission) => _userPermissions.contains(permission));
  }

  /// Get permissions for menu visibility
  Map<String, List<String>> get menuPermissions => {
        // DASHBOARD - accessible to everyone with view:dashboard
        'dashboard': [],

        // OPERASIONAL
        'tables': [
          "view:qrcode",
          "create:qrcode",
          "update:qrcode",
          "delete:qrcode",
          "scan:qrcode"
        ],
        'orders': [
          "view:order",
          "create:order",
          "update:order",
          "delete:order"
        ],
        'kitchen': [
          "view:order",
          "create:order",
          "update:order",
          "delete:order"
        ],
        'promos': [
          "view:promotion",
          "create:promotion",
          "update:promotion",
          "delete:promotion",
          "view:promotion_usage"
        ],

        // PRODUK & INVENTORI
        'products': [
          "view:product",
          "create:product",
          "update:product",
          "delete:product"
        ],
        'categories': [
          "view:category",
          "create:category",
          "update:category",
          "delete:category"
        ],
        'materials': [
          "view:inventory",
          "create:inventory",
          "update:inventory",
          "delete:inventory"
        ],
        'recipes': [
          "view:recipe",
          "create:recipe",
          "update:recipe",
          "delete:recipe"
        ],
        'assets': [
          // "view:asset",
          // "create:asset",
          // "update:asset",
          // "delete:asset"
          'view:dashboard'
        ],

        // KEUANGAN
        'income': ['view:dashboard'],
        'reports': ['view:dashboard'],
        'wallet': ['view:dashboard'],
        'bills': ['view:dashboard'],
        'profit': ['view:dashboard'],
        'disbursement': [
          "view:withdraw",
          "create:withdraw",
          "update:withdraw",
          "delete:withdraw"
        ],

        // MANAJEMEN SDM
        'employees': ['view:dashboard'],
        'employee_payments': ['view:dashboard'],
        'roles': ["view:role", "create:role", "update:role", "delete:role"],
        'accounts': [
          "view:user",
          "create:user",
          "update:user",
          "delete:user",
        ],

        // PELANGGAN & LOYALTY
        'customers': [
          "view:customer",
          "create:customer",
          "update:customer",
          "delete:customer"
        ],
        'point_rewards': [
          "view:reward",
          "create:reward",
          "update:reward",
          "delete:reward",
        ],
        'redemption_history': [
          "view:reward_redemption",
          "create:reward_redemption",
          "update:reward_redemption",
          "delete:reward_redemption",
        ],
        'point_config': [
          "view:point_config",
          "create:point_config",
          "update:point_config",
          "delete:point_config",
        ],

        // REFERRAL
        'referrals': [
          "view:referral",
          "create:referral",
          "update:referral",
          "delete:referral"
        ],
        'referral_withdraw': [
          "view:withdraw",
          "create:withdraw",
          "update:withdraw",
          "delete:withdraw"
        ],

        // PENGATURAN
        'themes': [
          "view:theme",
          "create:theme",
          "update:theme",
          "delete:theme"
        ],
        'tax_config': [
          "view:tax",
          "create:tax",
          "update:tax",
          "delete:tax",
          "view:tax_report",
        ],
        'qris_config': [
          "view:api_key",
          "create:api_key",
          "update:api_key",
          "delete:api_key",
        ],
        'change_password': ['view:dashboard'],
        'printer': [],
      };

  Future<void> refreshPermissions() async {
    await loadUserPermissions();
  }

  /// Clear permissions (untuk logout)
  void clearPermissions() {
    _userPermissions.clear();
    _isInitialized.value = false;
  }
}
