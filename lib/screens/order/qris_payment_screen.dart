// screens/payment/qris_payment_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/payment/QRISController.dart';
import 'package:pos/models/order/order_model.dart';

class QRISPaymentScreen extends StatefulWidget {
  final OrderModel order;
  final String customerName;
  final String customerPhone;
  final int tableNumber;
  final String? notes;
  final List<dynamic> orderItems;
  final String? promoCode;

  const QRISPaymentScreen({
    super.key,
    required this.order,
    required this.customerName,
    required this.customerPhone,
    required this.tableNumber,
    this.notes,
    required this.orderItems,
    this.promoCode,
  });

  static Future<void> show(
    BuildContext context, {
    required OrderModel order,
    required String customerName,
    required String customerPhone,
    required int tableNumber,
    String? notes,
    required List<dynamic> orderItems,
    String? promoCode,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QRISPaymentScreen(
        order: order,
        customerName: customerName,
        customerPhone: customerPhone,
        tableNumber: tableNumber,
        notes: notes,
        orderItems: orderItems,
        promoCode: promoCode,
      ),
    );
  }

  @override
  State<QRISPaymentScreen> createState() => _QRISPaymentScreenState();
}

class _QRISPaymentScreenState extends State<QRISPaymentScreen> {
  final QRISController qrisController = Get.put(QRISController());

