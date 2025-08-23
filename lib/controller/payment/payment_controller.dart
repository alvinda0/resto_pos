// controller/payment/payment_controller.dart
import 'package:get/get.dart';
import 'package:pos/models/order/order_model.dart';
import 'package:pos/models/payment/payment_model.dart';
import 'package:pos/services/payment/payment_service.dart';
import 'package:pos/services/payment/receipt_printer_service.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();
  final ReceiptPrinterService _receiptPrinter = ReceiptPrinterService();

  // Observable states
  var isProcessingPayment = false.obs;
  var paymentResult = Rx<PaymentProcessResult?>(null);
  var orderUpdateProgress = ''.obs;
  var autoPrintEnabled = true.obs; // Setting for auto print after payment
  var selectedPaymentMethod = 'Tunai'.obs;
  var paymentHistory = <PaymentModel>[].obs;
  var isLoadingHistory = false.obs;

  // Payment method options
  final List<String> paymentMethods = [
    'Tunai',
    'Kartu Debit',
    'Kartu Kredit',
    'QRIS',
    'Transfer Bank',
    'E-Wallet',
    'Voucher',
  ];

  @override
  void onInit() {
    super.onInit();
    // Load settings
    _loadSettings();
  }

  // Load saved settings
  void _loadSettings() {
    // You can implement SharedPreferences here
    // For now, using default values
    autoPrintEnabled.value = true;
    selectedPaymentMethod.value = 'Tunai';
  }

  // Save settings
  void _saveSettings() {
    // Implement SharedPreferences here
    print('Settings saved: autoPrint=${autoPrintEnabled.value}');
  }

  // Main method: Process order + payment in sequence, then refresh order
  Future<bool> processOrderPayment({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required int tableNumber,
    String? notes,
    required List<dynamic> orderItems,
    String? paymentMethod,
    String? promoCode,
    bool printReceipt = true,
    bool showSuccessDialog = true,
  }) async {
    PaymentProcessResult? result;

    try {
      isProcessingPayment.value = true;
      orderUpdateProgress.value = 'Memulai proses pembayaran...';

      // Clear previous result
      paymentResult.value = null;

      // Validate input
      _validatePaymentInput(
        customerName: customerName,
        customerPhone: customerPhone,
        tableNumber: tableNumber,
        orderItems: orderItems,
      );

      // Use selected payment method if not provided
      final method = paymentMethod ?? selectedPaymentMethod.value;

      orderUpdateProgress.value = 'Memperbarui pesanan...';
      print('Processing payment for order: $orderId with method: $method');

      // Call the service to process order payment (includes order refresh)
      result = await _paymentService.processOrderPayment(
        orderId: orderId,
        customerName: customerName.trim(),
        customerPhone: customerPhone.trim(),
        tableNumber: tableNumber,
        notes: notes?.trim(),
        orderItems: orderItems,
        paymentMethod: method,
        promoCode: promoCode?.trim(),
      );

      // Set result and check success
      paymentResult.value = result;
      orderUpdateProgress.value = 'Pembayaran selesai';

      print('Payment result success: ${result.isSuccess}');
      print('Payment result error: ${result.error}');

      if (result.isSuccess) {
        // Payment successful - handle post-payment tasks
        await _handlePostPaymentTasks(
          result: result,
          printReceipt: printReceipt,
          showSuccessDialog: showSuccessDialog,
          customerName: customerName.trim(),
          paymentMethod: method,
        );

        return true;
      } else {
        // Handle failure case
        _handlePaymentFailure(result);
        return false;
      }
    } catch (e) {
      print('Payment exception: $e');
      return _handlePaymentException(e, result);
    } finally {
      isProcessingPayment.value = false;
      // Clear progress after delay
      Future.delayed(const Duration(seconds: 3), () {
        orderUpdateProgress.value = '';
      });
    }
  }

  // Validate payment input
  void _validatePaymentInput({
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

    // Basic phone number validation
    if (!_isValidPhoneNumber(customerPhone.trim())) {
      throw Exception('Format nomor telepon tidak valid');
    }

    if (tableNumber <= 0) {
      throw Exception('Nomor meja tidak valid');
    }

    if (orderItems.isEmpty) {
      throw Exception('Pesanan tidak boleh kosong');
    }

    // Validate order items have required fields
    for (int i = 0; i < orderItems.length; i++) {
      final item = orderItems[i];
      if (item is Map) {
        if (item['productId'] == null && item['id'] == null) {
          throw Exception('Item pesanan ke-${i + 1} tidak memiliki ID produk');
        }
        if ((item['quantity'] ?? 0) <= 0) {
          throw Exception('Jumlah item pesanan ke-${i + 1} harus lebih dari 0');
        }
      }
    }
  }

  // Basic phone number validation
  bool _isValidPhoneNumber(String phone) {
    // Remove any spaces, dashes, or plus signs
    String cleanPhone = phone.replaceAll(RegExp(r'[\s\-\+]'), '');

    // Check if it's all digits and has reasonable length (8-15 digits)
    if (!RegExp(r'^\d{8,15}$').hasMatch(cleanPhone)) {
      return false;
    }

    // Check for common Indonesian prefixes
    return cleanPhone.startsWith('08') ||
        cleanPhone.startsWith('628') ||
        cleanPhone.startsWith('021') ||
        cleanPhone.startsWith('022') ||
        cleanPhone.startsWith('024');
  }

  // Handle post-payment tasks
  Future<void> _handlePostPaymentTasks({
    required PaymentProcessResult result,
    required bool printReceipt,
    required bool showSuccessDialog,
    required String customerName,
    required String paymentMethod,
  }) async {
    // Handle receipt printing
    if (printReceipt && autoPrintEnabled.value) {
      await _handleReceiptPrinting(result);
    }

    // Show success notification
    if (showSuccessDialog) {
      _showSuccessNotification(
        result: result,
        customerName: customerName,
        paymentMethod: paymentMethod,
      );
    }

    // Refresh payment history
    if (result.order != null) {
      await _refreshPaymentHistory(result.order!.id);
    }
  }

  // Show success notification
  void _showSuccessNotification({
    required PaymentProcessResult result,
    required String customerName,
    required String paymentMethod,
  }) {
    try {
      double total = 0.0;
      String orderId = '';

      if (result.order != null) {
        total = result.order!.totalAmount;
        orderId = result.order!.displayId ?? result.order!.id;
      }

      Get.snackbar(
        'Pembayaran Berhasil! 🎉',
        'Order ID: $orderId\n'
            'Customer: $customerName\n'
            'Total: ${total > 0 ? _formatCurrency(total) : 'Berhasil'}\n'
            'Metode: $paymentMethod',
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Error showing success notification: $e');
      // Fallback notification
      Get.snackbar(
        'Pembayaran Berhasil! 🎉',
        'Pembayaran telah diproses dengan sukses',
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Handle payment failure
  void _handlePaymentFailure(PaymentProcessResult result) {
    String errorMsg = result.errorMessage.isEmpty
        ? 'Pembayaran gagal - tidak ada informasi error'
        : result.errorMessage;

    Get.snackbar(
      'Pembayaran Gagal ❌',
      errorMsg,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      colorText: Get.theme.colorScheme.error,
      duration: const Duration(seconds: 6),
      snackPosition: SnackPosition.TOP,
    );
  }

  // Handle payment exception
  bool _handlePaymentException(dynamic e, PaymentProcessResult? result) {
    // Set failed result only if no result exists or result was successful
    if (result == null || result.isSuccess) {
      paymentResult.value = PaymentProcessResult(
        success: false,
        error: e.toString(),
      );
    }

    orderUpdateProgress.value = 'Error: $e';

    // Don't show error if payment actually succeeded
    if (result != null && result.isSuccess) {
      print('Payment was successful but exception occurred in UI handling: $e');
      return true;
    }

    // Format error message for user
    String errorMessage = _formatErrorMessage(e.toString());

    Get.snackbar(
      'Error ⚠️',
      errorMessage,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      colorText: Get.theme.colorScheme.error,
      duration: const Duration(seconds: 6),
      snackPosition: SnackPosition.TOP,
    );
    return false;
  }

  // Handle receipt printing after successful payment
  Future<void> _handleReceiptPrinting(PaymentProcessResult result) async {
    if (result.order == null) {
      print('PaymentController: Cannot print receipt - no order data');
      return;
    }

    try {
      orderUpdateProgress.value = 'Mencetak struk...';

      // Check if printer is connected
      if (!_receiptPrinter.isConnected) {
        print('PaymentController: Printer not connected, skipping print');
        orderUpdateProgress.value =
            'Printer tidak terhubung - struk tidak dicetak';

        _showPrinterNotification(
          title: 'Info Printer 📄',
          message: 'Printer tidak terhubung. Struk tidak dapat dicetak.',
          isError: false,
        );
        return;
      }

      print(
          'PaymentController: Printing receipt for order ${result.order!.id}');
      bool printSuccess = await _receiptPrinter.printReceipt(result.order!);

      if (printSuccess) {
        orderUpdateProgress.value = 'Struk berhasil dicetak';
        print('PaymentController: Receipt printed successfully');

        _showPrinterNotification(
          title: 'Struk Dicetak 📄',
          message: 'Struk pembayaran berhasil dicetak',
          isError: false,
        );
      } else {
        orderUpdateProgress.value = 'Gagal mencetak struk';
        print('PaymentController: Failed to print receipt');

        _showPrinterNotification(
          title: 'Error Printer ⚠️',
          message: 'Gagal mencetak struk. Periksa koneksi printer.',
          isError: true,
        );
      }
    } catch (e) {
      print('PaymentController: Receipt printing error: $e');
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

  // Manual print receipt method
  Future<bool> printReceipt(OrderModel order) async {
    try {
      orderUpdateProgress.value = 'Mencetak struk...';

      if (!_receiptPrinter.isConnected) {
        Get.snackbar(
          'Error Printer ❌',
          'Printer tidak terhubung. Hubungkan printer terlebih dahulu.',
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
          colorText: Get.theme.colorScheme.error,
          duration: const Duration(seconds: 4),
        );
        return false;
      }

      bool success = await _receiptPrinter.printReceipt(order);

      if (success) {
        orderUpdateProgress.value = 'Struk berhasil dicetak';
        Get.snackbar(
          'Struk Dicetak 📄',
          'Struk untuk order ${order.displayId ?? order.id} berhasil dicetak',
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
          colorText: Get.theme.colorScheme.primary,
          duration: const Duration(seconds: 3),
        );
      } else {
        orderUpdateProgress.value = 'Gagal mencetak struk';
        Get.snackbar(
          'Error Printer ❌',
          'Gagal mencetak struk. Periksa koneksi printer.',
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
          colorText: Get.theme.colorScheme.error,
          duration: const Duration(seconds: 4),
        );
      }

      return success;
    } catch (e) {
      orderUpdateProgress.value = 'Error: $e';
      Get.snackbar(
        'Error ⚠️',
        'Terjadi kesalahan saat mencetak struk: $e',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 5),
      );
      return false;
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        orderUpdateProgress.value = '';
      });
    }
  }

  // Test print receipt
  Future<bool> testPrintReceipt() async {
    try {
      orderUpdateProgress.value = 'Test cetak struk...';

      if (!_receiptPrinter.isConnected) {
        Get.snackbar(
          'Error Printer ❌',
          'Printer tidak terhubung. Hubungkan printer terlebih dahulu.',
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
          colorText: Get.theme.colorScheme.error,
          duration: const Duration(seconds: 4),
        );
        return false;
      }

      bool success = await _receiptPrinter.testPrintReceipt();

      if (success) {
        orderUpdateProgress.value = 'Test cetak berhasil';
        Get.snackbar(
          'Test Print Berhasil 📄',
          'Test cetak struk berhasil dilakukan',
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
          colorText: Get.theme.colorScheme.primary,
          duration: const Duration(seconds: 3),
        );
      } else {
        orderUpdateProgress.value = 'Test cetak gagal';
        Get.snackbar(
          'Test Print Gagal ❌',
          'Test cetak struk gagal. Periksa koneksi printer.',
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
          colorText: Get.theme.colorScheme.error,
          duration: const Duration(seconds: 4),
        );
      }

      return success;
    } catch (e) {
      orderUpdateProgress.value = 'Error: $e';
      Get.snackbar(
        'Error ⚠️',
        'Terjadi kesalahan saat test cetak: $e',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 5),
      );
      return false;
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        orderUpdateProgress.value = '';
      });
    }
  }

  // Refresh order data
  Future<OrderModel?> refreshOrderData(String orderId) async {
    try {
      orderUpdateProgress.value = 'Mengambil data order...';

      OrderModel refreshedOrder = await _paymentService.getOrderById(orderId);

      orderUpdateProgress.value = 'Data order berhasil diambil';

      // Update payment result if it exists
      if (paymentResult.value != null) {
        paymentResult.value = PaymentProcessResult(
          success: paymentResult.value!.success,
          order: refreshedOrder,
          payment: paymentResult.value!.payment,
          error: paymentResult.value!.error,
        );
      }

      return refreshedOrder;
    } catch (e) {
      orderUpdateProgress.value = 'Error mengambil data order: $e';
      Get.snackbar(
        'Error ⚠️',
        'Gagal mengambil data order: $e',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 4),
      );
      return null;
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        orderUpdateProgress.value = '';
      });
    }
  }

  // Update only order items
  Future<bool> updateOrderItems({
    required String orderId,
    required List<dynamic> orderItems,
    String? promoCode,
  }) async {
    try {
      isProcessingPayment.value = true;
      orderUpdateProgress.value = 'Memperbarui item pesanan...';

      final updatedOrder = await _paymentService.updateOrderItems(
        orderId: orderId,
        orderItems: orderItems,
        promoCode: promoCode,
      );

      orderUpdateProgress.value = 'Item pesanan berhasil diperbarui';

      Get.snackbar(
        'Berhasil ✅',
        'Item pesanan berhasil diperbarui',
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      orderUpdateProgress.value = 'Error: $e';

      Get.snackbar(
        'Error ⚠️',
        'Gagal memperbarui item pesanan: $e',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 5),
      );
      return false;
    } finally {
      isProcessingPayment.value = false;
      Future.delayed(const Duration(seconds: 3), () {
        orderUpdateProgress.value = '';
      });
    }
  }

  // Process payment only
  Future<bool> processPaymentOnly({
    required String orderId,
    String? paymentMethod,
    bool printReceipt = true,
  }) async {
    try {
      isProcessingPayment.value = true;
      orderUpdateProgress.value = 'Memproses pembayaran...';

      final method = paymentMethod ?? selectedPaymentMethod.value;

      final payment = await _paymentService.processPayment(
        orderId: orderId,
        paymentMethod: method,
      );

      orderUpdateProgress.value = 'Pembayaran berhasil';

      // Get updated order data
      OrderModel? updatedOrder;
      if (printReceipt && autoPrintEnabled.value) {
        try {
          updatedOrder = await _paymentService.getOrderById(orderId);
          if (updatedOrder != null) {
            await _handleReceiptPrinting(PaymentProcessResult(
              success: true,
              order: updatedOrder,
              payment: payment,
            ));
          }
        } catch (e) {
          print('PaymentController: Failed to get order for printing: $e');
        }
      }

      Get.snackbar(
        'Pembayaran Berhasil! 🎉',
        'Metode: $method\n'
            'Status: ${payment.status}\n'
            'Ref: ${payment.transactionRef}',
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
        duration: const Duration(seconds: 4),
      );

      // Refresh payment history
      await _refreshPaymentHistory(orderId);

      return true;
    } catch (e) {
      orderUpdateProgress.value = 'Error: $e';

      Get.snackbar(
        'Pembayaran Gagal ❌',
        'Gagal memproses pembayaran: $e',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 5),
      );
      return false;
    } finally {
      isProcessingPayment.value = false;
      Future.delayed(const Duration(seconds: 3), () {
        orderUpdateProgress.value = '';
      });
    }
  }

  // Get payment history for an order
  Future<List<PaymentModel>> getOrderPayments(String orderId) async {
    try {
      isLoadingHistory.value = true;
      orderUpdateProgress.value = 'Mengambil riwayat pembayaran...';

      final payments = await _paymentService.getOrderPayments(orderId);
      paymentHistory.value = payments;

      orderUpdateProgress.value = 'Riwayat pembayaran berhasil dimuat';

      return payments;
    } catch (e) {
      orderUpdateProgress.value = 'Error mengambil riwayat: $e';

      Get.snackbar(
        'Error ⚠️',
        'Gagal mengambil riwayat pembayaran: $e',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 4),
      );
      return [];
    } finally {
      isLoadingHistory.value = false;
      Future.delayed(const Duration(seconds: 2), () {
        orderUpdateProgress.value = '';
      });
    }
  }

  // Refresh payment history
  Future<void> _refreshPaymentHistory(String orderId) async {
    try {
      await getOrderPayments(orderId);
    } catch (e) {
      print('Error refreshing payment history: $e');
    }
  }

  // Helper method to format error message
  String _formatErrorMessage(String error) {
    String errorMessage = 'Terjadi kesalahan';

    if (error.contains('customer_name')) {
      errorMessage = 'Nama customer tidak boleh kosong';
    } else if (error.contains('customer_phone')) {
      errorMessage = 'Nomor telepon customer tidak valid';
    } else if (error.contains('table_number')) {
      errorMessage = 'Nomor meja tidak valid';
    } else if (error.contains('order_details')) {
      errorMessage = 'Data pesanan tidak valid';
    } else if (error.contains('payment')) {
      errorMessage = 'Gagal memproses pembayaran';
    } else if (error.contains('network') || error.contains('connection')) {
      errorMessage = 'Koneksi internet bermasalah';
    } else if (error.contains('timeout')) {
      errorMessage = 'Koneksi timeout. Silakan coba lagi';
    } else if (error.contains('Format nomor telepon')) {
      errorMessage = error;
    } else if (error.contains('Exception: ')) {
      errorMessage = error.replaceAll('Exception: ', '');
    } else {
      errorMessage = error;
    }

    return errorMessage;
  }

  // Utility method to format currency
  String _formatCurrency(double amount) {
    return "Rp${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}";
  }

  // Settings methods
  void toggleAutoPrint() {
    autoPrintEnabled.value = !autoPrintEnabled.value;
    _saveSettings();

    Get.snackbar(
      'Pengaturan Auto Print',
      'Auto print struk: ${autoPrintEnabled.value ? 'Aktif' : 'Nonaktif'}',
      backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
      colorText: Get.theme.colorScheme.secondary,
      duration: const Duration(seconds: 2),
    );
  }

  void setPaymentMethod(String method) {
    if (paymentMethods.contains(method)) {
      selectedPaymentMethod.value = method;
      _saveSettings();
    }
  }

  // Validation methods
  bool isValidCustomerData({
    required String customerName,
    required String customerPhone,
    required int tableNumber,
  }) {
    try {
      _validatePaymentInput(
        customerName: customerName,
        customerPhone: customerPhone,
        tableNumber: tableNumber,
        orderItems: [
          {'productId': 'dummy', 'quantity': 1}
        ], // dummy for validation
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  String? validateCustomerName(String name) {
    if (name.trim().isEmpty) {
      return 'Nama customer tidak boleh kosong';
    }
    if (name.trim().length < 2) {
      return 'Nama customer minimal 2 karakter';
    }
    return null;
  }

  String? validateCustomerPhone(String phone) {
    if (phone.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (!_isValidPhoneNumber(phone.trim())) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  String? validateTableNumber(int tableNumber) {
    if (tableNumber <= 0) {
      return 'Nomor meja harus lebih dari 0';
    }
    if (tableNumber > 999) {
      return 'Nomor meja tidak valid';
    }
    return null;
  }

  // Clear payment result
  void clearPaymentResult() {
    paymentResult.value = null;
    orderUpdateProgress.value = '';
  }

  // Clear payment history
  void clearPaymentHistory() {
    paymentHistory.clear();
  }

  // Reset controller state
  void reset() {
    isProcessingPayment.value = false;
    paymentResult.value = null;
    orderUpdateProgress.value = '';
    paymentHistory.clear();
    isLoadingHistory.value = false;
  }

  // Get payment summary
  Map<String, dynamic> getPaymentSummary() {
    final result = paymentResult.value;
    if (result == null || !result.isSuccess) {
      return {};
    }

    return {
      'orderId': result.order?.displayId ?? result.order?.id ?? '',
      'customerName': result.order?.customerName ?? '',
      'totalAmount': result.order?.totalAmount ?? 0.0,
      'paymentMethod': result.payment?.method ?? '',
      'paymentStatus': result.payment?.status ?? '',
      'transactionRef': result.payment?.transactionRef ?? '',
      'paidAt': result.payment?.paidAt,
      'success': result.isSuccess,
    };
  }

  // Getters
  OrderModel? get latestOrder => paymentResult.value?.order;
  PaymentModel? get latestPayment => paymentResult.value?.payment;
  bool get isPaymentSuccessful => paymentResult.value?.isSuccess ?? false;
  String get paymentErrorMessage => paymentResult.value?.errorMessage ?? '';
  bool get isPrinterConnected => _receiptPrinter.isConnected;

  // Get receipt printer service for settings
  ReceiptPrinterService get receiptPrinter => _receiptPrinter;

  @override
  void onClose() {
    // Save settings before closing
    _saveSettings();
    super.onClose();
  }
}
