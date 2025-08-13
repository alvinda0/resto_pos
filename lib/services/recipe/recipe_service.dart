import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pos/http_client.dart';
import 'package:pos/models/recipe/recipe_model.dart';

class RecipeService extends GetxService {
  static RecipeService get instance {
    if (!Get.isRegistered<RecipeService>()) {
      Get.put(RecipeService());
    }
    return Get.find<RecipeService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  Future<RecipeResponse> getRecipes({
    int page = 1,
    int limit = 10,
    String? search,
    String? storeId,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Add search parameter if provided
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await _httpClient.get(
        '/recipes',
        queryParameters: queryParameters,
        storeId: storeId,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return RecipeResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }

  Future<Recipe?> getRecipeById(String id, {String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '/recipes/$id',
        storeId: storeId,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return Recipe.fromJson(responseData['data']);
        }
        return null;
      } else {
        throw Exception('Failed to load recipe: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recipe: $e');
    }
  }

  Future<Recipe> createRecipe({
    required String name,
    required String description,
    required List<Map<String, dynamic>> items,
    String? storeId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'description': description,
        'items': items,
      };

      final response = await _httpClient.post(
        '/recipes',
        requestBody,
        storeId: storeId,
        requireAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Response body is empty');
        }

        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        // Check if response is successful
        if (jsonResponse['success'] == false) {
          throw Exception(jsonResponse['message'] ?? 'Failed to create recipe');
        }

        return Recipe.fromJson(jsonResponse['data']);
      } else {
        // Try to parse error message from response
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          throw Exception(
              errorResponse['message'] ?? 'Failed to create recipe');
        } catch (e) {
          throw Exception('Failed to create recipe (${response.statusCode})');
        }
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Silakan coba lagi.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Format data tidak valid.');
      }

      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Recipe> updateRecipe({
    required String id,
    required String name,
    required String description,
    required List<Map<String, dynamic>> items,
    String? storeId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'description': description,
        'items': items,
      };

      final response = await _httpClient.put(
        '/recipes/$id',
        requestBody,
        storeId: storeId,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final String responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Response body is empty');
        }

        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        // Check if response is successful
        if (jsonResponse['success'] == false) {
          throw Exception(jsonResponse['message'] ?? 'Failed to update recipe');
        }

        return Recipe.fromJson(jsonResponse['data']);
      } else {
        // Try to parse error message from response
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          throw Exception(
              errorResponse['message'] ?? 'Failed to update recipe');
        } catch (e) {
          throw Exception('Failed to update recipe (${response.statusCode})');
        }
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Silakan coba lagi.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Format data tidak valid.');
      }

      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Delete recipe
  Future<void> deleteRecipe(String id, {String? storeId}) async {
    try {
      final response = await _httpClient.delete(
        '/recipes/$id',
        storeId: storeId,
        requireAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final String responseBody = response.body;
        if (responseBody.isNotEmpty) {
          final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

          // Check if response is successful
          if (jsonResponse['success'] == false) {
            throw Exception(
                jsonResponse['message'] ?? 'Failed to delete recipe');
          }
        }
        // Success - recipe deleted
      } else {
        // Try to parse error message from response
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          throw Exception(
              errorResponse['message'] ?? 'Failed to delete recipe');
        } catch (e) {
          throw Exception('Failed to delete recipe (${response.statusCode})');
        }
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Silakan coba lagi.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Format data tidak valid.');
      }

      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Method to search recipes
  Future<RecipeResponse> searchRecipes({
    required String query,
    int page = 1,
    int limit = 10,
    String? storeId,
  }) async {
    return await getRecipes(
      page: page,
      limit: limit,
      search: query,
      storeId: storeId,
    );
  }

  // Method to refresh recipes (force reload)
  Future<RecipeResponse> refreshRecipes({
    int page = 1,
    int limit = 10,
    String? search,
    String? storeId,
  }) async {
    return await getRecipes(
      page: page,
      limit: limit,
      search: search,
      storeId: storeId,
    );
  }
}
