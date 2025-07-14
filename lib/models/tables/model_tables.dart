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
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      code: json['code'] ?? '',
      tableNumber: json['table_number'] ?? '',
      type: json['type'] ?? '',
      menuUrl: json['menu_url'] ?? '',
      expiresAt: DateTime.parse(json['expires_at']),
    );
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

// Response model untuk API
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
    return QrCodeResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      qrCodes: (json['data']['qrcodes'] as List)
          .map((qrCode) => QrCodeModel.fromJson(qrCode))
          .toList(),
    );
  }
}
