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

  // Get store ID with priority: parameter > storage > token
  String? _getStoreId([String? providedStoreId]) {
    // 1. Use provided store ID if available
    if (providedStoreId != null && providedStoreId.isNotEmpty) {
      return providedStoreId;
    }

    // 2. Use StorageService method that includes fallback to token
    final storeId = _storage.getStoreIdWithFallback();

    if (storeId != null && storeId.isNotEmpty) {
      return storeId;
    }

    return null;
  }

  // Enhanced method to refresh store ID from token
  void refreshStoreIdFromToken() {
    final token = _storage.getToken();
    if (token != null && token.isNotEmpty) {
      final storeId = _storage.extractStoreIdFromToken(token);
      if (storeId != null && storeId.isNotEmpty) {
        _storage.saveStoreId(storeId);
      }
    }
  }

  Map<String, String> get _headers {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = _storage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Add X-Store-ID header if available
    final storeId = _getStoreId();
    if (storeId != null && storeId.isNotEmpty) {
      headers['X-Store-ID'] = storeId;
    }

    return headers;
  }

  Map<String, String> get _headersWithoutAuth {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  // Method to get headers with custom store ID
  Map<String, String> _getHeadersWithStoreId(String? customStoreId,
      {bool requireAuth = true}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = _storage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    // Use the improved _getStoreId method
    final storeId = _getStoreId(customStoreId);
    if (storeId != null && storeId.isNotEmpty) {
      headers['X-Store-ID'] = storeId;
    }

    return headers;
  }

  // Helper method to build URI with query parameters
  Uri _buildUri(String endpoint, {Map<String, String>? queryParameters}) {
    final uri = Uri.parse('$baseUrl$endpoint');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }

    return uri;
  }

  Future<http.Response> get(String endpoint,
      {bool requireAuth = true,
      String? storeId,
      Map<String, String>? queryParameters}) async {
    try {
      final headers = storeId != null
          ? _getHeadersWithStoreId(storeId, requireAuth: requireAuth)
          : (requireAuth ? _headers : _headersWithoutAuth);

      final uri = _buildUri(endpoint, queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: headers,
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
    String? storeId,
  }) async {
    try {
      final headers = storeId != null
          ? _getHeadersWithStoreId(storeId, requireAuth: requireAuth)
          : (requireAuth ? _headers : _headersWithoutAuth);

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
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
    String? storeId,
  }) async {
    try {
      final headers = storeId != null
          ? _getHeadersWithStoreId(storeId, requireAuth: requireAuth)
          : (requireAuth ? _headers : _headersWithoutAuth);

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error saat PUT request: $e');
    }
  }

  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = true,
    String? storeId,
  }) async {
    try {
      final headers = storeId != null
          ? _getHeadersWithStoreId(storeId, requireAuth: requireAuth)
          : (requireAuth ? _headers : _headersWithoutAuth);

      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
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
    String? storeId,
  }) async {
    try {
      final headers = storeId != null
          ? _getHeadersWithStoreId(storeId, requireAuth: requireAuth)
          : (requireAuth ? _headers : _headersWithoutAuth);

      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
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
      _storage.removeStoreId();

      // Redirect ke login
      if (Get.currentRoute != AppRoutes.login &&
          Get.currentRoute != AppRoutes.onboarding) {
        Get.offAllNamed(AppRoutes.onboarding);
      }

      throw Exception('Sesi telah berakhir, silakan login kembali');
    }

    // Handle missing X-Store-ID header error
    if (response.statusCode == 400) {
      try {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message']?.toString() ?? '';

        if (message.contains('X-Store-ID') ||
            message.contains('store_id') ||
            message.contains('Store ID')) {
          // Try to refresh store ID from token
          refreshStoreIdFromToken();

          throw Exception(
              'Store ID tidak ditemukan. Silakan coba lagi atau login ulang.');
        }
      } catch (e) {
        // If JSON parsing fails, continue with normal error handling
      }
    }

    return response;
  }

  // Helper method to debug headers
  void debugHeaders({bool requireAuth = true, String? storeId}) {
    // Debug headers functionality can be implemented here if needed
  }

  // Method to manually set store ID
  void setStoreId(String storeId) {
    _storage.saveStoreId(storeId);
  }

  // Method to get current store ID
  String? getCurrentStoreId() {
    final storeId = _getStoreId();
    return storeId;
  }

  // Method to check if store ID is available
  bool hasStoreId() {
    final storeId = _getStoreId();
    final hasId = storeId != null && storeId.isNotEmpty;
    return hasId;
  }

  // Method to clear store ID
  void clearStoreId() {
    _storage.removeStoreId();
  }

  // Method to debug token content
  void debugToken() {
    final token = _storage.getToken();
    if (token != null && token.isNotEmpty) {
      _storage.extractStoreIdFromToken(token);
      _storage.getStoreId();
      _storage.getStoreIdWithFallback();

      // Debug token functionality can be implemented here if needed
    }
  }
}
