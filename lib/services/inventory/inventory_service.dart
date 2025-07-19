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

  // Get all inventories
  Future<List<InventoryModel>> getInventories() async {
    try {
      final response = await _httpClient.get('/inventories');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> inventoriesData = jsonData['data'] ?? [];

        return inventoriesData
            .map((json) => InventoryModel.fromJson(json))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Gagal mengambil data inventori');
      }
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

  // Search inventories by name
  Future<List<InventoryModel>> searchInventories(String query) async {
    try {
      // Since the API doesn't have search endpoint, we'll filter locally
      final inventories = await getInventories();
      if (query.isEmpty) return inventories;

      return inventories
          .where((inventory) =>
              inventory.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Filter inventories by status
  Future<List<InventoryModel>> filterInventoriesByStatus(String status) async {
    try {
      final inventories = await getInventories();
      if (status.isEmpty || status == 'Semua') return inventories;

      if (status == 'MENIPIS') {
        return inventories.where((inventory) => inventory.isLowStock).toList();
      } else if (status == 'CUKUP') {
        return inventories.where((inventory) => !inventory.isLowStock).toList();
      }

      return inventories;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
