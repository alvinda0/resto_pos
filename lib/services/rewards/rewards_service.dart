// services/reward_service.dart
import 'dart:convert';

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
}
