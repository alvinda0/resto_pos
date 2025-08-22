// services/tax_service.dart
import 'dart:convert';
import 'package:pos/http_client.dart';
import 'package:pos/models/tax/tax_model.dart';

class TaxService {
  late final HttpClient _httpClient;

  TaxService() {
    _httpClient = HttpClient.instance;
  }

  // Get all taxes with pagination
  Future<TaxListResponse> getTaxes({
    int page = 1,
    int limit = 10,
    String? search,
    String? type,
    bool? isActive,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      if (isActive != null) {
        queryParams['is_active'] = isActive.toString();
      }

      print('Making request to /taxes with params: $queryParams');

      final response = await _httpClient.get(
        '/taxes',
        queryParameters: queryParams,
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return TaxListResponse.fromJson(jsonResponse);
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to get taxes');
      }
    } catch (e) {
      print('TaxService.getTaxes error: $e');
      // Rethrow dengan pesan yang lebih jelas
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: $e');
      }
    }
  }

  // Get tax by ID
  Future<TaxResponse> getTaxById(String id) async {
    try {
      final response = await _httpClient.get('/taxes/$id');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return TaxResponse.fromJson(jsonResponse);
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to get tax');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: $e');
      }
    }
  }

  // Create new tax
  Future<TaxResponse> createTax(TaxModel tax) async {
    try {
      final requestBody = tax.toCreateJson();
      print('Creating tax with data: $requestBody');

      final response = await _httpClient.post('/taxes', requestBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return TaxResponse.fromJson(jsonResponse);
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to create tax');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: $e');
      }
    }
  }

  // Update tax
  Future<TaxResponse> updateTax(String id, TaxModel tax) async {
    try {
      final requestBody = tax.toCreateJson();
      print('Updating tax $id with data: $requestBody');

      final response = await _httpClient.put('/taxes/$id', requestBody);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return TaxResponse.fromJson(jsonResponse);
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to update tax');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: $e');
      }
    }
  }

  // Delete tax
  Future<bool> deleteTax(String id) async {
    try {
      print('Deleting tax with id: $id');

      final response = await _httpClient.delete('/taxes/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to delete tax');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: $e');
      }
    }
  }

  // Bulk operations
  Future<bool> bulkUpdateStatus(List<String> ids, bool isActive) async {
    try {
      final requestBody = {
        'ids': ids,
        'is_active': isActive,
      };

      print('Bulk updating status with data: $requestBody');

      final response =
          await _httpClient.patch('/taxes/bulk-status', requestBody);

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to bulk update');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: $e');
      }
    }
  }
}
