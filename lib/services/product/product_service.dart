// services/product_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pos/http_client.dart';
import 'package:pos/models/product/product_model.dart';

class ProductService extends GetxService {
  static ProductService get instance {
    if (!Get.isRegistered<ProductService>()) {
      Get.put(ProductService());
    }
    return Get.find<ProductService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  Future<ProductResponse> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
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

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      // Make API call
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
}
