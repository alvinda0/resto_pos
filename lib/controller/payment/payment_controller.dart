// controller/payment/payment_controller.dart
import 'package:get/get.dart';
import 'package:pos/models/order/order_model.dart';
import 'package:pos/models/payment/payment_model.dart';
import 'package:pos/services/payment/payment_service.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();

  // Observable states
  var isProcessingPayment = false.obs;
  var paymentResult = Rx<PaymentProcessResult?>(null);
  var orderUpdateProgress = ''.obs;

  // Process order payment (edit order first, then payment)
  Future<bool> processOrderPayment({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required int tableNumber,
    String? notes,
    required List<dynamic> orderItems,
    required String paymentMethod,
    String? promoCode,
  }) async {
    try {
      isProcessingPayment.value = true;
      orderUpdateProgress.value = 'Memulai proses pembayaran...';

      // Validate input
      if (customerName.trim().isEmpty) {
        throw Exception('Nama customer tidak boleh kosong');
      }

      if (tableNumber <= 0) {
        throw Exception('Nomor meja tidak valid');
      }

      if (orderItems.isEmpty) {
        throw Exception('Pesanan tidak boleh kosong');
      }

      orderUpdateProgress.value = 'Memperbarui pesanan...';

      // Call the service to process order payment
      final result = await _paymentService.processOrderPayment(
        orderId: orderId,
        customerName: customerName.trim(),
        customerPhone: customerPhone.trim(),
        tableNumber: tableNumber,
        notes: notes?.trim(),
        orderItems: orderItems,
        paymentMethod: paymentMethod,
        promoCode: promoCode?.trim(),
      );

      paymentResult.value = result;
      orderUpdateProgress.value = 'Proses selesai';

      if (result.isSuccess) {
        // Calculate total for display
        double total = 0.0;
        for (var item in orderItems) {
          if (item is Map) {
            total += (item['totalPrice'] ?? 0).toDouble();
          } else {
            total += (item.totalPrice ?? 0).toDouble();
          }
        }

        Get.snackbar(
          'Pembayaran Berhasil! 🎉',
          'Customer: ${customerName.trim()}\n'
              'Total: Rp${_formatPrice(total.round())}\n'
              'Metode: $paymentMethod',
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
          colorText: Get.theme.colorScheme.primary,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        Get.snackbar(
          'Pembayaran Gagal ❌',
          result.errorMessage,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
          colorText: Get.theme.colorScheme.error,
          duration: const Duration(seconds: 6),
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      orderUpdateProgress.value = 'Error: $e';

      String errorMessage = 'Terjadi kesalahan';
      if (e.toString().contains('customer_name')) {
        errorMessage = 'Nama customer tidak boleh kosong';
      } else if (e.toString().contains('table_number')) {
        errorMessage = 'Nomor meja tidak valid';
      } else if (e.toString().contains('order_details')) {
        errorMessage = 'Data pesanan tidak valid';
      } else if (e.toString().contains('payment')) {
        errorMessage = 'Gagal memproses pembayaran';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Koneksi internet bermasalah';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      Get.snackbar(
        'Error ⚠️',
        errorMessage,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 6),
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isProcessingPayment.value = false;
      // Clear progress after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
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
    required String paymentMethod,
  }) async {
    try {
      isProcessingPayment.value = true;
      orderUpdateProgress.value = 'Memproses pembayaran...';

      final payment = await _paymentService.processPayment(
        orderId: orderId,
        paymentMethod: paymentMethod,
      );

      orderUpdateProgress.value = 'Pembayaran berhasil';

      Get.snackbar(
        'Pembayaran Berhasil! 🎉',
        'Metode: $paymentMethod\n'
            'Status: ${payment.status}\n'
            'Ref: ${payment.transactionRef}',
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
        duration: const Duration(seconds: 4),
      );

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
      orderUpdateProgress.value = 'Mengambil riwayat pembayaran...';

      final payments = await _paymentService.getOrderPayments(orderId);

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
      Future.delayed(const Duration(seconds: 2), () {
        orderUpdateProgress.value = '';
      });
    }
  }

  // Utility method to format price
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  // Clear payment result
  void clearPaymentResult() {
    paymentResult.value = null;
    orderUpdateProgress.value = '';
  }

  // Reset controller state
  void reset() {
    isProcessingPayment.value = false;
    paymentResult.value = null;
    orderUpdateProgress.value = '';
  }

  // Get latest processed order
  OrderModel? get latestOrder => paymentResult.value?.order;

  // Get latest payment
  PaymentModel? get latestPayment => paymentResult.value?.payment;

  // Check if payment was successful
  bool get isPaymentSuccessful => paymentResult.value?.isSuccess ?? false;

  // Get payment error message
  String get paymentErrorMessage => paymentResult.value?.errorMessage ?? '';
}
