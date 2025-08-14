// services/order_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/order/new_order_model.dart';

class OrderService extends GetxService {
  final HttpClient _httpClient = HttpClient.instance;

  static OrderService get instance {
    if (!Get.isRegistered<OrderService>()) {
      Get.put(OrderService());
    }
    return Get.find<OrderService>();
  }

  // Create Order
  Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _httpClient.post(
        '/orders',
        request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return Order.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to create order');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      print('Error creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  // Process Payment (Cash/Debit)
  Future<PaymentResponse> processPayment({
    required String orderId,
    required String method,
  }) async {
    try {
      final response = await _httpClient.post(
        '/orders/$orderId/payments',
        {'method': method},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return PaymentResponse.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Payment failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Payment failed');
      }
    } catch (e) {
      print('Error processing payment: $e');
      throw Exception('Payment failed: $e');
    }
  }

  // Initiate QRIS Payment
  Future<QrisPaymentResponse> initiateQrisPayment(String orderId) async {
    try {
      final response = await _httpClient.post(
        '/qris/orders/$orderId/payment',
        {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return QrisPaymentResponse.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'QRIS payment failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'QRIS payment failed');
      }
    } catch (e) {
      print('Error initiating QRIS payment: $e');
      throw Exception('QRIS payment failed: $e');
    }
  }

  // Check QRIS Payment Status
  Future<QrisStatusResponse> checkQrisPaymentStatus(String orderId) async {
    try {
      final response = await _httpClient.get(
        '/qris/orders/$orderId/status',
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return QrisStatusResponse.fromJson(responseData['data']);
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to get payment status');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get payment status');
      }
    } catch (e) {
      print('Error checking QRIS payment status: $e');
      throw Exception('Failed to get payment status: $e');
    }
  }

  // Get Order by ID
  Future<Order> getOrder(String orderId) async {
    try {
      final response = await _httpClient.get('/orders/$orderId');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return Order.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get order');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get order');
      }
    } catch (e) {
      print('Error getting order: $e');
      throw Exception('Failed to get order: $e');
    }
  }

  // Get Orders List
  Future<List<Order>> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _httpClient.get(
        '/orders',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> ordersData =
              responseData['data']['orders'] ?? responseData['data'];
          return ordersData.map((order) => Order.fromJson(order)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get orders');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get orders');
      }
    } catch (e) {
      print('Error getting orders: $e');
      throw Exception('Failed to get orders: $e');
    }
  }
}
