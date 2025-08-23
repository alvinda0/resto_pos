// controller/order/new_order_controller.dart - FIXED VERSION
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/order/new_order_model.dart';
import 'package:pos/models/product/product_model.dart';
import 'package:pos/services/order/PrintServiceOrder.dart';
import 'package:pos/services/order/new_order_service.dart';

class NewOrderController extends GetxController {
  final OrderService _orderService = OrderService.instance;

  // Observable variables - pastikan semua menggunakan .obs
  final PrintService _printService = PrintService();

  final RxBool isLoading = false.obs;
  final RxBool isProcessingPayment = false.obs;
  final RxString error = ''.obs;
  final Rx<Order?> currentOrder = Rx<Order?>(null);
  final Rx<QrisPaymentResponse?> qrisPayment = Rx<QrisPaymentResponse?>(null);
  final RxBool isQrisPaymentActive = false.obs;

  // NEW: Add print status tracking
  final RxBool isPrinting = false.obs;
  final RxString printStatus = ''.obs;

  // Timer for QRIS status checking
  Timer? _qrisStatusTimer;

  // Order form data - semua observable
  final RxList<Map<String, dynamic>> orderItems = <Map<String, dynamic>>[].obs;
  final RxString customerName = ''.obs;
  final RxString customerPhone = ''.obs;
  final RxInt tableNumber = 0.obs;
  final RxString notes = ''.obs;
  final RxString promoCode = ''.obs;
  final RxString referralCode = ''.obs;
  final RxString selectedPaymentMethod = 'Tunai'.obs;
  final RxDouble cashAmount = 0.0.obs;
  final RxDouble changeAmount = 0.0.obs;

