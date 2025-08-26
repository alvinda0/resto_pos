// services/order_service.dart
import 'dart:convert';
import 'package:shao_kao/http_client.dart';
import 'package:shao_kao/models/order/order_model.dart';

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
}
