// services/order_service.dart
import 'dart:convert';
import 'package:pos/http_client.dart';
import 'package:pos/models/order/order_model.dart';

class OrderService {
  final HttpClient _httpClient = HttpClient.instance;

  // Get all orders
  Future<OrderResponse> getOrders({
    String? status,
    String? method,
    int? page,
    int? limit,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (method != null && method.isNotEmpty) {
        queryParams['method'] = method;
      }

      if (page != null) {
        queryParams['page'] = page.toString();
      }

      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      // Build endpoint with query parameters
      String endpoint = '/orders';
      if (queryParams.isNotEmpty) {
        final queryString =
            queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
        endpoint += '?$queryString';
      }

      final response = await _httpClient.get(endpoint);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return OrderResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Get order by ID
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _httpClient.get('/orders/$orderId');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return OrderModel.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  // Create new order
  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _httpClient.post('/orders', orderData);

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return OrderModel.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  // Update order status
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _httpClient.patch('/orders/$orderId/status', {
        'status': status,
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return OrderModel.fromJson(jsonData['data']);
      } else {
        throw Exception(
            'Failed to update order status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  // Update dish status
  Future<OrderModel> updateDishStatus(String orderId, String dishStatus) async {
    try {
      final response = await _httpClient.patch('/orders/$orderId/dish-status', {
        'dish_status': dishStatus,
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return OrderModel.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to update dish status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating dish status: $e');
    }
  }

  // Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      final response = await _httpClient.delete('/orders/$orderId');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting order: $e');
    }
  }

  // Pay order
  Future<OrderModel> payOrder(
      String orderId, Map<String, dynamic> paymentData) async {
    try {
      final response =
          await _httpClient.post('/orders/$orderId/pay', paymentData);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return OrderModel.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to pay order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error paying order: $e');
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStats() async {
    try {
      final response = await _httpClient.get('/orders/stats');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'];
      } else {
        throw Exception('Failed to load order stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching order stats: $e');
    }
  }
}
