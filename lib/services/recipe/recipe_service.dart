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
