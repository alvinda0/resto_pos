// controller/payment/qris_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:pos/models/order/order_model.dart';
import 'package:pos/models/order/qris_model.dart';
import 'package:pos/services/payment/payment_service.dart';
import 'package:pos/services/payment/receipt_printer_service.dart';

class QRISController extends GetxController {
  final PaymentService _paymentService = PaymentService();
  final ReceiptPrinterService _receiptPrinter = ReceiptPrinterService();

  // Observable states
  var isProcessingPayment = false.obs;
  var qrisResult = Rx<QRISPaymentResult?>(null);
  var qrisStatus = Rx<QRISStatusResult?>(null);
  var updatedOrder = Rx<OrderModel?>(null);
  var orderUpdateProgress = ''.obs;
  var timeRemaining = ''.obs;
  var isPaymentCompleted = false.obs;

  // Timer for checking payment status and countdown
  Timer? _statusCheckTimer;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    _stopTimers();
    super.onClose();
  }

  // Main method: Process QRIS payment (update order first, then create QRIS)
  Future<bool> processQRISPayment({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required int tableNumber,
    String? notes,
    required List<dynamic> orderItems,
    String? promoCode,
    bool printOnSuccess = true,
  }) async {
    try {
      isProcessingPayment.value = true;
      orderUpdateProgress.value = 'Memulai proses QRIS...';
      isPaymentCompleted.value = false;

      // Clear previous results
      qrisResult.value = null;
      qrisStatus.value = null;
      updatedOrder.value = null;

      // Validate input
      _validateQRISInput(
        customerName: customerName,
        customerPhone: customerPhone,
        tableNumber: tableNumber,
        orderItems: orderItems,
      );

      // Step 1: Update order with customer info and items
      orderUpdateProgress.value = 'Memperbarui pesanan...';
      print('Updating order: $orderId');

      updatedOrder.value = await _paymentService.updateOrderComplete(
        orderId: orderId,
        customerName: customerName.trim(),
        customerPhone: customerPhone.trim(),
        tableNumber: tableNumber,
        notes: notes?.trim(),
        orderItems: orderItems,
        promoCode: promoCode?.trim(),
      );

      print('Order updated successfully');

      // Step 2: Create QRIS payment
      orderUpdateProgress.value = 'Membuat pembayaran QRIS...';
      print('Creating QRIS payment for order: $orderId');

      qrisResult.value = await _paymentService.processQRISPayment(
        orderId: orderId,
      );

      print('QRIS payment created successfully');
      orderUpdateProgress.value = 'QRIS berhasil dibuat';

      // Step 3: Start monitoring payment status
      _startStatusMonitoring(orderId, printOnSuccess);

      return true;
    } catch (e) {
      print('Error in QRIS payment process: $e');
      return _handleQRISError(e);
    } finally {
      isProcessingPayment.value = false;
    }
  }

  // Start monitoring payment status and countdown
  void _startStatusMonitoring(String orderId, bool printOnSuccess) {
    if (qrisResult.value == null) return;

    // Start countdown timer
    _startCountdownTimer();

    // Start status checking timer
    _statusCheckTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkQRISStatus(orderId, printOnSuccess);
    });

    print('Started QRIS monitoring for order: $orderId');
  }

  // Start countdown timer
  void _startCountdownTimer() {
    final qris = qrisResult.value;
    if (qris == null) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (qris.isExpired || isPaymentCompleted.value) {
        timer.cancel();
        timeRemaining.value = '00:00';
        return;
      }

      final remaining = qris.timeRemaining;
      final minutes = remaining.inMinutes;
      final seconds = remaining.inSeconds % 60;
      timeRemaining.value =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    });

    // Set initial time
    final remaining = qris.timeRemaining;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    timeRemaining.value =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Check QRIS payment status
  Future<void> _checkQRISStatus(String orderId, bool printOnSuccess) async {
    try {
      final status = await _paymentService.checkQRISStatus(orderId: orderId);
      qrisStatus.value = status;

      print('QRIS status check - Status: ${status.status}');

      if (status.isSuccess) {
        print('QRIS payment successful!');
        await _handlePaymentSuccess(orderId, printOnSuccess);
      } else if (status.isFailed) {
        print('QRIS payment failed');
        _handlePaymentFailure();
      }
      // If still pending, continue monitoring
    } catch (e) {
      print('Error checking QRIS status: $e');
      // Continue monitoring on error
    }
  }

  // Handle successful payment
  Future<void> _handlePaymentSuccess(
      String orderId, bool printOnSuccess) async {
    try {
      _stopTimers();
      isPaymentCompleted.value = true;
      orderUpdateProgress.value = 'Pembayaran QRIS berhasil!';

      // Get updated order with payment details
      orderUpdateProgress.value = 'Mengambil detail pesanan...';
      updatedOrder.value = await _paymentService.getOrderById(orderId);

      // Show success notification
      _showSuccessNotification();

      // Print receipt if enabled
      if (printOnSuccess && updatedOrder.value != null) {
        await _handleReceiptPrinting();
      }

      print('QRIS payment process completed successfully');
    } catch (e) {
      print('Error handling QRIS payment success: $e');
      // Still consider payment successful since QRIS status is SUCCESS
      _showSuccessNotification();
    }
  }

  // Handle payment failure
  void _handlePaymentFailure() {
    _stopTimers();
    isPaymentCompleted.value = true;
    orderUpdateProgress.value = 'Pembayaran QRIS gagal';

    Get.snackbar(
      'Pembayaran Gagal ❌',
      'Pembayaran QRIS gagal atau dibatalkan',
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      colorText: Get.theme.colorScheme.error,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
    );
  }

  // Show success notification
  void _showSuccessNotification() {
    String orderDisplayId = '';
    String customerName = '';
    double totalAmount = 0.0;

    if (updatedOrder.value != null) {
      orderDisplayId = updatedOrder.value!.displayId ?? updatedOrder.value!.id;
      customerName = updatedOrder.value!.customerName;
      totalAmount = updatedOrder.value!.totalAmount;
    }

    Get.snackbar(
      'Pembayaran QRIS Berhasil! 🎉',
      'Order ID: $orderDisplayId\n'
          'Customer: $customerName\n'
          'Total: ${totalAmount > 0 ? _formatCurrency(totalAmount) : 'Berhasil'}\n'
          'Metode: QRIS',
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      colorText: Get.theme.colorScheme.primary,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
    );
  }

  // Handle receipt printing
  Future<void> _handleReceiptPrinting() async {
    final order = updatedOrder.value;
    if (order == null) {
      print('Cannot print receipt - no order data');
      return;
    }

    try {
      orderUpdateProgress.value = 'Mencetak struk...';

      if (!_receiptPrinter.isConnected) {
        orderUpdateProgress.value =
            'Printer tidak terhubung - struk tidak dicetak';
        _showPrinterNotification(
          title: 'Info Printer 📄',
          message: 'Printer tidak terhubung. Struk tidak dapat dicetak.',
          isError: false,
        );
        return;
      }

      bool printSuccess = await _receiptPrinter.printReceipt(order);

      if (printSuccess) {
        orderUpdateProgress.value = 'Struk berhasil dicetak';
        _showPrinterNotification(
          title: 'Struk Dicetak 📄',
          message: 'Struk pembayaran QRIS berhasil dicetak',
          isError: false,
        );
      } else {
        orderUpdateProgress.value = 'Gagal mencetak struk';
        _showPrinterNotification(
          title: 'Error Printer ⚠️',
          message: 'Gagal mencetak struk. Periksa koneksi printer.',
          isError: true,
        );
      }
    } catch (e) {
      print('Receipt printing error: $e');
      orderUpdateProgress.value = 'Error saat mencetak struk';
      _showPrinterNotification(
        title: 'Error Printer ⚠️',
        message: 'Terjadi kesalahan saat mencetak struk: $e',
        isError: true,
      );
    }
  }

  // Show printer notification
  void _showPrinterNotification({
    required String title,
    required String message,
    required bool isError,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError
          ? Get.theme.colorScheme.error.withOpacity(0.1)
          : Get.theme.colorScheme.secondary.withOpacity(0.1),
      colorText: isError
          ? Get.theme.colorScheme.error
          : Get.theme.colorScheme.secondary,
      duration: Duration(seconds: isError ? 4 : 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Manual status check
  Future<void> checkPaymentStatus(String orderId) async {
    if (isPaymentCompleted.value) return;

    try {
      orderUpdateProgress.value = 'Mengecek status pembayaran...';
      await _checkQRISStatus(orderId, true);
      orderUpdateProgress.value = 'Status pembayaran diperbarui';
    } catch (e) {
      orderUpdateProgress.value = 'Error mengecek status';
      print('Manual status check error: $e');
    }
  }

  // Cancel QRIS payment
  void cancelQRISPayment() {
    _stopTimers();
    isPaymentCompleted.value = true;
    orderUpdateProgress.value = 'Pembayaran QRIS dibatalkan';

    Get.snackbar(
      'Pembayaran Dibatalkan',
      'Pembayaran QRIS telah dibatalkan',
      backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
      colorText: Get.theme.colorScheme.secondary,
      duration: const Duration(seconds: 3),
    );
  }

  // Stop all timers
  void _stopTimers() {
    _statusCheckTimer?.cancel();
    _countdownTimer?.cancel();
    _statusCheckTimer = null;
    _countdownTimer = null;
  }

  // Handle QRIS error
  bool _handleQRISError(dynamic e) {
    orderUpdateProgress.value = 'Error: $e';

    String errorMessage = _formatErrorMessage(e.toString());

    Get.snackbar(
      'Error QRIS ⚠️',
      errorMessage,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      colorText: Get.theme.colorScheme.error,
      duration: const Duration(seconds: 6),
      snackPosition: SnackPosition.TOP,
    );

    return false;
  }

  // Validate QRIS input
  void _validateQRISInput({
    required String customerName,
    required String customerPhone,
    required int tableNumber,
    required List<dynamic> orderItems,
  }) {
    if (customerName.trim().isEmpty) {
      throw Exception('Nama customer tidak boleh kosong');
    }

    if (customerPhone.trim().isEmpty) {
      throw Exception('Nomor telepon customer tidak boleh kosong');
    }

    if (!_isValidPhoneNumber(customerPhone.trim())) {
      throw Exception('Format nomor telepon tidak valid');
    }

    if (tableNumber <= 0) {
      throw Exception('Nomor meja tidak valid');
    }

    if (orderItems.isEmpty) {
      throw Exception('Pesanan tidak boleh kosong');
    }
  }

  // Basic phone number validation
  bool _isValidPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[\s\-\+]'), '');

    if (!RegExp(r'^\d{8,15}$').hasMatch(cleanPhone)) {
      return false;
    }

    return cleanPhone.startsWith('08') ||
        cleanPhone.startsWith('628') ||
        cleanPhone.startsWith('021') ||
        cleanPhone.startsWith('022') ||
        cleanPhone.startsWith('024');
  }

  // Format error message
  String _formatErrorMessage(String error) {
    if (error.contains('customer_name')) {
      return 'Nama customer tidak boleh kosong';
    } else if (error.contains('customer_phone')) {
      return 'Nomor telepon customer tidak valid';
    } else if (error.contains('table_number')) {
      return 'Nomor meja tidak valid';
    } else if (error.contains('order_details')) {
      return 'Data pesanan tidak valid';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Koneksi internet bermasalah';
    } else if (error.contains('timeout')) {
      return 'Koneksi timeout. Silakan coba lagi';
    } else if (error.contains('Exception: ')) {
      return error.replaceAll('Exception: ', '');
    }
    return error;
  }

  // Format currency
  String _formatCurrency(double amount) {
    return "Rp${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}";
  }

  // Reset controller state
  void reset() {
    _stopTimers();
    isProcessingPayment.value = false;
    qrisResult.value = null;
    qrisStatus.value = null;
    updatedOrder.value = null;
    orderUpdateProgress.value = '';
    timeRemaining.value = '';
    isPaymentCompleted.value = false;
  }

  // Getters
  bool get isQRISExpired => qrisResult.value?.isExpired ?? false;
  bool get isQRISActive =>
      qrisResult.value != null && !isPaymentCompleted.value && !isQRISExpired;
  String get qrisImageData => qrisResult.value?.qrisData ?? '';
  double get qrisAmount => qrisResult.value?.amount ?? 0.0;
  String get currentStatus => qrisStatus.value?.status ?? 'PENDING';
  bool get isPrinterConnected => _receiptPrinter.isConnected;
}
