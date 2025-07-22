import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/category/category_model.dart';

class CategoryService extends GetxService {
  static CategoryService get instance {
    if (!Get.isRegistered<CategoryService>()) {
      Get.put(CategoryService());
    }
    return Get.find<CategoryService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  // Get all categories with pagination and search
  Future<ApiResponse<CategoriesResponse>> getCategories({
    String? storeId,
    int page = 1,
    int limit = 10,
    String? search,
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

      final response = await _httpClient.get(
        '/categories',
        storeId: storeId,
        queryParameters: queryParams,
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Check if data exists and is valid
        if (jsonResponse['data'] == null) {
          return ApiResponse<CategoriesResponse>(
            success: false,
            message: 'No data received from server',
            status: response.statusCode,
            timestamp:
                jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          );
        }

        // Parse metadata if available
        PaginationMetadata? metadata;
        if (jsonResponse['metadata'] != null) {
          metadata = PaginationMetadata.fromJson(jsonResponse['metadata']);
        }

        // Create categories response - data is now direct array
        final categoriesResponse = CategoriesResponse.fromJson(
          jsonResponse['data'],
          metadata: metadata,
        );

        return ApiResponse<CategoriesResponse>(
          success: jsonResponse['success'] ?? true,
          message:
              jsonResponse['message'] ?? 'Categories retrieved successfully',
          status: jsonResponse['status'] ?? 200,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          data: categoriesResponse,
          metadata: metadata,
        );
      } else {
        return ApiResponse<CategoriesResponse>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to get categories',
          status: response.statusCode,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          error: jsonResponse['error'] != null
              ? ApiError.fromJson(jsonResponse['error'])
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<CategoriesResponse>(
        success: false,
        message: 'Error getting categories: $e',
        status: 500,
        timestamp: DateTime.now().toIso8601String(),
      );
    }
  }

  // Create new category
  Future<ApiResponse<Category>> createCategory({
    required CategoryRequest categoryRequest,
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.post(
        '/categories',
        categoryRequest.toJson(),
        storeId: storeId,
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonResponse['data'] == null) {
          throw Exception('Server returned null data for created category');
        }

        final category = Category.fromJson(jsonResponse['data']);
        return ApiResponse<Category>(
          success: jsonResponse['success'] ?? true,
          message: jsonResponse['message'] ?? 'Category created successfully',
          status: jsonResponse['status'] ?? response.statusCode,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          data: category,
        );
      } else {
        return ApiResponse<Category>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to create category',
          status: response.statusCode,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          error: jsonResponse['error'] != null
              ? ApiError.fromJson(jsonResponse['error'])
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<Category>(
        success: false,
        message: 'Error creating category: $e',
        status: 500,
        timestamp: DateTime.now().toIso8601String(),
      );
    }
  }

  // Update category
  Future<ApiResponse<Category>> updateCategory({
    required String categoryId,
    required CategoryRequest categoryRequest,
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.put(
        '/categories/$categoryId',
        categoryRequest.toJson(),
        storeId: storeId,
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] == null) {
          throw Exception('Server returned null data for updated category');
        }

        final category = Category.fromJson(jsonResponse['data']);
        return ApiResponse<Category>(
          success: jsonResponse['success'] ?? true,
          message: jsonResponse['message'] ?? 'Category updated successfully',
          status: jsonResponse['status'] ?? 200,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          data: category,
        );
      } else {
        return ApiResponse<Category>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to update category',
          status: response.statusCode,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          error: jsonResponse['error'] != null
              ? ApiError.fromJson(jsonResponse['error'])
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<Category>(
        success: false,
        message: 'Error updating category: $e',
        status: 500,
        timestamp: DateTime.now().toIso8601String(),
      );
    }
  }

  // Delete category
  Future<ApiResponse<void>> deleteCategory({
    required String categoryId,
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.delete(
        '/categories/$categoryId',
        storeId: storeId,
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: jsonResponse['success'] ?? true,
          message: jsonResponse['message'] ?? 'Category deleted successfully',
          status: jsonResponse['status'] ?? 200,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to delete category',
          status: response.statusCode,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          error: jsonResponse['error'] != null
              ? ApiError.fromJson(jsonResponse['error'])
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error deleting category: $e',
        status: 500,
        timestamp: DateTime.now().toIso8601String(),
      );
    }
  }

  // Get category by ID
  Future<ApiResponse<Category>> getCategoryById({
    required String categoryId,
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.get(
        '/categories/$categoryId',
        storeId: storeId,
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] == null) {
          throw Exception('Server returned null data for category');
        }

        final category = Category.fromJson(jsonResponse['data']);
        return ApiResponse<Category>(
          success: jsonResponse['success'] ?? true,
          message: jsonResponse['message'] ?? 'Category retrieved successfully',
          status: jsonResponse['status'] ?? 200,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          data: category,
        );
      } else {
        return ApiResponse<Category>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to get category',
          status: response.statusCode,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          error: jsonResponse['error'] != null
              ? ApiError.fromJson(jsonResponse['error'])
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<Category>(
        success: false,
        message: 'Error getting category: $e',
        status: 500,
        timestamp: DateTime.now().toIso8601String(),
      );
    }
  }

  // Toggle category active status
  Future<ApiResponse<Category>> toggleCategoryStatus({
    required String categoryId,
    required bool isActive,
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.patch(
        '/categories/$categoryId',
        {'is_active': isActive},
        storeId: storeId,
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['data'] == null) {
          throw Exception('Server returned null data for toggled category');
        }

        final category = Category.fromJson(jsonResponse['data']);
        return ApiResponse<Category>(
          success: jsonResponse['success'] ?? true,
          message:
              jsonResponse['message'] ?? 'Category status updated successfully',
          status: jsonResponse['status'] ?? 200,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          data: category,
        );
      } else {
        return ApiResponse<Category>(
          success: false,
          message:
              jsonResponse['message'] ?? 'Failed to toggle category status',
          status: response.statusCode,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          error: jsonResponse['error'] != null
              ? ApiError.fromJson(jsonResponse['error'])
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<Category>(
        success: false,
        message: 'Error toggling category status: $e',
        status: 500,
        timestamp: DateTime.now().toIso8601String(),
      );
    }
  }
}
