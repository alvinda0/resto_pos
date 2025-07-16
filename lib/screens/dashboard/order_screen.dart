import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/order/order_controller.dart';
import 'package:pos/models/order/order_model.dart';

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
              _buildHeader(),
              _buildFilters(isDesktop),
              _buildDataTable(isDesktop),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Manajemen Pesanan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: const Text('Tambah',
                style: TextStyle(color: Colors.white, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
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
                child: _buildDropdown(
                    orderController.selectedStatus,
                    orderController.statusOptions,
                    orderController.updateStatusFilter,
                    Icons.filter_list)),
            const SizedBox(width: 8),
            Expanded(
                child: _buildDropdown(
                    orderController.selectedMethod,
                    orderController.methodOptions,
                    orderController.updateMethodFilter,
                    Icons.payment)),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildSearchField()),
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
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: orderController.updateSearchQuery,
      decoration: InputDecoration(
        hintText: 'Cari berdasarkan Nama',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    flex: 3,
                    child: Text('Aksi',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Daftar Pesanan',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
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
          Expanded(flex: 3, child: _buildActionButtons(order, false)),
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
        if (order.status.toLowerCase() == 'pending')
          ElevatedButton(
            onPressed: () => _showPaymentDialog(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('BAYAR', style: TextStyle(fontSize: 12)),
          ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showOrderDetails(order),
          icon: const Icon(Icons.receipt_long),
          style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.all(8)),
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit')
                ])),
            if (order.status.toLowerCase() != 'cancelled')
              const PopupMenuItem(
                  value: 'cancel',
                  child: Row(children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Batal')
                  ])),
            const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus')
                ])),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editOrder(order);
                break;
              case 'cancel':
                _cancelOrder(order);
                break;
              case 'delete':
                _deleteOrder(order);
                break;
            }
          },
        ),
      ],
    );
  }

  void _showPaymentDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bayar Pesanan ${order.displayId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${order.customerName}'),
            Text('Total: ${order.formattedTotal}'),
            const SizedBox(height: 16),
            const Text('Konfirmasi pembayaran?'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              orderController.payOrder(order.id,
                  {'method': order.paymentMethod, 'amount': order.totalAmount});
            },
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Pesanan ${order.displayId}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Customer: ${order.customerName}'),
              Text('Phone: ${order.customerPhone}'),
              Text('Table: ${order.tableNumber}'),
              Text('Status: ${order.status}'),
              Text('Total: ${order.formattedTotal}'),
              const SizedBox(height: 16),
              const Text('Items:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('• ${item.productName} x${item.quantity}'),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'))
        ],
      ),
    );
  }

  void _editOrder(OrderModel order) =>
      Get.snackbar('Info', 'Edit order functionality will be implemented');

  void _cancelOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: Text(
            'Apakah Anda yakin ingin membatalkan pesanan ${order.displayId}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              orderController.updateOrderStatus(order.id, 'CANCELLED');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  void _deleteOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: Text(
            'Apakah Anda yakin ingin menghapus pesanan ${order.displayId}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              orderController.deleteOrder(order.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }
}
