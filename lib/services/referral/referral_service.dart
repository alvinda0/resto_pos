// services/referral_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/referral/referral_model.dart';

class ReferralService extends GetxService {
  static ReferralService get instance {
    if (!Get.isRegistered<ReferralService>()) {
      Get.put(ReferralService());
    }
    return Get.find<ReferralService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  // GET all referrals with pagination
  Future<ReferralResponse> getAllReferrals({
    int page = 1,
    int limit = 10,
    String? storeId,
  }) async {
    try {
      String url = '/referrals?page=$page&limit=$limit';
      if (storeId != null && storeId.isNotEmpty) {
        url += '&store_id=$storeId';
      }

      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ReferralResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch referrals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching referrals: $e');
    }
  }

  // GET referral by ID
  Future<ReferralModel> getReferralById(String id) async {
    try {
      final response = await _httpClient.get('/referrals/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ReferralModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to fetch referral: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching referral: $e');
    }
  }

  // CREATE new referral - Updated to match new API
  Future<ReferralModel> createReferral({
    required String customerId,
    required String referralName,
    required String referralPhone,
    required String referralEmail,
    required String commissionType,
    required double commissionRate,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'customer_id': customerId,
        'referral_name': referralName,
        'referral_phone': referralPhone,
        'referral_email': referralEmail,
        'commission_type': commissionType,
        'commission_rate': commissionRate,
      };

      final response = await _httpClient.post('/referrals', data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ReferralModel.fromJson(jsonResponse['data']);
      } else {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ??
            'Failed to create referral: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating referral: $e');
    }
  }

  // UPDATE referral - Updated to match new API
  Future<bool> updateReferral(
    String id, {
    String? referralName,
    String? referralPhone,
    String? referralEmail,
    String? commissionType,
    double? commissionRate,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (referralName != null) data['referral_name'] = referralName;
      if (referralPhone != null) data['referral_phone'] = referralPhone;
      if (referralEmail != null) data['referral_email'] = referralEmail;
      if (commissionType != null) data['commission_type'] = commissionType;
      if (commissionRate != null) data['commission_rate'] = commissionRate;

      final response = await _httpClient.patch('/referrals/$id', data);

      if (response.statusCode == 200) {
        return true;
      } else {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ??
            'Failed to update referral: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating referral: $e');
    }
  }

  // DELETE referral
  Future<bool> deleteReferral(String id) async {
    try {
      final response = await _httpClient.delete('/referrals/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ??
            'Failed to delete referral: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting referral: $e');
    }
  }

  // GET referrals by store ID
  Future<ReferralResponse> getReferralsByStoreId(String storeId) async {
    try {
      final response = await _httpClient.get('/referrals?store_id=$storeId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ReferralResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to fetch referrals by store: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching referrals by store: $e');
    }
  }

  // GET referrals by customer ID
  Future<ReferralResponse> getReferralsByCustomerId(String customerId) async {
    try {
      final response =
          await _httpClient.get('/referrals?customer_id=$customerId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ReferralResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to fetch referrals by customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching referrals by customer: $e');
    }
  }

  // GET referral by code
  Future<ReferralModel> getReferralByCode(String code) async {
    try {
      final response = await _httpClient.get('/referrals?code=$code');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final referrals = ReferralResponse.fromJson(jsonResponse);

        if (referrals.data.isNotEmpty) {
          return referrals.data.first;
        } else {
          throw Exception('Referral with code $code not found');
        }
      } else {
        throw Exception(
            'Failed to fetch referral by code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching referral by code: $e');
    }
  }

  // GET referral statistics (if needed)
  Future<Map<String, dynamic>> getReferralStats() async {
    try {
      final response = await _httpClient.get('/referrals/stats');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? {};
      } else {
        throw Exception(
            'Failed to fetch referral stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching referral stats: $e');
    }
  }

  // Validate referral code
  Future<bool> validateReferralCode(String code) async {
    try {
      final response = await _httpClient.get('/referrals/validate/$code');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']['valid'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Generate QR code for referral (if API supports it)
  Future<String> generateQRCode(String referralId) async {
    try {
      final response =
          await _httpClient.post('/referrals/$referralId/qr-code', {});

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']['qr_code_image'] ?? '';
      } else {
        throw Exception('Failed to generate QR code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating QR code: $e');
    }
  }
}
