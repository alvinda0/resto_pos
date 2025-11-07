// controller/order/new_order_controller.dart - FIXED VERSION untuk QR Code flickering
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shao_kao/controller/promotion/promotion_controller.dart';
import 'package:shao_kao/controller/tax/tax_controller.dart';
import 'package:shao_kao/models/order/new_order_model.dart';
import 'package:shao_kao/models/product/product_model.dart';
import 'package:shao_kao/models/promotion/promotion_model.dart';
import 'package:shao_kao/services/order/PrintServiceOrder.dart';
import 'package:shao_kao/services/order/new_order_service.dart';
import 'package:shao_kao/screens/order/new_order_screen.dart';

class NewOrderController extends GetxController {
  final OrderService _orderService = OrderService.instance;
  final PrintService _printService = PrintService();

  // Add new observables for promo
  final Rx<Promotion?> appliedPromo = Rx<Promotion?>(null);
  final RxDouble promoDiscount = 0.0.obs;
  final RxBool isCheckingPromo = false.obs;

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
  final RxString orderMethod = 'DINE_IN'.obs; // DINE_IN or TAKE_AWAY
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

  void updateReferralCode(String code) {
    referralCode.value = code;
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
      // 1. Hitung base amount (subtotal dari semua item)
      double baseAmount = orderItems.fold(
          0.0, (sum, item) => sum + (item['totalPrice']?.toDouble() ?? 0.0));

      // 2. Kurangi discount dari base amount untuk mendapatkan subtotal
      double subtotal = baseAmount - promoDiscount.value;

      // Pastikan subtotal tidak negatif
      if (subtotal < 0) subtotal = 0.0;

      // 3. Hitung tax berdasarkan subtotal (setelah discount)
      double totalTaxAmount = 0.0;
      try {
        TaxController? taxController;
        try {
          taxController = Get.find<TaxController>();
        } catch (e) {
          taxController = Get.put(TaxController(), permanent: true);
          Future.delayed(Duration(milliseconds: 100), () {
            taxController!.loadActiveTaxes();
          });
        }

        if (taxController != null && taxController.activeTaxes.isNotEmpty) {
          totalTaxAmount = taxController.activeTaxes.fold(
              0.0, (sum, tax) => sum + (subtotal * (tax.percentage / 100)));
          print(
              'Base: $baseAmount, Discount: ${promoDiscount.value}, Subtotal: $subtotal, Tax: $totalTaxAmount');
        }
      } catch (e) {
        print('Error getting tax controller: $e');
        totalTaxAmount = 0.0;
      }

      // 4. Total akhir = subtotal + tax
      double finalTotal = subtotal + totalTaxAmount;
      return finalTotal >= 0 ? finalTotal : 0.0;
    } catch (e) {
      print('Error calculating order total with tax: $e');
      return orderTotal;
    }
  }

  void refreshTaxCalculation() {
    try {
      final taxController = Get.find<TaxController>();
      taxController.loadActiveTaxes().then((_) {
        calculateChange();
        update();
      });
    } catch (e) {
      print('Error refreshing tax calculation: $e');
    }
  }

  Future<void> checkAndApplyPromo(String promoCode) async {
    if (promoCode.trim().isEmpty) {
      _showErrorSnackbar('Masukkan kode promo terlebih dahulu');
      return;
    }

    if (orderItems.isEmpty) {
      _showErrorSnackbar(
          'Tambahkan produk terlebih dahulu sebelum menggunakan promo');
      return;
    }

    try {
      isCheckingPromo.value = true;

      // Get promotion controller
      final promotionController = Get.find<PromotionController>();
      final promotion = await promotionController
          .getPromotionByCode(promoCode.trim().toUpperCase());

      if (promotion == null) {
        _showErrorSnackbar(
            'Kode promo "$promoCode" tidak ditemukan atau sudah kadaluarsa');
        return;
      }

      // Validate if promotion is currently active
      if (!promotion.isCurrentlyActive) {
        String reason = '';
        if (promotion.status.toLowerCase() != 'active') {
          reason = 'promo tidak aktif';
        } else {
          reason = 'promo tidak berlaku pada waktu ini';
        }
        _showErrorSnackbar('Kode promo "$promoCode" $reason');
        return;
      }

      // Apply the promotion
      appliedPromo.value = promotion;
      calculatePromoDiscount();

      _showSuccessMessage(
          'Kode promo "${promotion.promoCode}" berhasil diterapkan! Diskon ${promotion.formattedDiscount}');
    } catch (e) {
      print('Error checking promo: $e');
      _showErrorSnackbar('Gagal memvalidasi kode promo: ${e.toString()}');
    } finally {
      isCheckingPromo.value = false;
    }
  }

  void calculatePromoDiscount() {
    if (appliedPromo.value == null) {
      promoDiscount.value = 0.0;
      return;
    }

    final promotion = appliedPromo.value!;
    // Hitung discount berdasarkan base amount (sebelum tax)
    double baseAmount = orderItems.fold(
        0.0, (sum, item) => sum + (item['totalPrice']?.toDouble() ?? 0.0));

    double discount = 0.0;

    if (promotion.discountType == 'percent') {
      // Percentage discount berdasarkan base amount
      discount = baseAmount * (promotion.discountValue / 100);

      // Apply max discount limit if specified
      if (promotion.maxDiscount > 0 && discount > promotion.maxDiscount) {
        discount = promotion.maxDiscount;
      }
    } else if (promotion.discountType == 'fixed') {
      // Fixed amount discount
      discount = promotion.discountValue;

      // Ensure discount doesn't exceed base amount
      if (discount > baseAmount) {
        discount = baseAmount;
      }
    }

    promoDiscount.value = discount;
    calculateChange(); // Recalculate change if cash payment
    update();
  }

  void removeAppliedPromo() {
    appliedPromo.value = null;
    promoDiscount.value = 0.0;
    promoController.clear();
    calculateChange();
    _showSuccessMessage('Promo telah dihapus');
    update();
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

  void addProductToOrder(Product product, {String? note}) {
    try {
      int existingIndex = orderItems.indexWhere((item) =>
          item['productId'] == product.id && item['note'] == (note ?? ''));

      if (existingIndex >= 0) {
        // If same product with same note exists, increase quantity
        orderItems[existingIndex]['quantity']++;
        orderItems[existingIndex]['totalPrice'] = orderItems[existingIndex]
                ['quantity'] *
            product.basePrice.toDouble();
      } else {
        // Add new item (even if same product but different note)
        orderItems.add({
          'id': product.id,
          'productId': product.id,
          'name': product.name,
          'productName': product.name,
          'quantity': 1,
          'price': product.basePrice.toDouble(),
          'totalPrice': product.basePrice.toDouble(),
          'note': note ?? '',
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

  void showAddProductDialog(Product product) {
    try {
      print(
          'NewOrderController: Opening add product dialog for: ${product.name}');

      Get.dialog(
        AlertDialog(
          title: const Text('Tambah Produk'),
          content: SingleChildScrollView(
            child: AddProductDialogContent(
              product: product,
              onAdd: (String? note) {
                try {
                  print(
                      'NewOrderController: Adding product with note: "$note"');

                  // Close dialog first
                  Get.back();

                  // Add product to order
                  addProductToOrder(product, note: note);

                  // Show success message
                  _showSuccessMessage('${product.name} berhasil ditambahkan');

                  print('NewOrderController: Product added successfully');
                } catch (e) {
                  print('NewOrderController: Error adding product: $e');
                  _showErrorSnackbar('Gagal menambahkan produk: $e');
                }
              },
              onCancel: () {
                print('NewOrderController: Add product dialog cancelled');
                Get.back();
              },
            ),
          ),
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      print('NewOrderController: Error showing add product dialog: $e');
      _showErrorSnackbar('Gagal membuka dialog produk: $e');
    }
  }

  // Simple method to add product without dialog (for quick add)
  void addProductQuick(Product product) {
    try {
      addProductToOrder(product);
      _showSuccessMessage('${product.name} berhasil ditambahkan');
    } catch (e) {
      _showErrorSnackbar('Gagal menambahkan produk: $e');
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

      if (customerPhone.value.trim().isEmpty) {
        error.value = 'Nomor telepon customer tidak boleh kosong';
        return false;
      }

      if (tableNumber.value <= 0) {
        error.value = 'Nomor meja harus lebih dari 0';
        return false;
      }

      if (orderItems.isEmpty) {
        error.value = 'Belum ada item pesanan';
        return false;
      }

      // Validate each order item
      for (int i = 0; i < orderItems.length; i++) {
        final item = orderItems[i];
        if (item['productId'] == null || item['productId'].toString().isEmpty) {
          error.value = 'Item ${i + 1}: Product ID tidak valid';
          return false;
        }
        if (item['quantity'] == null || item['quantity'] <= 0) {
          error.value = 'Item ${i + 1}: Quantity harus lebih dari 0';
          return false;
        }
      }

      if (selectedPaymentMethod.value.trim().isEmpty) {
        error.value = 'Metode pembayaran harus dipilih';
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

      print('NewOrderController: Starting order creation process');
      print('NewOrderController: Customer Name: ${customerName.value.trim()}');
      print(
          'NewOrderController: Customer Phone: ${customerPhone.value.trim()}');
      print('NewOrderController: Table Number: ${tableNumber.value}');
      print('NewOrderController: Order Items Count: ${orderItems.length}');
      print(
          'NewOrderController: Payment Method: ${selectedPaymentMethod.value}');

      final orderRequest = CreateOrderRequest(
        order: OrderDetails(
          customerName: customerName.value.trim(),
          customerPhone: customerPhone.value.trim(),
          tableNumber: tableNumber.value,
          notes: notes.value.trim(),
          referralCode: referralCode.value.trim(),
          promoCode: promoCode.value.trim(),
          orderMethod: orderMethod.value,
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

      print('NewOrderController: Order request created, calling service...');
      final order = await _orderService.createOrder(orderRequest);
      print(
          'NewOrderController: Order created successfully with ID: ${order.id}');

      currentOrder.value = order;

      await _processPayment(order.id);
    } catch (e) {
      print('NewOrderController: Error in processOrder: $e');
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
      orderMethod.value = 'DINE_IN';
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

      // Reset promo
      appliedPromo.value = null;
      promoDiscount.value = 0.0;
      isCheckingPromo.value = false;

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
