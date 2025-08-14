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
    PaymentProcessResult? result;

    try {
      isProcessingPayment.value = true;
      orderUpdateProgress.value = 'Memulai proses pembayaran...';

      // Clear previous result
      paymentResult.value = null;

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

      print('Processing payment for order: $orderId'); // Debug log

      // Call the service to process order payment
      result = await _paymentService.processOrderPayment(
        orderId: orderId,
        customerName: customerName.trim(),
        customerPhone: customerPhone.trim(),
        tableNumber: tableNumber,
        notes: notes?.trim(),
        orderItems: orderItems,
        paymentMethod: paymentMethod,
        promoCode: promoCode?.trim(),
      );

      // PERBAIKAN: Set result dan check success SEBELUM try lainnya
      paymentResult.value = result;
      orderUpdateProgress.value = 'Proses selesai';

      print('Payment result success: ${result.isSuccess}'); // Debug log
      print('Payment result error: ${result.error}'); // Debug log

      // PERBAIKAN: Handle success case dengan lebih robust
      if (result.isSuccess) {
        // Calculate total for display - wrapped in try-catch
        double total = 0.0;
        try {
          for (var item in orderItems) {
            if (item is Map) {
              total += (item['totalPrice'] ?? 0).toDouble();
            } else {
              total += (item.totalPrice ?? 0).toDouble();
            }
          }
        } catch (e) {
          print('Error calculating total for display: $e');
          total = 0.0; // fallback
        }

        try {
          Get.snackbar(
            'Pembayaran Berhasil! 🎉',
            'Customer: ${customerName.trim()}\n'
                'Total: ${total > 0 ? 'Rp${_formatPrice(total.round())}' : 'Berhasil'}\n'
                'Metode: $paymentMethod',
            backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
            colorText: Get.theme.colorScheme.primary,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
          );
        } catch (e) {
          print('Error showing success snackbar: $e');
          // Fallback success notification
          Get.snackbar(
            'Pembayaran Berhasil! 🎉',
            'Pembayaran telah diproses dengan sukses',
            backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
            colorText: Get.theme.colorScheme.primary,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
          );
        }

        return true;
      } else {
        // Handle failure case
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
        return false;
      }
    } catch (e) {
      print('Payment exception: $e'); // Debug log

      // PERBAIKAN: Set failed result hanya jika belum ada result atau result sukses
      if (result == null || result.isSuccess) {
        paymentResult.value = PaymentProcessResult(
          success: false,
          error: e.toString(),
        );
      }

      orderUpdateProgress.value = 'Error: $e';

      // PERBAIKAN: Jangan tampilkan error jika sebenarnya sukses
      if (result != null && result.isSuccess) {
        print(
            'Payment was successful but exception occurred in UI handling: $e');
        return true; // Return true karena payment sebenarnya berhasil
      }

      // Format error message untuk user
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
    } finally {
      isProcessingPayment.value = false;
      // Clear progress after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        orderUpdateProgress.value = '';
      });
    }
  }

  // PERBAIKAN: Helper method untuk format error message
  String _formatErrorMessage(String error) {
    String errorMessage = 'Terjadi kesalahan';

    if (error.contains('customer_name')) {
      errorMessage = 'Nama customer tidak boleh kosong';
    } else if (error.contains('table_number')) {
      errorMessage = 'Nomor meja tidak valid';
    } else if (error.contains('order_details')) {
      errorMessage = 'Data pesanan tidak valid';
    } else if (error.contains('payment')) {
      errorMessage = 'Gagal memproses pembayaran';
    } else if (error.contains('network') || error.contains('connection')) {
      errorMessage = 'Koneksi internet bermasalah';
    } else if (error.contains('Exception: ')) {
      errorMessage = error.replaceAll('Exception: ', '');
    } else {
      errorMessage = error;
    }

    return errorMessage;
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
