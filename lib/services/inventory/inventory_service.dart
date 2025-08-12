// services/inventory_service.dart
import 'dart:convert';
import 'package:pos/http_client.dart';
import 'package:pos/models/inventory/inventory_model.dart';

class InventoryService {
  static InventoryService? _instance;
  static InventoryService get instance {
    _instance ??= InventoryService._();
    return _instance!;
  }

  InventoryService._();

  final HttpClient _httpClient = HttpClient.instance;

  Future<InventoryResponse> getInventories({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Add search parameter if not empty
      if (search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Add status filter if not empty
      if (status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }

      final response = await _httpClient.get(
        '/inventories',
        requireAuth: true,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final String responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Response body is empty');
        }

        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        // Validate response structure
        if (!jsonResponse.containsKey('data') ||
            !jsonResponse.containsKey('metadata')) {
          throw Exception('Invalid response structure');
        }

        return InventoryResponse.fromJson(jsonResponse);
      } else {
        final String errorMessage = response.statusCode == 404
            ? 'Data tidak ditemukan'
            : response.statusCode == 500
                ? 'Server mengalami masalah'
                : 'Failed to fetch inventories (${response.statusCode})';

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Silakan coba lagi.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Format data tidak valid dari server.');
      }

      throw Exception(
          'Error fetching inventories: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<InventoryModel> getInventoryById(String id) async {
    try {
      final response = await _httpClient.get(
        '/inventories/$id',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return InventoryModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to fetch inventory: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching inventory: $e');
    }
  }

  // Future methods for CRUD operations can be added here
  // Future<InventoryModel> createInventory(Map<String, dynamic> data) async {}
  // Future<InventoryModel> updateInventory(String id, Map<String, dynamic> data) async {}
  // Future<void> deleteInventory(String id) async {}
}
