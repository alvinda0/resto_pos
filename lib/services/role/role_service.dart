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

  /// Membuat role baru
  Future<RoleResponse> createRole({
    required String name,
    required String description,
    int? position,
    List<String>? permissionIds,
    String? storeId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'description': description,
      };

      // Tambahkan position jika ada
      if (position != null) {
        requestBody['position'] = position;
      }

      // Tambahkan permission IDs jika ada
      if (permissionIds != null && permissionIds.isNotEmpty) {
        requestBody['permission_ids'] = permissionIds;
      }

      final response = await _httpClient.post(
        _endpoint,
        requestBody,
        storeId: storeId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return RoleResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to create role: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating role: $e');
    }
  }

  /// Mengupdate role
  Future<RoleResponse> updateRole({
    required String roleId,
    required String name,
    required String description,
    int? position,
    List<String>? permissionIds,
    String? storeId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'description': description,
      };

      // Tambahkan position jika ada
      if (position != null) {
        requestBody['position'] = position;
      }

      // Tambahkan permission IDs jika ada
      if (permissionIds != null && permissionIds.isNotEmpty) {
        requestBody['permission_ids'] = permissionIds;
      }

      final response = await _httpClient.put(
        '$_endpoint/$roleId',
        requestBody,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RoleResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to update role: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating role: $e');
    }
  }

  /// Menghapus role
  Future<BaseResponse> deleteRole(String roleId, {String? storeId}) async {
    try {
      final response = await _httpClient.delete(
        '$_endpoint/$roleId',
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return BaseResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to delete role: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting role: $e');
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

// Response models untuk CRUD operations
class RoleResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final Role data;

  RoleResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory RoleResponse.fromJson(Map<String, dynamic> json) {
    return RoleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: Role.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'timestamp': timestamp,
      'data': data.toJson(),
    };
  }
}

class BaseResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;

  BaseResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
