// services/redemption_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/redemption/redemption_model.dart';

class RedemptionService extends GetxService {
  final HttpClient _httpClient = HttpClient.instance;

  static RedemptionService get instance {
    if (!Get.isRegistered<RedemptionService>()) {
      Get.put(RedemptionService());
    }
    return Get.find<RedemptionService>();
  }

  /// Get redemptions with pagination
  Future<RedemptionResponse> getRedemptions({
    int page = 1,
    int limit = 10,
    String? status,
    String? customerId,
    String? rewardId,
  }) async {
    try {
      final Map<String, String> queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Add optional filters
      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status;
      }

      if (customerId != null && customerId.isNotEmpty) {
        queryParameters['customer_id'] = customerId;
      }

      if (rewardId != null && rewardId.isNotEmpty) {
        queryParameters['reward_id'] = rewardId;
      }

      final response = await _httpClient.get(
        '/redemptions',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RedemptionResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch redemptions');
      }
    } catch (e) {
      throw Exception('Error fetching redemptions: $e');
    }
  }

  /// Update redemption status
  Future<bool> updateRedemptionStatus(
    String redemptionId,
    RedemptionStatus status,
  ) async {
    try {
      final request = UpdateRedemptionStatusRequest(status: status);

      final response = await _httpClient.patch(
        '/redemptions/status/$redemptionId',
        request.toJson(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to update redemption status');
      }
    } catch (e) {
      throw Exception('Error updating redemption status: $e');
    }
  }

  /// Get single redemption by ID
  Future<Redemption?> getRedemptionById(String id) async {
    try {
      final response = await _httpClient.get('/redemptions/$id');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return Redemption.fromJson(jsonData['data']);
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error fetching redemption: $e');
    }
  }

  /// Get redemption statistics (if needed)
  Future<Map<String, int>> getRedemptionStats() async {
    try {
      final response = await _httpClient.get('/redemptions/stats');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];
          return {
            'total': data['total'] ?? 0,
            'pending': data['pending'] ?? 0,
            'approved': data['approved'] ?? 0,
            'rejected': data['rejected'] ?? 0,
          };
        }
      }

      return {
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
      };
    } catch (e) {
      // Return empty stats if endpoint doesn't exist
      return {
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
      };
    }
  }

  /// Bulk update redemption status (if needed)
  Future<bool> bulkUpdateRedemptionStatus(
    List<String> redemptionIds,
    RedemptionStatus status,
  ) async {
    try {
      final requestData = {
        'redemption_ids': redemptionIds,
        'status': status.value,
      };

      final response = await _httpClient.patch(
        '/redemptions/bulk-status',
        requestData,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to bulk update redemption status');
      }
    } catch (e) {
      throw Exception('Error bulk updating redemption status: $e');
    }
  }

  /// Search redemptions
  Future<RedemptionResponse> searchRedemptions({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, String> queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
        'search': query,
      };

      final response = await _httpClient.get(
        '/redemptions/search',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RedemptionResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to search redemptions');
      }
    } catch (e) {
      throw Exception('Error searching redemptions: $e');
    }
  }
}
