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

  Future<InventoryModel> createInventory({
    required String name,
    required double quantity,
    required String unit,
    required double price,
    required double minimumStock,
    required String vendorName,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'price': price,
        'minimum_stock': minimumStock,
        'vendor_name': vendorName,
      };

      final response = await _httpClient.post(
        '/inventories',
        requestBody,
        requireAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Response body is empty');
        }

        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        // Check if response is successful
        if (jsonResponse['success'] == false) {
          throw Exception(
              jsonResponse['message'] ?? 'Failed to create inventory');
        }

        return InventoryModel.fromJson(jsonResponse['data']);
      } else {
        // Try to parse error message from response
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          throw Exception(
              errorResponse['message'] ?? 'Failed to create inventory');
        } catch (e) {
          throw Exception(
              'Failed to create inventory (${response.statusCode})');
        }
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Silakan coba lagi.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Format data tidak valid.');
      }

      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<InventoryModel> updateInventory({
    required String id,
    String? name,
    double? quantity,
    String? unit,
    double? price,
    double? minimumStock,
    String? vendorName,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {};

      // Only add non-null values to request body
      if (name != null) requestBody['name'] = name;
      if (quantity != null) requestBody['quantity'] = quantity;
      if (unit != null) requestBody['unit'] = unit;
      if (price != null) requestBody['price'] = price;
      if (minimumStock != null) requestBody['minimum_stock'] = minimumStock;
      if (vendorName != null) requestBody['vendor_name'] = vendorName;

      final response = await _httpClient.put(
        '/inventories/$id',
        requestBody,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final String responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Response body is empty');
        }

        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        // Check if response is successful
        if (jsonResponse['success'] == false) {
          // Handle specific error codes
          if (jsonResponse['error']?['code'] == 'INVENTORY_UPDATE_ERROR' &&
              jsonResponse['error']?['details'] == 'record not found') {
            throw Exception('Data inventory tidak ditemukan');
          }
          throw Exception(
              jsonResponse['message'] ?? 'Failed to update inventory');
        }

        return InventoryModel.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Data inventory tidak ditemukan');
      } else if (response.statusCode == 500) {
        // Try to parse server error
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          if (errorResponse['error']?['details'] == 'record not found') {
            throw Exception('Data inventory tidak ditemukan');
          }
          throw Exception('Server mengalami masalah');
        } catch (e) {
          throw Exception('Server mengalami masalah');
        }
      } else {
        // Try to parse error message from response
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          throw Exception(
              errorResponse['message'] ?? 'Failed to update inventory');
        } catch (e) {
          throw Exception(
              'Failed to update inventory (${response.statusCode})');
        }
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Silakan coba lagi.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Format data tidak valid.');
      }

      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> deleteInventory(String id) async {
    try {
      final response = await _httpClient.delete(
        '/inventories/$id',
        requireAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - inventory deleted
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Data inventory tidak ditemukan');
      } else if (response.statusCode == 500) {
        throw Exception('Server mengalami masalah');
      } else {
        // Try to parse error message from response
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          throw Exception(
              errorResponse['message'] ?? 'Failed to delete inventory');
        } catch (e) {
          throw Exception(
              'Failed to delete inventory (${response.statusCode})');
        }
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Silakan coba lagi.');
      }

      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