  // Form controllers
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController tableController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController promoController = TextEditingController();
  final TextEditingController cashAmountController = TextEditingController();
  final TextEditingController changeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Delay initialization to avoid controller conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeListeners();
    });
  }

  @override
  void onClose() {
    _qrisStatusTimer?.cancel();
    _disposeControllers();
    super.onClose();
  }

  void resetControllerState() {
    // Cancel any ongoing operations
    _qrisStatusTimer?.cancel();

    // Reset loading states
    isLoading.value = false;
    isProcessingPayment.value = false;
    isQrisPaymentActive.value = false;
    isPrinting.value = false; // NEW

    // Clear error
    error.value = '';
    printStatus.value = ''; // NEW
  }

  void _initializeListeners() {
    try {
      // Listen to text controller changes
      customerNameController.addListener(() {
        customerName.value = customerNameController.text;
      });

      phoneController.addListener(() {
        customerPhone.value = phoneController.text;
      });

      tableController.addListener(() {
        tableNumber.value = int.tryParse(tableController.text) ?? 0;
      });

      notesController.addListener(() {
        notes.value = notesController.text;
      });

      promoController.addListener(() {
        promoCode.value = promoController.text;
      });

      cashAmountController.addListener(() {
        String cleanText = cashAmountController.text
            .replaceAll(',', '')
            .replaceAll('.', '')
            .replaceAll('Rp', '')
            .replaceAll(' ', '');
        cashAmount.value = double.tryParse(cleanText) ?? 0.0;
        calculateChange();
      });
    } catch (e) {
      print('Error setting up listeners: $e');
    }
  }

  void _disposeControllers() {
    try {
      customerNameController.dispose();
      phoneController.dispose();
      tableController.dispose();
      notesController.dispose();
      promoController.dispose();
      cashAmountController.dispose();
      changeController.dispose();
    } catch (e) {
      print('Error disposing controllers: $e');
    }
  }

  // Calculate order total
  double get orderTotal {
    try {
      return orderItems.fold(
          0.0, (sum, item) => sum + (item['totalPrice']?.toDouble() ?? 0.0));
    } catch (e) {
      print('Error calculating order total: $e');
      return 0.0;
    }
  }

  // Calculate change
  void calculateChange() {
    try {
      if (selectedPaymentMethod.value == 'Tunai' && cashAmount.value > 0) {
        double change = cashAmount.value - orderTotal;
        changeAmount.value = change >= 0 ? change : 0.0;
        changeController.text = 'Rp${formatPrice(changeAmount.value.round())}';
      } else {
        changeAmount.value = 0.0;
        changeController.text = 'Rp0';
      }
      update(); // Trigger UI update
    } catch (e) {
      print('Error calculating change: $e');
    }
  }

  // Format price helper
  String formatPrice(int price) {
    try {
      return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    } catch (e) {
      print('Error formatting price: $e');
      return price.toString();
    }
  }

  // Add product to order
  void addProductToOrder(Product product) {
    try {
      int existingIndex =
          orderItems.indexWhere((item) => item['productId'] == product.id);

      if (existingIndex >= 0) {
        orderItems[existingIndex]['quantity']++;
        orderItems[existingIndex]['totalPrice'] = orderItems[existingIndex]
                ['quantity'] *
            product.basePrice.toDouble();
      } else {
        orderItems.add({
          'id': product.id,
          'productId': product.id,
          'name': product.name,
          'productName': product.name,
          'quantity': 1,
          'price': product.basePrice.toDouble(),
          'totalPrice': product.basePrice.toDouble(),
          'note': '',
        });
      }

      orderItems.refresh();
      calculateChange();
      update(); // Trigger UI update
    } catch (e) {
      error.value = 'Failed to add product: $e';
      _showErrorSnackbar(error.value);
    }
  }

  // Increase quantity
  void increaseQuantity(int index) {
    try {
      if (index >= 0 && index < orderItems.length) {
        orderItems[index]['quantity']++;
        double unitPrice = orderItems[index]['price']?.toDouble() ?? 0.0;
        orderItems[index]['totalPrice'] =
            orderItems[index]['quantity'] * unitPrice;
        orderItems.refresh();
        calculateChange();
        update(); // Trigger UI update
      }
    } catch (e) {
      print('Error increasing quantity: $e');
    }
  }

  // Decrease quantity
  void decreaseQuantity(int index) {
    try {
      if (index >= 0 && index < orderItems.length) {
        if (orderItems[index]['quantity'] > 1) {
          orderItems[index]['quantity']--;
          double unitPrice = orderItems[index]['price']?.toDouble() ?? 0.0;
          orderItems[index]['totalPrice'] =
              orderItems[index]['quantity'] * unitPrice;
        } else {
          orderItems.removeAt(index);
        }
        orderItems.refresh();
        calculateChange();
        update(); // Trigger UI update
      }
    } catch (e) {
      print('Error decreasing quantity: $e');
    }
  }

  // Remove item
  void removeItem(int index) {
    try {
      if (index >= 0 && index < orderItems.length) {
        orderItems.removeAt(index);
        orderItems.refresh();
        calculateChange();
        update(); // Trigger UI update
      }
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  // Update payment method
  void updatePaymentMethod(String method) {
    try {
      selectedPaymentMethod.value = method;
      calculateChange();
      update(); // Trigger UI update
    } catch (e) {
      print('Error updating payment method: $e');
    }
  }

  // Validate order data
  bool validateOrder() {
    try {
      error.value = '';

      if (customerName.value.trim().isEmpty) {
        error.value = 'Nama customer tidak boleh kosong';
        return false;
      }

      if (orderItems.isEmpty) {
        error.value = 'Belum ada item pesanan';
        return false;
      }

      if (selectedPaymentMethod.value == 'Tunai' &&
          cashAmount.value < orderTotal) {
        error.value = 'Jumlah pembayaran kurang dari total pesanan';
        return false;
      }

      return true;
    } catch (e) {
      error.value = 'Error validating order: $e';
      return false;
    }
  }

  // Create order and process payment
  Future<void> processOrder() async {
    if (!validateOrder()) {
      _showErrorSnackbar(error.value);
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      update(); // Trigger UI update

      // Prepare order request
      final orderRequest = CreateOrderRequest(
        order: OrderDetails(
          customerName: customerName.value.trim(),
          customerPhone: customerPhone.value.trim(),
          tableNumber: tableNumber.value,
          notes: notes.value.trim(),
          referralCode: referralCode.value.trim(),
          promoCode: promoCode.value.trim(),
        ),
        orderDetails: orderItems
            .map((item) => OrderDetailRequest(
                  productId: item['productId'],
                  quantity: item['quantity'],
                  note: item['note'] ?? '',
                ))
            .toList(),
        payments: [
          PaymentRequest(method: selectedPaymentMethod.value),
        ],
      );

      // Create order
      final order = await _orderService.createOrder(orderRequest);
      currentOrder.value = order;

      // Process payment based on method
      await _processPayment(order.id);
    } catch (e) {
      error.value = e.toString();
      _showErrorSnackbar('Gagal membuat pesanan: ${error.value}');
    } finally {
      isLoading.value = false;
      update(); // Trigger UI update
    }
  }

  // Process payment - IMPROVED VERSION
  Future<void> _processPayment(String orderId) async {
    try {
      isProcessingPayment.value = true;
      update(); // Trigger UI update

      if (selectedPaymentMethod.value == 'QRIS') {
        // Handle QRIS payment
        await _initiateQrisPayment(orderId);
      } else {
        // Handle Cash/Debit payment
        final paymentResponse = await _orderService.processPayment(
          orderId: orderId,
          method: selectedPaymentMethod.value,
        );

        if (paymentResponse.status == 'SUCCESS') {
          _showSuccessMessage('Pembayaran berhasil!');

          // IMPROVED: Wait a moment and check printer status before auto print
          await _attemptAutoPrint();

          resetForm();
        } else {
          throw Exception(
              'Payment failed with status: ${paymentResponse.status}');
        }
      }
    } catch (e) {
      error.value = e.toString();
      _showErrorSnackbar('Pembayaran gagal: ${error.value}');
    } finally {
      isProcessingPayment.value = false;
      update(); // Trigger UI update
    }
  }

  // NEW: Improved auto print method with better error handling
  Future<void> _attemptAutoPrint() async {
    if (currentOrder.value == null) {
      print('NewOrderController: No order available for printing');
      return;
    }

    try {
      isPrinting.value = true;
      printStatus.value = 'Memeriksa koneksi printer...';
      update();

      // Wait a moment to ensure payment processing is complete
      await Future.delayed(Duration(milliseconds: 500));

      // Check printer connection status
      if (!_printService.isConnected) {
        printStatus.value = 'Printer tidak terhubung';
        _showWarningSnackbar(
            'Pembayaran berhasil tetapi printer tidak terhubung. '
            'Silakan print manual dari menu atau hubungkan printer terlebih dahulu.');
        return;
      }

      printStatus.value = 'Mencetak struk...';
      update();

      // Attempt to print with retry mechanism
      bool printed = false;
      int retryCount = 0;
      const maxRetries = 3;

      while (!printed && retryCount < maxRetries) {
        try {
          printed = await _printService.printOrderReceipt(currentOrder.value!);

          if (!printed) {
            retryCount++;
            if (retryCount < maxRetries) {
              print(
                  'NewOrderController: Print attempt $retryCount failed, retrying...');
              await Future.delayed(Duration(milliseconds: 1000));
            }
          }
        } catch (e) {
          print('NewOrderController: Print attempt $retryCount error: $e');
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(milliseconds: 1000));
          }
        }
      }

      if (printed) {
        printStatus.value = 'Struk berhasil dicetak';
        print('NewOrderController: Receipt auto-printed successfully');
        _showSuccessMessage('Struk berhasil dicetak otomatis');
      } else {
        printStatus.value = 'Gagal mencetak struk';
        print(
            'NewOrderController: Auto print failed after $maxRetries attempts');
        _showWarningSnackbar('Pembayaran berhasil tetapi gagal print otomatis. '
            'Periksa koneksi printer dan coba print manual.');
      }
    } catch (e) {
      print('NewOrderController: Auto print error: $e');
      printStatus.value = 'Error saat mencetak: $e';
      _showWarningSnackbar(
          'Pembayaran berhasil tetapi terjadi error saat print: $e');
    } finally {
      isPrinting.value = false;
      // Clear print status after delay
      Future.delayed(Duration(seconds: 3), () {
        printStatus.value = '';
        update();
      });
      update();
    }
  }

  // NEW: Manual print method for retry
  Future<void> manualPrint() async {
    if (currentOrder.value == null) {
      _showErrorSnackbar('Tidak ada order untuk dicetak');
      return;
    }

    await _attemptAutoPrint();
  }

  // Check QRIS payment status - IMPROVED VERSION
  Future<void> checkQrisPaymentStatus(String orderId) async {
    try {
      final statusResponse =
          await _orderService.checkQrisPaymentStatus(orderId);

      if (statusResponse.status == 'SUCCESS') {
        // Payment successful
        _qrisStatusTimer?.cancel();
        isQrisPaymentActive.value = false;
        _showSuccessMessage('Pembayaran QRIS berhasil!');

        // Auto print for QRIS payment
        await _attemptAutoPrint();

        resetForm();
      } else if (statusResponse.status == 'FAILED' ||
          statusResponse.status == 'EXPIRED') {
        // Payment failed
        _qrisStatusTimer?.cancel();
        isQrisPaymentActive.value = false;
        error.value = 'Pembayaran QRIS gagal atau expired';
        _showErrorSnackbar(error.value);
      } else {
        // Still pending, show current status
        print('QRIS Payment Status: ${statusResponse.status}');
      }

      update(); // Trigger UI update
    } catch (e) {
      print('Error checking QRIS status: $e');
      error.value = 'Error checking QRIS status: $e';
    }
  }

  // Initiate QRIS payment
  Future<void> _initiateQrisPayment(String orderId) async {
    try {
      final qrisResponse = await _orderService.initiateQrisPayment(orderId);
      qrisPayment.value = qrisResponse;
      isQrisPaymentActive.value = true;
      update(); // Trigger UI update

      // Start checking payment status
      _startQrisStatusCheck(orderId);
    } catch (e) {
      throw Exception('Failed to initiate QRIS payment: $e');
    }
  }

  // Start QRIS status checking
  void _startQrisStatusCheck(String orderId) {
    _qrisStatusTimer?.cancel();

    // Check immediately first
    checkQrisPaymentStatus(orderId);

    _qrisStatusTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final statusResponse =
            await _orderService.checkQrisPaymentStatus(orderId);

        if (statusResponse.status == 'SUCCESS') {
          // Payment successful
          timer.cancel();
          isQrisPaymentActive.value = false;
          _showSuccessMessage('Pembayaran QRIS berhasil!');

          // Auto print for QRIS payment
          await _attemptAutoPrint();

          resetForm();
        } else if (statusResponse.status == 'FAILED' ||
            statusResponse.status == 'EXPIRED') {
          // Payment failed
          timer.cancel();
          isQrisPaymentActive.value = false;
          error.value = 'Pembayaran QRIS gagal atau expired';
          _showErrorSnackbar(error.value);
        }
        // If still pending, continue checking
        update(); // Trigger UI update
      } catch (e) {
        print('Error checking QRIS status: $e');
      }
    });

    // Stop checking after expiry time
    if (qrisPayment.value != null) {
      Timer(
          Duration(
              milliseconds: qrisPayment.value!.expiresAt
                  .difference(DateTime.now())
                  .inMilliseconds), () {
        _qrisStatusTimer?.cancel();
        if (isQrisPaymentActive.value) {
          isQrisPaymentActive.value = false;
          error.value = 'QRIS payment expired';
          _showErrorSnackbar('QRIS payment expired');
          update(); // Trigger UI update
        }
      });
    }
  }

  // Cancel QRIS payment
  void cancelQrisPayment() {
    try {
      _qrisStatusTimer?.cancel();
      isQrisPaymentActive.value = false;
      qrisPayment.value = null;
      update(); // Trigger UI update
    } catch (e) {
      print('Error canceling QRIS payment: $e');
    }
  }

  // Reset form
  void resetForm() {
    try {
      orderItems.clear();
      customerName.value = '';
      customerPhone.value = '';
      tableNumber.value = 0;
      notes.value = '';
      promoCode.value = '';
      referralCode.value = '';
      selectedPaymentMethod.value = 'Tunai';
      cashAmount.value = 0.0;
      changeAmount.value = 0.0;
      currentOrder.value = null;
      qrisPayment.value = null;
      isQrisPaymentActive.value = false;
      error.value = '';
      isPrinting.value = false; // NEW
      printStatus.value = ''; // NEW

      // Clear controllers
      customerNameController.clear();
      phoneController.clear();
      tableController.clear();
      notesController.clear();
      promoController.clear();
      cashAmountController.clear();
      changeController.clear();

      _qrisStatusTimer?.cancel();
      update(); // Trigger UI update
    } catch (e) {
      print('Error resetting form: $e');
    }
  }

  // Show success message
  void _showSuccessMessage(String message) {
    try {
      Get.snackbar(
        'Berhasil',
        message,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error showing success message: $e');
    }
  }

  // Show error message
  void _showErrorSnackbar(String message) {
    try {
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      print('Error showing error message: $e');
    }
  }

  // NEW: Show warning message
  void _showWarningSnackbar(String message) {
    try {
      Get.snackbar(
        'Peringatan',
        message,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      print('Error showing warning message: $e');
    }
  }
}
