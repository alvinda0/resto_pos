class Debt {
  final String id;
  final String storeId;
  final String inventoryId;
  final String inventoryName;
  final String vendorName;
  final DateTime purchaseDate;
  final DateTime dueDate;
  final int amount;
  final String vendorPaymentStatus;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Debt({
    required this.id,
    required this.storeId,
    required this.inventoryId,
    required this.inventoryName,
    required this.vendorName,
    required this.purchaseDate,
    required this.dueDate,
    required this.amount,
    required this.vendorPaymentStatus,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      inventoryId: json['inventory_id'] ?? '',
      inventoryName: json['inventory_name'] ?? '',
      vendorName: json['vendor_name'] ?? '',
      purchaseDate: DateTime.parse(json['purchase_date']),
      dueDate: DateTime.parse(json['due_date']),
      amount: json['amount'] ?? 0,
      vendorPaymentStatus: json['vendor_payment_status'] ?? '',
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'inventory_id': inventoryId,
      'inventory_name': inventoryName,
      'vendor_name': vendorName,
      'purchase_date': purchaseDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'amount': amount,
      'vendor_payment_status': vendorPaymentStatus,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'inventory_id': inventoryId,
      'vendor_name': vendorName,
      'purchase_date': purchaseDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'amount': amount,
      'vendor_payment_status': vendorPaymentStatus,
    };
  }

  Debt copyWith({
    String? id,
    String? storeId,
    String? inventoryId,
    String? inventoryName,
    String? vendorName,
    DateTime? purchaseDate,
    DateTime? dueDate,
    int? amount,
    String? vendorPaymentStatus,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      inventoryId: inventoryId ?? this.inventoryId,
      inventoryName: inventoryName ?? this.inventoryName,
      vendorName: vendorName ?? this.vendorName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      vendorPaymentStatus: vendorPaymentStatus ?? this.vendorPaymentStatus,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPaid => vendorPaymentStatus == 'PAID';
  bool get isUnpaid => vendorPaymentStatus == 'UNPAID';
  bool get isOverdue => DateTime.now().isAfter(dueDate) && isUnpaid;

  String get formattedAmount {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}

class DebtResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<Debt> data;

  DebtResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory DebtResponse.fromJson(Map<String, dynamic> json) {
    return DebtResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Debt.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class DebtSingleResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final Debt? data;

  DebtSingleResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    this.data,
  });

  factory DebtSingleResponse.fromJson(Map<String, dynamic> json) {
    return DebtSingleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: json['data'] != null ? Debt.fromJson(json['data']) : null,
    );
  }
}
