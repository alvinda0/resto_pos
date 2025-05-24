// models/table/qr_code_model.dart
class QrCodeModel {
  final String id;
  final String code;
  final String tableNumber;
  final String type;
  final String menuUrl;
  final DateTime? expiresAt;

  QrCodeModel({
    required this.id,
    required this.code,
    required this.tableNumber,
    required this.type,
    required this.menuUrl,
    this.expiresAt,
  });

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      id: json['id'],
      code: json['code'],
      tableNumber: json['table_number'],
      type: json['type'],
      menuUrl: json['menu_url'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'table_number': tableNumber,
      'type': type,
      'menu_url': menuUrl,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}

// models/table/table_response_model.dart
class TableResponseModel {
  final String message;
  final int status;
  final TableDataModel data;

  TableResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory TableResponseModel.fromJson(Map<String, dynamic> json) {
    return TableResponseModel(
      message: json['message'],
      status: json['status'],
      data: TableDataModel.fromJson(json['data']),
    );
  }
}

class TableDataModel {
  final List<QrCodeModel> qrCodes;

  TableDataModel({required this.qrCodes});

  factory TableDataModel.fromJson(Map<String, dynamic> json) {
    return TableDataModel(
      qrCodes: (json['qr_codes'] as List)
          .map((item) => QrCodeModel.fromJson(item))
          .toList(),
    );
  }
}

// models/table/table_status.dart
enum TableStatus {
  available,
  occupied,
  reserved,
}

extension TableStatusExtension on TableStatus {
  String get displayName {
    switch (this) {
      case TableStatus.available:
        return 'Kosong';
      case TableStatus.occupied:
        return 'Terisi';
      case TableStatus.reserved:
        return 'Reservasi';
    }
  }
}
