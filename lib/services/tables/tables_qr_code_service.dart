// services/qr_code_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/tables/model_tables.dart';
import 'package:pos/storage_service.dart';

class QrCodeService extends GetxService {
  static QrCodeService get instance {
    if (!Get.isRegistered<QrCodeService>()) {
      Get.put(QrCodeService());
    }
    return Get.find<QrCodeService>();
  }

  final HttpClient _httpClient = HttpClient.instance;
  final StorageService _storage = StorageService.instance;

  // Get store ID from token or storage
  String? _getStoreId() {
    // First try to get from storage
    String? storeId = _storage.getString('store_id');

    if (storeId == null || storeId.isEmpty) {
      // If not in storage, try to extract from token
      final token = _storage.getToken();
      if (token != null) {
        storeId = _extractStoreIdFromToken(token);
        // Save to storage for future use
        if (storeId != null) {
          _storage.setString('store_id', storeId);
        }
      }
    }

    return storeId;
  }

  // Extract store ID from JWT token
  String? _extractStoreIdFromToken(String token) {
    try {
      // Split token into parts
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload (second part)
      final payload = parts[1];

      // Add padding if needed
      String normalizedPayload = payload;
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

      // Decode base64
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final Map<String, dynamic> decodedPayload = jsonDecode(decodedString);

      // Extract store_id from token payload
      return decodedPayload['store_id']?.toString() ??
          decodedPayload['storeId']?.toString() ??
          decodedPayload['store']?.toString();
    } catch (e) {
      print('Error extracting store ID from token: $e');
      return null;
    }
  }

  // Get all QR codes
  Future<List<QrCodeModel>> getQrCodes() async {
    try {
      final storeId = _getStoreId();
      final response = await _httpClient.get('/qr-codes', storeId: storeId);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Handle different response structures
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse.containsKey('data')) {
            // If response has 'data' field
            final data = jsonResponse['data'];
            if (data is List) {
              return data.map((item) => QrCodeModel.fromJson(item)).toList();
            } else if (data is Map && data.containsKey('qr_codes')) {
              final qrCodes = data['qr_codes'] as List;
              return qrCodes.map((item) => QrCodeModel.fromJson(item)).toList();
            }
          } else if (jsonResponse.containsKey('qr_codes')) {
            // If response has direct 'qr_codes' field
            final qrCodes = jsonResponse['qr_codes'] as List;
            return qrCodes.map((item) => QrCodeModel.fromJson(item)).toList();
          } else {
            // If response is direct array in data field
            return [QrCodeModel.fromJson(jsonResponse)];
          }
        } else if (jsonResponse is List) {
          // If response is direct array
          return jsonResponse
              .map((item) => QrCodeModel.fromJson(item))
              .toList();
        }

        return [];
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow; // Re-throw if it's already an Exception to avoid nesting
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get QR code by ID
  Future<QrCodeModel> getQrCodeById(String id) async {
    try {
      final storeId = _getStoreId();
      final response = await _httpClient.get('/qr-codes/$id', storeId: storeId);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Handle different response structures
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse.containsKey('data')) {
            return QrCodeModel.fromJson(jsonResponse['data']);
          } else {
            return QrCodeModel.fromJson(jsonResponse);
          }
        }

        throw Exception('Invalid response format');
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Create new QR code
  Future<QrCodeModel> createQrCode({
    required String storeId,
    required String tableNumber,
    required String type,
    required String menuUrl,
    required DateTime expiresAt,
  }) async {
    try {
      final currentStoreId = _getStoreId() ?? storeId;

      final data = {
        'store_id': currentStoreId,
        'table_number': tableNumber,
        'type': type,
        'menu_url': menuUrl,
        'expires_at': expiresAt.toIso8601String(),
      };

      final response =
          await _httpClient.post('/qr-codes', data, storeId: currentStoreId);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse.containsKey('data')) {
            return QrCodeModel.fromJson(jsonResponse['data']);
          } else {
            return QrCodeModel.fromJson(jsonResponse);
          }
        }

