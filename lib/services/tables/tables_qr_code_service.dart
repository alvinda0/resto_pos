// services/qr_code_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/tables/model_tables.dart';

class QrCodeService extends GetxService {
  static QrCodeService get instance {
    if (!Get.isRegistered<QrCodeService>()) {
      Get.put(QrCodeService());
    }
    return Get.find<QrCodeService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  // Get all QR codes
  Future<List<QrCodeModel>> getQrCodes() async {
    try {
      final response = await _httpClient.get('/qr-codes');

      if (response.statusCode == 200) {
        final qrCodeResponse =
            QrCodeResponse.fromJson(jsonDecode(response.body));
        return qrCodeResponse.qrCodes;
      } else {
        throw Exception('Gagal mengambil data QR codes');
      }
    } catch (e) {
      throw Exception('Error saat mengambil QR codes: $e');
    }
  }

  // Get QR code by ID
  Future<QrCodeModel> getQrCodeById(String id) async {
    try {
      final response = await _httpClient.get('/qr-codes/$id');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return QrCodeModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Gagal mengambil data QR code');
      }
    } catch (e) {
      throw Exception('Error saat mengambil QR code: $e');
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
      final data = {
        'store_id': storeId,
        'table_number': tableNumber,
        'type': type,
        'menu_url': menuUrl,
        'expires_at': expiresAt.toIso8601String(),
      };

      final response = await _httpClient.post('/qr-codes', data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return QrCodeModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Gagal membuat QR code');
      }
    } catch (e) {
      throw Exception('Error saat membuat QR code: $e');
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
      final data = <String, dynamic>{};

      if (storeId != null) data['store_id'] = storeId;
      if (tableNumber != null) data['table_number'] = tableNumber;
      if (type != null) data['type'] = type;
      if (menuUrl != null) data['menu_url'] = menuUrl;
      if (expiresAt != null) data['expires_at'] = expiresAt.toIso8601String();

      final response = await _httpClient.patch('/qr-codes/$id', data);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return QrCodeModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Gagal mengupdate QR code');
      }
    } catch (e) {
      throw Exception('Error saat mengupdate QR code: $e');
    }
  }

  // Delete QR code
  Future<bool> deleteQrCode(String id) async {
    try {
      final response = await _httpClient.delete('/qr-codes/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Gagal menghapus QR code');
      }
    } catch (e) {
      throw Exception('Error saat menghapus QR code: $e');
    }
  }

  // Get QR codes by store
  Future<List<QrCodeModel>> getQrCodesByStore(String storeId) async {
    try {
      final response = await _httpClient.get('/qr-codes?store_id=$storeId');

      if (response.statusCode == 200) {
        final qrCodeResponse =
            QrCodeResponse.fromJson(jsonDecode(response.body));
        return qrCodeResponse.qrCodes;
      } else {
        throw Exception('Gagal mengambil QR codes untuk store');
      }
    } catch (e) {
      throw Exception('Error saat mengambil QR codes by store: $e');
    }
  }

  // Get QR code by table number
  Future<QrCodeModel?> getQrCodeByTableNumber(String tableNumber) async {
    try {
      final response =
          await _httpClient.get('/qr-codes?table_number=$tableNumber');

      if (response.statusCode == 200) {
        final qrCodeResponse =
            QrCodeResponse.fromJson(jsonDecode(response.body));
        return qrCodeResponse.qrCodes.isNotEmpty
            ? qrCodeResponse.qrCodes.first
            : null;
      } else {
        throw Exception('Gagal mengambil QR code untuk meja');
      }
    } catch (e) {
      throw Exception('Error saat mengambil QR code by table: $e');
    }
  }
}
