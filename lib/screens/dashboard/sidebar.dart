import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/auth/auth_controller.dart';
import 'package:pos/controller/auth/permission_controller.dart';
import 'package:pos/services/auth_service.dart';

class MenuItem {
  final IconData icon;
  final String title;
  final List<MenuItem>? subItems;
  final bool isExpanded;
  final String? permissionKey;

  MenuItem(
    this.icon,
    this.title, {
    this.subItems,
    this.isExpanded = false,
    this.permissionKey,
  });
}

class MainLayout extends StatefulWidget {
  final Widget child;
  final String? currentRoute;

  const MainLayout({
    super.key,
    required this.child,
    this.currentRoute,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Static variables untuk menyimpan state sidebar
  static int _selectedIndex = 0;
  static int? _selectedSubIndex;
  static int? _expandedMenuIndex;
  static bool _isSidebarExpanded = false;
  static bool _isMobileSidebarOpen = false;
  static bool _hasInitializedRoute = false;

  final PermissionController _permissionController =
      PermissionController.instance;

  // Menu yang dikelompokkan berdasarkan kategori dengan permission keys
  final List<MenuItem> _allMenuItems = [
    // DASHBOARD
    MenuItem(Icons.dashboard, 'Dashboard', permissionKey: 'dashboard'),

    // OPERASIONAL
    MenuItem(Icons.store, 'Operasional', subItems: [
      MenuItem(Icons.table_restaurant, 'Meja', permissionKey: 'tables'),
      MenuItem(Icons.shopping_cart, 'Pesanan', permissionKey: 'orders'),
      MenuItem(Icons.restaurant, 'Dapur', permissionKey: 'kitchen'),
      MenuItem(Icons.percent, 'Promo', permissionKey: 'promos'),
    ]),

    // PRODUK & INVENTORI
    MenuItem(Icons.inventory_2, 'Produk & Inventori', subItems: [
      MenuItem(Icons.layers, 'Produk', permissionKey: 'products'),
      MenuItem(Icons.category, 'Kategori', permissionKey: 'categories'),
      MenuItem(Icons.kitchen, 'Bahan', permissionKey: 'materials'),
      MenuItem(Icons.restaurant_menu, 'Resep', permissionKey: 'recipes'),
      MenuItem(Icons.inventory, 'Aset', permissionKey: 'assets'),
    ]),

    // KEUANGAN
    MenuItem(Icons.account_balance_wallet, 'Keuangan', subItems: [
      MenuItem(Icons.trending_up, 'Pendapatan', permissionKey: 'income'),
      MenuItem(Icons.receipt_long, 'Laporan Transaksi',
          permissionKey: 'reports'),
      MenuItem(Icons.account_balance_wallet, 'Dompet', permissionKey: 'wallet'),
      MenuItem(Icons.receipt_long, 'Tagihan', permissionKey: 'bills'),
      MenuItem(Icons.analytics, 'Keuntungan', permissionKey: 'profit'),
      MenuItem(Icons.account_balance_wallet, 'Pencairan',
          permissionKey: 'disbursement'),
    ]),

    // MANAJEMEN SDM
    MenuItem(Icons.people, 'Manajemen SDM', subItems: [
      MenuItem(Icons.person, 'Data Karyawan', permissionKey: 'employees'),
      MenuItem(Icons.payment, 'Pembayaran Karyawan',
          permissionKey: 'employee_payments'),
      MenuItem(Icons.person_add, 'Role', permissionKey: 'roles'),
      MenuItem(Icons.account_circle, 'Akun', permissionKey: 'accounts'),
    ]),

    // PELANGGAN & LOYALTY
    MenuItem(Icons.people_alt, 'Pelanggan & Loyalty', subItems: [
      MenuItem(Icons.people, 'Data Pelanggan', permissionKey: 'customers'),
      MenuItem(Icons.card_giftcard, 'Hadiah Poin',
          permissionKey: 'point_rewards'),
      MenuItem(Icons.history, 'Riwayat Penukaran',
          permissionKey: 'redemption_history'),
      MenuItem(Icons.tune, 'Konfigurasi Poin', permissionKey: 'point_config'),
    ]),

    // REFERRAL & PARTNERSHIP
    MenuItem(Icons.share, 'Referral', subItems: [
      MenuItem(Icons.person_add, 'Kelola Referral', permissionKey: 'referrals'),
      MenuItem(Icons.attach_money, 'Pencairan Referral',
          permissionKey: 'referral_withdraw'),
    ]),

    // PENGATURAN SISTEM
    MenuItem(Icons.settings, 'Pengaturan', subItems: [
      MenuItem(Icons.palette, 'Tema', permissionKey: 'themes'),
      MenuItem(Icons.account_balance, 'Konfigurasi Pajak',
          permissionKey: 'tax_config'),
      MenuItem(Icons.qr_code, 'Konfigurasi QRIS', permissionKey: 'qris_config'),
      MenuItem(Icons.key, 'Ganti Password', permissionKey: 'change_password'),
      MenuItem(Icons.description, 'Printer', permissionKey: 'printer'),
    ]),
  ];

  // Filtered menu items based on permissions
  List<MenuItem> get _menuItems {
    return _filterMenuItems(_allMenuItems);
  }

  @override
  void initState() {
    super.initState();
    // Initialize permission controller
    Get.put(PermissionController());

    // Hanya set initial route sekali saja
    if (!_hasInitializedRoute) {
      _setInitialRoute();
      _hasInitializedRoute = true;
    }
  }

  /// Filter menu items based on user permissions
  List<MenuItem> _filterMenuItems(List<MenuItem> items) {
    List<MenuItem> filteredItems = [];

    for (MenuItem item in items) {
      bool hasAccess = _checkMenuAccess(item);

      if (item.subItems != null && item.subItems!.isNotEmpty) {
        // Filter sub items
        List<MenuItem> filteredSubItems = _filterMenuItems(item.subItems!);

        // Only show parent if it has accessible sub items
        if (filteredSubItems.isNotEmpty) {
          filteredItems.add(MenuItem(
            item.icon,
            item.title,
            subItems: filteredSubItems,
            isExpanded: item.isExpanded,
            permissionKey: item.permissionKey,
          ));
        }
      } else if (hasAccess) {
        // Regular menu item - add if user has access
        filteredItems.add(item);
      }
    }

    return filteredItems;
  }

  /// Check if user has access to a menu item
  bool _checkMenuAccess(MenuItem item) {
    // If no permission key is specified, allow access
    if (item.permissionKey == null || item.permissionKey!.isEmpty) {
      return true;
    }

    // Special case for change password - everyone should be able to change password
    if (item.permissionKey == 'change_password') {
      return true;
    }

    // Get required permissions for this menu
    final requiredPermissions =
        _permissionController.menuPermissions[item.permissionKey];

    if (requiredPermissions == null || requiredPermissions.isEmpty) {
      return true; // No specific permissions required
    }

    // Check if user has any of the required permissions
    return _permissionController.hasAnyPermission(requiredPermissions);
  }

  void _setInitialRoute() {
    final currentRoute = Get.currentRoute;

    // Find the matching route in filtered menu items
    _findAndSetRoute(currentRoute, _menuItems);
  }

  void _findAndSetRoute(String currentRoute, List<MenuItem> menuItems) {
    for (int i = 0; i < menuItems.length; i++) {
      final item = menuItems[i];

      if (item.subItems != null && item.subItems!.isNotEmpty) {
        for (int j = 0; j < item.subItems!.length; j++) {
          final subItem = item.subItems![j];
          String routeName =
              _getRouteForMenuItem(item.permissionKey, subItem.permissionKey);

          if (routeName == currentRoute) {
            _selectedIndex = i;
            _selectedSubIndex = j;
            _expandedMenuIndex = i;
            return;
          }
        }
      } else {
        String routeName = _getRouteForMenuItem(item.permissionKey, null);
        if (routeName == currentRoute) {
          _selectedIndex = i;
          _selectedSubIndex = null;
          _expandedMenuIndex = null;
          return;
        }
      }
    }
  }

  String _getRouteForMenuItem(String? parentKey, String? subKey) {
    final key = subKey ?? parentKey;

    switch (key) {
      case 'dashboard':
        return '/dashboard';
      case 'tables':
        return '/tables';
      case 'orders':
        return '/orders';
      case 'kitchen':
        return '/kitchen';
      case 'promos':
        return '/promos';
      case 'products':
        return '/product';
      case 'categories':
        return '/categories';
      case 'materials':
        return '/material';
      case 'recipes':
        return '/recipe';
      case 'assets':
        return '/assets';
      case 'income':
        return '/income';
      case 'reports':
        return '/report';
      case 'wallet':
        return '/wallet';
      case 'bills':
        return '/report/bills';
      case 'profit':
        return '/report/profit';
      case 'disbursement':
        return '/disbursement';
      case 'employees':
        return '/employees';
      case 'employee_payments':
        return '/employees/payment';
      case 'roles':
        return '/manage-account';
      case 'accounts':
        return '/account';
      case 'customers':
        return '/customers';
      case 'point_rewards':
        return '/points/rewards';
      case 'redemption_history':
        return '/points/redemptions-history';
      case 'point_config':
        return '/points/configuration';
      case 'referrals':
        return '/referral';
      case 'referral_withdraw':
        return '/withdraw';
      case 'themes':
        return '/settings/themes';
      case 'tax_config':
        return '/settings/tax';
      case 'qris_config':
        return '/settings/credentials';
      case 'change_password':
        return '/password';
      case 'printer':
        return '/settings/printer';
      default:
        return '/dashboard';
    }
  }

  bool get isMobile => MediaQuery.of(context).size.width < 768;

  void _toggleSidebar() {
    setState(() {
      if (isMobile) {
        _isMobileSidebarOpen = !_isMobileSidebarOpen;
      } else {
        _isSidebarExpanded = !_isSidebarExpanded;
        if (!_isSidebarExpanded) {
          _expandedMenuIndex = null;
        }
      }
    });
  }

  void _closeMobileSidebar() {
    if (isMobile && _isMobileSidebarOpen) {
      setState(() {
        _isMobileSidebarOpen = false;
      });
    }
  }

  void _toggleSubmenu(int index) {
    setState(() {
      if (_expandedMenuIndex == index) {
        _expandedMenuIndex = null;
      } else {
        _expandedMenuIndex = index;
      }
    });
  }

  void _navigateToPage(int index, [int? subIndex]) {
    setState(() {
      _selectedIndex = index;
      _selectedSubIndex = subIndex;
      _expandedMenuIndex = subIndex != null ? index : null;
      if (isMobile) {
        _isMobileSidebarOpen = false;
      }
    });

    final menuItems = _menuItems;
    String routeName = '/dashboard';

    if (index < menuItems.length) {
      final selectedItem = menuItems[index];

      if (subIndex != null &&
          selectedItem.subItems != null &&
          subIndex < selectedItem.subItems!.length) {
        final subItem = selectedItem.subItems![subIndex];
        routeName = _getRouteForMenuItem(
            selectedItem.permissionKey, subItem.permissionKey);
      } else {
        routeName = _getRouteForMenuItem(selectedItem.permissionKey, null);
      }
    }

    // Use Get.toNamed() untuk navigasi
    if (routeName != Get.currentRoute) {
      Get.toNamed(routeName);
    }
  }

  Widget _buildMenuItem(MenuItem item, int index) {
    final isSelected = _selectedIndex == index && _selectedSubIndex == null;
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;
    final isExpanded = _expandedMenuIndex == index;
    final showExpanded = isMobile ? _isMobileSidebarOpen : _isSidebarExpanded;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: showExpanded ? 12 : 6,
        vertical: 4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (hasSubItems && showExpanded) {
              _toggleSubmenu(index);
            } else if (hasSubItems && !showExpanded) {
              setState(() {
                _isSidebarExpanded = true;
                _expandedMenuIndex = index;
              });
            } else {
              _navigateToPage(index);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: BoxConstraints(
              minHeight: showExpanded ? 48 : 56,
            ),
            padding: EdgeInsets.symmetric(
              vertical: showExpanded ? 12 : 8,
              horizontal: showExpanded ? 16 : 8,
            ),
            decoration: BoxDecoration(
              color: (isSelected && !hasSubItems) || isExpanded
                  ? Colors.red.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isSelected && !hasSubItems) || isExpanded
                    ? Colors.red
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: showExpanded
                ? Row(
                    children: [
                      Icon(
                        item.icon,
                        color: (isSelected && !hasSubItems) || isExpanded
                            ? Colors.red
                            : Colors.white70,
                        size: 22,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: (isSelected && !hasSubItems) || isExpanded
                                ? Colors.white
                                : Colors.white70,
                            fontSize: 14,
                            fontWeight:
                                (isSelected && !hasSubItems) || isExpanded
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (hasSubItems)
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: (isSelected && !hasSubItems) || isExpanded
                                ? Colors.red
                                : Colors.white70,
                            size: 20,
                          ),
                        ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: (isSelected && !hasSubItems) || isExpanded
                              ? Colors.red
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (isSelected && !hasSubItems) || isExpanded
                                ? Colors.red
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: (isSelected && !hasSubItems) || isExpanded
                              ? Colors.white
                              : Colors.white70,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 70,
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: (isSelected && !hasSubItems) || isExpanded
                                ? Colors.white
                                : Colors.white60,
                            fontSize: 10,
                            fontWeight:
                                (isSelected && !hasSubItems) || isExpanded
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(MenuItem subItem, int mainIndex, int subIndex) {
    final isSelected =
        _selectedIndex == mainIndex && _selectedSubIndex == subIndex;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToPage(mainIndex, subIndex),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.red.shade400.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.red.shade400 : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red.shade400 : Colors.white60,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  subItem.icon,
                  color: isSelected ? Colors.red.shade400 : Colors.white60,
                  size: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subItem.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmenuList(List<MenuItem> subItems, int mainIndex) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: subItems.asMap().entries.map((entry) {
            return _buildSubMenuItem(entry.value, mainIndex, entry.key);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final showExpanded = isMobile ? _isMobileSidebarOpen : _isSidebarExpanded;
    final sidebarWidth = isMobile ? 280.0 : (showExpanded ? 250.0 : 90.0);

    return Obx(() {
      if (_permissionController.isLoading) {
        return Container(
          width: sidebarWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade700,
                Colors.deepPurple.shade800,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        );
      }

      // Jika tidak ada menu yang dapat diakses, tampilkan pesan
      if (_menuItems.isEmpty) {
        return Container(
          width: sidebarWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade700,
                Colors.deepPurple.shade800,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No accessible menu items',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: sidebarWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade700,
              Colors.deepPurple.shade800,
            ],
          ),
          boxShadow: isMobile
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 80,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (showExpanded) ...[
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'POS Shao Kao',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleSidebar,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isMobile
                              ? Icons.close
                              : (showExpanded
                                  ? Icons.chevron_left
                                  : Icons.chevron_right),
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Menu Items
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ...List.generate(_menuItems.length, (index) {
                      final item = _menuItems[index];
                      final isExpanded = _expandedMenuIndex == index;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMenuItem(item, index),
                          if (item.subItems != null &&
                              isExpanded &&
                              showExpanded)
                            _buildSubmenuList(item.subItems!, index),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Logout Button
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white24,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.defaultDialog(
                          title: 'Konfirmasi Logout',
                          middleText: 'Apakah Anda yakin ingin keluar?',
                          textConfirm: 'Logout',
                          textCancel: 'Batal',
                          confirmTextColor: Colors.white,
                          onConfirm: () async {
                            Get.back(); // Close dialog

                            // Gunakan AuthController untuk logout
                            try {
                              if (Get.isRegistered<AuthController>()) {
                                final authController = AuthController.instance;
                                await authController.logout();
                              } else {
                                // Manual logout jika AuthController tidak terdaftar
                                final authService = AuthService.instance;
                                await authService.logout();

                                if (Get.isRegistered<PermissionController>()) {
                                  final permissionController =
                                      PermissionController.instance;
                                  permissionController.clearPermissions();
                                  Get.delete<PermissionController>();
                                }

                                Get.offAllNamed('/login');
                              }
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'Error during logout: ${e.toString()}',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: showExpanded ? 16 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.red.shade400.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: showExpanded
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.logout,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            : const Icon(
                                Icons.logout,
                                color: Colors.white70,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main layout
          Row(
            children: [
              // Desktop sidebar
              if (!isMobile) _buildSidebar(),

              // Main content
              Expanded(
                child: Column(
                  children: [
                    // Mobile app bar
                    if (isMobile)
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.menu, color: Colors.black87),
                              onPressed: _toggleSidebar,
                            ),
                            const Expanded(
                              child: Text(
                                'POS Shao Kao',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Main content area
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Mobile sidebar overlay
          if (isMobile && _isMobileSidebarOpen) ...[
            // Backdrop
            GestureDetector(
              onTap: _closeMobileSidebar,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

            // Sidebar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildSidebar(),
            ),
          ],
        ],
      ),
    );
  }
}
