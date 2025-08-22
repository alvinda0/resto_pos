import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/order/order_controller.dart';
import 'package:pos/controller/product/product_controller.dart';
import 'package:pos/models/order/order_model.dart';
import 'package:pos/models/product/product_model.dart';
import 'package:pos/controller/payment/payment_controller.dart';

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
    if (isDesktop) {
      return _buildThreeColumnLayout();
    } else if (isTablet) {
      return _buildTwoColumnLayout();
    } else {
      return _buildSingleColumnLayout();
    }
  }

  // Desktop: 3 columns (Add Product | Order List | Customer & Payment)
  Widget _buildThreeColumnLayout() {
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

  // Tablet: 2 columns (Left: Add Product & Order | Right: Customer & Payment)
  Widget _buildTwoColumnLayout() {
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

  // Mobile: Single column with tabs or scrollable sections
  Widget _buildSingleColumnLayout() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            child: TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              labelStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Produk'),
                Tab(text: 'Pesanan'),
                Tab(text: 'Bayar'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAddProductSection(),
                _buildOrderSection(),
                _buildCustomerPaymentSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Text(
            'Tambah Produk',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              children: [
                TextField(
                  controller: productSearchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 12,
                      vertical: isMobile ? 6 : 8,
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (productController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (productController.products.isEmpty) {
                      return const Center(child: Text('Tidak ada produk'));
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getProductGridColumns(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: isMobile ? 0.8 : 0.75,
                      ),
                      itemCount: productController.products.length,
                      itemBuilder: (context, index) =>
                          _buildProductCard(productController.products[index]),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _getProductGridColumns() {
    if (isMobile) return 2;
    if (isTablet) return 3;
    return 2; // Desktop dalam kolom kecil
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: product.imageUrl != null
                  ? Image.network(product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.fastfood, size: 30)))
                  : const Center(child: Icon(Icons.fastfood, size: 30)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            child: Column(
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Rp${_formatPrice(product.basePrice)}',
                  style: TextStyle(
                    fontSize: isMobile ? 8 : 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: product.isAvailable
                        ? () => _addProductToOrder(product)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          product.isAvailable ? Colors.blue : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 2 : 4,
                      ),
                      minimumSize: Size(0, isMobile ? 20 : 24),
                    ),
                    child: Text(
                      product.isAvailable ? 'Tambah' : 'Habis',
                      style: TextStyle(fontSize: isMobile ? 8 : 10),
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

  Widget _buildOrderSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Pesanan',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total: ${currentOrderItems.length} items',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isMobile ? 10 : 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: currentOrderItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: isMobile ? 40 : 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada pesanan',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  itemCount: currentOrderItems.length,
                  itemBuilder: (context, index) =>
                      _buildOrderItem(currentOrderItems[index], index),
                ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(dynamic item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 6 : 8),
      padding: EdgeInsets.all(isMobile ? 6 : 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 24 : 30,
            height: isMobile ? 24 : 30,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.fastfood, size: isMobile ? 12 : 16),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getItemName(item),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isMobile ? 10 : 12,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${_getItemQuantity(item)} x ${_getItemUnitPrice(item)}',
                      style: TextStyle(
                        fontSize: isMobile ? 8 : 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _getItemTotalPrice(item),
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _decreaseQuantity(index),
                icon: Icon(Icons.remove, size: isMobile ? 10 : 12),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  minimumSize: Size(isMobile ? 20 : 24, isMobile ? 20 : 24),
                  padding: EdgeInsets.zero,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
                child: Text(
                  _getItemQuantity(item).toString(),
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _increaseQuantity(index),
                icon: Icon(Icons.add, size: isMobile ? 10 : 12),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  minimumSize: Size(isMobile ? 20 : 24, isMobile ? 20 : 24),
                  padding: EdgeInsets.zero,
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
      child: Column(
        children: [
          _buildCustomerDetailsCard(),
          _buildPaymentCard(),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsCard() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Customer',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          if (isDesktop || isTablet) ...[
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        'Nama Customer', customerNameController)),
                const SizedBox(width: 8),
                Expanded(child: _buildTextField('Nomor WA', phoneController)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildTextField('Nomor Meja', tableController)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildTextField('Catatan', notesController,
                        hintText: 'Catatan')),
              ],
            ),
          ] else ...[
            _buildTextField('Nama Customer', customerNameController),
            const SizedBox(height: 8),
            _buildTextField('Nomor WA', phoneController),
            const SizedBox(height: 8),
            _buildTextField('Nomor Meja', tableController),
            const SizedBox(height: 8),
            _buildTextField('Catatan', notesController, hintText: 'Catatan'),
          ],
          const SizedBox(height: 8),
          _buildTextField('Kode Promo', promoController,
              hintText: 'Masukkan kode promo'),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isMobile ? 10 : 12,
          ),
        ),
        SizedBox(height: isMobile ? 2 : 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 8,
              vertical: isMobile ? 4 : 6,
            ),
            isDense: true,
          ),
          style: TextStyle(fontSize: isMobile ? 10 : 12),
        ),
      ],
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pembayaran',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          // Payment method buttons
          isDesktop || isTablet
              ? Row(
                  children: paymentMethods.map((method) {
                    final isSelected = selectedPaymentMethod == method;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
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
                            foregroundColor:
                                isSelected ? Colors.white : Colors.black,
                            padding: EdgeInsets.symmetric(
                              vertical: isMobile ? 4 : 6,
                            ),
                            minimumSize: Size(0, isMobile ? 24 : 30),
                          ),
                          child: Text(
                            method,
                            style: TextStyle(fontSize: isMobile ? 8 : 10),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
              : Column(
                  children: paymentMethods.map((method) {
                    final isSelected = selectedPaymentMethod == method;
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 4),
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
                          foregroundColor:
                              isSelected ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(method),
                      ),
                    );
                  }).toList(),
                ),
          SizedBox(height: isMobile ? 8 : 12),
          // Total section
          Container(
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rp${_formatPrice(_calculateOrderTotal().round())}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Cash payment fields
          if (selectedPaymentMethod == 'Tunai') ...[
            _buildTextField('Jumlah Pembayaran', cashAmountController,
                hintText: 'Jumlah uang cash'),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kembalian',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isMobile ? 10 : 12,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                TextField(
                  controller: changeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 8,
                      vertical: isMobile ? 4 : 6,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: isMobile ? 10 : 12),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 12),
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
              backgroundColor: Colors.green,
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
                : Text(
                    'Proses Pembayaran',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          )),
    );
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
