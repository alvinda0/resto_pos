// models/withdrawal_model.dart
class WithdrawalModel {
  final String id;
  final String walletId;
  final String storeId;
  final String referralId;
  final String referralName;
  final double amount;
  final String status;
  final String type;
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountName;
  final DateTime createdAt;
  final DateTime updatedAt;

  WithdrawalModel({
    required this.id,
    required this.walletId,
    required this.storeId,
    required this.referralId,
    required this.referralName,
    required this.amount,
    required this.status,
    required this.type,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'] ?? '',
      walletId: json['wallet_id'] ?? '',
      storeId: json['store_id'] ?? '',
      referralId: json['referral_id'] ?? '',
      referralName: json['referral_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      bankName: json['bank_name'] ?? '',
      bankAccountNumber: json['bank_account_number'] ?? '',
      bankAccountName: json['bank_account_name'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'store_id': storeId,
      'referral_id': referralId,
      'referral_name': referralName,
      'amount': amount,
      'status': status,
      'type': type,
      'bank_name': bankName,
      'bank_account_number': bankAccountNumber,
      'bank_account_name': bankAccountName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  String get formattedAmount =>
      'Rp${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\d{1,3}(?=(\d{3})+(?!\d))'), (match) => '${match.group(0)}.')}';

  String get formattedDate =>
      '${createdAt.day.toString().padLeft(2, '0')} ${_getMonthName(createdAt.month)} ${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}:${createdAt.second.toString().padLeft(2, '0')}';

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

class WithdrawalResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<WithdrawalModel> data;

  WithdrawalResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => WithdrawalModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class WithdrawalUpdateRequest {
  final String status;
  final String note;

  WithdrawalUpdateRequest({
    required this.status,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'note': note,
    };
  }
}

class WithdrawalUpdateResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;

  WithdrawalUpdateResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
  });

  factory WithdrawalUpdateResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
    );
  }
}
