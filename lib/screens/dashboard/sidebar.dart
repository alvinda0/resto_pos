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
  bool _isPengaturanExpanded = false;
  bool _isCollapsed = false; // Untuk mengontrol collapsed/expanded sidebar

  final List<MenuItem> _menuItems = [
    MenuItem(Icons.home, 'Beranda'),
    MenuItem(Icons.table_restaurant, 'Meja'),
    MenuItem(Icons.category, 'Kategori dan Menu'),
    MenuItem(Icons.local_offer, 'Promo'),
    MenuItem(Icons.shopping_cart, 'Pesanan'),
    MenuItem(Icons.kitchen, 'Dapur'),
    MenuItem(Icons.person, 'Role dan Akun'),
    MenuItem(Icons.calculate, 'Tax'),
    MenuItem(Icons.settings, 'Pengaturan', subItems: [
      MenuItem(Icons.palette, 'Tema'),
      MenuItem(Icons.qr_code, 'Konfigurasi QRIS'),
      MenuItem(Icons.article, 'Logs'),
    ]),
  ];

  Widget _getSelectedPage() {
    if (_selectedSubIndex != null) {
      // Handle sub-menu selections
      switch (_selectedIndex) {
        case 8: // Pengaturan
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

    // Handle main menu selections
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
      case 8:
        return const SettingsPage();
      default:
        return const DashboardPage();
    }
  }

  Widget _buildMenuItem(MenuItem item, int index) {
    final isSelected = _selectedIndex == index && _selectedSubIndex == null;
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;

    if (_isCollapsed) {
      // Mode collapsed - hanya tampilkan icon
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Tooltip(
              message: item.title,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                    _selectedSubIndex = null;
                    if (hasSubItems) {
                      _isPengaturanExpanded = !_isPengaturanExpanded;
                    } else {
                      _isPengaturanExpanded = false;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red.shade50 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected ? Colors.red : Colors.white70,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          // Sub-menu items untuk mode collapsed
          if (hasSubItems && _isPengaturanExpanded && _isCollapsed)
            ...item.subItems!.asMap().entries.map((entry) {
              final subIndex = entry.key;
              final subItem = entry.value;
              final isSubSelected =
                  _selectedIndex == index && _selectedSubIndex == subIndex;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Tooltip(
                  message: subItem.title,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                        _selectedSubIndex = subIndex;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSubSelected
                            ? Colors.red.shade50
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        subItem.icon,
                        color: isSubSelected ? Colors.red : Colors.white60,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      );
    }

    // Mode expanded - tampilkan icon dan text
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: ListTile(
            leading: Icon(
              item.icon,
              color: isSelected ? Colors.red : Colors.white70,
              size: 20,
            ),
            title: Text(
              item.title,
              style: TextStyle(
                color: isSelected ? Colors.red : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            trailing: hasSubItems
                ? Icon(
                    _isPengaturanExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: isSelected ? Colors.red : Colors.white70,
                    size: 20,
                  )
                : null,
            selected: isSelected,
            selectedTileColor: Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onTap: () {
              setState(() {
                _selectedIndex = index;
                _selectedSubIndex = null;
                if (hasSubItems) {
                  _isPengaturanExpanded = !_isPengaturanExpanded;
                } else {
                  _isPengaturanExpanded = false;
                }
              });
            },
          ),
        ),
        // Sub-menu items (hanya tampil jika tidak collapsed)
        if (hasSubItems && _isPengaturanExpanded && !_isCollapsed)
          ...item.subItems!.asMap().entries.map((entry) {
            final subIndex = entry.key;
            final subItem = entry.value;
            final isSubSelected =
                _selectedIndex == index && _selectedSubIndex == subIndex;

            return Container(
              margin:
                  const EdgeInsets.only(left: 24, right: 8, top: 2, bottom: 2),
              child: ListTile(
                leading: Icon(
                  subItem.icon,
                  color: isSubSelected ? Colors.red : Colors.white60,
                  size: 18,
                ),
                title: Text(
                  subItem.title,
                  style: TextStyle(
                    color: isSubSelected ? Colors.red : Colors.white60,
                    fontWeight:
                        isSubSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                selected: isSubSelected,
                selectedTileColor: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                    _selectedSubIndex = subIndex;
                  });
                },
              ),
            );
          }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isCollapsed ? 80 : 280,
            color: Colors.deepPurple.shade700,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: _isCollapsed
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_isCollapsed)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '加班烧烤',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      // Toggle button
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isCollapsed = !_isCollapsed;
                            if (_isCollapsed) {
                              _isPengaturanExpanded = false;
                            }
                          });
                        },
                        icon: Icon(
                          _isCollapsed ? Icons.menu_open : Icons.menu,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Label
                if (!_isCollapsed)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'MENU',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                // Menu Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      return _buildMenuItem(_menuItems[index], index);
                    },
                  ),
                ),

                // User Info
                Container(
                  padding: const EdgeInsets.all(16),
                  child: _isCollapsed
                      ? Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 20,
                              child: const Text(
                                'OU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              onPressed: () {
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
                              icon: const Icon(Icons.logout,
                                  color: Colors.white70, size: 20),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 16,
                              child: const Text(
                                'OU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Owner User',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'owner@siresto.com',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
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
                              icon: const Icon(Icons.logout,
                                  color: Colors.white70, size: 20),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: _getSelectedPage(),
          ),
        ],
      ),
    );
  }
}
