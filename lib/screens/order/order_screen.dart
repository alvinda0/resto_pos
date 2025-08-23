import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/order/order_controller.dart';
import 'package:pos/models/order/order_model.dart';
import 'package:pos/screens/order/invoice_screen.dart';
import 'package:pos/screens/order/order_payment_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderController orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 768;
          return Column(
            children: [
              _buildFilters(isDesktop),
              _buildDataTable(isDesktop),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: isDesktop ? _buildDesktopFilters() : _buildMobileFilters(),
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        _buildSearchField(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildCompactDropdown(
                  orderController.selectedStatus,
                  orderController.statusOptions,
                  orderController.updateStatusFilter,
                  Icons.filter_list,
                  'Status'),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _buildCompactDropdown(
                  orderController.selectedMethod,
                  orderController.methodOptions,
                  orderController.updateMethodFilter,
                  Icons.payment,
                  'Method'),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  // Add loading check before navigation
                  try {
                    Get.toNamed('/neworders');
                  } catch (e) {
                    print('Navigation error: $e');
                    // Alternative navigation
                    Navigator.pushNamed(context, '/neworders');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.add, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactDropdown(RxString selectedValue, List<String> options,
      Function(String) onChanged, IconData icon, String hint) {
    return Obx(() => Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedValue.value,
            onChanged: (value) => value != null ? onChanged(value) : null,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade600),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
            ),
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down,
                size: 18, color: Colors.grey.shade600),
            dropdownColor: Colors.white,
            items: options
                .map((option) => DropdownMenuItem(
                      value: option,
                      child: Text(
                        option,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
          ),
        ));
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildSearchField(isMobile: false), // Fix parameter
        ),
        const SizedBox(width: 16),
        Expanded(
            flex: 2,
            child: _buildDropdown(
                orderController.selectedStatus,
                orderController.statusOptions,
                orderController.updateStatusFilter,
                Icons.filter_list)),
        const SizedBox(width: 16),
        Expanded(
            flex: 2,
            child: _buildDropdown(
                orderController.selectedMethod,
                orderController.methodOptions,
                orderController.updateMethodFilter,
                Icons.payment)),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {
            // Add loading check before navigation
            try {
              Get.toNamed('/neworders');
            } catch (e) {
              print('Navigation error: $e');
              // Alternative navigation
              Navigator.pushNamed(context, '/neworders');
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('New Order'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField({bool isMobile = false}) {
    return SizedBox(
      height: isMobile ? 40 : null, // tinggi lebih kecil untuk mobile
      child: TextField(
        onChanged: orderController.updateSearchQuery,
        style: TextStyle(fontSize: isMobile ? 12 : 14),
        decoration: InputDecoration(
          hintText: 'Cari berdasarkan Nama',
          hintStyle: TextStyle(fontSize: isMobile ? 12 : 14),
          prefixIcon: Icon(Icons.search, size: isMobile ? 18 : 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: isMobile ? 8 : 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(RxString selectedValue, List<String> options,
      Function(String) onChanged, IconData icon) {
    return Obx(() => DropdownButtonFormField<String>(
          value: selectedValue.value,
          onChanged: (value) => value != null ? onChanged(value) : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: options
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
        ));
  }

  Widget _buildDataTable(bool isDesktop) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildTableHeader(isDesktop),
            Expanded(
              child: Obx(() {
                if (orderController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (orderController.filteredOrders.isEmpty) {
                  return const Center(
                      child: Text('Tidak ada pesanan ditemukan'));
                }
                return ListView.builder(
                  itemCount: orderController.filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = orderController.filteredOrders[index];
                    return isDesktop
                        ? _buildDesktopRow(order, index)
                        : _buildMobileCard(order);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: isDesktop
          ? const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Id Order',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Tanggal',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Customer',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1,
                    child: Text('Meja',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1,
                    child: Text('Items',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Status',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Metode',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Aksi',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildMobileCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.displayId,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text('Meja ${order.tableNumber}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Text(orderController.formatDate(order.createdAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${order.totalItems} items',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text(order.formattedTotal,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Metode: ${order.paymentMethod}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 12),
          _buildActionButtons(order, true),
        ],
      ),
    );
  }

  Widget _buildDesktopRow(OrderModel order, int index) {
    final isEven = index % 2 == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration:
          BoxDecoration(color: isEven ? Colors.white : Colors.grey.shade50),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(order.displayId,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
              flex: 2,
              child: Text(orderController.formatDate(order.createdAt))),
          Expanded(flex: 2, child: Text(order.customerName)),
          Expanded(flex: 1, child: Text(order.tableNumber.toString())),
          Expanded(flex: 1, child: Text('${order.totalItems} items')),
          Expanded(
              flex: 2,
              child: Text(order.formattedTotal,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: _buildStatusBadge(order.status)),
          Expanded(flex: 2, child: Text(order.paymentMethod)),
          Expanded(flex: 2, child: _buildActionButtons(order, false)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order, bool isMobile) {
    return Row(
      mainAxisAlignment:
          isMobile ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // Menu titik tiga (PopupMenuButton)
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'invoice':
                _showInvoice(order);
                break;
            }
          },
          icon: const Icon(Icons.more_vert, size: 20),
          iconSize: 20,
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'detail',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Detail Order'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'invoice',
              child: Row(
                children: [
                  Icon(Icons.receipt, size: 16),
                  SizedBox(width: 8),
                  Text('Lihat Invoice'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Button Bayar (hanya tampil jika status pending)
        if (order.status.toLowerCase() == 'pending')
          ElevatedButton(
            onPressed: () => _processPayment(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(60, 32),
            ),
            child: Text(
              'Bayar',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
      ],
    );
  }

  void _showInvoice(OrderModel order) {
    InvoiceDialog.show(context, order, orderController);
  }

  void _processPayment(OrderModel order) {
    // Show the order detail as a popup instead of navigating
    OrderDetailDialog.show(
      context,
      order,
      showPaymentDialog: true,
    );
  }
}
