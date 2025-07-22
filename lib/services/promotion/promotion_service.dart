// promotion_service.dart - Updated service
import 'dart:convert';
import 'package:pos/http_client.dart';
import 'package:pos/models/promotion/promotion_model.dart';

class PromotionService {
  final HttpClient _httpClient = HttpClient.instance;

  Future<List<Promotion>> getPromotions({
    String? storeId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _httpClient.get(
        '/promotions?page=$page&limit=$limit',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotionResponse = PromotionResponse.fromJson(jsonResponse);

        return promotionResponse.promotions;
      } else {
        throw Exception('Failed to load promotions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching promotions: $e');
    }
  }

  Future<Promotion> getPromotionById(String id, {String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '/promotions/$id',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotionResponse =
            SinglePromotionResponse.fromJson(jsonResponse);

        return promotionResponse.promotion;
      } else {
        throw Exception('Failed to load promotion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching promotion: $e');
    }
  }

  Future<Promotion> createPromotion(Map<String, dynamic> promotionData,
      {String? storeId}) async {
    try {
      final response = await _httpClient.post(
        '/promotions',
        promotionData,
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotionResponse =
            SinglePromotionResponse.fromJson(jsonResponse);

        return promotionResponse.promotion;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(
            errorResponse['message'] ?? 'Failed to create promotion');
      }
    } catch (e) {
      throw Exception('Error creating promotion: $e');
    }
  }

  Future<Promotion> updatePromotion(
      String id, Map<String, dynamic> promotionData,
      {String? storeId}) async {
    try {
      final response = await _httpClient.put(
        '/promotions/$id',
        promotionData,
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotionResponse =
            SinglePromotionResponse.fromJson(jsonResponse);

        return promotionResponse.promotion;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(
            errorResponse['message'] ?? 'Failed to update promotion');
      }
    } catch (e) {
      throw Exception('Error updating promotion: $e');
    }
  }

  Future<void> deletePromotion(String id, {String? storeId}) async {
    try {
      final response = await _httpClient.delete(
        '/promotions/$id',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(
            errorResponse['message'] ?? 'Failed to delete promotion');
      }
    } catch (e) {
      throw Exception('Error deleting promotion: $e');
    }
  }

  Future<void> togglePromotionStatus(String id, String newStatus,
      {String? storeId}) async {
    try {
      final response = await _httpClient.patch(
        '/promotions/$id/status',
        {'status': newStatus},
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(
            errorResponse['message'] ?? 'Failed to update promotion status');
      }
    } catch (e) {
      throw Exception('Error updating promotion status: $e');
    }
  }

  Future<List<Promotion>> searchPromotions(String query,
      {String? storeId, int page = 1, int limit = 10}) async {
    try {
      final response = await _httpClient.get(
        '/promotions/search?q=$query&page=$page&limit=$limit',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotionResponse = PromotionResponse.fromJson(jsonResponse);

        return promotionResponse.promotions;
      } else {
        throw Exception('Failed to search promotions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching promotions: $e');
    }
  }

  // Additional method to get all promotions with pagination support
  Future<PromotionResponse> getPromotionsWithMetadata({
    String? storeId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _httpClient.get(
        '/promotions?page=$page&limit=$limit',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotionResponse = PromotionResponse.fromJson(jsonResponse);

        return promotionResponse;
      } else {
        throw Exception('Failed to load promotions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching promotions: $e');
    }
  }
}
