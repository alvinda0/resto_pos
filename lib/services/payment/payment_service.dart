// services/payment_service.dart
import 'dart:convert';
import 'package:pos/http_client.dart';
import 'package:pos/models/order/order_model.dart';
import 'package:pos/models/payment/payment_model.dart';

class PaymentService {
  final HttpClient _httpClient = HttpClient.instance;

  // Main method: Process order + payment in sequence, then refresh order
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
    OrderModel? updatedOrder;
    PaymentModel? payment;
    OrderModel? finalOrder; // Order after payment completion

    try {
      print('Starting payment process for order: $orderId');

      // Step 1: Update order with items AND customer info in single call
      print('Step 1: Updating order...');
      updatedOrder = await updateOrderComplete(
        orderId: orderId,
        customerName: customerName,
        customerPhone: customerPhone,
        tableNumber: tableNumber,
        notes: notes,
        orderItems: orderItems,
        promoCode: promoCode,
      );
      print('Order updated successfully');

      // Step 2: Process payment
      print('Step 2: Processing payment...');
      payment = await processPayment(
        orderId: orderId,
        paymentMethod: paymentMethod,
      );
      print('Payment processed successfully');

      // Step 3: Get the final order with payment details
      print('Step 3: Getting final order details...');
      finalOrder = await getOrderById(orderId);
      print('Final order retrieved successfully');

      // Return success result with final order
      return PaymentProcessResult(
        success: true,
        order: finalOrder, // Use the final order with payment details
        payment: payment,
      );
    } catch (e, stackTrace) {
      print('Error in processOrderPayment: $e');
      print('StackTrace: $stackTrace');

      // Handle different types of errors
      String errorMessage = e.toString();

      // If order update succeeded but payment failed
      if (updatedOrder != null && payment == null) {
        errorMessage =
            'Order berhasil diperbarui, tetapi pembayaran gagal: $errorMessage';
      }
      // If both order update and payment succeeded but final order fetch failed
      else if (updatedOrder != null && payment != null && finalOrder == null) {
        print('Payment succeeded but failed to get final order details');
        // Still return success since payment went through
        return PaymentProcessResult(
          success: true,
          order: updatedOrder, // Use the updated order as fallback
          payment: payment,
          error:
              'Pembayaran berhasil, tetapi gagal mengambil detail order final',
        );
      }
      // If both failed
      else if (updatedOrder == null) {
        errorMessage = 'Gagal memperbarui order: $errorMessage';
      }

      return PaymentProcessResult(
        success: false,
        order: updatedOrder, // Include partial success
        error: errorMessage,
      );
    }
  }

  // Get order by ID - NEW METHOD
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      print('Getting order by ID: $orderId');

      final response = await _httpClient.get('/orders/$orderId');

      print('Get order response status: ${response.statusCode}');
      print('Get order response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('Order retrieved successfully');
          return OrderModel.fromJson(responseData['data']);
        } else {
          final errorMsg =
              responseData['message'] ?? 'Failed to retrieve order';
          print('Get order API returned success=false: $errorMsg');
          throw Exception(errorMsg);
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['message'] ?? 'HTTP ${response.statusCode}';
        print('Get order HTTP error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Error getting order by ID: $e');
      rethrow;
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
      List<Map<String, dynamic>> orderDetails = _convertOrderItems(orderItems);

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

      return _handleOrderResponse(response, 'update order items');
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
      List<Map<String, dynamic>> orderDetails = _convertOrderItems(orderItems);

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

      return _handleOrderResponse(response, 'update order');
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

      print(
          'Processing payment for order: $orderId with method: $paymentMethod');
      print('Payment request: ${jsonEncode(request)}');

      final response = await _httpClient.post(
        '/orders/$orderId/payments',
        request,
      );

      print('Payment response status: ${response.statusCode}');
      print('Payment response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('Payment processed successfully');
          return PaymentModel.fromJson(responseData['data']);
        } else {
          final errorMsg =
              responseData['message'] ?? 'Failed to process payment';
          print('Payment API returned success=false: $errorMsg');
          throw Exception(errorMsg);
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['message'] ?? 'HTTP ${response.statusCode}';
        print('Payment HTTP error: $errorMsg');
        throw Exception(errorMsg);
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

      // Try using the same endpoint with just customer data
      final response = await _httpClient.put(
        '/orders/$orderId',
        request,
      );

      return _handleOrderResponse(response, 'update customer info');
    } catch (e) {
      rethrow;
    }
  }

  // Helper method untuk convert order items
  List<Map<String, dynamic>> _convertOrderItems(List<dynamic> orderItems) {
    return orderItems.map((item) {
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
  }

  // Helper method untuk handle order response
  OrderModel _handleOrderResponse(response, String operation) {
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('$operation completed successfully');
        return OrderModel.fromJson(responseData['data']);
      } else {
        final errorMsg = responseData['message'] ?? 'Failed to $operation';
        print('$operation API returned success=false: $errorMsg');
        throw Exception(errorMsg);
      }
    } else {
      final errorData = jsonDecode(response.body);
      final errorMsg = errorData['message'] ?? 'HTTP ${response.statusCode}';
      print('$operation HTTP error: $errorMsg');
      throw Exception(errorMsg);
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
