import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/kitchen/kitchen_controller.dart';
import 'package:pos/models/kitchen/kitchen_model.dart';
import 'package:pos/widgets/pagination_widget.dart'; // Import your pagination widget

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  final KitchenController kitchenController = Get.put(KitchenController());

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
              _buildPagination(), // Add pagination here
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
              'Manajemen Dapur',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Auto refresh toggle
          Obx(() => Switch(
                value: kitchenController.isAutoRefreshEnabled.value,
                onChanged: (value) => kitchenController.toggleAutoRefresh(),
              )),
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
                    kitchenController.selectedStatus,
                    kitchenController.statusOptions,
                    kitchenController.updateStatusFilter,
                    Icons.filter_list)),
            const SizedBox(width: 8),
            Expanded(
                child: _buildDropdown(
                    kitchenController.selectedMethod,
                    kitchenController.methodOptions,
                    kitchenController.updateMethodFilter,
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
                kitchenController.selectedStatus,
                kitchenController.statusOptions,
                kitchenController.updateStatusFilter,
                Icons.filter_list)),
        const SizedBox(width: 16),
        Expanded(
            flex: 2,
            child: _buildDropdown(
                kitchenController.selectedMethod,
                kitchenController.methodOptions,
                kitchenController.updateMethodFilter,
                Icons.payment)),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: kitchenController.updateSearchQuery,
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
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
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
                if (kitchenController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Use the API data directly instead of filtered data
                if (kitchenController.kitchens.isEmpty) {
                  return const Center(
                      child: Text('Tidak ada pesanan dapur ditemukan'));
                }
                return ListView.builder(
                  itemCount: kitchenController.kitchens.length,
                  itemBuilder: (context, index) {
                    final kitchen = kitchenController.kitchens[index];
                    return isDesktop
                        ? _buildDesktopRow(kitchen, index)
                        : _buildMobileCard(kitchen);
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
                    child: Text('Id Kitchen',
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
                    child: Text('Status Masakan',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Aksi',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Daftar Pesanan Dapur',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
    );
  }

  Widget _buildMobileCard(KitchenModel kitchen) {
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
              Text(kitchen.displayId,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              _buildStatusBadge(kitchen.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kitchen.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text('Meja ${kitchen.tableNumber}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Text(kitchenController.formatDate(kitchen.createdAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          // Add dish status badge for mobile
          Row(
            children: [
              Text('Status Masakan: ',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              _buildDishStatusBadge(kitchen.dishStatus),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${kitchen.totalItems} items',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text(kitchen.formattedTotal,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          _buildActionButtons(kitchen, true),
        ],
      ),
    );
  }

  Widget _buildDesktopRow(KitchenModel kitchen, int index) {
    final isEven = index % 2 == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration:
          BoxDecoration(color: isEven ? Colors.white : Colors.grey.shade50),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(kitchen.displayId,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
              flex: 2,
              child: Text(kitchenController.formatDate(kitchen.createdAt))),
          Expanded(flex: 2, child: Text(kitchen.customerName)),
          Expanded(flex: 1, child: Text(kitchen.tableNumber.toString())),
          Expanded(flex: 1, child: Text('${kitchen.totalItems} items')),
          Expanded(
              flex: 2,
              child: Text(kitchen.formattedTotal,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: _buildDishStatusBadge(kitchen.dishStatus)),
          Expanded(flex: 2, child: _buildActionButtons(kitchen, false)),
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

  // New method for dish status badge
  Widget _buildDishStatusBadge(String dishStatus) {
    Color color;
    String displayText;

    switch (dishStatus.toLowerCase()) {
      case 'received':
        color = const Color(0xFF6366F1); // Indigo
        displayText = 'DITERIMA';
        break;
      case 'processed':
        color = const Color(0xFF3B82F6); // Blue
        displayText = 'DIPROSES';
        break;
      case 'completed':
        color = const Color(0xFF10B981); // Green
        displayText = 'SELESAI';
        break;
      case 'cancelled':
        color = const Color(0xFFEF4444); // Red
        displayText = 'DIBATALKAN';
        break;
      default:
        color = const Color(0xFF6B7280); // Gray
        displayText = dishStatus.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  // New method for tracking info
  Widget _buildTrackingInfo(OrderTracking tracking) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tracking Info:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          if (tracking.created != null)
            _buildTrackingItem('Created', tracking.created!),
          if (tracking.lastModified != null)
            _buildTrackingItem('Last Modified', tracking.lastModified!),
          if (tracking.paid != null) _buildTrackingItem('Paid', tracking.paid!),
          if (tracking.cancelled != null)
            _buildTrackingItem('Cancelled', tracking.cancelled!),
        ],
      ),
    );
  }

  Widget _buildTrackingItem(String label, TrackingEvent event) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Text('$label: ',
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              event.at != null
                  ? '${kitchenController.formatDate(event.at!)} by ${event.by ?? 'Unknown'}'
                  : 'N/A',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(KitchenModel kitchen, bool isMobile) {
    return Obx(() => Row(
          mainAxisAlignment:
              isMobile ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => _showKitchenDetails(kitchen),
              icon: const Icon(Icons.visibility),
              style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.all(8)),
            ),
            const SizedBox(width: 8),
            // Tampilkan button selesai hanya jika status dish adalah 'processed'
            if (kitchenController.canCompleteOrder(kitchen.dishStatus))
              kitchenController.isCompletingOrder.value
                  ? SizedBox(
                      width: isMobile ? 80 : 90,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: null, // Disable button saat loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        child: const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _handleCompleteOrder(kitchen),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Selesai',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
            else
              // Tampilkan status jika tidak bisa diselesaikan
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  kitchenController.getStatusLabel(kitchen.dishStatus),
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ));
  }

  // Handler untuk complete order
  void _handleCompleteOrder(KitchenModel kitchen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(
            'Apakah Anda yakin ingin menyelesaikan pesanan ${kitchen.displayId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              kitchenController.completeOrder(kitchen.id, kitchen.displayId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Ya, Selesai'),
          ),
        ],
      ),
    );
  }

  // Add pagination widget
  Widget _buildPagination() {
    return Obx(() {
      return PaginationWidget(
        currentPage: kitchenController.currentPage.value,
        totalItems: kitchenController.totalItems.value,
        itemsPerPage: kitchenController.itemsPerPage.value,
        availablePageSizes: kitchenController.itemsPerPageOptions,
        startIndex: kitchenController.startIndex,
        endIndex: kitchenController.endIndex,
        hasPreviousPage: kitchenController.hasPreviousPage,
        hasNextPage: kitchenController.hasNextPage,
        pageNumbers: kitchenController.pageNumbers,
        onPageSizeChanged: kitchenController.updateItemsPerPage,
        onPreviousPage: kitchenController.previousPage,
        onNextPage: kitchenController.nextPage,
        onPageSelected: kitchenController.goToPage,
      );
    });
  }

  void _showKitchenDetails(KitchenModel kitchen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Pesanan Dapur ${kitchen.displayId}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Customer: ${kitchen.customerName}'),
              Text('Phone: ${kitchen.customerPhone}'),
              Text('Table: ${kitchen.tableNumber}'),
              Text('Status: ${kitchen.status}'),
              Text('Dish Status: ${kitchen.dishStatus}'),
              Text('Total: ${kitchen.formattedTotal}'),
              const SizedBox(height: 16),
              if (kitchen.tracking != null) ...[
                const Text('Tracking Information:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTrackingInfo(kitchen.tracking!),
                const SizedBox(height: 16),
              ],
              const Text('Items:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...kitchen.items.map((item) => Padding(
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
}
