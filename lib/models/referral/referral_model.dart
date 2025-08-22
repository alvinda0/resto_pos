// models/referral/referral_model.dart
import 'dart:convert';

class ReferralModel {
  final String id;
  final String storeId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String code;
  final String qrCodeImage;
  final double commissionRate;
  final String commissionType;
  final String oneTimePassword;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReferralModel({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.code,
    required this.qrCodeImage,
    required this.commissionRate,
    required this.commissionType,
    required this.oneTimePassword,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      code: json['code'] ?? '',
      qrCodeImage: json['qr_code_image'] ?? '',
      commissionRate: (json['commission_rate'] ?? 0).toDouble(),
      commissionType: json['commission_type'] ?? 'percentage',
      oneTimePassword: json['one_time_password'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'code': code,
      'qr_code_image': qrCodeImage,
      'commission_rate': commissionRate,
      'commission_type': commissionType,
      'one_time_password': oneTimePassword,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create copy with updated fields
  ReferralModel copyWith({
    String? id,
    String? storeId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? code,
    String? qrCodeImage,
    double? commissionRate,
    String? commissionType,
    String? oneTimePassword,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReferralModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      code: code ?? this.code,
      qrCodeImage: qrCodeImage ?? this.qrCodeImage,
      commissionRate: commissionRate ?? this.commissionRate,
      commissionType: commissionType ?? this.commissionType,
      oneTimePassword: oneTimePassword ?? this.oneTimePassword,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReferralModel(id: $id, customerName: $customerName, code: $code, commissionRate: $commissionRate, commissionType: $commissionType)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferralModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Response wrapper model with pagination metadata
class ReferralResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<ReferralModel> data;
  final PaginationMetadata? metadata;

  ReferralResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    this.metadata,
  });

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    return ReferralResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => ReferralModel.fromJson(item))
              .toList() ??
          [],
      metadata: json['metadata'] != null
          ? PaginationMetadata.fromJson(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'timestamp': timestamp,
      'data': data.map((item) => item.toJson()).toList(),
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }
}

// Pagination metadata model
class PaginationMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }
}

// Single referral response model (for individual operations)
class SingleReferralResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final ReferralModel data;

  SingleReferralResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory SingleReferralResponse.fromJson(Map<String, dynamic> json) {
    return SingleReferralResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      data: ReferralModel.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'timestamp': timestamp,
      'data': data.toJson(),
    };
  }
}

// Error response model
class ReferralErrorResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final Map<String, dynamic>? errors;

  ReferralErrorResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    this.errors,
  });

  factory ReferralErrorResponse.fromJson(Map<String, dynamic> json) {
    return ReferralErrorResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      status: json['status'] ?? 500,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'timestamp': timestamp,
      if (errors != null) 'errors': errors,
    };
  }
}
