import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/order/order_controller.dart';
import 'package:pos/models/order/order_model.dart';

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
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController tableController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController promoController = TextEditingController();
  final TextEditingController cashAmountController = TextEditingController();
  final TextEditingController changeController = TextEditingController();

  String selectedPaymentMethod = 'Tunai';
  List<String> paymentMethods = ['Tunai', 'QRIS', 'Debit'];

  @override
  void initState() {
    super.initState();
    // Initialize form with order data
    customerNameController.text = widget.order.customerName;
    phoneController.text = widget.order.customerPhone ?? '';
    tableController.text = widget.order.tableNumber.toString();

    // Calculate change when cash amount changes
    cashAmountController.addListener(_calculateChange);
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
    super.dispose();
  }

  void _calculateChange() {
    if (selectedPaymentMethod == 'Tunai' &&
        cashAmountController.text.isNotEmpty) {
      double cashAmount =
          double.tryParse(cashAmountController.text.replaceAll(',', '')) ?? 0;

      // Safe conversion to double - handle both int and double types
      double total = 0.0;
      if (widget.order.totalItems is int) {
        total = (widget.order.totalItems as int).toDouble();
      } else if (widget.order.totalItems is double) {
        total = widget.order.totalItems as double;
      } else {
        try {
          total = double.tryParse(widget.order.totalItems.toString()) ?? 0.0;
        } catch (e) {
          total = 0.0;
        }
      }

      double change = cashAmount - total;
      changeController.text =
          change >= 0 ? 'Rp${change.toStringAsFixed(0)}' : 'Rp0';
    } else {
      changeController.text = 'Rp0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 1200,
          maxHeight: 800,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Body
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 768;
                  if (isDesktop) {
                    return _buildDesktopLayout();
                  } else {
                    return _buildMobileLayout();
                  }
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
              style: TextStyle(
                fontSize: 20,
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

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Side - Order Items
        Expanded(
          flex: 1,
          child: _buildOrderSection(),
        ),
        // Divider
        Container(
          width: 1,
          color: Colors.grey.shade300,
        ),
        // Right Side - Customer & Payment Details
        Expanded(
          flex: 1,
          child: _buildCustomerPaymentSection(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildOrderSection(),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          _buildCustomerPaymentSection(),
        ],
      ),
    );
  }

  Widget _buildOrderSection() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Pesanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: ${widget.order.totalItems} items',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Order Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.order.items.length,
              itemBuilder: (context, index) {
                final item = widget.order.items[index];
                return _buildOrderItem(item);
              },
            ),
          ),

          // Add Product Section (Optional - can be removed if not needed in popup)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Produk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: _getItemImage(item),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getItemName(item),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // Tampilkan harga per unit dan total seperti di InvoiceDialog
                Row(
                  children: [
                    Text(
                      '${_getItemQuantity(item)} x ${_getItemUnitPrice(item)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _getItemTotalPrice(item),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Quantity Controls
          Row(
            children: [
              IconButton(
                onPressed: () => _decreaseQuantity(item),
                icon: const Icon(Icons.remove, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  minimumSize: const Size(28, 28),
                  padding: EdgeInsets.zero,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _getItemQuantity(item).toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _increaseQuantity(item),
                icon: const Icon(Icons.add, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  minimumSize: const Size(28, 28),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods to safely access item properties
  Widget _getItemImage(dynamic item) {
    return const Icon(Icons.fastfood, size: 20);
  }

  String _getItemName(dynamic item) {
    try {
      return item.name?.toString() ??
          item.productName?.toString() ??
          item.title?.toString() ??
          'Unknown Product';
    } catch (e) {
      return 'Unknown Product';
    }
  }

  // Helper method untuk mendapatkan harga per unit
  String _getItemUnitPrice(dynamic item) {
    try {
      double unitPrice = 0.0;
      int quantity = _getItemQuantity(item);

      if (item.totalPrice != null && quantity > 0) {
        double totalPrice = item.totalPrice is double
            ? item.totalPrice
            : double.parse(item.totalPrice.toString());
        unitPrice = totalPrice / quantity;
      } else if (item.price != null) {
        unitPrice = item.price is double
            ? item.price
            : double.parse(item.price.toString());
      }

      return 'Rp${_formatPrice(unitPrice.round())}';
    } catch (e) {
      return 'Rp0';
    }
  }

  // Helper method untuk mendapatkan total harga item
  String _getItemTotalPrice(dynamic item) {
    try {
      double totalPrice = 0.0;

      if (item.totalPrice != null) {
        totalPrice = item.totalPrice is double
            ? item.totalPrice
            : double.parse(item.totalPrice.toString());
      } else if (item.price != null) {
        double unitPrice = item.price is double
            ? item.price
            : double.parse(item.price.toString());
        totalPrice = unitPrice * _getItemQuantity(item);
      }

      return 'Rp${_formatPrice(totalPrice.round())}';
    } catch (e) {
      return 'Rp0';
    }
  }

  int _getItemQuantity(dynamic item) {
    try {
      return item.quantity ?? 1;
    } catch (e) {
      return 1;
    }
  }

  // Helper method untuk format harga
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Widget _buildCustomerPaymentSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Details Section
          _buildCustomerDetailsCard(),
          const SizedBox(height: 16),

          // Payment Section
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Customer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama Customer',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: customerNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nomor WA',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nomor Meja',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: tableController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catatan Order',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        hintText: 'Catatan tambahan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kode Promo',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: promoController,
                decoration: InputDecoration(
                  hintText: 'Masukkan kode promo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Payment Method Buttons
          Row(
            children: paymentMethods.map((method) {
              final isSelected = selectedPaymentMethod == method;
              IconData icon;
              Color color;

              switch (method) {
                case 'Tunai':
                  icon = Icons.payments;
                  color = Colors.green;
                  break;
                case 'QRIS':
                  icon = Icons.qr_code;
                  color = Colors.blue;
                  break;
                case 'Debit':
                  icon = Icons.credit_card;
                  color = Colors.orange;
                  break;
                default:
                  icon = Icons.payment;
                  color = Colors.grey;
              }

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedPaymentMethod = method;
                        _calculateChange();
                      });
                    },
                    icon: Icon(icon, size: 16),
                    label: Text(method, style: const TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? color : Colors.grey.shade200,
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Order Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.order.formattedTotal,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Cash Payment Fields (only show for Tunai)
          if (selectedPaymentMethod == 'Tunai') ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jumlah Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: cashAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan jumlah uang cash',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Kembalian',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: changeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Process Payment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Proses Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _increaseQuantity(dynamic item) {
    // Implement increase quantity logic
    setState(() {
      // Update item quantity
      // You'll need to access your order controller or update the order model
    });
  }

  void _decreaseQuantity(dynamic item) {
    // Implement decrease quantity logic
    setState(() {
      // Update item quantity
      // You'll need to access your order controller or update the order model
    });
  }

  void _processPayment() {
    // Validate form
    if (customerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama customer tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedPaymentMethod == 'Tunai') {
      double cashAmount =
          double.tryParse(cashAmountController.text.replaceAll(',', '')) ?? 0;

      // Safe conversion to double for comparison
      double total = 0.0;
      if (widget.order.totalItems is int) {
        total = (widget.order.totalItems as int).toDouble();
      } else if (widget.order.totalItems is double) {
        total = widget.order.totalItems as double;
      } else {
        try {
          total = double.tryParse(widget.order.totalItems.toString()) ?? 0.0;
        } catch (e) {
          total = 0.0;
        }
      }

      if (cashAmount < total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jumlah pembayaran kurang dari total'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Process payment
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${customerNameController.text}'),
            Text('Meja: ${tableController.text}'),
            Text('Total: ${widget.order.formattedTotal}'),
            Text('Metode: $selectedPaymentMethod'),
            if (selectedPaymentMethod == 'Tunai') ...[
              Text('Bayar: Rp${cashAmountController.text}'),
              Text('Kembalian: ${changeController.text}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
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
    // Implement payment completion logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pembayaran ${widget.order.displayId} berhasil diproses'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context); // Close the main dialog
  }
}
