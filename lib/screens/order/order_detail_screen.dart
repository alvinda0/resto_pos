import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/order/order_controller.dart';
import 'package:pos/controller/product/product_controller.dart';
import 'package:pos/models/order/order_model.dart';
import 'package:pos/models/product/product_model.dart';

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

  void _addProductToOrder(Product product) {
    setState(() {
      // Check if product already exists in order
      int existingIndex = currentOrderItems.indexWhere((item) {
        if (item is Map) {
          return (item['productId'] ?? item['id']) == product.id;
        }
        return (item.productId ?? item.id) == product.id;
      });

      if (existingIndex >= 0) {
        // Increase quantity if product exists
        currentOrderItems[existingIndex] = _createOrderItem(
            product, _getItemQuantity(currentOrderItems[existingIndex]) + 1);
      } else {
        // Add new product to order
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
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400, maxHeight: 800),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return constraints.maxWidth >= 1000
                      ? _buildThreeColumnLayout()
                      : _buildMobileLayout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'BAYAR PESANAN',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAddProductSection(),
          Container(height: 1, color: Colors.grey.shade300),
          _buildOrderSection(),
          Container(height: 1, color: Colors.grey.shade300),
          _buildCustomerPaymentSection(),
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
          child: const Text(
            'Tambah Produk',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  child: Obx(() {
                    if (productController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (productController.products.isEmpty) {
                      return const Center(child: Text('Tidak ada produk'));
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.75,
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
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('Rp${_formatPrice(product.basePrice)}',
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
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
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: const Size(0, 24),
                    ),
                    child: Text(product.isAvailable ? 'Tambah' : 'Habis',
                        style: const TextStyle(fontSize: 10)),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daftar Pesanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Total: ${currentOrderItems.length} items',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.fastfood, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getItemName(item),
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 12)),
                Row(
                  children: [
                    Text(
                        '${_getItemQuantity(item)} x ${_getItemUnitPrice(item)}',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade600)),
                    const Spacer(),
                    Text(_getItemTotalPrice(item),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500)),
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
                icon: const Icon(Icons.remove, size: 12),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    minimumSize: const Size(24, 24),
                    padding: EdgeInsets.zero),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(_getItemQuantity(item).toString(),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                onPressed: () => _increaseQuantity(index),
                icon: const Icon(Icons.add, size: 12),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    minimumSize: const Size(24, 24),
                    padding: EdgeInsets.zero),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail Customer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child:
                      _buildTextField('Nama Customer', customerNameController)),
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
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
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
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(0, 30),
                    ),
                    child: Text(method, style: const TextStyle(fontSize: 10)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Rp${_formatPrice(_calculateOrderTotal().round())}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (selectedPaymentMethod == 'Tunai') ...[
            _buildTextField('Jumlah Pembayaran', cashAmountController,
                hintText: 'Jumlah uang cash'),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kembalian',
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: changeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Proses Pembayaran',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods - FIXED VERSION
  String _getItemName(dynamic item) {
    if (item is Map) {
      return item['name']?.toString() ??
          item['productName']?.toString() ??
          'Unknown Product';
    }
    // For OrderItem objects, you need to access the correct property
    // Assuming OrderItem has productName or similar property
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
        // For OrderItem objects
        if (item.totalPrice != null) {
          return item.totalPrice is double
              ? item.totalPrice
              : double.parse(item.totalPrice.toString());
        }

        // Try different possible price property names
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
        // For OrderItem objects
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
        // For OrderItem objects, convert to Map format
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
          // For OrderItem objects, convert to Map format
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completePayment();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  void _completePayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Pembayaran ${widget.order.displayId} berhasil'),
          backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }
}
