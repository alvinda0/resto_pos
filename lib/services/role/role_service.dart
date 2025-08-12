import 'dart:convert';

import 'package:pos/http_client.dart';
import 'package:pos/models/role/role_model.dart';

class RoleService {
  final HttpClient _httpClient = HttpClient.instance;

  static const String _endpoint = '/roles';

  /// Mengambil daftar role dengan pagination dan pencarian
  Future<RoleListResponse> getRoles({
    int page = 1,
    int limit = 10,
    String? search,
    String? storeId,
  }) async {
    try {
      // Siapkan query parameters
      final Map<String, String> queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Tambahkan search jika ada
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await _httpClient.get(
        _endpoint,
        queryParameters: queryParameters,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RoleListResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load roles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching roles: $e');
    }
  }

  /// Mengambil detail role berdasarkan ID
  Future<Role> getRoleById(String roleId, {String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '$_endpoint/$roleId',
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Role.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load role: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching role: $e');
    }
  }

  /// Mengambil role dengan pagination yang dapat dikustomisasi
  Future<RoleListResponse> getRolesWithCustomParams({
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
    Map<String, String>? additionalParams,
    String? storeId,
  }) async {
    try {
      final Map<String, String> queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Tambahkan parameter opsional
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParameters['sort_by'] = sortBy;
      }

      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParameters['sort_order'] = sortOrder;
      }

      // Tambahkan parameter tambahan jika ada
      if (additionalParams != null) {
        queryParameters.addAll(additionalParams);
      }

      final response = await _httpClient.get(
        _endpoint,
        queryParameters: queryParameters,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RoleListResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load roles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching roles: $e');
    }
  }
}
