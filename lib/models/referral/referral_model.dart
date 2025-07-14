// models/referral_model.dart
class ReferralModel {
  final String id;
  final String storeId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String code;
  final String qrCodeImage;
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
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ReferralModel(id: $id, customerName: $customerName, code: $code)';
  }
}

// Response wrapper model
class ReferralResponse {
  final String message;
  final int status;
  final List<ReferralModel> data;

  ReferralResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    return ReferralResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => ReferralModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
