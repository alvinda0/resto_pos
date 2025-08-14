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

  // Process order payment (edit order first, then payment)
  Future<bool> processOrderPayment({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required int tableNumber,
    String? notes,
    required List<dynamic> orderItems,
    required String paymentMethod,
  }) async {
    try {
      isProcessingPayment.value = true;

      // Call the service to process order payment
      final result = await _paymentService.processOrderPayment(
        orderId: orderId,
        customerName: customerName,
        customerPhone: customerPhone,
        tableNumber: tableNumber,
        notes: notes,
        orderItems: orderItems,
        paymentMethod: paymentMethod,
      );

      paymentResult.value = result;

      if (result.isSuccess) {
        Get.snackbar(
          'Berhasil',
          'Pembayaran berhasil diproses',
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
          colorText: Get.theme.colorScheme.primary,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          result.errorMessage,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
          colorText: Get.theme.colorScheme.error,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return false;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  // Get payment history for an order
  Future<List<PaymentModel>> getOrderPayments(String orderId) async {
    try {
      return await _paymentService.getOrderPayments(orderId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil riwayat pembayaran: $e',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return [];
    }
  }

  // Clear payment result
  void clearPaymentResult() {
    paymentResult.value = null;
  }

  // Get latest processed order
  OrderModel? get latestOrder => paymentResult.value?.order;

  // Get latest payment
  PaymentModel? get latestPayment => paymentResult.value?.payment;
}
