// models/qr_code_model.dart
class QrCodeModel {
  final String id;
  final String storeId;
  final String code;
  final String tableNumber;
  final String type;
  final String menuUrl;
  final DateTime expiresAt;

  QrCodeModel({
    required this.id,
    required this.storeId,
    required this.code,
    required this.tableNumber,
    required this.type,
    required this.menuUrl,
    required this.expiresAt,
  });

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      id: json['id']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      tableNumber: json['table_number']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      menuUrl: json['menu_url']?.toString() ?? '',
      expiresAt: _parseDateTime(json['expires_at']),
    );
  }

  // Helper method untuk parsing DateTime yang lebih robust
  static DateTime _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();

    try {
      if (dateStr is String) {
        return DateTime.parse(dateStr);
      } else if (dateStr is int) {
        // Unix timestamp
        return DateTime.fromMillisecondsSinceEpoch(dateStr * 1000);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'code': code,
      'table_number': tableNumber,
      'type': type,
      'menu_url': menuUrl,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'QrCodeModel(id: $id, storeId: $storeId, code: $code, tableNumber: $tableNumber, type: $type, menuUrl: $menuUrl, expiresAt: $expiresAt)';
  }
}

// Response model untuk API - dengan multiple kemungkinan struktur
class QrCodeResponse {
  final String message;
  final int status;
  final List<QrCodeModel> qrCodes;

  QrCodeResponse({
    required this.message,
    required this.status,
    required this.qrCodes,
  });

  factory QrCodeResponse.fromJson(Map<String, dynamic> json) {
    try {
      List<QrCodeModel> qrCodeList = [];

      // Debug: Print raw JSON
      print('Raw JSON Response: $json');

      // Coba berbagai kemungkinan struktur response
      if (json['data'] != null) {
        var data = json['data'];

        // Kemungkinan 1: data.qrcodes
        if (data['qrcodes'] != null && data['qrcodes'] is List) {
          qrCodeList = (data['qrcodes'] as List)
              .map((qrCode) => QrCodeModel.fromJson(qrCode))
              .toList();
        }
        // Kemungkinan 2: data.qr_codes
        else if (data['qr_codes'] != null && data['qr_codes'] is List) {
          qrCodeList = (data['qr_codes'] as List)
              .map((qrCode) => QrCodeModel.fromJson(qrCode))
              .toList();
        }
        // Kemungkinan 3: data langsung adalah array
        else if (data is List) {
          qrCodeList = (data as List)
              .map((qrCode) => QrCodeModel.fromJson(qrCode))
              .toList();
        }
      }
      // Kemungkinan 4: qrcodes langsung di root
      else if (json['qrcodes'] != null && json['qrcodes'] is List) {
        qrCodeList = (json['qrcodes'] as List)
            .map((qrCode) => QrCodeModel.fromJson(qrCode))
            .toList();
      }
      // Kemungkinan 5: qr_codes langsung di root
      else if (json['qr_codes'] != null && json['qr_codes'] is List) {
        qrCodeList = (json['qr_codes'] as List)
            .map((qrCode) => QrCodeModel.fromJson(qrCode))
            .toList();
      }

      return QrCodeResponse(
        message: json['message']?.toString() ?? '',
        status: json['status'] ?? json['statusCode'] ?? 200,
        qrCodes: qrCodeList,
      );
    } catch (e) {
      print('Error parsing QrCodeResponse: $e');
      return QrCodeResponse(
        message: 'Error parsing response',
        status: 500,
        qrCodes: [],
      );
    }
  }
}
