// controller/order/new_order_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/order/new_order_model.dart';
import 'package:pos/models/product/product_model.dart';
import 'package:pos/services/order/new_order_service.dart';

class NewOrderController extends GetxController {
  final OrderService _orderService = OrderService.instance;

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isProcessingPayment = false.obs;
  final RxString error = ''.obs;
  final Rx<Order?> currentOrder = Rx<Order?>(null);
  final Rx<QrisPaymentResponse?> qrisPayment = Rx<QrisPaymentResponse?>(null);
  final RxBool isQrisPaymentActive = false.obs;

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
    _initializeListeners();
  }

  @override
  void onClose() {
    _qrisStatusTimer?.cancel();
    _disposeControllers();
    super.onClose();
  }

  void _initializeListeners() {
    // Listen to text controller changes
    customerNameController
        .addListener(() => customerName.value = customerNameController.text);
    phoneController
        .addListener(() => customerPhone.value = phoneController.text);
    tableController.addListener(
        () => tableNumber.value = int.tryParse(tableController.text) ?? 0);
    notesController.addListener(() => notes.value = notesController.text);
    promoController.addListener(() => promoCode.value = promoController.text);
    cashAmountController.addListener(() {
      cashAmount.value = double.tryParse(cashAmountController.text
              .replaceAll(',', '')
              .replaceAll('Rp', '')) ??
          0.0;
      calculateChange();
    });
  }

  void _disposeControllers() {
    customerNameController.dispose();
    phoneController.dispose();
    tableController.dispose();
    notesController.dispose();
    promoController.dispose();
    cashAmountController.dispose();
    changeController.dispose();
  }

  // Calculate order total
  double get orderTotal {
    return orderItems.fold(
        0.0, (sum, item) => sum + (item['totalPrice']?.toDouble() ?? 0.0));
  }

  // Calculate change
  void calculateChange() {
    if (selectedPaymentMethod.value == 'Tunai' && cashAmount.value > 0) {
      double change = cashAmount.value - orderTotal;
      changeAmount.value = change >= 0 ? change : 0.0;
      changeController.text = 'Rp${formatPrice(changeAmount.value.round())}';
    } else {
      changeAmount.value = 0.0;
      changeController.text = 'Rp0';
    }
  }

  // Format price helper
  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
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
    } catch (e) {
      error.value = 'Failed to add product: $e';
      _showErrorSnackbar(error.value);
    }
  }

  // Increase quantity
  void increaseQuantity(int index) {
    if (index >= 0 && index < orderItems.length) {
      orderItems[index]['quantity']++;
      double unitPrice = orderItems[index]['price']?.toDouble() ?? 0.0;
      orderItems[index]['totalPrice'] =
          orderItems[index]['quantity'] * unitPrice;
      orderItems.refresh();
      calculateChange();
    }
  }

  // Decrease quantity
  void decreaseQuantity(int index) {
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
    }
  }

  // Remove item
  void removeItem(int index) {
    if (index >= 0 && index < orderItems.length) {
      orderItems.removeAt(index);
      orderItems.refresh();
      calculateChange();
    }
  }

  // Update payment method
  void updatePaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    calculateChange();
  }

  // Validate order data
  bool validateOrder() {
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
    }
  }

  // Process payment
  Future<void> _processPayment(String orderId) async {
    try {
      isProcessingPayment.value = true;

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
    }
  }

  // Initiate QRIS payment
  Future<void> _initiateQrisPayment(String orderId) async {
    try {
      final qrisResponse = await _orderService.initiateQrisPayment(orderId);
      qrisPayment.value = qrisResponse;
      isQrisPaymentActive.value = true;

      // Start checking payment status
      _startQrisStatusCheck(orderId);
    } catch (e) {
      throw Exception('Failed to initiate QRIS payment: $e');
    }
  }

  // Start QRIS status checking
  void _startQrisStatusCheck(String orderId) {
    _qrisStatusTimer?.cancel();

    _qrisStatusTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final statusResponse =
            await _orderService.checkQrisPaymentStatus(orderId);

        if (statusResponse.status == 'PAID') {
          // Payment successful
          timer.cancel();
          isQrisPaymentActive.value = false;
          _showSuccessMessage('Pembayaran QRIS berhasil!');
          resetForm();
        } else if (statusResponse.status == 'FAILED' ||
            statusResponse.status == 'EXPIRED') {
          // Payment failed
          timer.cancel();
          isQrisPaymentActive.value = false;
          error.value = 'Pembayaran QRIS gagal atau expired';
          _showErrorSnackbar(error.value);
        }
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
        }
      });
    }
  }

  // Cancel QRIS payment
  void cancelQrisPayment() {
    _qrisStatusTimer?.cancel();
    isQrisPaymentActive.value = false;
    qrisPayment.value = null;
  }

  // Reset form
  void resetForm() {
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

    // Clear controllers
    customerNameController.clear();
    phoneController.clear();
    tableController.clear();
    notesController.clear();
    promoController.clear();
    cashAmountController.clear();
    changeController.clear();

    _qrisStatusTimer?.cancel();
  }

  // Show success message
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // Show error message
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
