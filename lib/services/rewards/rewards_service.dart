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
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to load rewards: ${response.statusCode}');
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
      if (name.isEmpty || description.isEmpty || pointsCost <= 0) {
        throw Exception('Name, description, and points cost are required.');
      }

      if (image != null) {
        if (!await image.exists()) {
          throw Exception('Image file does not exist.');
        }
        // Use multipart for image upload with reward as JSON field
        final Map<String, dynamic> rewardData = {
          'name': name,
          'description': description,
          'points_cost': pointsCost,
        };

        final Map<String, String> fields = {
          'reward': jsonEncode(rewardData), // Send reward data as JSON string
        };

        final Map<String, File> files = {
          'image': image,
        };

        final response = await _httpClient.postMultipart(
          '/rewards',
          fields,
          files: files,
          storeId: storeId,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonData = jsonDecode(response.body);
          // Handle different response structures
          if (jsonData.containsKey('data')) {
            return RewardModel.fromJson(jsonData['data']);
          } else {
            return RewardModel.fromJson(jsonData);
          }
        } else {
          String errorMessage;
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? 'Failed to create reward';

            // Handle validation errors
            if (errorData.containsKey('errors')) {
              final errors = errorData['errors'];
              if (errors is Map) {
                List<String> errorMessages = [];
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.cast<String>());
                  } else {
                    errorMessages.add(value.toString());
                  }
                });
                errorMessage = errorMessages.join(', ');
              }
            }
          } catch (e) {
            errorMessage = 'Failed to create reward: ${response.statusCode}';
          }
          throw Exception(errorMessage);
        }
      } else {
        // Use regular JSON for no image
        final Map<String, dynamic> data = {
          'name': name,
          'description': description,
          'points_cost': pointsCost,
        };

        final response = await _httpClient.post(
          '/rewards',
          data,
          storeId: storeId,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonData = jsonDecode(response.body);
          // Handle different response structures
          if (jsonData.containsKey('data')) {
            return RewardModel.fromJson(jsonData['data']);
          } else {
            return RewardModel.fromJson(jsonData);
          }
        } else {
          String errorMessage;
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? 'Failed to create reward';

            // Handle validation errors
            if (errorData.containsKey('errors')) {
              final errors = errorData['errors'];
              if (errors is Map) {
                List<String> errorMessages = [];
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.cast<String>());
                  } else {
                    errorMessages.add(value.toString());
                  }
                });
                errorMessage = errorMessages.join(', ');
              }
            }
          } catch (e) {
            errorMessage = 'Failed to create reward: ${response.statusCode}';
          }
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      // Log the full error for debugging
      print('Error creating reward: $e');
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
      if (image != null) {
        // Use multipart for image upload with reward as JSON field
        final Map<String, dynamic> rewardData = {
          'name': name,
          'description': description,
          'points_cost': pointsCost,
        };

        final Map<String, String> fields = {
          'reward': jsonEncode(rewardData), // Send reward data as JSON string
        };

        final Map<String, File> files = {
          'image': image,
        };

        final response = await _httpClient.putMultipart(
          '/rewards/$rewardId',
          fields,
          files: files,
          storeId: storeId,
        );

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          // Handle different response structures
          if (jsonData.containsKey('data')) {
            return RewardModel.fromJson(jsonData['data']);
          } else {
            return RewardModel.fromJson(jsonData);
          }
        } else {
          String errorMessage;
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? 'Failed to update reward';

            // Handle validation errors
            if (errorData.containsKey('errors')) {
              final errors = errorData['errors'];
              if (errors is Map) {
                List<String> errorMessages = [];
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.cast<String>());
                  } else {
                    errorMessages.add(value.toString());
                  }
                });
                errorMessage = errorMessages.join(', ');
              }
            }
          } catch (e) {
            errorMessage = 'Failed to update reward: ${response.statusCode}';
          }
          throw Exception(errorMessage);
        }
      } else {
        // Use regular JSON for no image
        final Map<String, dynamic> data = {
          'name': name,
          'description': description,
          'points_cost': pointsCost,
        };

        final response = await _httpClient.put(
          '/rewards/$rewardId',
          data,
          storeId: storeId,
        );

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          // Handle different response structures
          if (jsonData.containsKey('data')) {
            return RewardModel.fromJson(jsonData['data']);
          } else {
            return RewardModel.fromJson(jsonData);
          }
        } else {
          String errorMessage;
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? 'Failed to update reward';

            // Handle validation errors
            if (errorData.containsKey('errors')) {
              final errors = errorData['errors'];
              if (errors is Map) {
                List<String> errorMessages = [];
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.cast<String>());
                  } else {
                    errorMessages.add(value.toString());
                  }
                });
                errorMessage = errorMessages.join(', ');
              }
            }
          } catch (e) {
            errorMessage = 'Failed to update reward: ${response.statusCode}';
          }
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      // Log the full error for debugging
      print('Error updating reward: $e');
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
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? 'Failed to toggle reward status';
        } catch (e) {
          errorMessage =
              'Failed to toggle reward status: ${response.statusCode}';
        }
        throw Exception(errorMessage);
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

      if (response.statusCode != 200 && response.statusCode != 204) {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Failed to delete reward';
        } catch (e) {
          errorMessage = 'Failed to delete reward: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error deleting reward: $e');
    }
  }
}
