// services/reward_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:pos/http_client.dart';
import 'package:pos/models/rewards/rewards_model.dart';

class RewardService {
  final HttpClient _httpClient = HttpClient.instance;

  Future<RewardResponse> getRewards({
    int page = 1,
    int limit = 10,
    String? storeId,
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _httpClient.get(
        '/rewards',
        queryParameters: queryParameters,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RewardResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load rewards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching rewards: $e');
    }
  }

  Future<RewardModel> createReward({
    required String name,
    required String description,
    required int pointsCost,
    File? image,
    String? storeId,
  }) async {
    try {
      // For now, we'll send as JSON without image support
      // You'll need to implement multipart support in HttpClient if images are required
      final Map<String, dynamic> data = {
        'name': name,
        'description': description,
        'points_cost': pointsCost,
      };

      // Note: Image upload is not supported with current HttpClient
      // You'll need to add postMultipart method to HttpClient for image support
      if (image != null) {
        throw Exception(
            'Image upload not supported yet. Please implement postMultipart in HttpClient.');
      }

      final response = await _httpClient.post(
        '/rewards',
        data,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RewardModel.fromJson(jsonData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create reward');
      }
    } catch (e) {
      throw Exception('Error creating reward: $e');
    }
  }

  Future<RewardModel> updateReward({
    required String rewardId,
    required String name,
    required String description,
    required int pointsCost,
    File? image,
    String? storeId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'description': description,
        'points_cost': pointsCost,
      };

      // Note: Image upload is not supported with current HttpClient
      // You'll need to add putMultipart method to HttpClient for image support
      if (image != null) {
        throw Exception(
            'Image upload not supported yet. Please implement putMultipart in HttpClient.');
      }

      final response = await _httpClient.put(
        '/rewards/$rewardId',
        data,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RewardModel.fromJson(jsonData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update reward');
      }
    } catch (e) {
      throw Exception('Error updating reward: $e');
    }
  }

  Future<void> toggleRewardStatus({
    required String rewardId,
    required bool isActive,
    String? storeId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'is_active': isActive,
      };

      final response = await _httpClient.patch(
        '/rewards/$rewardId/toggle',
        data,
        storeId: storeId,
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to toggle reward status');
      }
    } catch (e) {
      throw Exception('Error toggling reward status: $e');
    }
  }

  Future<void> deleteReward({
    required String rewardId,
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.delete(
        '/rewards/$rewardId',
        storeId: storeId,
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete reward');
      }
    } catch (e) {
      throw Exception('Error deleting reward: $e');
    }
  }
}
