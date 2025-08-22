import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/points/points_model.dart';

class PointConfigService extends GetxService {
  final HttpClient _httpClient = HttpClient.instance;

  static PointConfigService get instance {
    if (!Get.isRegistered<PointConfigService>()) {
      Get.put(PointConfigService());
    }
    return Get.find<PointConfigService>();
  }

  // Get all point configs with pagination
  Future<PointConfigResponse> getPointConfigs({
    int page = 1,
    int limit = 10,
    String? storeId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _httpClient.get(
        '/point-configs',
        queryParameters: queryParams,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PointConfigResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to get point configs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting point configs: $e');
    }
  }

  // Create new point config
  Future<PointConfig> createPointConfig({
    required PointConfigRequest request,
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.post(
        '/point-configs',
        request.toJson(),
        storeId: storeId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final pointConfigResponse = PointConfigResponse.fromJson(responseData);

        if (pointConfigResponse.data.isNotEmpty) {
          return pointConfigResponse.data.first;
        } else {
          throw Exception('No data returned from create point config');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to create point config');
      }
    } catch (e) {
      throw Exception('Error creating point config: $e');
    }
  }

  // Update point config
  Future<PointConfig> updatePointConfig({
    required String id,
    required PointConfigRequest request,
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.put(
        '/point-configs/$id',
        request.toJson(),
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final pointConfigResponse = PointConfigResponse.fromJson(responseData);

        if (pointConfigResponse.data.isNotEmpty) {
          return pointConfigResponse.data.first;
        } else {
          throw Exception('No data returned from update point config');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to update point config');
      }
    } catch (e) {
      throw Exception('Error updating point config: $e');
    }
  }

  // Toggle point config active status
  Future<bool> togglePointConfigStatus({
    required String id,
    required bool isActive,
    String? storeId,
  }) async {
    try {
      final request = PointConfigToggleRequest(isActive: isActive);

      final response = await _httpClient.patch(
        '/point-configs/$id/toggle',
        request.toJson(),
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to toggle point config status');
      }
    } catch (e) {
      throw Exception('Error toggling point config status: $e');
    }
  }

  // Delete point config
  Future<bool> deletePointConfig({
    required String id,
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.delete(
        '/point-configs/$id',
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to delete point config');
      }
    } catch (e) {
      throw Exception('Error deleting point config: $e');
    }
  }

  // Get single point config by ID
  Future<PointConfig> getPointConfigById({
    required String id,
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.get(
        '/point-configs/$id',
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final pointConfigResponse = PointConfigResponse.fromJson(responseData);

        if (pointConfigResponse.data.isNotEmpty) {
          return pointConfigResponse.data.first;
        } else {
          throw Exception('Point config not found');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get point config');
      }
    } catch (e) {
      throw Exception('Error getting point config: $e');
    }
  }
}
