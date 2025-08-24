import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pos/controller/product/product_controller.dart';
import 'package:pos/controller/order/new_order_controller.dart';
import 'package:pos/models/product/product_model.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  // Use Get.find() dengan fallback untuk avoid multiple initialization
  ProductController get productController {
    try {
      return Get.find<ProductController>();
    } catch (e) {
      return Get.put(ProductController(), permanent: true);
    }
  }

  NewOrderController get orderController {
    try {
      return Get.find<NewOrderController>();
    } catch (e) {
      return Get.put(NewOrderController(), permanent: true);
    }
  }

  final TextEditingController productSearchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    // Initialize controllers dengan proper error handling
    _initializeControllers();

    // Setup listeners setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListeners();
      _loadInitialData();
    });
  }

  void _initializeControllers() {
    try {
      // Pastikan controller sudah ada atau buat baru
      if (!Get.isRegistered<ProductController>()) {
        Get.put(ProductController(), permanent: true);
      }
      if (!Get.isRegistered<NewOrderController>()) {
        Get.put(NewOrderController(), permanent: true);
      }
    } catch (e) {
      print('Error initializing controllers: $e');
    }
  }

  void _setupListeners() {
    try {
      productSearchController.addListener(_onSearchChanged);
    } catch (e) {
      print('Error setting up listeners: $e');
    }
  }

  void _loadInitialData() {
    try {
      // Load products hanya jika belum ada
      if (productController.products.isEmpty) {
        productController.loadProducts();
      }

      // Reset order controller state
      orderController.resetControllerState();
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      try {
        productController.searchProducts(productSearchController.text);
      } catch (e) {
        print('Error searching products: $e');
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    productSearchController.removeListener(_onSearchChanged);
    productSearchController.dispose();
    super.dispose();
  }

  // Helper method to decode base64 image
  Uint8List _decodeBase64Image(String base64String) {
    String cleanBase64 = base64String;
    if (base64String.contains(',')) {
      cleanBase64 = base64String.split(',').last;
    }
    return base64Decode(cleanBase64);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 768;
                bool isTablet =
                    constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
                bool isDesktop = constraints.maxWidth >= 1200;

                if (isMobile) {
                  return _buildEnhancedMobileLayout();
                } else if (isTablet) {
                  return _buildTabletLayout();
                } else {
                  return _buildDesktopLayout();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Show order summary in header for mobile
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 768) {
                return GetBuilder<NewOrderController>(
                  init: orderController,
                  builder: (controller) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart,
                              size: 16, color: Colors.blue.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${controller.orderItems.length} items',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rp${controller.formatPrice(controller.orderTotal.round())}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Show QRIS cancel button if active
          GetBuilder<NewOrderController>(
            init: orderController,
            builder: (controller) {
              return controller.isQrisPaymentActive.value
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ElevatedButton.icon(
                        onPressed: controller.cancelQrisPayment,
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Batalkan QRIS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // Enhanced Mobile Layout with Tab Navigation
  Widget _buildEnhancedMobileLayout() {
    return GetBuilder<NewOrderController>(
      init: orderController,
      builder: (controller) {
        // Jika QRIS payment aktif, tampilkan interface QRIS
        if (controller.isQrisPaymentActive.value) {
          return _buildQrisPaymentInterface();
        }

        // Jika tidak, tampilkan tab normal
        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: const TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                        icon: Icon(Icons.add_shopping_cart, size: 20),
                        text: "Produk"),
                    Tab(
                        icon: Icon(Icons.receipt_long, size: 20),
                        text: "Pesanan"),
                    Tab(icon: Icon(Icons.payment, size: 20), text: "Bayar"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildMobileProductSection(),
                    _buildMobileOrderSection(),
                    _buildMobilePaymentSection(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Tablet Layout (768px - 1199px)
  Widget _buildTabletLayout() {
    return GetBuilder<NewOrderController>(
      init: orderController,
      builder: (controller) {
        if (controller.isQrisPaymentActive.value) {
          return _buildQrisPaymentInterface();
        }

        // Use the same 3-column layout as desktop
        return Row(
          children: [
            Expanded(flex: 1, child: _buildAddProductSection()),
            Container(width: 1, color: Colors.grey.shade300),
            Expanded(flex: 1, child: _buildOrderSection()),
            Container(width: 1, color: Colors.grey.shade300),
            Expanded(flex: 1, child: _buildCustomerPaymentSection()),
          ],
        );
      },
    );
  }

  // Desktop Layout (≥1200px)
  Widget _buildDesktopLayout() {
    return GetBuilder<NewOrderController>(
      init: orderController,
      builder: (controller) {
        if (controller.isQrisPaymentActive.value) {
          return _buildQrisPaymentInterface();
        }

        return Row(
          children: [
            Expanded(flex: 1, child: _buildAddProductSection()),
            Container(width: 1, color: Colors.grey.shade300),
            Expanded(flex: 1, child: _buildOrderSection()),
            Container(width: 1, color: Colors.grey.shade300),
            Expanded(flex: 1, child: _buildCustomerPaymentSection()),
          ],
        );
      },
    );
  }

  // Mobile-specific product section
  Widget _buildMobileProductSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: productSearchController,
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),
        Expanded(
          child: GetBuilder<ProductController>(
            init: productController,
            builder: (controller) {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Memuat produk...')
                    ],
                  ),
                );
              }

              if (controller.products.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Tidak ada produk',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 produk per baris di mobile
                  crossAxisSpacing: 8, // Spacing kecil
                  mainAxisSpacing: 8, // Spacing kecil
                  childAspectRatio: 0.75, // Produk kecil dan compact
                ),
                itemCount: controller.products.length,
                itemBuilder: (context, index) =>
                    _buildResponsiveProductCard(controller.products[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // Mobile-specific order section
  Widget _buildMobileOrderSection() {
    return GetBuilder<NewOrderController>(
      init: orderController,
      builder: (controller) {
        if (controller.orderItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Belum ada pesanan',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tambahkan produk untuk memulai',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${controller.orderItems.length} items',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    'Rp${controller.formatPrice(controller.orderTotal.round())}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.orderItems.length,
                itemBuilder: (context, index) =>
                    _buildMobileOrderItem(controller.orderItems[index], index),
              ),
            ),
          ],
        );
      },
    );
  }

  // Mobile-specific payment section
  Widget _buildMobilePaymentSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCustomerDetailsCard(),
          const SizedBox(height: 16),
          _buildPaymentCard(),
        ],
      ),
    );
  }

  Widget _buildAddProductSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              const Icon(Icons.add_shopping_cart, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Tambah Produk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 768) {
                    return GetBuilder<ProductController>(
                      init: productController,
                      builder: (controller) {
                        return Text(
                          '${controller.products.length} produk',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: productSearchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GetBuilder<ProductController>(
                    init: productController,
                    builder: (controller) {
                      if (controller.isLoading.value &&
                          controller.products.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.products.isEmpty) {
                        return const Center(child: Text('Tidak ada produk'));
                      }

                      return _buildResponsiveProductGrid();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Enhanced responsive product grid
  Widget _buildResponsiveProductGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth < 400) {
          crossAxisCount = 3; // 3 produk per baris untuk layar kecil
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth < 600) {
          crossAxisCount = 4; // 4 produk per baris untuk layar menengah
          childAspectRatio = 0.8;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 5; // 5 produk per baris untuk layar besar
          childAspectRatio = 0.85;
        } else {
          crossAxisCount = 5; // 5 produk per baris untuk layar extra besar
          childAspectRatio = 0.9;
        }

        return GetBuilder<ProductController>(
          init: productController,
          builder: (controller) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8, // Spacing kecil
                mainAxisSpacing: 8, // Spacing kecil
                childAspectRatio: childAspectRatio,
              ),
              itemCount: controller.products.length,
              itemBuilder: (context, index) =>
                  _buildResponsiveProductCard(controller.products[index]),
            );
          },
        );
      },
    );
  }

  // Enhanced responsive product card
  Widget _buildResponsiveProductCard(Product product) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallCard =
            constraints.maxWidth < 100; // Threshold untuk card kecil

        return GestureDetector(
          onTap: product.isAvailable
              ? () => orderController.addProductToOrder(product)
              : null,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: product.isAvailable
                    ? Colors.grey.shade300
                    : Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
              color: product.isAvailable ? Colors.white : Colors.grey.shade100,
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3, // Area gambar
                  child: Container(
                    decoration: BoxDecoration(
                      color: product.isAvailable
                          ? Colors.grey.shade200
                          : Colors.grey.shade300,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Stack(
                        children: [
                          product.imageUrl != null
                              ? Image.network(
                                  product.imageUrl!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  color:
                                      product.isAvailable ? null : Colors.grey,
                                  colorBlendMode: product.isAvailable
                                      ? null
                                      : BlendMode.saturation,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Icon(
                                      Icons.fastfood,
                                      size: isSmallCard ? 20 : 24,
                                      color: product.isAvailable
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.fastfood,
                                    size: isSmallCard ? 20 : 24,
                                    color: product.isAvailable
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade500,
                                  ),
                                ),
                          // Overlay untuk produk habis
                          if (!product.isAvailable)
                            Container(
                              color: Colors.black.withOpacity(0.3),
                              child: const Center(
                                child: Text(
                                  'HABIS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2, // Area text
                  child: Padding(
                    padding: EdgeInsets.all(isSmallCard ? 4 : 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: isSmallCard ? 9 : 10,
                            fontWeight: FontWeight.bold,
                            color: product.isAvailable
                                ? Colors.black
                                : Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rp${orderController.formatPrice(product.basePrice)}',
                          style: TextStyle(
                            fontSize: isSmallCard ? 8 : 9,
                            color: product.isAvailable
                                ? Colors.orange.shade600
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 0,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: GetBuilder<NewOrderController>(
            init: orderController,
            builder: (controller) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Daftar Pesanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      '${controller.orderItems.length} items',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: GetBuilder<NewOrderController>(
            init: orderController,
            builder: (controller) {
              return controller.orderItems.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada pesanan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tambahkan produk untuk memulai',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey.shade50,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: controller.orderItems.length,
                              itemBuilder: (context, index) => _buildOrderItem(
                                  controller.orderItems[index], index),
                            ),
                          ),
                        ),
                        // Footer dengan total
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pesanan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Rp${controller.formatPrice(controller.orderTotal.round())}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF8C00),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon produk
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 20,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(width: 12),
          // Detail produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp${orderController.formatPrice((item['price']?.toDouble() ?? 0.0).round())} per item',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Harga total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp${orderController.formatPrice((item['totalPrice']?.toDouble() ?? 0.0).round())}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8C00), // Orange color seperti gambar
                ),
              ),
              const SizedBox(height: 8),
              // Quantity controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => orderController.decreaseQuantity(index),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.remove,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 32),
                      alignment: Alignment.center,
                      child: Text(
                        '${item['quantity'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => orderController.increaseQuantity(index),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Mobile-specific order item with better spacing
  Widget _buildMobileOrderItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with icon and details
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 20,
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp${orderController.formatPrice((item['price']?.toDouble() ?? 0.0).round())} per item',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rp${orderController.formatPrice((item['totalPrice']?.toDouble() ?? 0.0).round())}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8C00), // Orange color
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quantity controls centered
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => orderController.decreaseQuantity(index),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.remove,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 40),
                  alignment: Alignment.center,
                  child: Text(
                    '${item['quantity'] ?? 0}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => orderController.increaseQuantity(index),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.grey,
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

  Widget _buildCustomerPaymentSection() {
    return GetBuilder<NewOrderController>(
      init: orderController,
      builder: (controller) {
        if (controller.isQrisPaymentActive.value) {
          return _buildQrisPaymentInterface();
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildCustomerDetailsCard(),
              _buildPaymentCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQrisPaymentInterface() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 768;

        return Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code,
                            size: isMobile ? 20 : 24,
                            color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Pembayaran QRIS',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GetBuilder<NewOrderController>(
                      init: orderController,
                      builder: (controller) {
                        return Text(
                          'Total: Rp${controller.formatPrice(controller.orderTotal.round())}',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GetBuilder<NewOrderController>(
                      init: orderController,
                      builder: (controller) {
                        final qrisPayment = controller.qrisPayment.value;
                        if (qrisPayment != null &&
                            qrisPayment.qrisData != null) {
                          double qrSize =
                              isMobile ? 180 : 220; // Smaller QR for mobile
                          return Container(
                            width: qrSize,
                            height: qrSize,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 2),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _decodeBase64Image(qrisPayment.qrisData!),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline,
                                              color: Colors.red, size: 32),
                                          SizedBox(height: 8),
                                          Text(
                                            'QR Code tidak dapat dimuat',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        double qrSize = isMobile ? 180 : 220;
                        return Container(
                          width: qrSize,
                          height: qrSize,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade300, width: 2),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Memuat QR Code...')
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan QR Code dengan aplikasi pembayaran Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GetBuilder<NewOrderController>(
                      init: orderController,
                      builder: (controller) {
                        final qrisPayment = controller.qrisPayment.value;
                        if (qrisPayment != null) {
                          final remaining =
                              qrisPayment.expiresAt.difference(DateTime.now());
                          if (remaining.isNegative) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'QR Code telah expired',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 11 : 12,
                                ),
                              ),
                            );
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Berakhir dalam ${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                                fontSize: isMobile ? 11 : 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    // Mobile: Stack buttons vertically, Desktop: Side by side
                    isMobile
                        ? Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: orderController.cancelQrisPayment,
                                  icon: const Icon(Icons.close, size: 18),
                                  label: const Text('Batalkan Pembayaran'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    side:
                                        BorderSide(color: Colors.red.shade300),
                                    foregroundColor: Colors.red.shade600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Get.snackbar(
                                      'Info',
                                      'Status pembayaran sedang dicek otomatis setiap 5 detik',
                                      backgroundColor: Colors.blue,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 2),
                                      snackPosition: SnackPosition.TOP,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: 8,
                                    );
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Cek Status Otomatis'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: orderController.cancelQrisPayment,
                                  icon: const Icon(Icons.close, size: 18),
                                  label: const Text('Batalkan'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    side:
                                        BorderSide(color: Colors.red.shade300),
                                    foregroundColor: Colors.red.shade600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Get.snackbar(
                                      'Info',
                                      'Status pembayaran sedang dicek otomatis setiap 5 detik',
                                      backgroundColor: Colors.blue,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 2),
                                      snackPosition: SnackPosition.TOP,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: 8,
                                    );
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Status Auto'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue, size: isMobile ? 16 : 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Status pembayaran akan diperbarui otomatis setiap 1 detik',
                        style: TextStyle(
                            fontSize: isMobile ? 11 : 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text('Detail Customer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobileForm = constraints.maxWidth < 400;

              if (isMobileForm) {
                return Column(
                  children: [
                    _buildResponsiveTextField('Nama Customer',
                        orderController.customerNameController),
                    const SizedBox(height: 12),
                    _buildResponsiveTextField(
                        'Nomor WA', orderController.phoneController),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _buildResponsiveTextField(
                                'Nomor Meja', orderController.tableController)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildResponsiveTextField(
                            'Catatan',
                            orderController.notesController,
                            hintText: 'Optional',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildResponsiveTextField(
                      'Kode Promo',
                      orderController.promoController,
                      hintText: 'Masukkan kode promo (optional)',
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildResponsiveTextField('Nama Customer',
                                orderController.customerNameController)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildResponsiveTextField(
                                'Nomor WA', orderController.phoneController)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _buildResponsiveTextField(
                                'Nomor Meja', orderController.tableController)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildResponsiveTextField(
                            'Catatan',
                            orderController.notesController,
                            hintText: 'Optional',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildResponsiveTextField(
                      'Kode Promo',
                      orderController.promoController,
                      hintText: 'Masukkan kode promo (optional)',
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Enhanced responsive text field
  Widget _buildResponsiveTextField(
      String label, TextEditingController controller,
      {String? hintText}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isCompact = constraints.maxWidth < 200;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isCompact ? 11 : 13,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: isCompact ? 4 : 6),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 8 : 12,
                  vertical: isCompact ? 8 : 10,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: TextStyle(fontSize: isCompact ? 11 : 13),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text('Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),

          // Payment Methods Row
          GetBuilder<NewOrderController>(
            init: orderController,
            builder: (controller) {
              return Row(
                children: [
                  // Tunai
                  Expanded(
                    child: _buildPaymentMethodButton(
                      method: 'Tunai',
                      icon: Icons.money,
                      isSelected:
                          controller.selectedPaymentMethod.value == 'Tunai',
                      onTap: () => controller.updatePaymentMethod('Tunai'),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // QRIS
                  Expanded(
                    child: _buildPaymentMethodButton(
                      method: 'QRIS',
                      icon: Icons.qr_code,
                      isSelected:
                          controller.selectedPaymentMethod.value == 'QRIS',
                      onTap: () => controller.updatePaymentMethod('QRIS'),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Debit
                  Expanded(
                    child: _buildPaymentMethodButton(
                      method: 'Debit',
                      icon: Icons.credit_card,
                      isSelected:
                          controller.selectedPaymentMethod.value == 'Debit',
                      onTap: () => controller.updatePaymentMethod('Debit'),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Total Payment Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.green.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: GetBuilder<NewOrderController>(
              init: orderController,
              builder: (controller) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      'Rp${controller.formatPrice(controller.orderTotal.round())}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Cash Payment Input (if Tunai is selected)
          GetBuilder<NewOrderController>(
            init: orderController,
            builder: (controller) {
              return controller.selectedPaymentMethod.value == 'Tunai'
                  ? Column(
                      children: [
                        _buildResponsiveTextField(
                          'Jumlah Pembayaran',
                          controller.cashAmountController,
                          hintText: 'Masukkan jumlah uang cash',
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kembalian',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: controller.changeController,
                              readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                fillColor: Colors.orange.shade50,
                                filled: true,
                                prefixIcon: Icon(Icons.account_balance_wallet,
                                    color: Colors.orange.shade600, size: 20),
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox.shrink();
            },
          ),

          // Process Payment Button
          GetBuilder<NewOrderController>(
            init: orderController,
            builder: (controller) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.orderItems.isEmpty ||
                          controller.isLoading.value ||
                          controller.isProcessingPayment.value
                      ? null
                      : controller.processOrder,
                  icon: controller.isLoading.value ||
                          controller.isProcessingPayment.value
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle, size: 20),
                  label: Text(
                    controller.isLoading.value ||
                            controller.isProcessingPayment.value
                        ? 'Memproses...'
                        : 'Proses Pembayaran',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodButton({
    required String method,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              method,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
