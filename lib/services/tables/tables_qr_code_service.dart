// services/qr_code_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/tables/model_tables.dart';
import 'package:pos/storage_service.dart';

class QrCodeService extends GetxService {
  static QrCodeService get instance => Get.find<QrCodeService>();

  final HttpClient _httpClient = HttpClient.instance;
  final StorageService _storage = StorageService.instance;

  // Get store ID from storage or token
  String? get _storeId {
    String? storeId = _storage.getString('store_id');
    if (storeId?.isNotEmpty == true) return storeId;

    final token = _storage.getToken();
    if (token != null) {
      storeId = _extractStoreIdFromToken(token);
      if (storeId != null) _storage.setString('store_id', storeId);
    }
    return storeId;
  }

  // Extract store ID from JWT token
  String? _extractStoreIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];
      // Add base64 padding
      payload += '=' * (4 - payload.length % 4);

      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
      return decoded['store_id']?.toString() ??
          decoded['storeId']?.toString() ??
          decoded['store']?.toString();
    } catch (e) {
      return null;
    }
  }

  // Get all QR codes
  Future<List<QrCodeModel>> getQrCodes() async {
    try {
      final response = await _httpClient.get('/qr-codes', storeId: _storeId);

      if (response.statusCode != 200) {
        throw Exception(_extractErrorMessage(response));
      }

      final data = jsonDecode(response.body);
      final qrCodes = _extractQrCodesFromResponse(data);

      return qrCodes.map((item) => QrCodeModel.fromJson(item)).toList();
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  // Bulk create QR codes for tables
  Future<List<QrCodeModel>> createBulkQrCodes({
    required int tableCount,
    required int startNumber,
    required String type,
    required String menuUrl,
    DateTime? expiresAt,
  }) async {
    try {
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'table_count': tableCount,
        'start_number': startNumber,
        'type': type,
        'menu_url': menuUrl,
      };

      // Add expiry date if provided
      if (expiresAt != null) {
        requestData['expires_at'] = expiresAt.toIso8601String();
      }

      // Make POST request to bulk endpoint
      final response = await _httpClient.post(
        '/qr-codes/bulk',
        requestData,
        storeId: _storeId,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_extractErrorMessage(response));
      }

      final data = jsonDecode(response.body);

      // Extract QR codes from response
      final qrCodesData = _extractQrCodesFromBulkResponse(data);

      // Convert to QrCodeModel objects
      final qrCodes =
          qrCodesData.map((item) => QrCodeModel.fromJson(item)).toList();

      return qrCodes;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to create bulk QR codes: $e');
    }
  }

  // Extract QR codes from bulk creation response
  List<dynamic> _extractQrCodesFromBulkResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Check for data field first (as shown in your API response)
      if (data.containsKey('data') && data['data'] is List) {
        return data['data'] as List<dynamic>;
      }

      // Fallback to other possible structures
      if (data.containsKey('qrcodes') && data['qrcodes'] is List) {
        return data['qrcodes'] as List<dynamic>;
      }

      if (data.containsKey('qr_codes') && data['qr_codes'] is List) {
        return data['qr_codes'] as List<dynamic>;
      }
    }

    // If data itself is a list
    if (data is List) {
      return data;
    }

    return [];
  }

  // Extract QR codes list from various response structures
  List<dynamic> _extractQrCodesFromResponse(dynamic data) {
    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      // Try different possible structures
      final possiblePaths = [
        ['data', 'qrcodes'],
        ['data', 'qr_codes'],
        ['qrcodes'],
        ['qr_codes'],
        ['data']
      ];

      for (final path in possiblePaths) {
        dynamic current = data;
        for (final key in path) {
          if (current is Map<String, dynamic> && current.containsKey(key)) {
            current = current[key];
          } else {
            current = null;
            break;
          }
        }
        if (current is List) return current;
      }
    }

    return [];
  }

  // Extract error message from response
  String _extractErrorMessage(dynamic response) {
    try {
      if (response.body?.isNotEmpty == true) {
        final error = jsonDecode(response.body);
        if (error is Map<String, dynamic>) {
          return error['message'] ?? error['error'] ?? 'Request failed';
        }
      }
    } catch (e) {
      // If JSON parsing fails, continue with fallback
    }
    return 'Request failed with status ${response.statusCode}';
  }
}
