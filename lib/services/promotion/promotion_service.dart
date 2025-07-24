// promotion_service.dart - Fixed service
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
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ??
            'Failed to load promotions: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
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
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ??
            'Failed to load promotion: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error fetching promotion: $e');
    }
  }

  Future<Promotion> createPromotion(Map<String, dynamic> promotionData,
      {String? storeId}) async {
    try {
      // Validate required fields
      _validatePromotionData(promotionData);

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
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error creating promotion: $e');
    }
  }

  Future<Promotion> updatePromotion(
      String id, Map<String, dynamic> promotionData,
      {String? storeId}) async {
    try {
      // Validate required fields
      _validatePromotionData(promotionData);

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
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error updating promotion: $e');
    }
  }

  Future<bool> deletePromotion(String id, {String? storeId}) async {
    try {
      final response = await _httpClient.delete(
        '/promotions/$id',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(
            errorResponse['message'] ?? 'Failed to delete promotion');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error deleting promotion: $e');
    }
  }

  Future<bool> togglePromotionStatus(String id, String newStatus,
      {String? storeId}) async {
    try {
      final response = await _httpClient.patch(
        '/promotions/$id/status',
        {'status': newStatus},
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(
            errorResponse['message'] ?? 'Failed to update promotion status');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error updating promotion status: $e');
    }
  }

  Future<List<Promotion>> searchPromotions(String query,
      {String? storeId, int page = 1, int limit = 10}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await _httpClient.get(
        '/promotions/search?q=$encodedQuery&page=$page&limit=$limit',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotionResponse = PromotionResponse.fromJson(jsonResponse);

        return promotionResponse.promotions;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ??
            'Failed to search promotions: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
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
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ??
            'Failed to load promotions: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error fetching promotions: $e');
    }
  }

  // Get promotions by status filter
  Future<List<Promotion>> getPromotionsByStatus(String status,
      {String? storeId, int page = 1, int limit = 10}) async {
    try {
      final response = await _httpClient.get(
        '/promotions?status=$status&page=$page&limit=$limit',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final promotionResponse = PromotionResponse.fromJson(jsonResponse);

        return promotionResponse.promotions;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ??
            'Failed to load promotions by status: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error fetching promotions by status: $e');
    }
  }

  // Validate promotion data before sending to API
  void _validatePromotionData(Map<String, dynamic> data) {
    final List<String> errors = [];

    // Required fields validation
    if (data['name'] == null || data['name'].toString().trim().isEmpty) {
      errors.add('Nama promo harus diisi');
    }

    if (data['description'] == null ||
        data['description'].toString().trim().isEmpty) {
      errors.add('Deskripsi promo harus diisi');
    }

    if (data['discount_type'] == null ||
        !['percent', 'fixed'].contains(data['discount_type'])) {
      errors.add('Jenis diskon harus dipilih (percent atau fixed)');
    }

    if (data['discount_value'] == null || data['discount_value'] <= 0) {
      errors.add('Nilai diskon harus lebih dari 0');
    }

    if (data['time_type'] == null ||
        !['daily', 'period'].contains(data['time_type'])) {
      errors.add('Jenis waktu harus dipilih (daily atau period)');
    }

    if (data['start_date'] == null) {
      errors.add('Tanggal mulai harus diisi');
    }

    if (data['time_type'] == 'period' && data['end_date'] == null) {
      errors.add('Tanggal berakhir harus diisi untuk tipe periode');
    }

    if (data['start_time'] == null) {
      errors.add('Waktu mulai harus diisi');
    }

    if (data['end_time'] == null) {
      errors.add('Waktu berakhir harus diisi');
    }

    if (data['promo_code'] == null ||
        data['promo_code'].toString().trim().isEmpty) {
      errors.add('Kode promo harus diisi');
    }

    if (data['usage_limit'] == null || data['usage_limit'] <= 0) {
      errors.add('Batas penggunaan harus lebih dari 0');
    }

    // Specific validations
    if (data['discount_type'] == 'percent' && data['discount_value'] > 100) {
      errors.add('Diskon persentase tidak boleh lebih dari 100%');
    }

    if (data['max_discount'] != null && data['max_discount'] <= 0) {
      errors.add('Maksimal diskon harus lebih dari 0');
    }

    // Date validation for period type
    if (data['time_type'] == 'period' &&
        data['start_date'] != null &&
        data['end_date'] != null) {
      try {
        final startDate = DateTime.parse(data['start_date']);
        final endDate = DateTime.parse(data['end_date']);

        if (endDate.isBefore(startDate)) {
          errors.add('Tanggal berakhir harus setelah tanggal mulai');
        }
      } catch (e) {
        errors.add('Format tanggal tidak valid');
      }
    }

    // Time validation
    if (data['start_time'] != null && data['end_time'] != null) {
      try {
        final startTime = DateTime.parse(data['start_time']);
        final endTime = DateTime.parse(data['end_time']);

        if (endTime.isBefore(startTime)) {
          errors.add('Waktu berakhir harus setelah waktu mulai');
        }
      } catch (e) {
        errors.add('Format waktu tidak valid');
      }
    }

    if (errors.isNotEmpty) {
      throw Exception('Validasi gagal:\n${errors.join('\n')}');
    }
  }
}
