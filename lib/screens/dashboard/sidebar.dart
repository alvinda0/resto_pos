import 'package:flutter/material.dart';
import 'package:pos/screens/akun/akun_role_screen.dart';
import 'package:pos/screens/auth/login_screen.dart';
import 'package:pos/screens/dashboard/customers_screen.dart';
import 'package:pos/screens/dashboard/dashboard_screen.dart';
import 'package:pos/screens/inventory/inventory_screen.dart';
import 'package:pos/screens/menu/products_screen.dart';
import 'package:pos/screens/dashboard/promo_screen.dart';
import 'package:pos/screens/dashboard/order_screen.dart';
import 'package:pos/screens/referral/referral_screen.dart';
import 'package:pos/screens/table/tables_screen.dart';
import 'package:pos/screens/withdraw/withdraw_screen.dart';

class MenuItem {
  final IconData icon;
  final String title;
  final List<MenuItem>? subItems;
  final bool isExpanded;

  MenuItem(this.icon, this.title, {this.subItems, this.isExpanded = false});
}

class SideBarScreen extends StatefulWidget {
  const SideBarScreen({super.key});

  @override
  State<SideBarScreen> createState() => _SideBarScreenState();
}

class _SideBarScreenState extends State<SideBarScreen> {
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
  }

  @override
  void dispose() {
    super.dispose();
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
        // Jangan set _selectedIndex untuk menu yang memiliki submenu
        // _selectedIndex = index;
        // _selectedSubIndex = null;
      }
    });
  }

  Widget _getSelectedPage() {
    if (_selectedSubIndex != null) {
      switch (_selectedIndex) {
        case 2: // Menu dan Bahan
          switch (_selectedSubIndex) {
            case 0:
              return const ProductScreen(); // Menu
            case 1:
              return const InventoryScreen(); // Bahan
          }
          break;
        case 8: // Referral
          switch (_selectedSubIndex) {
            case 0:
              return ReferralScreen();
            case 1:
              return const WithdrawScreen(); // Pencairan
          }
          break;
        case 9: // Points
          switch (_selectedSubIndex) {
            case 0:
              return const Center(
                  child: Text('Hadiah Page', style: TextStyle(fontSize: 24)));
            case 1:
              return const Center(
                  child: Text('Riwayat Penukaran Page',
                      style: TextStyle(fontSize: 24)));
            case 2:
              return const Center(
                  child: Text('Konfigurasi Point Page',
                      style: TextStyle(fontSize: 24)));
          }
          break;
        case 10: // Pengaturan
          switch (_selectedSubIndex) {
            case 0:
              return const Center(
                  child: Text('Tema Page', style: TextStyle(fontSize: 24)));
            case 1:
              return ReferralScreen(); // Konfigurasi Pajak
            case 2:
              return const Center(
                  child: Text('Konfigurasi QRIS Page',
                      style: TextStyle(fontSize: 24)));
            case 3:
              return const Center(
                  child: Text('Logs Page', style: TextStyle(fontSize: 24)));
          }
          break;
      }
    }

    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen(); // Beranda
      case 1:
        return const TableScreen(); // Meja
      case 3:
        return const PromoScreen(); // Promo
      case 4:
        return const OrderScreen(); // Pesanan
      case 5:
        return const Center(
            child: Text('Dapur Page', style: TextStyle(fontSize: 24)));
      case 6:
        return const AkunRoleScreen();
      case 8:
        return const CustomersScreen(); // Customer
      default:
        return const DashboardScreen();
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
                // Jika memiliki submenu dan sidebar expanded, toggle submenu
                _toggleSubmenu(index);
              } else if (hasSubItems && !showExpanded) {
                // Jika memiliki submenu tapi sidebar collapsed, expand sidebar dulu
                _isSidebarExpanded = true;
                _expandedMenuIndex = index;
              } else {
                // Jika tidak memiliki submenu, set sebagai selected
                _selectedIndex = index;
                _selectedSubIndex = null;
                _expandedMenuIndex = null;
                // Close mobile sidebar when item is selected
                if (isMobile) {
                  _isMobileSidebarOpen = false;
                }
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
          onTap: () {
            setState(() {
              _selectedIndex = mainIndex;
              _selectedSubIndex = subIndex;
              // Close mobile sidebar when sub-item is selected
              if (isMobile) {
                _isMobileSidebarOpen = false;
              }
            });
          },
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
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content:
                              const Text('Apakah Anda yakin ingin keluar?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
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
                        child: _getSelectedPage(),
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
