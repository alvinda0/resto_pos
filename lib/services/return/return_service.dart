import 'dart:convert';
import 'package:get/get.dart';
import 'package:shao_kao/http_client.dart';
import 'package:shao_kao/models/return/return_model.dart';

class WasteService extends GetxService {
  static WasteService get instance {
    if (!Get.isRegistered<WasteService>()) {
      Get.put(WasteService());
    }
    return Get.find<WasteService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  /// Get waste records with pagination and search
  ///
  /// Parameters:
  /// - [page]: Current page number (default: 1)
  /// - [limit]: Number of items per page (default: 10)
  /// - [search]: Search query for filtering (optional)
  /// - [storeId]: Store ID (optional, will use default from storage)
  Future<WasteResponse> getWastes({
    int page = 1,
    int limit = 10,
    String? search,
    String? storeId,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _httpClient.get(
        '/wastes',
        requireAuth: true,
        storeId: storeId,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return WasteResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load wastes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting wastes: $e');
    }
  }

  /// Get waste record by ID
  Future<WasteRecord> getWasteById(String id, {String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '/wastes/$id',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return WasteRecord.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to load waste: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting waste by ID: $e');
    }
  }

  /// Create new waste record
  Future<WasteRecord> createWaste(
    Map<String, dynamic> data, {
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.post(
        '/wastes',
        data,
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return WasteRecord.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to create waste: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating waste: $e');
    }
  }

  /// Update waste record
  Future<WasteRecord> updateWaste(
    String id,
    Map<String, dynamic> data, {
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.put(
        '/wastes/$id',
        data,
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return WasteRecord.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to update waste: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating waste: $e');
    }
  }

  /// Delete waste record
  Future<bool> deleteWaste(String id, {String? storeId}) async {
    try {
      final response = await _httpClient.delete(
        '/wastes/$id',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete waste: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting waste: $e');
    }
  }
}
