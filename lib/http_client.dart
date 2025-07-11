import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pos/config/config.dart';
import 'package:pos/models/routes.dart';
import 'storage_service.dart';

class HttpClient extends GetxService {
  static HttpClient get instance {
    if (!Get.isRegistered<HttpClient>()) {
      Get.put(HttpClient());
    }
    return Get.find<HttpClient>();
  }

  final String baseUrl = '${Config.publicBackEndUrl}${Config.apiVersion}';

  // Lazy loading storage service
  StorageService get _storage => StorageService.instance;

  Map<String, String> get _headers {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = _storage.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, String> get _headersWithoutAuth {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  Future<http.Response> get(String endpoint, {bool requireAuth = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: requireAuth ? _headers : _headersWithoutAuth,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error saat GET request: $e');
    }
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: requireAuth ? _headers : _headersWithoutAuth,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error saat POST request: $e');
    }
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: requireAuth ? _headers : _headersWithoutAuth,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error saat PUT request: $e');
    }
  }

  // NEW: PATCH method added
  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: requireAuth ? _headers : _headersWithoutAuth,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error saat PATCH request: $e');
    }
  }

  Future<http.Response> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: requireAuth ? _headers : _headersWithoutAuth,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error saat DELETE request: $e');
    }
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      // Token expired atau invalid
      _storage.removeToken();
      _storage.removeUserData();

      // Redirect ke login, tapi cek dulu apakah sudah di halaman login
      if (Get.currentRoute != AppRoutes.login &&
          Get.currentRoute != AppRoutes.onboarding) {
        Get.offAllNamed(AppRoutes.onboarding);
      }

      throw Exception('Sesi telah berakhir, silakan login kembali');
    }

    return response;
  }
}
