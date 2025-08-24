import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/order/order_controller.dart';
import 'package:pos/controller/product/product_controller.dart';
import 'package:pos/models/order/order_model.dart';
import 'package:pos/models/product/product_model.dart';
import 'package:pos/controller/payment/payment_controller.dart';
import 'package:pos/screens/order/qris_payment_screen.dart';

class OrderDetailDialog extends StatefulWidget {
  final OrderModel order;
  final bool showPaymentDialog;

  const OrderDetailDialog({
    super.key,
    required this.order,
    this.showPaymentDialog = false,
  });

  static Future<void> show(BuildContext context, OrderModel order,
      {bool showPaymentDialog = false}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrderDetailDialog(
        order: order,
        showPaymentDialog: showPaymentDialog,
      ),
    );
  }

  @override
  State<OrderDetailDialog> createState() => _OrderDetailDialogState();
}

class _OrderDetailDialogState extends State<OrderDetailDialog> {
  final OrderController orderController = Get.find<OrderController>();
  final ProductController productController = Get.put(ProductController());
  final PaymentController paymentController = Get.put(PaymentController());

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController tableController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController promoController = TextEditingController();
  final TextEditingController cashAmountController = TextEditingController();
  final TextEditingController changeController = TextEditingController();
  final TextEditingController productSearchController = TextEditingController();

  String selectedPaymentMethod = 'Tunai';
  List<String> paymentMethods = ['Tunai', 'QRIS', 'Debit'];
  List<dynamic> currentOrderItems = [];

  @override
  void initState() {
    super.initState();
    customerNameController.text = widget.order.customerName;
    phoneController.text = widget.order.customerPhone ?? '';
    tableController.text = widget.order.tableNumber.toString();
    cashAmountController.addListener(_calculateChange);
    currentOrderItems = List.from(widget.order.items);

    // Setup product search listener
    productSearchController.addListener(() {
      productController.searchProducts(productSearchController.text);
    });
  }

  @override
  void dispose() {
    paymentController.clearPaymentResult();
    customerNameController.dispose();
    phoneController.dispose();
    tableController.dispose();
    notesController.dispose();
    promoController.dispose();
    cashAmountController.dispose();
    changeController.dispose();
    productSearchController.dispose();
    super.dispose();
  }

  // Helper method to determine device type and breakpoints
  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1024;

  void _addProductToOrder(Product product) {
    setState(() {
      int existingIndex = currentOrderItems.indexWhere((item) {
        if (item is Map) {
          return (item['productId'] ?? item['id']) == product.id;
        }
        return (item.productId ?? item.id) == product.id;
      });

      if (existingIndex >= 0) {
        currentOrderItems[existingIndex] = _createOrderItem(
            product, _getItemQuantity(currentOrderItems[existingIndex]) + 1);
      } else {
        currentOrderItems.add(_createOrderItem(product, 1));
      }
    });
    _calculateChange();
  }

  dynamic _createOrderItem(Product product, int quantity) {
    return {
      'id': product.id,
      'productId': product.id,
      'name': product.name,
      'productName': product.name,
      'quantity': quantity,
      'price': product.basePrice.toDouble(),
      'totalPrice': (product.basePrice * quantity).toDouble(),
    };
  }

  void _calculateChange() {
    if (selectedPaymentMethod == 'Tunai' &&
        cashAmountController.text.isNotEmpty) {
      double cashAmount =
          double.tryParse(cashAmountController.text.replaceAll(',', '')) ?? 0;
      double total = _calculateOrderTotal();
      double change = cashAmount - total;
      changeController.text =
          change >= 0 ? 'Rp${_formatPrice(change.round())}' : 'Rp0';
    } else {
      changeController.text = 'Rp0';
    }
  }

