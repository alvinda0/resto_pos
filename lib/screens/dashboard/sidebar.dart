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

  final List<MenuItem> _menuItems = [
    MenuItem(Icons.home, 'Beranda'),
    MenuItem(Icons.table_restaurant, 'Meja'),
    MenuItem(Icons.category, 'Menu dan Bahan', subItems: [
      MenuItem(Icons.category, 'Menu'),
      MenuItem(Icons.kitchen, 'Bahan'),
    ]),
    MenuItem(Icons.local_offer, 'Promo'),
    MenuItem(Icons.shopping_cart, 'Pesanan'),
    MenuItem(Icons.restaurant, 'Dapur'),
    MenuItem(Icons.person, 'Akun'),
    MenuItem(Icons.bar_chart, 'Laporan', subItems: [
      MenuItem(Icons.receipt_long, 'Transaksi'),
      MenuItem(Icons.account_balance_wallet, 'Wallet'),
    ]),
    MenuItem(Icons.person_add, 'Referral', subItems: [
      MenuItem(Icons.person_add, 'Kelola Referral'),
      MenuItem(Icons.attach_money, 'Pencairan'),
    ]),
    MenuItem(Icons.people, 'Customer'),
    MenuItem(Icons.stars, 'Points', subItems: [
      MenuItem(Icons.card_giftcard, 'Hadiah'),
      MenuItem(Icons.history, 'Riwayat Penukaran'),
      MenuItem(Icons.scale, 'Konfigurasi Point'),
    ]),
    MenuItem(Icons.settings, 'Pengaturan', subItems: [
      MenuItem(Icons.palette, 'Tema'),
      MenuItem(Icons.calculate, 'Konfigurasi Pajak'),
      MenuItem(Icons.qr_code, 'Konfigurasi QRIS'),
      MenuItem(Icons.article, 'Logs'),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _setInitialRoute();
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
      case '/products':
        _selectedIndex = 2;
        _selectedSubIndex = 0;
        _expandedMenuIndex = 2;
        break;
      case '/ingredients':
        _selectedIndex = 2;
        _selectedSubIndex = 1;
        _expandedMenuIndex = 2;
        break;
      case '/promo':
        _selectedIndex = 3;
        break;
      case '/sales':
        _selectedIndex = 4;
        break;
      case '/kitchen':
        _selectedIndex = 5;
        break;
      case '/account':
        _selectedIndex = 6;
        break;
      case '/referral':
        _selectedIndex = 8;
        _selectedSubIndex = 0;
        _expandedMenuIndex = 8;
        break;
      case '/referral/withdrawal':
        _selectedIndex = 8;
        _selectedSubIndex = 1;
        _expandedMenuIndex = 8;
        break;
      case '/customers':
        _selectedIndex = 9;
        break;
      case '/points/gifts':
        _selectedIndex = 10;
        _selectedSubIndex = 0;
        _expandedMenuIndex = 10;
        break;
      case '/points/history':
        _selectedIndex = 10;
        _selectedSubIndex = 1;
        _expandedMenuIndex = 10;
        break;
      case '/points/configuration':
        _selectedIndex = 10;
        _selectedSubIndex = 2;
        _expandedMenuIndex = 10;
        break;
      case '/settings/theme':
        _selectedIndex = 11;
        _selectedSubIndex = 0;
        _expandedMenuIndex = 11;
        break;
      case '/settings/tax':
        _selectedIndex = 11;
        _selectedSubIndex = 1;
        _expandedMenuIndex = 11;
        break;
      case '/settings/qris':
        _selectedIndex = 11;
        _selectedSubIndex = 2;
        _expandedMenuIndex = 11;
        break;
      case '/settings/logs':
        _selectedIndex = 11;
        _selectedSubIndex = 3;
        _expandedMenuIndex = 11;
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
        case 2: // Menu dan Bahan
          switch (subIndex) {
            case 0:
              routeName = '/products';
              break;
            case 1:
              routeName = '/ingredients';
              break;
          }
          break;
        case 7: // Laporan - Note: These routes don't exist in AppRoutes yet
          switch (subIndex) {
            case 0:
              // routeName = '/reports/transactions'; // Add to AppRoutes if needed
              Get.snackbar(
                  'Info', 'Halaman Laporan Transaksi dalam pengembangan');
              return;
            case 1:
              // routeName = '/reports/wallet'; // Add to AppRoutes if needed
              Get.snackbar('Info', 'Halaman Laporan Wallet dalam pengembangan');
              return;
          }
          break;
        case 8: // Referral
          switch (subIndex) {
            case 0:
              routeName = '/referral';
              break;
            case 1:
              routeName = '/referral/withdrawal';
              break;
          }
          break;
        case 10: // Points
          switch (subIndex) {
            case 0:
              routeName = '/points/gifts';
              break;
            case 1:
              routeName = '/points/history';
              break;
            case 2:
              routeName = '/points/configuration';
              break;
          }
          break;
        case 11: // Pengaturan
          switch (subIndex) {
            case 0:
              routeName = '/settings/theme';
              break;
            case 1:
              routeName = '/settings/tax';
              break;
            case 2:
              routeName = '/settings/qris';
              break;
            case 3:
              routeName = '/settings/logs';
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
          routeName = '/promo';
          break;
        case 4:
          routeName = '/sales';
          break;
        case 5:
          routeName = '/kitchen';
          break;
        case 6:
          routeName = '/account';
          break;
        case 9:
          routeName = '/customers';
          break;
      }
    }

    // Use GetX navigation
    if (routeName != Get.currentRoute) {
      Get.offAllNamed(routeName);
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
