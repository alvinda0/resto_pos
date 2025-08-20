// services/product_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pos/http_client.dart';
import 'package:pos/models/product/product_model.dart';
import 'package:pos/storage_service.dart';

class ProductService extends GetxService {
  static ProductService get instance {
    if (!Get.isRegistered<ProductService>()) {
      Get.put(ProductService());
    }
    return Get.find<ProductService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  // Get products with pagination and filters
  Future<ProductResponse> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final response = await _httpClient.get(
        '/products',
        queryParameters: queryParams,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ProductResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting products: $e');
    }
  }

  // Get single product by ID
  Future<Product> getProductById(String id) async {
    try {
      final response = await _httpClient.get(
        '/products/$id',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Product.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting product: $e');
    }
  }

  // Create new product
  Future<ProductCreateResponse> createProduct({
    required String name,
    required String description,
    required int basePrice,
    required String categoryId,
    required bool isAvailable,
    required int position,
    String? recipeId,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_httpClient.baseUrl}/products'),
      );

      // Add headers manually
      final token = Get.find<StorageService>().getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add store ID header if available
      final storeId = _httpClient.getCurrentStoreId();
      if (storeId != null && storeId.isNotEmpty) {
        request.headers['X-Store-ID'] = storeId;
      }

      request.headers['Accept'] = 'application/json';

      // Add product data
      Map<String, dynamic> productData = {
        'name': name,
        'description': description,
        'base_price': basePrice,
        'category_id': categoryId,
        'is_available': isAvailable,
        'position': position,
      };

      if (recipeId != null) {
        productData['recipe_id'] = recipeId;
      }

      request.fields['product'] = jsonEncode(productData);

      // Add image if provided
      if (imageFile != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return ProductCreateResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create product');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  // Update product
  Future<ProductUpdateResponse> updateProduct({
    required String id,
    required String name,
    required String description,
    required int basePrice,
    required String categoryId,
    required bool isAvailable,
    required int position,
    String? recipeId,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${_httpClient.baseUrl}/products/$id'),
      );

      // Add headers manually
      final token = Get.find<StorageService>().getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add store ID header if available
      final storeId = _httpClient.getCurrentStoreId();
      if (storeId != null && storeId.isNotEmpty) {
        request.headers['X-Store-ID'] = storeId;
      }

      request.headers['Accept'] = 'application/json';

      // Add product data
      Map<String, dynamic> productData = {
        'name': name,
        'description': description,
        'base_price': basePrice,
        'category_id': categoryId,
        'is_available': isAvailable,
        'position': position,
      };

      if (recipeId != null) {
        productData['recipe_id'] = recipeId;
      }

      request.fields['product'] = jsonEncode(productData);

      // Add image if provided
      if (imageFile != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ProductUpdateResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update product');
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    try {
      final response = await _httpClient.delete(
        '/products/$id',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete product');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  // Get categories for dropdown
  Future<List<ProductCategory>> getCategories() async {
    try {
      final response = await _httpClient.get(
        '/categories',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> categoriesData = jsonData['data'] ?? [];
        return categoriesData
            .map((category) => ProductCategory.fromJson(category))
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error getting categories: $e');
    }
  }
}
