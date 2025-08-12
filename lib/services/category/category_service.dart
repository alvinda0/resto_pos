import 'dart:convert';

import 'package:pos/http_client.dart';
import 'package:pos/models/category/category_model.dart';

class CategoryService {
  final HttpClient _httpClient = HttpClient.instance;

  Future<CategoryResponse> getCategories({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
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

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _httpClient.get(
        '/categories',
        requireAuth: true,
        storeId: storeId,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return CategoryResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<Category> getCategoryById(String id, {String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '/categories/$id',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return Category.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching category: $e');
    }
  }

  // For future implementation
  Future<Category> createCategory(Map<String, dynamic> data,
      {String? storeId}) async {
    try {
      final response = await _httpClient.post(
        '/categories',
        data,
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return Category.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to create category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating category: $e');
    }
  }

  // For future implementation
  Future<Category> updateCategory(String id, Map<String, dynamic> data,
      {String? storeId}) async {
    try {
      final response = await _httpClient.put(
        '/categories/$id',
        data,
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return Category.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  // For future implementation
  Future<bool> deleteCategory(String id, {String? storeId}) async {
    try {
      final response = await _httpClient.delete(
        '/categories/$id',
        requireAuth: true,
        storeId: storeId,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }
}
