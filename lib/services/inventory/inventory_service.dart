// services/inventory_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/inventory/inventory_model.dart';

class InventoryService extends GetxService {
  final HttpClient _httpClient = HttpClient.instance;

  static InventoryService get instance {
    if (!Get.isRegistered<InventoryService>()) {
      Get.put(InventoryService());
    }
    return Get.find<InventoryService>();
  }

  // Get inventories with pagination and search
  Future<InventoryListResponse> getInventories({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Note: Status filtering might need to be handled on backend
      // For now, we'll filter on frontend if needed
      if (status != null && status.isNotEmpty && status != 'Semua') {
        queryParams['status'] = status;
      }

      final response = await _httpClient.get(
        '/inventories',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return InventoryListResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Gagal mengambil data inventori');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get all inventories (for backward compatibility)
  Future<List<InventoryModel>> getAllInventories() async {
    try {
      // Get first page with high limit to get all data
      // This is for backward compatibility with existing filter methods
      final response = await getInventories(page: 1, limit: 1000);
      return response.data;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create new inventory
  Future<InventoryModel> createInventory(CreateInventoryRequest request) async {
    try {
      final response = await _httpClient.post('/inventories', request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return InventoryModel.fromJson(jsonData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal membuat inventori');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update inventory
  Future<InventoryModel> updateInventory(
      String id, UpdateInventoryRequest request) async {
    try {
      final response =
          await _httpClient.put('/inventories/$id', request.toJson());

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return InventoryModel.fromJson(jsonData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal memperbarui inventori');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete inventory
  Future<bool> deleteInventory(String id) async {
    try {
      final response = await _httpClient.delete('/inventories/$id');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal menghapus inventori');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get inventory by ID
  Future<InventoryModel> getInventoryById(String id) async {
    try {
      final response = await _httpClient.get('/inventories/$id');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return InventoryModel.fromJson(jsonData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Gagal mengambil data inventori');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Search inventories (now uses server-side search via pagination)
  Future<InventoryListResponse> searchInventories(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await getInventories(
        page: page,
        limit: limit,
        search: query.isNotEmpty ? query : null,
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Filter inventories by status (legacy method for local filtering)
  Future<List<InventoryModel>> filterInventoriesByStatus(String status) async {
    try {
      final response = await getAllInventories();
      if (status.isEmpty || status == 'Semua') return response;

      if (status == 'MENIPIS') {
        return response.where((inventory) => inventory.isLowStock).toList();
      } else if (status == 'CUKUP') {
        return response.where((inventory) => !inventory.isLowStock).toList();
      }

      return response;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
