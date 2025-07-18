// services/category_service.dart
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

  // Get all categories
  Future<ApiResponse<CategoriesResponse>> getCategories(
      {String? storeId}) async {
    try {
      print('🔄 Fetching categories from API...');

      final response = await _httpClient.get(
        '/categories',
        storeId: storeId,
      );

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Categories retrieved successfully');

        // Check if data exists and is valid
        if (jsonResponse['data'] == null) {
          print('⚠️ Warning: API returned null data');
          return ApiResponse<CategoriesResponse>(
            success: false,
            message: 'No data received from server',
            status: response.statusCode,
            timestamp:
                jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          );
        }

        final categoriesResponse =
            CategoriesResponse.fromJson(jsonResponse['data']);

        print('📊 Categories loaded: ${categoriesResponse.categories.length}');

        return ApiResponse<CategoriesResponse>(
          success: jsonResponse['success'] ?? true,
          message:
              jsonResponse['message'] ?? 'Categories retrieved successfully',
          status: jsonResponse['status'] ?? 200,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
          data: categoriesResponse,
        );
      } else {
        print(
            '❌ API Error: ${response.statusCode} - ${jsonResponse['message']}');
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
    } catch (e, stackTrace) {
      print('💥 Exception in getCategories: $e');
      print('📍 Stack trace: $stackTrace');

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
      print('🔄 Creating category: ${categoryRequest.name}');

      final response = await _httpClient.post(
        '/categories',
        categoryRequest.toJson(),
        storeId: storeId,
      );

      print('📡 Create Category Response: ${response.statusCode}');
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Category created successfully');

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
        print('❌ Create Category Error: ${response.statusCode}');
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
    } catch (e, stackTrace) {
      print('💥 Exception in createCategory: $e');
      print('📍 Stack trace: $stackTrace');

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
      print('🔄 Updating category: $categoryId');

      final response = await _httpClient.put(
        '/categories/$categoryId',
        categoryRequest.toJson(),
        storeId: storeId,
      );

      print('📡 Update Category Response: ${response.statusCode}');
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Category updated successfully');

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
        print('❌ Update Category Error: ${response.statusCode}');
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
    } catch (e, stackTrace) {
      print('💥 Exception in updateCategory: $e');
      print('📍 Stack trace: $stackTrace');

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
      print('🔄 Deleting category: $categoryId');

      final response = await _httpClient.delete(
        '/categories/$categoryId',
        storeId: storeId,
      );

      print('📡 Delete Category Response: ${response.statusCode}');
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Category deleted successfully');
        return ApiResponse<void>(
          success: jsonResponse['success'] ?? true,
          message: jsonResponse['message'] ?? 'Category deleted successfully',
          status: jsonResponse['status'] ?? 200,
          timestamp:
              jsonResponse['timestamp'] ?? DateTime.now().toIso8601String(),
        );
      } else {
        print('❌ Delete Category Error: ${response.statusCode}');
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
    } catch (e, stackTrace) {
      print('💥 Exception in deleteCategory: $e');
      print('📍 Stack trace: $stackTrace');

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
      print('🔄 Fetching category by ID: $categoryId');

      final response = await _httpClient.get(
        '/categories/$categoryId',
        storeId: storeId,
      );

      print('📡 Get Category Response: ${response.statusCode}');
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Category retrieved successfully');

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
        print('❌ Get Category Error: ${response.statusCode}');
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
    } catch (e, stackTrace) {
      print('💥 Exception in getCategoryById: $e');
      print('📍 Stack trace: $stackTrace');

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
      print('🔄 Toggling category status: $categoryId -> $isActive');

      final response = await _httpClient.patch(
        '/categories/$categoryId',
        {'is_active': isActive},
        storeId: storeId,
      );

      print('📡 Toggle Status Response: ${response.statusCode}');
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Category status toggled successfully');

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
        print('❌ Toggle Status Error: ${response.statusCode}');
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
    } catch (e, stackTrace) {
      print('💥 Exception in toggleCategoryStatus: $e');
      print('📍 Stack trace: $stackTrace');

      return ApiResponse<Category>(
        success: false,
        message: 'Error toggling category status: $e',
        status: 500,
        timestamp: DateTime.now().toIso8601String(),
      );
    }
  }
}
