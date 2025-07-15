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

  // Extract store ID from JWT token
  String? _extractStoreIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Invalid JWT token format');
        return null;
      }

      final payload = parts[1];
      String normalizedPayload = payload;

      // Add padding if needed for proper base64 decoding
      switch (payload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final Map<String, dynamic> decodedPayload = jsonDecode(decodedString);

      print('=== HTTP CLIENT TOKEN EXTRACTION ===');
      print('Token payload: $decodedPayload');

      // Try multiple possible keys for store ID
      final storeId = decodedPayload['store_id']?.toString() ??
          decodedPayload['storeId']?.toString() ??
          decodedPayload['store']?.toString() ??
          decodedPayload['store_uuid']?.toString() ??
          decodedPayload['shop_id']?.toString() ??
          decodedPayload['tenant_id']?.toString();

      print('🏪 EXTRACTED STORE ID: $storeId');
      print('===================================');

      return storeId;
    } catch (e) {
      print('❌ Error extracting store ID from token: $e');
      return null;
    }
  }

  // Get store ID with priority: parameter > storage > token
  String? _getStoreId([String? providedStoreId]) {
    print('=== GET STORE ID ===');
    print('🔍 Provided store ID: $providedStoreId');

    // 1. Use provided store ID if available
    if (providedStoreId != null && providedStoreId.isNotEmpty) {
      print('✅ Using provided store ID: $providedStoreId');
      print('🏪 FINAL STORE ID: $providedStoreId');
      print('===================');
      return providedStoreId;
    }

    // 2. Use StorageService method that includes fallback to token
    final storeId = _storage.getStoreIdWithFallback();
    print('💾 Store ID from storage with fallback: $storeId');

    if (storeId != null && storeId.isNotEmpty) {
      print('✅ Store ID found: $storeId');
      print('🏪 FINAL STORE ID: $storeId');
      print('===================');
      return storeId;
    }

    print('❌ No store ID found from any source');
    print('🏪 FINAL STORE ID: null');
    print('===================');
    return null;
  }

  // Enhanced method to refresh store ID from token
  void refreshStoreIdFromToken() {
    print('=== REFRESH STORE ID FROM TOKEN ===');
    final token = _storage.getToken();
    if (token != null && token.isNotEmpty) {
      final storeId = _storage.extractStoreIdFromToken(token);
      if (storeId != null && storeId.isNotEmpty) {
        _storage.saveStoreId(storeId);
        print('✅ Store ID refreshed from token: $storeId');
      } else {
        print('❌ No store ID found in token');
      }
    } else {
      print('❌ No token available');
    }
    print('==================================');
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

    print('=== DEFAULT HEADERS ===');
    print(
        '🔑 Authorization: ${headers['Authorization'] != null ? 'Bearer ${headers['Authorization']!.substring(7, 37)}...' : 'Not set'}');
    print('🏪 X-Store-ID: ${headers['X-Store-ID'] ?? 'Not set'}');
    print('======================');

    return headers;
  }

  Map<String, String> get _headersWithoutAuth {
    print('=== HEADERS WITHOUT AUTH ===');
    print('🔑 Using headers without auth');
    print('🏪 X-Store-ID: Not included (no auth)');
    print('============================');
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

    print('=== CUSTOM HEADERS ===');
    print('🔍 Custom store ID: $customStoreId');
    print('🏪 Final store ID: $storeId');
    print(
        '🔑 Authorization: ${headers['Authorization'] != null ? 'Bearer ${headers['Authorization']!.substring(7, 37)}...' : 'Not set'}');
    print('🏪 X-Store-ID: ${headers['X-Store-ID'] ?? 'Not set'}');
    print('======================');

    return headers;
  }

  // Method to get headers without store ID (for login, register, etc.)
  Map<String, String> _getHeadersWithoutStoreId({bool requireAuth = true}) {
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

    print('=== HEADERS WITHOUT STORE ID ===');
    print('🔑 RequireAuth: $requireAuth');
    print(
        '🔑 Authorization: ${headers['Authorization'] != null ? 'Bearer ${headers['Authorization']!.substring(7, 37)}...' : 'Not set'}');
    print('🏪 X-Store-ID: Not included (intentionally excluded)');
    print('===============================');

    return headers;
  }

  Future<http.Response> get(String endpoint,
      {bool requireAuth = true, String? storeId}) async {
    try {
      final headers = storeId != null
          ? _getHeadersWithStoreId(storeId, requireAuth: requireAuth)
          : (requireAuth ? _headers : _headersWithoutAuth);

      print('=== HTTP GET REQUEST ===');
      print('📡 Endpoint: $endpoint');
      print('🌐 Full URL: $baseUrl$endpoint');
      print('🏪 Store ID Parameter: ${storeId ?? 'null'}');
      print('🏪 X-Store-ID Header: ${headers['X-Store-ID'] ?? 'Not set'}');
      print('🔑 Headers:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          print('  $key: Bearer ${value.substring(7, 37)}...');
        } else {
          print('  $key: $value');
        }
      });
      print('========================');

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      print('=== HTTP GET RESPONSE ===');
      print('📊 Status code: ${response.statusCode}');
      print('🏪 Used Store ID: ${headers['X-Store-ID'] ?? 'Not used'}');
      print(
          '📝 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      print('=========================');

      return _handleResponse(response);
    } catch (e) {
      print('=== HTTP GET ERROR ===');
      print('❌ Error: $e');
      print('🏪 Store ID: ${storeId ?? 'null'}');
      print('======================');
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

      print('=== HTTP POST REQUEST ===');
      print('📡 Endpoint: $endpoint');
      print('🌐 Full URL: $baseUrl$endpoint');
      print('🏪 Store ID Parameter: ${storeId ?? 'null'}');
      print('🏪 X-Store-ID Header: ${headers['X-Store-ID'] ?? 'Not set'}');
      print('🔑 Headers:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          print('  $key: Bearer ${value.substring(7, 37)}...');
        } else {
          print('  $key: $value');
        }
      });
      print('📝 Data: $data');
      print('=========================');

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      print('=== HTTP POST RESPONSE ===');
      print('📊 Status code: ${response.statusCode}');
      print('🏪 Used Store ID: ${headers['X-Store-ID'] ?? 'Not used'}');
      print(
          '📝 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      print('==========================');

      return _handleResponse(response);
    } catch (e) {
      print('=== HTTP POST ERROR ===');
      print('❌ Error: $e');
      print('🏪 Store ID: ${storeId ?? 'null'}');
      print('=======================');
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

      print('=== HTTP PUT REQUEST ===');
      print('📡 Endpoint: $endpoint');
      print('🌐 Full URL: $baseUrl$endpoint');
      print('🏪 Store ID Parameter: ${storeId ?? 'null'}');
      print('🏪 X-Store-ID Header: ${headers['X-Store-ID'] ?? 'Not set'}');
      print(
          '🏪 Headers contain X-Store-ID: ${headers.containsKey('X-Store-ID')}');
      print('📝 Data: $data');
      print('========================');

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      print('=== HTTP PUT RESPONSE ===');
      print('📊 Status code: ${response.statusCode}');
      print('🏪 Used Store ID: ${headers['X-Store-ID'] ?? 'Not used'}');
      print('=========================');

      return _handleResponse(response);
    } catch (e) {
      print('=== HTTP PUT ERROR ===');
      print('❌ Error: $e');
      print('🏪 Store ID: ${storeId ?? 'null'}');
      print('======================');
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

      print('=== HTTP PATCH REQUEST ===');
      print('📡 Endpoint: $endpoint');
      print('🌐 Full URL: $baseUrl$endpoint');
      print('🏪 Store ID Parameter: ${storeId ?? 'null'}');
      print('🏪 X-Store-ID Header: ${headers['X-Store-ID'] ?? 'Not set'}');
      print(
          '🏪 Headers contain X-Store-ID: ${headers.containsKey('X-Store-ID')}');
      print('📝 Data: $data');
      print('==========================');

      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      print('=== HTTP PATCH RESPONSE ===');
      print('📊 Status code: ${response.statusCode}');
      print('🏪 Used Store ID: ${headers['X-Store-ID'] ?? 'Not used'}');
      print('===========================');

      return _handleResponse(response);
    } catch (e) {
      print('=== HTTP PATCH ERROR ===');
      print('❌ Error: $e');
      print('🏪 Store ID: ${storeId ?? 'null'}');
      print('========================');
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

      print('=== HTTP DELETE REQUEST ===');
      print('📡 Endpoint: $endpoint');
      print('🌐 Full URL: $baseUrl$endpoint');
      print('🏪 Store ID Parameter: ${storeId ?? 'null'}');
      print('🏪 X-Store-ID Header: ${headers['X-Store-ID'] ?? 'Not set'}');
      print(
          '🏪 Headers contain X-Store-ID: ${headers.containsKey('X-Store-ID')}');
      print('===========================');

      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      print('=== HTTP DELETE RESPONSE ===');
      print('📊 Status code: ${response.statusCode}');
      print('🏪 Used Store ID: ${headers['X-Store-ID'] ?? 'Not used'}');
      print('============================');

      return _handleResponse(response);
    } catch (e) {
      print('=== HTTP DELETE ERROR ===');
      print('❌ Error: $e');
      print('🏪 Store ID: ${storeId ?? 'null'}');
      print('=========================');
      throw Exception('Error saat DELETE request: $e');
    }
  }

  http.Response _handleResponse(http.Response response) {
    print('=== RESPONSE HANDLING ===');
    print('📊 Status code: ${response.statusCode}');

    if (response.statusCode == 401) {
      print('🔒 401 Unauthorized - clearing auth data');
      // Token expired atau invalid
      _storage.removeToken();
      _storage.removeUserData();
      _storage.removeStoreId();
      print('🗑️ Cleared store_id from storage');

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
          print('🏪 400 Bad Request - X-Store-ID missing');
          print('❌ Store ID tidak ditemukan di header');

          // Try to refresh store ID from token
          refreshStoreIdFromToken();

          throw Exception(
              'Store ID tidak ditemukan. Silakan coba lagi atau login ulang.');
        }
      } catch (e) {
        print('❌ Error parsing 400 response: $e');
        // If JSON parsing fails, continue with normal error handling
      }
    }

    print('✅ Response handled successfully');
    print('=========================');
    return response;
  }

  // Helper method to debug headers
  void debugHeaders({bool requireAuth = true, String? storeId}) {
    final headers = storeId != null
        ? _getHeadersWithStoreId(storeId, requireAuth: requireAuth)
        : (requireAuth ? _headers : _headersWithoutAuth);

    print('=== DEBUG HEADERS ===');
    print('🏪 Store ID Parameter: ${storeId ?? 'null'}');
    print('🏪 X-Store-ID Header: ${headers['X-Store-ID'] ?? 'Not set'}');
    print('🔑 Headers:');
    headers.forEach((key, value) {
      if (key == 'Authorization') {
        print('  $key: Bearer ${value.substring(7, 37)}...');
      } else {
        print('  $key: $value');
      }
    });
    print('=====================');
  }

  // Method to manually set store ID
  void setStoreId(String storeId) {
    print('=== MANUAL SET STORE ID ===');
    print('🏪 Setting store ID: $storeId');
    _storage.saveStoreId(storeId);
    print('✅ Store ID set successfully');
    print('===========================');
  }

  // Method to get current store ID
  String? getCurrentStoreId() {
    final storeId = _getStoreId();
    print('=== GET CURRENT STORE ID ===');
    print('🏪 Current store ID: $storeId');
    print('============================');
    return storeId;
  }

  // Method to check if store ID is available
  bool hasStoreId() {
    final storeId = _getStoreId();
    final hasId = storeId != null && storeId.isNotEmpty;
    print('=== CHECK STORE ID AVAILABILITY ===');
    print('🏪 Store ID: $storeId');
    print('✅ Has Store ID: $hasId');
    print('==================================');
    return hasId;
  }

  // Method to clear store ID
  void clearStoreId() {
    print('=== CLEAR STORE ID ===');
    _storage.removeStoreId();
    print('🗑️ Store ID cleared from storage');
    print('==================');
  }

  // Method to debug token content
  void debugToken() {
    print('=== DEBUG TOKEN ===');
    final token = _storage.getToken();
    if (token != null && token.isNotEmpty) {
      print('🔑 Token available: Yes');
      print('🔑 Token length: ${token.length}');
      print(
          '🔑 Token preview: ${token.substring(0, token.length > 50 ? 50 : token.length)}...');

      final storeId = _storage.extractStoreIdFromToken(token);
      print('🏪 Store ID from token: $storeId');

      final currentStoreId = _storage.getStoreId();
      print('🏪 Store ID from storage: $currentStoreId');

      final storeIdWithFallback = _storage.getStoreIdWithFallback();
      print('🏪 Store ID with fallback: $storeIdWithFallback');
    } else {
      print('🔑 Token available: No');
    }
    print('===================');
  }
}
