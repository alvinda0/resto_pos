// controller/order/new_order_controller.dart - FIXED VERSION untuk QR Code flickering
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shao_kao/controller/tax/tax_controller.dart';
import 'package:shao_kao/models/order/new_order_model.dart';
import 'package:shao_kao/models/product/product_model.dart';
import 'package:shao_kao/services/order/PrintServiceOrder.dart';
import 'package:shao_kao/services/order/new_order_service.dart';

class NewOrderController extends GetxController {
  final OrderService _orderService = OrderService.instance;
  final PrintService _printService = PrintService();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isProcessingPayment = false.obs;
  final RxString error = ''.obs;
  final Rx<Order?> currentOrder = Rx<Order?>(null);
  final Rx<QrisPaymentResponse?> qrisPayment = Rx<QrisPaymentResponse?>(null);
  final RxBool isQrisPaymentActive = false.obs;

  // FIXED: Separate observable for QRIS status to prevent QR code flickering
  final RxString qrisPaymentStatus = 'PENDING'.obs;
  final Rx<DateTime> qrisLastUpdated = DateTime.now().obs;

  final RxBool isPrinting = false.obs;
  final RxString printStatus = ''.obs;

  // Timer for QRIS status checking
  Timer? _qrisStatusTimer;

  // Order form data
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
    _qrisStatusTimer?.cancel();
    isLoading.value = false;
    isProcessingPayment.value = false;
    isQrisPaymentActive.value = false;
    isPrinting.value = false;
    error.value = '';
    printStatus.value = '';
    qrisPaymentStatus.value = 'PENDING';
  }

  void _initializeListeners() {
    try {
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

  double get orderTotalWithTax {
    try {
      double subtotal = orderItems.fold(
          0.0, (sum, item) => sum + (item['totalPrice']?.toDouble() ?? 0.0));

      double totalTaxAmount = 0.0;
      try {
        final taxController = Get.find<TaxController>();
        totalTaxAmount = taxController.activeTaxes
            .fold(0.0, (sum, tax) => sum + (subtotal * (tax.percentage / 100)));
      } catch (e) {
        totalTaxAmount = 0.0;
      }

      return subtotal + totalTaxAmount;
    } catch (e) {
      print('Error calculating order total with tax: $e');
      return orderTotal;
    }
  }

  void calculateChange() {
    try {
      if (selectedPaymentMethod.value == 'Tunai' && cashAmount.value > 0) {
        double change = cashAmount.value - orderTotalWithTax;
        changeAmount.value = change >= 0 ? change : 0.0;
        changeController.text = 'Rp${formatPrice(changeAmount.value.round())}';
      } else {
        changeAmount.value = 0.0;
        changeController.text = 'Rp0';
      }
      update();
    } catch (e) {
      print('Error calculating change: $e');
    }
  }

  String formatPrice(int price) {
    try {
      return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    } catch (e) {
      print('Error formatting price: $e');
      return price.toString();
    }
  }

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
      update();
    } catch (e) {
      error.value = 'Failed to add product: $e';
      _showErrorSnackbar(error.value);
    }
  }

  void increaseQuantity(int index) {
    try {
      if (index >= 0 && index < orderItems.length) {
        orderItems[index]['quantity']++;
        double unitPrice = orderItems[index]['price']?.toDouble() ?? 0.0;
        orderItems[index]['totalPrice'] =
            orderItems[index]['quantity'] * unitPrice;
        orderItems.refresh();
        calculateChange();
        update();
      }
    } catch (e) {
      print('Error increasing quantity: $e');
    }
  }

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
        update();
      }
    } catch (e) {
      print('Error decreasing quantity: $e');
    }
  }

  void removeItem(int index) {
    try {
      if (index >= 0 && index < orderItems.length) {
        orderItems.removeAt(index);
        orderItems.refresh();
        calculateChange();
        update();
      }
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  void updatePaymentMethod(String method) {
    try {
      selectedPaymentMethod.value = method;
      calculateChange();
      update();
    } catch (e) {
      print('Error updating payment method: $e');
    }
  }

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
          cashAmount.value < orderTotalWithTax) {
        error.value = 'Jumlah pembayaran kurang dari total pesanan';
        return false;
      }

      return true;
    } catch (e) {
      error.value = 'Error validating order: $e';
      return false;
    }
  }

  Future<void> processOrder() async {
    if (!validateOrder()) {
      _showErrorSnackbar(error.value);
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      update();

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

      final order = await _orderService.createOrder(orderRequest);
      currentOrder.value = order;

      await _processPayment(order.id);
    } catch (e) {
      error.value = e.toString();
      _showErrorSnackbar('Gagal membuat pesanan: ${error.value}');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> _processPayment(String orderId) async {
    try {
      isProcessingPayment.value = true;
      update();

      if (selectedPaymentMethod.value == 'QRIS') {
        await _initiateQrisPayment(orderId);
      } else {
        final paymentResponse = await _orderService.processPayment(
          orderId: orderId,
          method: selectedPaymentMethod.value,
        );

        if (paymentResponse.status == 'SUCCESS') {
          _showSuccessMessage('Pembayaran berhasil!');
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
      update();
    }
  }

  Future<void> _attemptAutoPrint() async {
    if (currentOrder.value == null) {
      print('NewOrderController: No order available for printing');
      return;
    }

    try {
      isPrinting.value = true;
      printStatus.value = 'Memeriksa koneksi printer...';
      update();

      await Future.delayed(Duration(milliseconds: 500));

      if (!_printService.isConnected) {
        printStatus.value = 'Printer tidak terhubung';
        _showWarningSnackbar(
            'Pembayaran berhasil tetapi printer tidak terhubung. '
            'Silakan print manual dari menu atau hubungkan printer terlebih dahulu.');
        return;
      }

      printStatus.value = 'Mencetak struk...';
      update();

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
      Future.delayed(Duration(seconds: 3), () {
        printStatus.value = '';
        update();
      });
      update();
    }
  }

  Future<void> manualPrint() async {
    if (currentOrder.value == null) {
      _showErrorSnackbar('Tidak ada order untuk dicetak');
      return;
    }
    await _attemptAutoPrint();
  }

  // FIXED: Improved QRIS status checking without causing UI flicker
  Future<void> checkQrisPaymentStatus(String orderId) async {
    try {
      final statusResponse =
          await _orderService.checkQrisPaymentStatus(orderId);

      // Update status tanpa memanggil update() global
      qrisPaymentStatus.value = statusResponse.status;
      qrisLastUpdated.value = DateTime.now();

      if (statusResponse.status == 'SUCCESS') {
        _qrisStatusTimer?.cancel();
        isQrisPaymentActive.value = false;
        _showSuccessMessage('Pembayaran QRIS berhasil!');

        await _attemptAutoPrint();
        resetForm();
      } else if (statusResponse.status == 'FAILED' ||
          statusResponse.status == 'EXPIRED') {
        _qrisStatusTimer?.cancel();
        isQrisPaymentActive.value = false;
        error.value = 'Pembayaran QRIS gagal atau expired';
        _showErrorSnackbar(error.value);
      }

      // Hanya update UI jika ada perubahan status penting
      if (statusResponse.status == 'SUCCESS' ||
          statusResponse.status == 'FAILED' ||
          statusResponse.status == 'EXPIRED') {
        update();
      }
    } catch (e) {
      print('Error checking QRIS status: $e');
      error.value = 'Error checking QRIS status: $e';
    }
  }

  Future<void> _initiateQrisPayment(String orderId) async {
    try {
      final qrisResponse = await _orderService.initiateQrisPayment(orderId);
      qrisPayment.value = qrisResponse;
      isQrisPaymentActive.value = true;
      qrisPaymentStatus.value = 'PENDING';
      update(); // Update UI setelah QR code dimuat

      _startQrisStatusCheck(orderId);
    } catch (e) {
      throw Exception('Failed to initiate QRIS payment: $e');
    }
  }

  // FIXED: Improved status checking to prevent UI flickering
  void _startQrisStatusCheck(String orderId) {
    _qrisStatusTimer?.cancel();

    // Check immediately first
    checkQrisPaymentStatus(orderId);

    _qrisStatusTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final statusResponse =
            await _orderService.checkQrisPaymentStatus(orderId);

        // Update status observable tanpa global update
        qrisPaymentStatus.value = statusResponse.status;
        qrisLastUpdated.value = DateTime.now();

        if (statusResponse.status == 'SUCCESS') {
          timer.cancel();
          isQrisPaymentActive.value = false;
          _showSuccessMessage('Pembayaran QRIS berhasil!');
          await _attemptAutoPrint();
          resetForm();
        } else if (statusResponse.status == 'FAILED' ||
            statusResponse.status == 'EXPIRED') {
          timer.cancel();
          isQrisPaymentActive.value = false;
          error.value = 'Pembayaran QRIS gagal atau expired';
          _showErrorSnackbar(error.value);
        }

        // PENTING: Jangan panggil update() di sini untuk mencegah flickering QR code
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
          update();
        }
      });
    }
  }

  void cancelQrisPayment() {
    try {
      _qrisStatusTimer?.cancel();
      isQrisPaymentActive.value = false;
      qrisPayment.value = null;
      qrisPaymentStatus.value = 'PENDING';
      update();
    } catch (e) {
      print('Error canceling QRIS payment: $e');
    }
  }

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
      qrisPaymentStatus.value = 'PENDING';
      error.value = '';
      isPrinting.value = false;
      printStatus.value = '';

      customerNameController.clear();
      phoneController.clear();
      tableController.clear();
      notesController.clear();
      promoController.clear();
      cashAmountController.clear();
      changeController.clear();

      _qrisStatusTimer?.cancel();
      update();
    } catch (e) {
      print('Error resetting form: $e');
    }
  }

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
