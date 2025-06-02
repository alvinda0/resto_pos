import 'package:flutter/material.dart';
import 'package:pos/screens/auth/login_screen.dart';
import 'package:pos/screens/dashboard/customers_page.dart';
import 'package:pos/screens/dashboard/dashboard_page.dart';
import 'package:pos/screens/menu/products_page.dart';
import 'package:pos/screens/dashboard/promo_page.dart';
import 'package:pos/screens/dashboard/sales_page.dart';
import 'package:pos/screens/dashboard/settings_page.dart';
import 'package:pos/screens/table/tables_page.dart';

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

  final List<MenuItem> _menuItems = [
    MenuItem(Icons.home, 'Beranda'),
    MenuItem(Icons.table_restaurant, 'Meja'),
    MenuItem(Icons.category, 'Menu'),
    MenuItem(Icons.local_offer, 'Promo'),
    MenuItem(Icons.shopping_cart, 'Pesanan'),
    MenuItem(Icons.kitchen, 'Dapur'),
    MenuItem(Icons.person, 'Akun'),
    MenuItem(Icons.calculate, 'Tax'),
    MenuItem(Icons.stars, 'Points', subItems: [
      MenuItem(Icons.card_giftcard, 'Hadiah'),
      MenuItem(Icons.history, 'Riwayat Penukaran'),
      MenuItem(Icons.settings_applications, 'Konfigurasi Poin'),
    ]),
    MenuItem(Icons.settings, 'Pengaturan', subItems: [
      MenuItem(Icons.palette, 'Tema'),
      MenuItem(Icons.qr_code, 'QRIS'),
      MenuItem(Icons.article, 'Logs'),
    ]),
  ];

  Widget _getSelectedPage() {
    if (_selectedSubIndex != null) {
      // Handle sub-menu selections
      switch (_selectedIndex) {
        case 8: // Points
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
                  child: Text('Konfigurasi Poin Page',
                      style: TextStyle(fontSize: 24)));
          }
          break;
        case 9: // Pengaturan
          switch (_selectedSubIndex) {
            case 0:
              return const Center(
                  child: Text('Tema Page', style: TextStyle(fontSize: 24)));
            case 1:
              return const Center(
                  child: Text('Konfigurasi QRIS Page',
                      style: TextStyle(fontSize: 24)));
            case 2:
              return const Center(
                  child: Text('Logs Page', style: TextStyle(fontSize: 24)));
          }
          break;
      }
    }

    // Handle main menu selections (only for menus without submenus)
    switch (_selectedIndex) {
      case 0:
        return const DashboardPage();
      case 1:
        return const TablesPage();
      case 2:
        return const ProductsPage();
      case 3:
        return const PromoPage();
      case 4:
        return const SalesPage();
      case 5:
        return const Center(
            child: Text('Dapur Page', style: TextStyle(fontSize: 24)));
      case 6:
        return const CustomersPage();
      case 7:
        return const Center(
            child: Text('Tax Page', style: TextStyle(fontSize: 24)));
      default:
        return const DashboardPage();
    }
  }

  Widget _buildMenuItem(MenuItem item, int index) {
    final isSelected = _selectedIndex == index && _selectedSubIndex == null;
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;
    final isExpanded = _expandedMenuIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            if (hasSubItems) {
              // If it has subitems, toggle expansion but don't set as selected
              if (_expandedMenuIndex == index) {
                _expandedMenuIndex = null;
              } else {
                _expandedMenuIndex = index;
                _selectedIndex = index;
                _selectedSubIndex = null;
              }
            } else {
              // If no subitems, select normally
              _selectedIndex = index;
              _selectedSubIndex = null;
              _expandedMenuIndex = null;
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: (isSelected && !hasSubItems) || isExpanded
                      ? Colors.red
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 4),
              Text(
                item.title,
                style: TextStyle(
                  color: (isSelected && !hasSubItems) || isExpanded
                      ? Colors.white
                      : Colors.white60,
                  fontSize: 10,
                  fontWeight: (isSelected && !hasSubItems) || isExpanded
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(MenuItem subItem, int mainIndex, int subIndex) {
    final isSelected =
        _selectedIndex == mainIndex && _selectedSubIndex == subIndex;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = mainIndex;
            _selectedSubIndex = subIndex;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red.shade400 : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.red.shade400 : Colors.white24,
                    width: 1,
                  ),
                ),
                child: Icon(
                  subItem.icon,
                  color: isSelected ? Colors.white : Colors.white60,
                  size: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subItem.title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: 8,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar - Icon Only
          Container(
            width: 90,
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
            child: Column(
              children: [
                // Header dengan Logo
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Very',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Menu Items
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...List.generate(_menuItems.length, (index) {
                          final item = _menuItems[index];
                          final isExpanded = _expandedMenuIndex == index;

                          return Column(
                            children: [
                              _buildMenuItem(item, index),
                              // Show sub-menu items if this item is expanded and has sub-items
                              if (item.subItems != null && isExpanded)
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Column(
                                    children: item.subItems!
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      return _buildSubMenuItem(
                                          entry.value, index, entry.key);
                                    }).toList(),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // User Profile & Logout
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Divider
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

                      // Logout Button
                      Tooltip(
                        message: 'Logout',
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Konfirmasi Logout'),
                                content: const Text(
                                    'Apakah Anda yakin ingin keluar?'),
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
                                          builder: (context) =>
                                              const LoginScreen(),
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
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.red.shade400.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.red.shade400.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
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
          ),

          // Main Content
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
    );
  }
}
