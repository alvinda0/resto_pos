// layouts/main_layout.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuItem {
  final IconData icon;
  final String title;
  final List<MenuItem>? subItems;
  final bool isExpanded;

  MenuItem(this.icon, this.title, {this.subItems, this.isExpanded = false});
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
  int _selectedIndex = 0;
  int? _selectedSubIndex;
  int? _expandedMenuIndex;
  bool _isSidebarExpanded = false;
  bool _isMobileSidebarOpen = false;

  // Add this controller to manage page content
  Widget _currentPageWidget = Container();

  final List<MenuItem> _menuItems = [
    MenuItem(Icons.home, 'Beranda'),
    MenuItem(Icons.table_restaurant, 'Meja'),
    MenuItem(Icons.layers, 'Produk dan Bahan', subItems: [
      MenuItem(Icons.layers, 'Produk'),
      MenuItem(Icons.category, 'Kategori'),
      MenuItem(Icons.kitchen, 'Bahan'),
      MenuItem(Icons.restaurant_menu, 'Resep'),
    ]),
    MenuItem(Icons.percent, 'Promo'),
    MenuItem(Icons.shopping_cart, 'Pesanan'),
    MenuItem(Icons.restaurant, 'Dapur'),
    MenuItem(Icons.description, 'Akun dan Role', subItems: [
      MenuItem(Icons.person_add, 'Role'),
      MenuItem(Icons.person, 'Akun'),
    ]),
    MenuItem(Icons.description, 'Laporan', subItems: [
      MenuItem(Icons.receipt_long, 'Transaksi'),
      MenuItem(Icons.account_balance_wallet, 'Dompet'),
    ]),
    MenuItem(Icons.inventory, 'Aset'),
    MenuItem(Icons.person_add, 'Referral', subItems: [
      MenuItem(Icons.person_add, 'Kelola Referral'),
      MenuItem(Icons.attach_money, 'Pencairan'),
    ]),
    MenuItem(Icons.trending_up, 'Pendapatan'),
    MenuItem(Icons.account_balance_wallet, 'Pencairan'),
    MenuItem(Icons.key, 'Ganti Password'),
    MenuItem(Icons.people, 'Pelanggan'),
    MenuItem(Icons.card_giftcard, 'Poin', subItems: [
      MenuItem(Icons.card_giftcard, 'Hadiah'),
      MenuItem(Icons.history, 'Riwayat Penukaran'),
      MenuItem(Icons.tune, 'Konfigurasi Poin'),
    ]),
    MenuItem(Icons.settings, 'Pengaturan', subItems: [
      MenuItem(Icons.palette, 'Tema'),
      MenuItem(Icons.account_balance, 'Konfigurasi Pajak'),
      MenuItem(Icons.qr_code, 'Konfigurasi QRIS'),
      MenuItem(Icons.description, 'Logs'),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _currentPageWidget = widget.child;
    _setInitialRoute();
  }

  @override
  void didUpdateWidget(MainLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      setState(() {
        _currentPageWidget = widget.child;
      });
    }
  }

  void _setInitialRoute() {
    // Set selected index based on current route using GetX route names
    final currentRoute = Get.currentRoute;

    switch (currentRoute) {
      case '/dashboard':
        _selectedIndex = 0;
        break;
      case '/tables':
        _selectedIndex = 1;
        break;
      case '/product':
        _selectedIndex = 2;
        _selectedSubIndex = 0;
        _expandedMenuIndex = 2;
        break;
      case '/categories':
        _selectedIndex = 2;
        _selectedSubIndex = 1;
        _expandedMenuIndex = 2;
        break;
      case '/material':
        _selectedIndex = 2;
        _selectedSubIndex = 2;
        _expandedMenuIndex = 2;
        break;
      case '/recipe':
        _selectedIndex = 2;
        _selectedSubIndex = 3;
        _expandedMenuIndex = 2;
        break;
      case '/promos':
        _selectedIndex = 3;
        break;
      case '/orders':
        _selectedIndex = 4;
        break;
      case '/kitchen':
        _selectedIndex = 5;
        break;
      case '/manage-account':
        _selectedIndex = 6;
        _selectedSubIndex = 0;
        _expandedMenuIndex = 6;
        break;
      case '/account':
        _selectedIndex = 6;
        _selectedSubIndex = 1;
        _expandedMenuIndex = 6;
        break;
      case '/report':
        _selectedIndex = 7;
        _selectedSubIndex = 0;
        _expandedMenuIndex = 7;
        break;
      case '/wallet':
        _selectedIndex = 7;
        _selectedSubIndex = 1;
        _expandedMenuIndex = 7;
        break;
      case '/assets':
        _selectedIndex = 8;
        break;
      case '/referral':
        _selectedIndex = 9;
        _selectedSubIndex = 0;
        _expandedMenuIndex = 9;
        break;
      case '/withdraw':
        _selectedIndex = 9;
        _selectedSubIndex = 1;
        _expandedMenuIndex = 9;
        break;
      case '/income':
        _selectedIndex = 10;
        break;
      case '/disbursement':
        _selectedIndex = 11;
        break;
      case '/password':
        _selectedIndex = 12;
        break;
      case '/customers':
        _selectedIndex = 13;
        break;
      case '/points/rewards':
        _selectedIndex = 14;
        _selectedSubIndex = 0;
        _expandedMenuIndex = 14;
        break;
      case '/points/redemptions-history':
        _selectedIndex = 14;
        _selectedSubIndex = 1;
        _expandedMenuIndex = 14;
        break;
      case '/points/configuration':
        _selectedIndex = 14;
        _selectedSubIndex = 2;
        _expandedMenuIndex = 14;
        break;
      case '/settings/themes':
        _selectedIndex = 15;
        _selectedSubIndex = 0;
        _expandedMenuIndex = 15;
        break;
      case '/settings/tax':
        _selectedIndex = 15;
        _selectedSubIndex = 1;
        _expandedMenuIndex = 15;
        break;
      case '/settings/credentials':
        _selectedIndex = 15;
        _selectedSubIndex = 2;
        _expandedMenuIndex = 15;
        break;
      case '/settings/logs-viewer':
        _selectedIndex = 15;
        _selectedSubIndex = 3;
        _expandedMenuIndex = 15;
        break;
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

  // Modified navigation method - menggunakan Get.toNamed() alih-alih Get.offAllNamed()
  void _navigateToPage(int index, [int? subIndex]) {
    setState(() {
      _selectedIndex = index;
      _selectedSubIndex = subIndex;
      _expandedMenuIndex = subIndex != null ? index : null;
      if (isMobile) {
        _isMobileSidebarOpen = false;
      }
    });

    // Navigate using GetX routing
    String routeName = '/dashboard';

    if (subIndex != null) {
      switch (index) {
        case 2: // Produk dan Bahan
          switch (subIndex) {
            case 0:
              routeName = '/product';
              break;
            case 1:
              routeName = '/categories';
              break;
            case 2:
              routeName = '/material';
              break;
            case 3:
              routeName = '/recipe';
              break;
          }
          break;
        case 6: // Akun dan Role
          switch (subIndex) {
            case 0:
              routeName = '/manage-account';
              break;
            case 1:
              routeName = '/account';
              break;
          }
          break;
        case 7: // Laporan
          switch (subIndex) {
            case 0:
              routeName = '/report';
              break;
            case 1:
              routeName = '/wallet';
              break;
          }
          break;
        case 9: // Referral
          switch (subIndex) {
            case 0:
              routeName = '/referral';
              break;
            case 1:
              routeName = '/withdraw';
              break;
          }
          break;
        case 14: // Poin
          switch (subIndex) {
            case 0:
              routeName = '/points/rewards';
              break;
            case 1:
              routeName = '/points/redemptions-history';
              break;
            case 2:
              routeName = '/points/configuration';
              break;
          }
          break;
        case 15: // Pengaturan
          switch (subIndex) {
            case 0:
              routeName = '/settings/themes';
              break;
            case 1:
              routeName = '/settings/tax';
              break;
            case 2:
              routeName = '/settings/credentials';
              break;
            case 3:
              routeName = '/settings/logs-viewer';
              break;
          }
          break;
      }
    } else {
      switch (index) {
        case 0:
          routeName = '/dashboard';
          break;
        case 1:
          routeName = '/tables';
          break;
        case 3:
          routeName = '/promos';
          break;
        case 4:
          routeName = '/orders';
          break;
        case 5:
          routeName = '/kitchen';
          break;
        case 8:
          routeName = '/assets';
          break;
        case 10:
          routeName = '/income';
          break;
        case 11:
          routeName = '/disbursement';
          break;
        case 12:
          routeName = '/password';
          break;
        case 13:
          routeName = '/customers';
          break;
      }
    }

    // Use Get.toNamed() instead of Get.offAllNamed() to preserve the layout
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
            setState(() {
              if (hasSubItems && showExpanded) {
                _toggleSubmenu(index);
              } else if (hasSubItems && !showExpanded) {
                _isSidebarExpanded = true;
                _expandedMenuIndex = index;
              } else {
                _navigateToPage(index);
              }
            });
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
                      'POS System',
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
                        if (item.subItems != null && isExpanded && showExpanded)
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
                        onConfirm: () {
                          Get.back(); // Close dialog
                          Get.offAllNamed('/login');
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
                                'POS System',
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

                    // Main content area - menggunakan widget child langsung
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                        ),
                        child:
                            widget.child, // Langsung menggunakan widget.child
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
