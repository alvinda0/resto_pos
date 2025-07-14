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

  // GET all referrals
  Future<ReferralResponse> getAllReferrals() async {
    try {
      final response = await _httpClient.get('/referrals');

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

  // CREATE new referral
  Future<ReferralModel> createReferral({
    required String storeId,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String code,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'store_id': storeId,
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_email': customerEmail,
        'code': code,
      };

      final response = await _httpClient.post('/referrals', data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ReferralModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to create referral: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating referral: $e');
    }
  }

  // UPDATE referral
  Future<ReferralModel> updateReferral(
    String id, {
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? code,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (customerName != null) data['customer_name'] = customerName;
      if (customerPhone != null) data['customer_phone'] = customerPhone;
      if (customerEmail != null) data['customer_email'] = customerEmail;
      if (code != null) data['code'] = code;

      final response = await _httpClient.put('/referrals/$id', data);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ReferralModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to update referral: ${response.statusCode}');
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
        throw Exception('Failed to delete referral: ${response.statusCode}');
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
}
