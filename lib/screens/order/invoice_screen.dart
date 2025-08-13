import 'package:flutter/material.dart';
import 'package:pos/controller/order/order_controller.dart';
import 'package:pos/models/order/order_model.dart';

class InvoiceDialog extends StatelessWidget {
  final OrderModel order;
  final OrderController orderController;

  const InvoiceDialog({
    super.key,
    required this.order,
    required this.orderController,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isMobile = screenSize.width < 600;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: _getDialogWidth(screenSize),
        height: _getDialogHeight(screenSize),
        constraints: BoxConstraints(
          maxWidth: isTablet ? 1000 : screenSize.width * 0.95,
          maxHeight: screenSize.height * 0.9,
        ),
        child: Column(
          children: [
            // Header dengan close button
            _buildHeader(context, isMobile),

            // Content
            Expanded(
              child: _buildContent(context, isMobile, isTablet),
            ),
          ],
        ),
      ),
    );
  }

  double _getDialogWidth(Size screenSize) {
    if (screenSize.width > 1200) return screenSize.width * 0.7;
    if (screenSize.width > 768) return screenSize.width * 0.85;
    return screenSize.width * 0.95;
  }

  double _getDialogHeight(Size screenSize) {
    if (screenSize.width > 768) return screenSize.height * 0.8;
    return screenSize.height * 0.9;
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'INVOICE',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: isMobile ? 20 : 24,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isMobile, bool isTablet) {
    final padding = isMobile ? 16.0 : 24.0;

    if (isMobile) {
      // Layout vertikal untuk mobile
      return SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            _buildOrderList(isMobile, isTablet),
            const SizedBox(height: 24),
            _buildCustomerDetails(isMobile, isTablet),
          ],
        ),
      );
    } else {
      // Layout horizontal untuk tablet/desktop dengan SingleChildScrollView
      return SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column - Daftar Pesanan
              Expanded(
                flex: 1,
                child: _buildOrderList(isMobile, isTablet),
              ),
              const SizedBox(width: 24),
              // Right Column - Detail Customer & Payment Info
              Expanded(
                flex: 1,
                child: _buildCustomerDetails(isMobile, isTablet),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildInvoiceHeader(bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: isMobile
          ? Column(
              children: [
                _buildHeaderItem(
                  'Tanggal Issue:',
                  orderController.formatDate(order.createdAt),
                  isMobile,
                ),
                const SizedBox(height: 12),
                _buildHeaderItem(
                  'Status Pembayaran:',
                  null,
                  isMobile,
                  isStatus: true,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _buildHeaderItem(
                    'Tanggal Issue:',
                    orderController.formatDate(order.createdAt),
                    isMobile,
                  ),
                ),
                Flexible(
                  child: _buildHeaderItem(
                    'Status Pembayaran:',
                    null,
                    isMobile,
                    isStatus: true,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderItem(String label, String? value, bool isMobile,
      {bool isStatus = false}) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : isStatus
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        if (isStatus)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Paid',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else if (value != null)
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildOrderList(bool isMobile, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInvoiceHeader(isMobile, isTablet),
        const SizedBox(height: 24),

        // Daftar Pesanan
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Daftar Pesanan',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Items List
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  children: order.items
                      .map((item) => Container(
                            margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                            child: _buildOrderItem(item, isMobile),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(dynamic item, bool isMobile) {
    // Safe conversion untuk menangani double/int
    final unitPrice = (item.totalPrice / item.quantity).round();
    final totalPrice =
        item.totalPrice is double ? item.totalPrice.round() : item.totalPrice;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${item.quantity} x',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp${_formatPrice(unitPrice)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Rp${_formatPrice(totalPrice)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Rp${_formatPrice(unitPrice)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.quantity} x',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 16),
          Text(
            'Rp${_formatPrice(totalPrice)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildCustomerDetails(bool isMobile, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Detail Customer
        _buildSection(
          'Detail Customer',
          [
            _buildDetailRow('Nama Customer', order.customerName, isMobile),
            SizedBox(height: isMobile ? 8 : 12),
            _buildDetailRow('Nomor WA', order.customerPhone, isMobile),
            SizedBox(height: isMobile ? 8 : 12),
            _buildDetailRow(
                'Nomor Meja', order.tableNumber.toString(), isMobile),
            SizedBox(height: isMobile ? 8 : 12),
            _buildDetailRow('Catatan Order', order.notes ?? '-', isMobile),
          ],
          isMobile,
        ),

        const SizedBox(height: 24),

        // Informasi Pembayaran - Fixed overflow issue
        _buildPaymentSection(isMobile),
      ],
    );
  }

  Widget _buildPaymentSection(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Informasi Pembayaran',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              children: [
                _buildPaymentRow(
                  'Subtotal',
                  'Rp${_formatPrice(_safeIntConversion(order.totalItems))}',
                  isMobile,
                ),
                SizedBox(height: isMobile ? 6 : 8),
                _buildPaymentRow(
                  'Total',
                  order.formattedTotal,
                  isMobile,
                  isBold: true,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                _buildPaymentMethod(isMobile),
                SizedBox(height: isMobile ? 6 : 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        orderController.formatDate(order.createdAt),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildPaymentRow(String label, String value, bool isMobile,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(bool isMobile) {
    return Row(
      children: [
        Container(
          width: isMobile ? 10 : 12,
          height: isMobile ? 10 : 12,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: isMobile ? 6 : 8),
        const Expanded(
          child: Text(
            'Tunai',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            order.formattedTotal,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  // Helper function untuk konversi yang aman dari double ke int
  int _safeIntConversion(dynamic value) {
    if (value is double) {
      return value.round();
    } else if (value is int) {
      return value;
    } else {
      return 0; // fallback
    }
  }

  // Static method untuk memudahkan pemanggilan
  static void show(
    BuildContext context,
    OrderModel order,
    OrderController orderController,
  ) {
    showDialog(
      context: context,
      builder: (context) => InvoiceDialog(
        order: order,
        orderController: orderController,
      ),
    );
  }
}
