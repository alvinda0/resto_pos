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
  final ProductController productController = Get.put(ProductController());
  final NewOrderController orderController = Get.put(NewOrderController());
  final TextEditingController productSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Setup product search listener
    productSearchController.addListener(() {
      productController.searchProducts(productSearchController.text);
    });
  }

  @override
  void dispose() {
    productSearchController.dispose();
    super.dispose();
  }

  // Helper method to decode base64 image
  Uint8List _decodeBase64Image(String base64String) {
    // Remove data:image/png;base64, prefix if it exists
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
                return constraints.maxWidth >= 1000
                    ? _buildThreeColumnLayout()
                    : _buildMobileLayout();
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
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'BAYAR PESANAN',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Show QRIS cancel button if active
          Obx(() {
            return orderController.isQrisPaymentActive.value
                ? ElevatedButton.icon(
                    onPressed: orderController.cancelQrisPayment,
                    icon: const Icon(Icons.close),
                    label: const Text('Batalkan QRIS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  )
                : const SizedBox.shrink();
          }),
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
                Text('Rp${orderController.formatPrice(product.basePrice)}',
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: product.isAvailable
                        ? () => orderController.addProductToOrder(product)
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
          child: Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daftar Pesanan',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Total: ${orderController.orderItems.length} items',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            );
          }),
        ),
        Expanded(
          child: Obx(() {
            return orderController.orderItems.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada pesanan\nTambahkan produk untuk memulai',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orderController.orderItems.length,
                    itemBuilder: (context, index) => _buildOrderItem(
                        orderController.orderItems[index], index),
                  );
          }),
        ),
      ],
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item, int index) {
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
                Text(item['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 12)),
                Row(
                  children: [
                    Text(
                        '${item['quantity']} x Rp${orderController.formatPrice((item['price']?.toDouble() ?? 0.0).round())}',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade600)),
                    const Spacer(),
                    Text(
                        'Rp${orderController.formatPrice((item['totalPrice']?.toDouble() ?? 0.0).round())}',
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
                onPressed: () => orderController.decreaseQuantity(index),
                icon: const Icon(Icons.remove, size: 12),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    minimumSize: const Size(24, 24),
                    padding: EdgeInsets.zero),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(item['quantity'].toString(),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                onPressed: () => orderController.increaseQuantity(index),
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
    return Obx(() {
      // Show QRIS payment interface if QRIS payment is active
      if (orderController.isQrisPaymentActive.value) {
        return _buildQrisPaymentInterface();
      }

      // Show normal customer and payment form
      return SingleChildScrollView(
        child: Column(
          children: [
            _buildCustomerDetailsCard(),
            _buildPaymentCard(),
          ],
        ),
      );
    });
  }

  Widget _buildQrisPaymentInterface() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Pembayaran QRIS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                    'Total: Rp${orderController.formatPrice(orderController.orderTotal.round())}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Obx(() {
                  final qrisPayment = orderController.qrisPayment.value;
                  if (qrisPayment != null && qrisPayment.qrisData != null) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _decodeBase64Image(qrisPayment.qrisData!),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red),
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
                  return const CircularProgressIndicator();
                }),
                const SizedBox(height: 16),
                const Text(
                  'Scan QR Code dengan aplikasi pembayaran Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final qrisPayment = orderController.qrisPayment.value;
                  if (qrisPayment != null) {
                    final remaining =
                        qrisPayment.expiresAt.difference(DateTime.now());
                    if (remaining.isNegative) {
                      return const Text(
                        'QR Code telah expired',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      );
                    }
                    return Text(
                      'Berakhir dalam ${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.orange.shade700),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: orderController.cancelQrisPayment,
                        child: const Text('Batalkan'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Show info that auto checking is running
                          Get.snackbar(
                            'Info',
                            'Status pembayaran sedang dicek otomatis setiap 5 detik',
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: const Text('Status Auto'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Status pembayaran akan diperbarui otomatis setiap 1 detik',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
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
                  child: _buildTextField(
                      'Nama Customer', orderController.customerNameController)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildTextField(
                      'Nomor WA', orderController.phoneController)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(
                      'Nomor Meja', orderController.tableController)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildTextField(
                      'Catatan', orderController.notesController,
                      hintText: 'Catatan')),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField('Kode Promo', orderController.promoController,
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
          Obx(() {
            return Row(
              children: ['Tunai', 'QRIS', 'Debit'].map((method) {
                final isSelected =
                    orderController.selectedPaymentMethod.value == method;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: ElevatedButton(
                      onPressed: () =>
                          orderController.updatePaymentMethod(method),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected ? Colors.blue : Colors.grey.shade200,
                        foregroundColor:
                            isSelected ? Colors.white : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        minimumSize: const Size(0, 30),
                      ),
                      child: Text(method, style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6)),
            child: Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(
                      'Rp${orderController.formatPrice(orderController.orderTotal.round())}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              );
            }),
          ),
          const SizedBox(height: 8),
          Obx(() {
            return orderController.selectedPaymentMethod.value == 'Tunai'
                ? Column(
                    children: [
                      _buildTextField('Jumlah Pembayaran',
                          orderController.cashAmountController,
                          hintText: 'Jumlah uang cash'),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kembalian',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: orderController.changeController,
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
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
                  )
                : const SizedBox.shrink();
          }),
          Obx(() {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: orderController.orderItems.isEmpty ||
                        orderController.isLoading.value ||
                        orderController.isProcessingPayment.value
                    ? null
                    : orderController.processOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: orderController.isLoading.value ||
                        orderController.isProcessingPayment.value
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Proses Pembayaran',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            );
          }),
        ],
      ),
    );
  }
}