        throw Exception('Invalid response format');
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Update QR code
  Future<QrCodeModel> updateQrCode({
    required String id,
    String? storeId,
    String? tableNumber,
    String? type,
    String? menuUrl,
    DateTime? expiresAt,
  }) async {
    try {
      final currentStoreId = _getStoreId();
      final data = <String, dynamic>{};

      if (storeId != null) data['store_id'] = storeId;
      if (tableNumber != null) data['table_number'] = tableNumber;
      if (type != null) data['type'] = type;
      if (menuUrl != null) data['menu_url'] = menuUrl;
      if (expiresAt != null) data['expires_at'] = expiresAt.toIso8601String();

      final response = await _httpClient.patch('/qr-codes/$id', data,
          storeId: currentStoreId);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse.containsKey('data')) {
            return QrCodeModel.fromJson(jsonResponse['data']);
          } else {
            return QrCodeModel.fromJson(jsonResponse);
          }
        }

        throw Exception('Invalid response format');
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Delete QR code
  Future<bool> deleteQrCode(String id) async {
    try {
      final storeId = _getStoreId();
      final response =
          await _httpClient.delete('/qr-codes/$id', storeId: storeId);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get QR codes by store
  Future<List<QrCodeModel>> getQrCodesByStore(String storeId) async {
    try {
      final currentStoreId = _getStoreId() ?? storeId;
      final response = await _httpClient
          .get('/qr-codes?store_id=$currentStoreId', storeId: currentStoreId);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse.containsKey('data')) {
            final data = jsonResponse['data'];
            if (data is List) {
              return data.map((item) => QrCodeModel.fromJson(item)).toList();
            } else if (data is Map && data.containsKey('qr_codes')) {
              final qrCodes = data['qr_codes'] as List;
              return qrCodes.map((item) => QrCodeModel.fromJson(item)).toList();
            }
          } else if (jsonResponse.containsKey('qr_codes')) {
            final qrCodes = jsonResponse['qr_codes'] as List;
            return qrCodes.map((item) => QrCodeModel.fromJson(item)).toList();
          }
        } else if (jsonResponse is List) {
          return jsonResponse
              .map((item) => QrCodeModel.fromJson(item))
              .toList();
        }

        return [];
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get QR code by table number
  Future<QrCodeModel?> getQrCodeByTableNumber(String tableNumber) async {
    try {
      final storeId = _getStoreId();
      final response = await _httpClient
          .get('/qr-codes?table_number=$tableNumber', storeId: storeId);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        List<QrCodeModel> qrCodes = [];

        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse.containsKey('data')) {
            final data = jsonResponse['data'];
            if (data is List) {
              qrCodes = data.map((item) => QrCodeModel.fromJson(item)).toList();
            } else if (data is Map && data.containsKey('qr_codes')) {
              final qrCodesData = data['qr_codes'] as List;
              qrCodes = qrCodesData
                  .map((item) => QrCodeModel.fromJson(item))
                  .toList();
            }
          } else if (jsonResponse.containsKey('qr_codes')) {
            final qrCodesData = jsonResponse['qr_codes'] as List;
            qrCodes =
                qrCodesData.map((item) => QrCodeModel.fromJson(item)).toList();
          }
        } else if (jsonResponse is List) {
          qrCodes =
              jsonResponse.map((item) => QrCodeModel.fromJson(item)).toList();
        }

        return qrCodes.isNotEmpty ? qrCodes.first : null;
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Helper method to extract error message from response
  String _extractErrorMessage(dynamic response) {
    try {
      if (response.body != null && response.body.isNotEmpty) {
        final errorResponse = jsonDecode(response.body);
        if (errorResponse is Map<String, dynamic>) {
          return errorResponse['message'] ??
              errorResponse['error'] ??
              'Request failed with status ${response.statusCode}';
        }
      }
    } catch (e) {
      // If JSON parsing fails, return generic message
    }
    return 'Request failed with status ${response.statusCode}';
  }
}