  double _calculateOrderTotal() {
    return currentOrderItems.fold(
        0.0, (sum, item) => sum + _getItemTotalPriceDouble(item));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1400 : (isTablet ? 1000 : double.infinity),
          maxHeight: isDesktop ? 800 : (isTablet ? 700 : double.infinity),
        ),
        width: double.infinity,
        height: isMobile ? MediaQuery.of(context).size.height * 0.95 : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildResponsiveLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMobile ? 8 : 12),
          topRight: Radius.circular(isMobile ? 8 : 12),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'BAYAR PESANAN',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveLayout() {
    return LayoutBuilder(
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
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(flex: 1, child: _buildAddProductSection()),
              Container(height: 1, color: Colors.grey.shade300),
              Expanded(flex: 1, child: _buildOrderSection()),
            ],
          ),
        ),
        Container(width: 1, color: Colors.grey.shade300),
        Expanded(
          flex: 1,
          child: _buildCustomerPaymentSection(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(flex: 1, child: _buildAddProductSection()),
        Container(width: 1, color: Colors.grey.shade300),
        Expanded(flex: 1, child: _buildOrderSection()),
        Container(width: 1, color: Colors.grey.shade300),
        Expanded(flex: 1, child: _buildCustomerPaymentSection()),
      ],
    );
  }

  Widget _buildAddProductSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.only(bottom: 16),
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
          // Products grid
          Expanded(
            child: Obx(() {
              if (productController.isLoading.value &&
                  productController.products.isEmpty) {
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

              if (productController.products.isEmpty) {
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
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemCount: productController.products.length,
                itemBuilder: (context, index) => _buildResponsiveProductCard(
                    productController.products[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Order header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pesanan (${currentOrderItems.length} items)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                Text(
                  'Rp${_formatPrice(_calculateOrderTotal().round())}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Order items list
          Expanded(
            child: currentOrderItems.isEmpty
                ? const Center(
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
                  )
                : ListView.builder(
                    itemCount: currentOrderItems.length,
                    itemBuilder: (context, index) =>
                        _buildOrderItem(currentOrderItems[index], index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Icon(Icons.fastfood, size: 24, color: Colors.blue.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getItemName(item),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_getItemUnitPrice(item)} per item',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getItemTotalPrice(item),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _decreaseQuantity(index),
                      icon: const Icon(Icons.remove, size: 16),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        _getItemQuantity(item).toString(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _increaseQuantity(index),
                      icon: const Icon(Icons.add, size: 16),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
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

  Widget _buildCustomerPaymentSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildEnhancedCustomerDetailsCard(),
          const SizedBox(height: 16),
          _buildEnhancedPaymentCard(),
        ],
      ),
    );
  }

  Widget _buildEnhancedMobileLayout() {
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
                Tab(icon: Icon(Icons.receipt_long, size: 20), text: "Pesanan"),
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
  }

// 3. Add mobile-specific product section
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
          child: Obx(() {
            if (productController.isLoading.value &&
                productController.products.isEmpty) {
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

            if (productController.products.isEmpty) {
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
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: productController.products.length,
              itemBuilder: (context, index) => _buildResponsiveProductCard(
                  productController.products[index]),
            );
          }),
        ),
      ],
    );
  }

// 4. Add mobile-specific order section
  Widget _buildMobileOrderSection() {
    if (currentOrderItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
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
                'Total: ${currentOrderItems.length} items',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
              Text(
                'Rp${_formatPrice(_calculateOrderTotal().round())}',
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
            itemCount: currentOrderItems.length,
            itemBuilder: (context, index) =>
                _buildMobileOrderItem(currentOrderItems[index], index),
          ),
        ),
      ],
    );
  }

// 5. Add mobile-specific order item
  Widget _buildMobileOrderItem(dynamic item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Icon(Icons.fastfood, size: 20, color: Colors.blue.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getItemName(item),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_getItemUnitPrice(item)} per item',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getItemTotalPrice(item),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _decreaseQuantity(index),
                      icon: const Icon(Icons.remove, size: 14),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        minimumSize: const Size(28, 28),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _getItemQuantity(item).toString(),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _increaseQuantity(index),
                      icon: const Icon(Icons.add, size: 14),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        minimumSize: const Size(28, 28),
                        padding: EdgeInsets.zero,
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

// 5. Add mobile-specific order item
  Widget _buildMobilePaymentSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildEnhancedCustomerDetailsCard(),
          const SizedBox(height: 16),
          _buildEnhancedPaymentCard(),
        ],
      ),
    );
  }

  Widget _buildResponsiveProductCard(Product product) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallCard = constraints.maxWidth < 100;

        return GestureDetector(
          onTap: product.isAvailable ? () => _addProductToOrder(product) : null,
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
                  flex: 3,
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
                  flex: 2,
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
                          'Rp${_formatPrice(product.basePrice)}',
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

// 8. Enhanced customer details card with better responsiveness
  Widget _buildEnhancedCustomerDetailsCard() {
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
                    _buildResponsiveTextField(
                        'Nama Customer', customerNameController),
                    const SizedBox(height: 12),
                    _buildResponsiveTextField('Nomor WA', phoneController,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _buildResponsiveTextField(
                                'Nomor Meja', tableController,
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _buildResponsiveTextField(
                                'Catatan', notesController,
                                hintText: 'Optional')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildResponsiveTextField('Kode Promo', promoController,
                        hintText: 'Masukkan kode promo (optional)'),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildResponsiveTextField(
                                'Nama Customer', customerNameController)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildResponsiveTextField(
                                'Nomor WA', phoneController,
                                keyboardType: TextInputType.phone)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _buildResponsiveTextField(
                                'Nomor Meja', tableController,
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildResponsiveTextField(
                                'Catatan', notesController,
                                hintText: 'Optional')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildResponsiveTextField('Kode Promo', promoController,
                        hintText: 'Masukkan kode promo (optional)'),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

// 9. Enhanced responsive text field with proper keyboard types
  Widget _buildResponsiveTextField(
      String label, TextEditingController controller,
      {String? hintText, TextInputType? keyboardType}) {
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
              keyboardType: keyboardType,
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

// 10. Enhanced payment card
  Widget _buildEnhancedPaymentCard() {
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

          // Payment method buttons in row - FIXED SECTION
          Row(
            children: paymentMethods.map((method) {
              final isSelected = selectedPaymentMethod == method;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: method != paymentMethods.last ? 8 : 0,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedPaymentMethod = method;
                        _calculateChange();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.blue : Colors.grey.shade200,
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: isSelected ? 2 : 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          method == 'Tunai'
                              ? Icons.money
                              : method == 'QRIS'
                                  ? Icons.qr_code
                                  : Icons.credit_card,
                          size: 20,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          // END FIXED SECTION

          const SizedBox(height: 16),
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
            child: Row(
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
                  'Rp${_formatPrice(_calculateOrderTotal().round())}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (selectedPaymentMethod == 'Tunai') ...[
            _buildResponsiveTextField(
              'Jumlah Pembayaran',
              cashAmountController,
              hintText: 'Masukkan jumlah uang cash',
              keyboardType: TextInputType.number,
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
                  controller: changeController,
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
          _buildPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
            onPressed: paymentController.isProcessingPayment.value
                ? null
                : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPaymentButtonColor(),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 8 : 10,
              ),
            ),
            child: paymentController.isProcessingPayment.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: isMobile ? 12 : 16,
                        height: isMobile ? 12 : 16,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: isMobile ? 4 : 8),
                      Text(
                        'Memproses...',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getPaymentButtonIcon(),
                        size: isMobile ? 16 : 18,
                      ),
                      SizedBox(width: isMobile ? 6 : 8),
                      Text(
                        _getPaymentButtonText(),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          )),
    );
  }

  Color _getPaymentButtonColor() {
    switch (selectedPaymentMethod) {
      case 'QRIS':
        return Colors.blue.shade600;
      case 'Tunai':
        return Colors.green.shade600;
      case 'Debit':
        return Colors.purple.shade600;
      default:
        return Colors.green;
    }
  }

  IconData _getPaymentButtonIcon() {
    switch (selectedPaymentMethod) {
      case 'QRIS':
        return Icons.qr_code;
      case 'Tunai':
        return Icons.payments;
      case 'Debit':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentButtonText() {
    switch (selectedPaymentMethod) {
      case 'QRIS':
        return 'Bayar dengan QRIS';
      case 'Tunai':
        return 'Proses Pembayaran Tunai';
      case 'Debit':
        return 'Proses Pembayaran Debit';
      default:
        return 'Proses Pembayaran';
    }
  }

  // Helper methods - keeping the original implementation
  String _getItemName(dynamic item) {
    if (item is Map) {
      return item['name']?.toString() ??
          item['productName']?.toString() ??
          'Unknown Product';
    }
    try {
      return item.productName?.toString() ??
          item.product?.name?.toString() ??
          'Unknown Product';
    } catch (e) {
      return 'Unknown Product';
    }
  }

  int _getItemQuantity(dynamic item) {
    if (item is Map) {
      return item['quantity'] ?? 1;
    }
    try {
      return item.quantity ?? 1;
    } catch (e) {
      return 1;
    }
  }

  double _getItemTotalPriceDouble(dynamic item) {
    try {
      if (item is Map) {
        if (item['totalPrice'] != null) {
          return item['totalPrice'] is double
              ? item['totalPrice']
              : double.parse(item['totalPrice'].toString());
        }
        double unitPrice = item['price'] is double
            ? item['price']
            : double.parse(item['price'].toString());
        int quantity = item['quantity'] ?? 1;
        return unitPrice * quantity;
      } else {
        if (item.totalPrice != null) {
          return item.totalPrice is double
              ? item.totalPrice
              : double.parse(item.totalPrice.toString());
        }

        double unitPrice = 0.0;
        try {
          unitPrice = item.price?.toDouble() ??
              item.unitPrice?.toDouble() ??
              item.product?.basePrice?.toDouble() ??
              0.0;
        } catch (e) {
          unitPrice = 0.0;
        }

        return unitPrice * _getItemQuantity(item);
      }
    } catch (e) {
      print('Error getting total price: $e');
      return 0.0;
    }
  }

  String _getItemUnitPrice(dynamic item) {
    try {
      if (item is Map) {
        double price = item['price'] is double
            ? item['price']
            : double.parse((item['price'] ?? 0).toString());
        return 'Rp${_formatPrice(price.round())}';
      } else {
        double price = 0.0;
        try {
          price = item.price?.toDouble() ??
              item.unitPrice?.toDouble() ??
              item.product?.basePrice?.toDouble() ??
              0.0;
        } catch (e) {
          price = 0.0;
        }
        return 'Rp${_formatPrice(price.round())}';
      }
    } catch (e) {
      print('Error getting unit price: $e');
      return 'Rp0';
    }
  }

  String _getItemTotalPrice(dynamic item) =>
      'Rp${_formatPrice(_getItemTotalPriceDouble(item).round())}';

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  void _increaseQuantity(int index) {
    setState(() {
      var item = currentOrderItems[index];
      int newQuantity = _getItemQuantity(item) + 1;
      double unitPrice = 0.0;

      if (item is Map) {
        unitPrice = item['price'] is double
            ? item['price']
            : double.parse(item['price'].toString());
        currentOrderItems[index] = {
          ...item,
          'quantity': newQuantity,
          'totalPrice': unitPrice * newQuantity,
        };
      } else {
        try {
          unitPrice = item.price?.toDouble() ??
              item.unitPrice?.toDouble() ??
              item.product?.basePrice?.toDouble() ??
              0.0;
        } catch (e) {
          unitPrice = 0.0;
        }

        currentOrderItems[index] = {
          'id': item.id,
          'productId': item.productId ?? item.id,
          'name': _getItemName(item),
          'productName': _getItemName(item),
          'quantity': newQuantity,
          'price': unitPrice,
          'totalPrice': unitPrice * newQuantity,
        };
      }
    });
    _calculateChange();
  }

  void _decreaseQuantity(int index) {
    setState(() {
      var item = currentOrderItems[index];
      int currentQuantity = _getItemQuantity(item);

      if (currentQuantity > 1) {
        int newQuantity = currentQuantity - 1;
        double unitPrice = 0.0;

        if (item is Map) {
          unitPrice = item['price'] is double
              ? item['price']
              : double.parse(item['price'].toString());
          currentOrderItems[index] = {
            ...item,
            'quantity': newQuantity,
            'totalPrice': unitPrice * newQuantity,
          };
        } else {
          try {
            unitPrice = item.price?.toDouble() ??
                item.unitPrice?.toDouble() ??
                item.product?.basePrice?.toDouble() ??
                0.0;
          } catch (e) {
            unitPrice = 0.0;
          }

          currentOrderItems[index] = {
            'id': item.id,
            'productId': item.productId ?? item.id,
            'name': _getItemName(item),
            'productName': _getItemName(item),
            'quantity': newQuantity,
            'price': unitPrice,
            'totalPrice': unitPrice * newQuantity,
          };
        }
      } else {
        currentOrderItems.removeAt(index);
      }
    });
    _calculateChange();
  }

  void _processPayment() {
    // Validation sama seperti sebelumnya
    if (customerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nama customer tidak boleh kosong'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (selectedPaymentMethod == 'Tunai') {
      double cashAmount =
          double.tryParse(cashAmountController.text.replaceAll(',', '')) ?? 0;
      double total = _calculateOrderTotal();
      if (cashAmount < total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Jumlah pembayaran kurang'),
              backgroundColor: Colors.red),
        );
        return;
      }
    }

    if (selectedPaymentMethod == 'QRIS') {
      _processQRISPayment();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${customerNameController.text}'),
            Text('Total: Rp${_formatPrice(_calculateOrderTotal().round())}'),
            Text('Metode: $selectedPaymentMethod'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          Obx(() => ElevatedButton(
                onPressed: paymentController.isProcessingPayment.value
                    ? null
                    : () {
                        Navigator.pop(context);
                        _completePayment();
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: paymentController.isProcessingPayment.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Konfirmasi'),
              )),
        ],
      ),
    );
  }

  void _processQRISPayment() {
    int tableNumber = int.tryParse(tableController.text) ?? 0;
    if (tableNumber <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nomor meja tidak valid'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (currentOrderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pesanan tidak boleh kosong'),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Tutup dialog saat ini dan buka QRIS screen
    Navigator.pop(context);

    QRISPaymentScreen.show(
      context,
      order: widget.order,
      customerName: customerNameController.text.trim(),
      customerPhone: phoneController.text.trim(),
      tableNumber: tableNumber,
      notes: notesController.text.isEmpty ? null : notesController.text.trim(),
      orderItems: List.from(currentOrderItems),
      promoCode:
          promoController.text.isEmpty ? null : promoController.text.trim(),
    );
  }

// Method untuk payment normal (Tunai, Debit, etc)

  void _completePayment() async {
    print('=== Starting _completePayment ===');

    try {
      int tableNumber = int.tryParse(tableController.text) ?? 0;
      if (tableNumber <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Nomor meja tidak valid'),
              backgroundColor: Colors.red),
        );
        return;
      }

      if (currentOrderItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pesanan tidak boleh kosong'),
              backgroundColor: Colors.red),
        );
        return;
      }

      print('Calling processOrderPayment...');

      final success = await paymentController.processOrderPayment(
        orderId: widget.order.id,
        customerName: customerNameController.text,
        customerPhone: phoneController.text,
        tableNumber: tableNumber,
        notes: notesController.text.isEmpty ? null : notesController.text,
        orderItems: currentOrderItems,
        paymentMethod: selectedPaymentMethod,
      );

      print('Payment process completed, success: $success');

      final result = paymentController.paymentResult.value;
      print('Payment result from controller: ${result?.isSuccess}');

      if (success) {
        print('Payment successful, closing dialog');

        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        print('Success message already handled by controller');
      } else {
        print('Payment failed');

        final errorFromController = result?.errorMessage;
        if (errorFromController == null || errorFromController.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pembayaran gagal - silakan coba lagi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Exception in _completePayment: $e');

      final result = paymentController.paymentResult.value;
      if (result != null && result.isSuccess) {
        print('Payment was successful despite UI exception, closing dialog');

        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