  // Helper method to determine device type
  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1024;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startQRISPayment();
    });
  }

  @override
  void dispose() {
    qrisController.reset();
    super.dispose();
  }

  Future<void> _startQRISPayment() async {
    final success = await qrisController.processQRISPayment(
      orderId: widget.order.id,
      customerName: widget.customerName,
      customerPhone: widget.customerPhone,
      tableNumber: widget.tableNumber,
      notes: widget.notes,
      orderItems: widget.orderItems,
      promoCode: widget.promoCode,
      printOnSuccess: true,
    );

    if (!success && mounted) {
      // If QRIS creation failed, close dialog after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  double _calculateOrderTotal() {
    return widget.orderItems.fold(0.0, (sum, item) {
      try {
        if (item is Map) {
          double totalPrice = item['totalPrice'] is double
              ? item['totalPrice']
              : double.parse(item['totalPrice'].toString());
          return sum + totalPrice;
        } else {
          double totalPrice = item.totalPrice?.toDouble() ?? 0.0;
          return sum + totalPrice;
        }
      } catch (e) {
        return sum;
      }
    });
  }

  String _formatCurrency(double amount) {
    return "Rp${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 500 : (isTablet ? 450 : double.infinity),
          maxHeight: isDesktop ? 700 : (isTablet ? 650 : double.infinity),
        ),
        width: double.infinity,
        height: isMobile ? MediaQuery.of(context).size.height * 0.90 : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
            _buildFooter(),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.qr_code,
              color: Colors.blue,
              size: isMobile ? 20 : 24,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembayaran QRIS',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Order ID: ${widget.order.displayId ?? widget.order.id}',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => qrisController.isPaymentCompleted.value
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: const CircleBorder(),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _showCancelConfirmation(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: const CircleBorder(),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (qrisController.isProcessingPayment.value) {
        return _buildLoadingState();
      }

      if (qrisController.qrisResult.value == null) {
        return _buildErrorState();
      }

      if (qrisController.isPaymentCompleted.value) {
        return _buildCompletedState();
      }

      return _buildQRISState();
    });
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Text(
            'Membuat Pembayaran QRIS...',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Obx(() => Text(
                qrisController.orderUpdateProgress.value,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              )),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isMobile ? 60 : 80,
            color: Colors.red.shade400,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Text(
            'Gagal Membuat QRIS',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Obx(() => Text(
                qrisController.orderUpdateProgress.value.isNotEmpty
                    ? qrisController.orderUpdateProgress.value
                    : 'Terjadi kesalahan saat membuat pembayaran QRIS',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              )),
          SizedBox(height: isMobile ? 20 : 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 8 : 12,
              ),
            ),
            child: Text(
              'Tutup',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRISState() {
    final qrisResult = qrisController.qrisResult.value!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        children: [
          // Payment Amount
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Text(
                  _formatCurrency(_calculateOrderTotal()),
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Timer and Status
          _buildStatusBar(),

          SizedBox(height: isMobile ? 16 : 20),

          // QR Code
          _buildQRCode(qrisResult.qrisData),

          SizedBox(height: isMobile ? 16 : 20),

          // Instructions
          _buildInstructions(),

          SizedBox(height: isMobile ? 16 : 20),

          // Manual Check Button
          _buildManualCheckButton(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Pembayaran',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Obx(() => Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Waktu Tersisa',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Obx(() => Text(
                    qrisController.timeRemaining.value.isNotEmpty
                        ? qrisController.timeRemaining.value
                        : '00:00',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: qrisController.isQRISExpired
                          ? Colors.red.shade600
                          : Colors.orange.shade600,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode(String qrisData) {
    if (qrisData.isEmpty) {
      return Container(
        width: isMobile ? 200 : 250,
        height: isMobile ? 200 : 250,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.qr_code, size: 80, color: Colors.grey),
        ),
      );
    }

    // Parse base64 image data
    String base64String = qrisData;
    if (qrisData.contains(',')) {
      base64String = qrisData.split(',')[1];
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              base64Decode(base64String),
              width: isMobile ? 200 : 250,
              height: isMobile ? 200 : 250,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: isMobile ? 200 : 250,
                  height: isMobile ? 200 : 250,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.error, size: 40, color: Colors.red),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'Scan QR Code untuk membayar',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade600,
                size: isMobile ? 16 : 20,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'Cara Pembayaran',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          ..._buildInstructionSteps(),
        ],
      ),
    );
  }

  List<Widget> _buildInstructionSteps() {
    final steps = [
      'Buka aplikasi e-wallet (OVO, GoPay, DANA, dll)',
      'Pilih menu "Scan QR" atau "QRIS"',
      'Arahkan kamera ke QR code di atas',
      'Konfirmasi pembayaran di aplikasi',
      'Tunggu konfirmasi pembayaran berhasil',
    ];

    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;

      return Padding(
        padding: EdgeInsets.only(bottom: isMobile ? 4 : 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isMobile ? 16 : 20,
              height: isMobile ? 16 : 20,
              margin: EdgeInsets.only(right: isMobile ? 6 : 8, top: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                step,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 13,
                  color: Colors.blue.shade700,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildManualCheckButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: qrisController.isPaymentCompleted.value
                ? null
                : () => qrisController.checkPaymentStatus(widget.order.id),
            icon: Icon(
              Icons.refresh,
              size: isMobile ? 16 : 18,
            ),
            label: Text(
              'Cek Status Pembayaran',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 8 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ));
  }

  Widget _buildCompletedState() {
    final isSuccess = qrisController.qrisStatus.value?.isSuccess ?? false;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 80 : 100,
            height: isMobile ? 80 : 100,
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              size: isMobile ? 50 : 60,
              color: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Text(
            isSuccess ? 'Pembayaran Berhasil!' : 'Pembayaran Gagal',
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          if (isSuccess) ...[
            Text(
              'Pembayaran QRIS berhasil diproses',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  _buildResultRow(
                      'Order ID', widget.order.displayId ?? widget.order.id),
                  _buildResultRow('Customer', widget.customerName),
                  _buildResultRow(
                      'Total', _formatCurrency(_calculateOrderTotal())),
                  _buildResultRow('Metode', 'QRIS'),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Pembayaran QRIS gagal atau dibatalkan',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: isMobile ? 20 : 24),
          Obx(() => Text(
                qrisController.orderUpdateProgress.value,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              )),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 2 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isMobile ? 8 : 12),
          bottomRight: Radius.circular(isMobile ? 8 : 12),
        ),
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Obx(() {
        if (qrisController.isPaymentCompleted.value) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
              ),
              child: Text(
                'Tutup',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCancelConfirmation(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade600),
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                ),
                child: Text(
                  'Batal',
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: ElevatedButton(
                onPressed: qrisController.isQRISExpired
                    ? () => _startQRISPayment()
                    : () => qrisController.checkPaymentStatus(widget.order.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: qrisController.isQRISExpired
                      ? Colors.blue.shade600
                      : Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                ),
                child: Text(
                  qrisController.isQRISExpired ? 'Buat Ulang' : 'Refresh',
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Helper methods
  Color _getStatusColor() {
    final status = qrisController.currentStatus;
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return Colors.green.shade600;
      case 'FAILED':
      case 'CANCELLED':
        return Colors.red.shade600;
      case 'PENDING':
      default:
        return Colors.orange.shade600;
    }
  }

  String _getStatusText() {
    final status = qrisController.currentStatus;
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return 'Berhasil';
      case 'FAILED':
        return 'Gagal';
      case 'CANCELLED':
        return 'Dibatalkan';
      case 'PENDING':
      default:
        return 'Menunggu Pembayaran';
    }
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pembayaran QRIS ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close confirmation dialog
              qrisController.cancelQRISPayment();
              Navigator.pop(context); // Close QRIS payment screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}
