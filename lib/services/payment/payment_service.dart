// services/payment_service.dart
import 'dart:convert';
import 'package:pos/http_client.dart';
import 'package:pos/models/order/order_model.dart';
import 'package:pos/models/payment/payment_model.dart';

class PaymentService {
  final HttpClient _httpClient = HttpClient.instance;

  // Main method: Process order + payment in sequence
  Future<PaymentProcessResult> processOrderPayment({
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
      print('Starting payment process for order: $orderId');

      // Step 1: Update order with items AND customer info in single call
      final updatedOrder = await updateOrderComplete(
        orderId: orderId,
        customerName: customerName,
        customerPhone: customerPhone,
        tableNumber: tableNumber,
        notes: notes,
        orderItems: orderItems,
        promoCode: promoCode,
      );

      print('Order updated successfully, now processing payment...');

      // Step 2: Process payment
      final payment = await processPayment(
        orderId: orderId,
        paymentMethod: paymentMethod,
      );

      print('Payment processed successfully');

      return PaymentProcessResult(
        success: true,
        order: updatedOrder,
        payment: payment,
      );
    } catch (e) {
      print('Error in payment process: $e');
      return PaymentProcessResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Update order with items only (based on your API example)
  Future<OrderModel> updateOrderItems({
    required String orderId,
    required List<dynamic> orderItems,
    String? promoCode,
  }) async {
    try {
      // Convert order items to the expected format
      List<Map<String, dynamic>> orderDetails = orderItems.map((item) {
        String productId;
        int quantity;
        String? note;

        if (item is Map) {
          productId =
              item['productId']?.toString() ?? item['id']?.toString() ?? '';
          quantity = item['quantity'] ?? 1;
          note = item['note']?.toString();
        } else {
          productId = item.productId?.toString() ?? item.id?.toString() ?? '';
          quantity = item.quantity ?? 1;
          note = item.note?.toString();
        }

        Map<String, dynamic> orderDetail = {
          'product_id': productId,
          'quantity': quantity,
        };

        // Only add note if it's not null or empty
        if (note != null && note.isNotEmpty) {
          orderDetail['note'] = note;
        }

        return orderDetail;
      }).toList();

      // Create the request matching your API format
      final request = {
        'order_details': orderDetails,
      };

      print('Updating order items for order: $orderId');
      print('Request: ${jsonEncode(request)}');

      final response = await _httpClient.put(
        '/orders/$orderId',
        request,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print('Order items updated successfully');
          return OrderModel.fromJson(responseData['data']);
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to update order items');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating order items: $e');
      rethrow;
    }
  }

  // Updated method to handle complete order update (items + customer info)
  Future<OrderModel> updateOrderComplete({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required int tableNumber,
    String? notes,
    required List<dynamic> orderItems,
    String? promoCode,
  }) async {
    try {
      // Convert order items to the expected format
      List<Map<String, dynamic>> orderDetails = orderItems.map((item) {
        String productId;
        int quantity;
        String? note;

        if (item is Map) {
          productId =
              item['productId']?.toString() ?? item['id']?.toString() ?? '';
          quantity = item['quantity'] ?? 1;
          note = item['note']?.toString();
        } else {
          productId = item.productId?.toString() ?? item.id?.toString() ?? '';
          quantity = item.quantity ?? 1;
          note = item.note?.toString();
        }

        Map<String, dynamic> orderDetail = {
          'product_id': productId,
          'quantity': quantity,
        };

        // Only add note if it's not null or empty
        if (note != null && note.isNotEmpty) {
          orderDetail['note'] = note;
        }

        return orderDetail;
      }).toList();

      // Create complete request with both order items and customer info
      final request = {
        'order_details': orderDetails,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'table_number': tableNumber,
      };

      // Only add optional fields if they have values
      if (promoCode != null && promoCode.isNotEmpty) {
        request['promo_code'] = promoCode;
      }
      if (notes != null && notes.isNotEmpty) {
        request['notes'] = notes;
      }

      print('Updating complete order for order: $orderId');
      print('Request: ${jsonEncode(request)}');

      final response = await _httpClient.put(
        '/orders/$orderId',
        request,
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

  // Process payment (matching your API format)
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
      print('Request: ${jsonEncode(request)}');

      final response = await _httpClient.post(
        '/orders/$orderId/payments',
        request,
      );

      print('Payment response status: ${response.statusCode}');
      print('Payment response body: ${response.body}');

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
      print('Getting payments for order: $orderId');

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

  // Alternative method: Update only customer info (if API supports separate endpoint)
  Future<OrderModel> updateCustomerInfo({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required int tableNumber,
    String? notes,
  }) async {
    try {
      final request = {
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'table_number': tableNumber,
      };

      if (notes != null && notes.isNotEmpty) {
        request['notes'] = notes;
      }

      print('Updating customer info for order: $orderId');
      print('Request: ${jsonEncode(request)}');

      // Try using the same endpoint with just customer data
      final response = await _httpClient.put(
        '/orders/$orderId',
        request,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print('Customer info updated successfully');
          return OrderModel.fromJson(responseData['data']);
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to update customer info');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating customer info: $e');
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

  @override
  String toString() {
    return 'PaymentProcessResult(success: $success, order: ${order?.id}, payment: ${payment?.id}, error: $error)';
  }
}
