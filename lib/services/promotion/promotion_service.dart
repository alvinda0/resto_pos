import 'dart:convert';
import 'package:pos/http_client.dart';
import 'package:pos/models/promotion/promotion_model.dart';

class PromotionService {
  final HttpClient _httpClient = HttpClient.instance;

  Future<List<Promotion>> getPromotions({String? storeId}) async {
    try {
      print('=== PROMOTION SERVICE - GET PROMOTIONS ===');

      final response = await _httpClient.get(
        '/promotions',
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');
      print('📝 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotionResponse = PromotionResponse.fromJson(jsonResponse);

        print(
            '✅ Successfully retrieved ${promotionResponse.promotions.length} promotions');
        return promotionResponse.promotions;
      } else {
        print('❌ Failed to get promotions: ${response.statusCode}');
        throw Exception('Failed to load promotions: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getPromotions: $e');
      throw Exception('Error fetching promotions: $e');
    }
  }

  Future<Promotion> getPromotionById(String id, {String? storeId}) async {
    try {
      print('=== PROMOTION SERVICE - GET PROMOTION BY ID ===');
      print('🆔 Promotion ID: $id');

      final response = await _httpClient.get(
        '/promotions/$id',
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotion = Promotion.fromJson(jsonResponse['data']);

        print('✅ Successfully retrieved promotion: ${promotion.name}');
        return promotion;
      } else {
        print('❌ Failed to get promotion: ${response.statusCode}');
        throw Exception('Failed to load promotion: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getPromotionById: $e');
      throw Exception('Error fetching promotion: $e');
    }
  }

  Future<Promotion> createPromotion(Map<String, dynamic> promotionData,
      {String? storeId}) async {
    try {
      print('=== PROMOTION SERVICE - CREATE PROMOTION ===');
      print('📝 Promotion data: $promotionData');

      final response = await _httpClient.post(
        '/promotions',
        promotionData,
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotion = Promotion.fromJson(jsonResponse['data']);

        print('✅ Successfully created promotion: ${promotion.name}');
        return promotion;
      } else {
        print('❌ Failed to create promotion: ${response.statusCode}');
        final errorResponse = jsonDecode(response.body);
        throw Exception(
            errorResponse['message'] ?? 'Failed to create promotion');
      }
    } catch (e) {
      print('❌ Error in createPromotion: $e');
      throw Exception('Error creating promotion: $e');
    }
  }

  Future<Promotion> updatePromotion(
      String id, Map<String, dynamic> promotionData,
      {String? storeId}) async {
    try {
      print('=== PROMOTION SERVICE - UPDATE PROMOTION ===');
      print('🆔 Promotion ID: $id');
      print('📝 Promotion data: $promotionData');

      final response = await _httpClient.put(
        '/promotions/$id',
        promotionData,
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotion = Promotion.fromJson(jsonResponse['data']);

        print('✅ Successfully updated promotion: ${promotion.name}');
        return promotion;
      } else {
        print('❌ Failed to update promotion: ${response.statusCode}');
        final errorResponse = jsonDecode(response.body);
        throw Exception(
            errorResponse['message'] ?? 'Failed to update promotion');
      }
    } catch (e) {
      print('❌ Error in updatePromotion: $e');
      throw Exception('Error updating promotion: $e');
    }
  }

  Future<void> deletePromotion(String id, {String? storeId}) async {
    try {
      print('=== PROMOTION SERVICE - DELETE PROMOTION ===');
      print('🆔 Promotion ID: $id');

      final response = await _httpClient.delete(
        '/promotions/$id',
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Successfully deleted promotion');
      } else {
        print('❌ Failed to delete promotion: ${response.statusCode}');
        final errorResponse = jsonDecode(response.body);
        throw Exception(
            errorResponse['message'] ?? 'Failed to delete promotion');
      }
    } catch (e) {
      print('❌ Error in deletePromotion: $e');
      throw Exception('Error deleting promotion: $e');
    }
  }

  Future<void> togglePromotionStatus(String id, String newStatus,
      {String? storeId}) async {
    try {
      print('=== PROMOTION SERVICE - TOGGLE STATUS ===');
      print('🆔 Promotion ID: $id');
      print('🔄 New status: $newStatus');

      final response = await _httpClient.patch(
        '/promotions/$id/status',
        {'status': newStatus},
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Successfully updated promotion status');
      } else {
        print('❌ Failed to update promotion status: ${response.statusCode}');
        final errorResponse = jsonDecode(response.body);
        throw Exception(
            errorResponse['message'] ?? 'Failed to update promotion status');
      }
    } catch (e) {
      print('❌ Error in togglePromotionStatus: $e');
      throw Exception('Error updating promotion status: $e');
    }
  }

  Future<List<Promotion>> searchPromotions(String query,
      {String? storeId}) async {
    try {
      print('=== PROMOTION SERVICE - SEARCH PROMOTIONS ===');
      print('🔍 Search query: $query');

      final response = await _httpClient.get(
        '/promotions/search?q=$query',
        requireAuth: true,
        storeId: storeId,
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotionResponse = PromotionResponse.fromJson(jsonResponse);

        print(
            '✅ Successfully searched promotions: ${promotionResponse.promotions.length} results');
        return promotionResponse.promotions;
      } else {
        print('❌ Failed to search promotions: ${response.statusCode}');
        throw Exception('Failed to search promotions: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in searchPromotions: $e');
      throw Exception('Error searching promotions: $e');
    }
  }
}
