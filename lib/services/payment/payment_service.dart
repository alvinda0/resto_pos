// services/payment_service.dart
import 'dart:convert';
import 'package:pos/http_client.dart';
import 'package:pos/models/order/order_model.dart';
import 'package:pos/models/payment/payment_model.dart';

class PaymentService {
  final HttpClient _httpClient = HttpClient.instance;

  // Proses edit order + payment secara berurutan
  Future<PaymentProcessResult> processOrderPayment({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required int tableNumber,
    String? notes,
    required List<dynamic> orderItems,
    required String paymentMethod,
  }) async {
    try {
      // Step 1: Update order terlebih dahulu
      final updatedOrder = await updateOrder(
        orderId: orderId,
        customerName: customerName,
        customerPhone: customerPhone,
        tableNumber: tableNumber,
        notes: notes,
        orderItems: orderItems,
        paymentMethod: paymentMethod,
      );

      // Step 2: Proses payment dengan order ID yang sudah di-update
      final payment = await processPayment(
        orderId: updatedOrder.id,
        paymentMethod: paymentMethod,
      );

      return PaymentProcessResult(
        success: true,
        order: updatedOrder,
        payment: payment,
      );
    } catch (e) {
      return PaymentProcessResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Update order
  Future<OrderModel> updateOrder({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required int tableNumber,
    String? notes,
    required List<dynamic> orderItems,
    required String paymentMethod,
  }) async {
    try {
      // Convert order items to OrderDetailRequest format
      List<OrderDetailRequest> orderDetails = orderItems.map((item) {
        String productId;
        int quantity;

        if (item is Map) {
          productId =
              item['productId']?.toString() ?? item['id']?.toString() ?? '';
          quantity = item['quantity'] ?? 1;
        } else {
          productId = item.productId?.toString() ?? item.id?.toString() ?? '';
          quantity = item.quantity ?? 1;
        }

        return OrderDetailRequest(
          productId: productId,
          quantity: quantity,
          note: null, // Add note if needed
        );
      }).toList();

      // Create update request
      final request = OrderUpdateRequest(
        order: OrderUpdateInfo(
          customerName: customerName,
          customerPhone: customerPhone,
          tableNumber: tableNumber,
          notes: notes,
        ),
        orderDetails: orderDetails,
        payments: [
          PaymentRequest(method: paymentMethod),
        ],
      );

      final response = await _httpClient.put(
        '/orders/$orderId',
        request.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print('Order updated successfully');
          return OrderModel.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update order');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating order: $e');
      rethrow;
    }
  }

  // Process payment
  Future<PaymentModel> processPayment({
    required String orderId,
    required String paymentMethod,
  }) async {
    try {
      final request = {
        'method': paymentMethod,
      };

      print('Processing payment for order: $orderId');
      print('Payment method: $paymentMethod');

      final response = await _httpClient.post(
        '/orders/$orderId/payments',
        request,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print('Payment processed successfully');
          return PaymentModel.fromJson(responseData['data']);
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to process payment');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error processing payment: $e');
      rethrow;
    }
  }

  // Get payment history for an order
  Future<List<PaymentModel>> getOrderPayments(String orderId) async {
    try {
      final response = await _httpClient.get('/orders/$orderId/payments');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> paymentsData = responseData['data'] ?? [];
          return paymentsData
              .map((payment) => PaymentModel.fromJson(payment))
              .toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get payments');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting order payments: $e');
      rethrow;
    }
  }
}

// Result class for payment process
class PaymentProcessResult {
  final bool success;
  final OrderModel? order;
  final PaymentModel? payment;
  final String? error;

  PaymentProcessResult({
    required this.success,
    this.order,
    this.payment,
    this.error,
  });

  bool get isSuccess => success && error == null;
  String get errorMessage => error ?? 'Unknown error';
}
