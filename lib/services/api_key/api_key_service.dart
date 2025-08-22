// services/api_key_service.dart
import 'dart:convert';
import 'package:pos/http_client.dart';
import 'package:pos/models/api_key/api_key_model.dart';

class ApiKeyService {
  // Singleton pattern instead of GetX service
  static ApiKeyService? _instance;
  static ApiKeyService get instance {
    _instance ??= ApiKeyService._internal();
    return _instance!;
  }

  ApiKeyService._internal();

  final HttpClient _httpClient = HttpClient.instance;
  final String _endpoint = '/api-keys';

  /// Get all API keys
  Future<List<ApiKeyModel>> getApiKeys() async {
    try {
      final response = await _httpClient.get(_endpoint);

      if (response.statusCode == 200) {
        final apiResponse = ApiKeyResponse.fromJson(jsonDecode(response.body));

        if (apiResponse.success && apiResponse.data != null) {
          final List<dynamic> dataList = apiResponse.data as List<dynamic>;
          return dataList.map((json) => ApiKeyModel.fromJson(json)).toList();
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        throw Exception('Failed to load API keys: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching API keys: $e');
    }
  }

  /// Create new API key
  Future<ApiKeyModel> createApiKey(ApiKeyModel apiKey) async {
    try {
      final response = await _httpClient.post(
        _endpoint,
        apiKey.toJson(),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiKeyResponse.fromJson(jsonDecode(response.body));

        if (apiResponse.success && apiResponse.data != null) {
          final data = apiResponse.data as Map<String, dynamic>;
          final apiKeyData = data['api_key'] as Map<String, dynamic>;
          return ApiKeyModel.fromJson(apiKeyData);
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to create API key');
      }
    } catch (e) {
      throw Exception('Error creating API key: $e');
    }
  }

  /// Update existing API key
  Future<ApiKeyModel> updateApiKey(String id, ApiKeyModel apiKey) async {
    try {
      final response = await _httpClient.put(
        '$_endpoint/$id',
        apiKey.toJson(),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiKeyResponse.fromJson(jsonDecode(response.body));

        if (apiResponse.success && apiResponse.data != null) {
          final data = apiResponse.data as Map<String, dynamic>;
          final apiKeyData = data['api_key'] as Map<String, dynamic>;
          return ApiKeyModel.fromJson(apiKeyData);
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to update API key');
      }
    } catch (e) {
      throw Exception('Error updating API key: $e');
    }
  }

  /// Delete API key
  Future<bool> deleteApiKey(String id) async {
    try {
      final response = await _httpClient.delete('$_endpoint/$id');

      if (response.statusCode == 200) {
        final apiResponse = ApiKeyResponse.fromJson(jsonDecode(response.body));
        return apiResponse.success;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to delete API key');
      }
    } catch (e) {
      throw Exception('Error deleting API key: $e');
    }
  }

  /// Get single API key by ID
  Future<ApiKeyModel?> getApiKeyById(String id) async {
    try {
      final response = await _httpClient.get('$_endpoint/$id');

      if (response.statusCode == 200) {
        final apiResponse = ApiKeyResponse.fromJson(jsonDecode(response.body));

        if (apiResponse.success && apiResponse.data != null) {
          return ApiKeyModel.fromJson(apiResponse.data);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching API key: $e');
    }
  }
}
