// services/kitchen_service.dart
import 'dart:convert';
import 'package:pos/http_client.dart';
import 'package:pos/models/kitchen/kitchen_model.dart';

class KitchenService {
  final HttpClient _httpClient = HttpClient.instance;

  // Get all kitchens with PROCESSED dish_status only
  Future<KitchenResponse> getKitchens({
    String? status,
    String? method,
    int? page,
    int? limit,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {};

      // Always filter for PROCESSED dish status for kitchen
      queryParams['status_pesanan'] = 'PROCESSED';

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

        // Convert the API response to match your KitchenResponse format
        final List<dynamic> ordersData = jsonData['data'];
        final List<KitchenModel> kitchens =
            ordersData.map((order) => KitchenModel.fromJson(order)).toList();

        return KitchenResponse(
          message: jsonData['message'] ?? 'Success',
          status: jsonData['status'] ?? 200,
          data: kitchens,
        );
      } else {
        throw Exception('Failed to load kitchens: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching kitchens: $e');
    }
  }
}
