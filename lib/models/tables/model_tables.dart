// lib/models/qr_code.dart
class QRCode {
  final String id;
  final String storeId;
  final String code;
  final String tableNumber;
  final String type;
  final String menuUrl;
  final DateTime expiresAt;
  final String? image; // Base64 encoded image

  QRCode({
    required this.id,
    required this.storeId,
    required this.code,
    required this.tableNumber,
    required this.type,
    required this.menuUrl,
    required this.expiresAt,
    this.image,
  });

  factory QRCode.fromJson(Map<String, dynamic> json) {
    return QRCode(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      code: json['code'] ?? '',
      tableNumber: json['table_number'] ?? '',
      type: json['type'] ?? '',
      menuUrl: json['menu_url'] ?? '',
      expiresAt: DateTime.parse(json['expires_at']),
      image: json['image'],
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
      if (image != null) 'image': image,
    };
  }
}

class QRCodeListResponse {
  final bool success;
  final String message;
  final int status;
  final DateTime timestamp;
  final List<QRCode> qrcodes;
  final QRCodeMetadata metadata;

  QRCodeListResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.qrcodes,
    required this.metadata,
  });

  factory QRCodeListResponse.fromJson(Map<String, dynamic> json) {
    return QRCodeListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
      qrcodes: (json['data']['qrcodes'] as List<dynamic>?)
              ?.map((item) => QRCode.fromJson(item))
              .toList() ??
          [],
      metadata: QRCodeMetadata.fromJson(json['metadata']),
    );
  }
}

class QRCodeMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  QRCodeMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory QRCodeMetadata.fromJson(Map<String, dynamic> json) {
    return QRCodeMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 100,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

class CreateQRCodeRequest {
  final String tableNumber;
  final String type;
  final String menuUrl;
  final DateTime expiresAt;

  CreateQRCodeRequest({
    required this.tableNumber,
    required this.type,
    required this.menuUrl,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'table_number': tableNumber,
      'type': type,
      'menu_url': menuUrl,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}

class CreateQRCodeResponse {
  final bool success;
  final String message;
  final int status;
  final DateTime timestamp;
  final QRCode data;

  CreateQRCodeResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory CreateQRCodeResponse.fromJson(Map<String, dynamic> json) {
    return CreateQRCodeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
      data: QRCode.fromJson(json['data']),
    );
  }
}

class BulkCreateQRCodeRequest {
  final int tableCount;
  final int startNumber;
  final String type;
  final String menuUrl;
  final DateTime expiresAt;

  BulkCreateQRCodeRequest({
    required this.tableCount,
    required this.startNumber,
    required this.type,
    required this.menuUrl,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'table_count': tableCount,
      'start_number': startNumber,
      'type': type,
      'menu_url': menuUrl,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}

class BulkCreateQRCodeResponse {
  final bool success;
  final String message;
  final int status;
  final DateTime timestamp;
  final List<QRCode> data;

  BulkCreateQRCodeResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory BulkCreateQRCodeResponse.fromJson(Map<String, dynamic> json) {
    return BulkCreateQRCodeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => QRCode.fromJson(item))
              .toList() ??
          [],
    );
  }
}
