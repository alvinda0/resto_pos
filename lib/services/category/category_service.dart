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

  /// Creates a new category
  ///
  /// [name] - Category name (required)
  /// [isActive] - Whether the category is active (default: true)
  /// [position] - Category position/order (optional)
  /// [storeId] - Store ID for multi-store setup (optional)
  Future<Category> createCategory({
    required String name,
    bool isActive = true,
    int? position,
    String? storeId,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'name': name,
        'is_active': isActive,
      };

      if (position != null) {
        requestData['position'] = position;
      }

      final response = await _httpClient.post(
        '/categories',
        requestData,
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

  /// Updates an existing category
  ///
  /// [id] - Category ID to update
  /// [name] - New category name (optional)
  /// [isActive] - Whether the category is active (optional)
  /// [position] - New category position/order (optional)
  /// [storeId] - Store ID for multi-store setup (optional)
  Future<Category> updateCategory(
    String id, {
    String? name,
    bool? isActive,
    int? position,
    String? storeId,
  }) async {
    try {
      final Map<String, dynamic> requestData = {};

      if (name != null) {
        requestData['name'] = name;
      }

      if (isActive != null) {
        requestData['is_active'] = isActive;
      }

      if (position != null) {
        requestData['position'] = position;
      }

      if (requestData.isEmpty) {
        throw Exception('At least one field must be provided for update');
      }

      final response = await _httpClient.put(
        '/categories/$id',
        requestData,
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

  /// Deletes a category by ID
  ///
  /// [id] - Category ID to delete
  /// [storeId] - Store ID for multi-store setup (optional)
  ///
  /// Returns true if deletion was successful
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

  // Legacy method for backward compatibility
  @deprecated
  Future<Category> createCategoryLegacy(Map<String, dynamic> data,
      {String? storeId}) async {
    return createCategory(
      name: data['name'],
      isActive: data['is_active'] ?? true,
      position: data['position'],
      storeId: storeId,
    );
  }

  // Legacy method for backward compatibility
  @deprecated
  Future<Category> updateCategoryLegacy(String id, Map<String, dynamic> data,
      {String? storeId}) async {
    return updateCategory(
      id,
      name: data['name'],
      isActive: data['is_active'],
      position: data['position'],
      storeId: storeId,
    );
  }
}
