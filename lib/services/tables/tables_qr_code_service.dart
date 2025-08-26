// lib/services/qr_code_service.dart
import 'dart:convert';

import 'package:pos/http_client.dart';
import 'package:pos/models/tables/model_tables.dart';

class QRCodeService {
  final HttpClient _httpClient = HttpClient.instance;

  // Get QR codes with pagination and search
  Future<QRCodeListResponse> getQRCodes({
    int page = 1,
    int limit = 100,
    String search = '',
    String? storeId,
  }) async {
    try {
      final queryParameters = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'search': search,
      };

      final response = await _httpClient.get(
        '/qr-codes',
        requireAuth: true,
        storeId: storeId,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return QRCodeListResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch QR codes');
      }
    } catch (e) {
      throw Exception('Error fetching QR codes: $e');
    }
  }

  // Create QR codes using bulk API (supports both single and multiple)
  Future<BulkCreateQRCodeResponse> createQRCodes({
    required BulkCreateQRCodeRequest request,
    String? storeId,
  }) async {
    try {
      // Use the exact format that matches your API expectation
      final requestData = {
        'table_count': request.tableCount,
        'start_number': request.startNumber,
        'type': request.type,
        'menu_url': request.menuUrl,
        'expires_at': request.expiresAt.toUtc().toIso8601String(),
      };

      print('=== QR Code Creation ===');
      print('Request data: $requestData');
      print('JSON string: ${jsonEncode(requestData)}');
      print('Store ID: $storeId');
      print('========================');

      final response = await _httpClient.post(
        '/qr-codes/bulk',
        requestData,
        requireAuth: true,
        storeId: storeId,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return BulkCreateQRCodeResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create QR codes');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error creating QR codes: $e');
    }
  }

  // Delete QR code by ID
  Future<bool> deleteQRCode({
    required String qrCodeId,
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.delete(
        '/qr-codes/$qrCodeId',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['success'] ?? false;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete QR code');
      }
    } catch (e) {
      throw Exception('Error deleting QR code: $e');
    }
  }

  // Get QR code image as base64 (if needed separately)
  Future<String?> getQRCodeImage({
    required String qrCodeId,
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.get(
        '/qr-codes/$qrCodeId/image',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data']['image'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get QR code image');
      }
    } catch (e) {
      throw Exception('Error getting QR code image: $e');
    }
  }

  // Helper method to validate table number
  bool isValidTableNumber(String tableNumber) {
    return tableNumber.isNotEmpty && tableNumber.trim().isNotEmpty;
  }

  // Helper method to validate menu URL
  bool isValidMenuUrl(String menuUrl) {
    try {
      final uri = Uri.parse(menuUrl);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Helper method to check if QR code is expired
  bool isQRCodeExpired(QRCode qrCode) {
    return DateTime.now().isAfter(qrCode.expiresAt);
  }

  // Validate request before sending
  bool validateCreateRequest(BulkCreateQRCodeRequest request) {
    print('=== Request Validation ===');
    print(
        'Table Count: ${request.tableCount} (valid: ${request.tableCount > 0})');
    print(
        'Start Number: ${request.startNumber} (valid: ${request.startNumber >= 0})');
    print('Type: "${request.type}" (valid: ${request.type.isNotEmpty})');
    print(
        'Menu URL: "${request.menuUrl}" (valid: ${isValidMenuUrl(request.menuUrl)})');
    print(
        'Expires At: ${request.expiresAt} (valid: ${request.expiresAt.isAfter(DateTime.now())})');
    print('========================');

    return request.tableCount > 0 &&
        request.startNumber >= 0 &&
        request.type.isNotEmpty &&
        isValidMenuUrl(request.menuUrl) &&
        request.expiresAt.isAfter(DateTime.now());
  }
}
