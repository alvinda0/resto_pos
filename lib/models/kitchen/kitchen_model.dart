// models/kitchen_model.dart
class KitchenModel {
  final String id;
  final String storeId;
  final String customerName;
  final String customerPhone;
  final int tableNumber;
  final String status;
  final String dishStatus;
  final double baseAmount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String? notes;
  final DateTime createdAt;
  final List<PaymentMethod> paymentMethods;
  final List<KitchenItem> items;

  KitchenModel({
    required this.id,
    required this.storeId,
    required this.customerName,
    required this.customerPhone,
    required this.tableNumber,
    required this.status,
    required this.dishStatus,
    required this.baseAmount,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    this.notes,
    required this.createdAt,
    required this.paymentMethods,
    required this.items,
  });

  factory KitchenModel.fromJson(Map<String, dynamic> json) {
    return KitchenModel(
      id: json['id'],
      storeId: json['store_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      tableNumber: json['table_number'],
      status: json['status'],
      dishStatus: json['dish_status'],
      baseAmount: (json['base_amount'] as num).toDouble(),
      taxRate: (json['tax_rate'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      paymentMethods: (json['payment_methods'] as List)
          .map((e) => PaymentMethod.fromJson(e))
          .toList(),
      items:
          (json['items'] as List).map((e) => KitchenItem.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'table_number': tableNumber,
      'status': status,
      'dish_status': dishStatus,
      'base_amount': baseAmount,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'payment_methods': paymentMethods.map((e) => e.toJson()).toList(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  // Helper getters
  String get displayId => id.substring(0, 8).toUpperCase();
  String get formattedTotal => 'Rp${totalAmount.toStringAsFixed(0)}';
  String get paymentMethod =>
      paymentMethods.isNotEmpty ? paymentMethods.first.method : 'N/A';
  int get totalItems => items.length;

  // Status color helpers
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'success';
      case 'pending':
        return 'warning';
      case 'cancelled':
        return 'danger';
      default:
        return 'primary';
    }
  }
}

class PaymentMethod {
  final String id;
  final String method;
  final double amount;
  final String status;
  final String transactionRef;
  final DateTime? paidAt;

  PaymentMethod({
    required this.id,
    required this.method,
    required this.amount,
    required this.status,
    required this.transactionRef,
    this.paidAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      method: json['method'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      transactionRef: json['transaction_ref'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'amount': amount,
      'status': status,
      'transaction_ref': transactionRef,
      'paid_at': paidAt?.toIso8601String(),
    };
  }
}

class KitchenItem {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? note;
  final String? imageUrl;

  KitchenItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.note,
    this.imageUrl,
  });

  factory KitchenItem.fromJson(Map<String, dynamic> json) {
    return KitchenItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      note: json['note'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'note': note,
      'image_url': imageUrl,
    };
  }
}

class KitchenResponse {
  final String message;
  final int status;
  final List<KitchenModel> data;

  KitchenResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory KitchenResponse.fromJson(Map<String, dynamic> json) {
    return KitchenResponse(
      message: json['message'],
      status: json['status'],
      data:
          (json['data'] as List).map((e) => KitchenModel.fromJson(e)).toList(),
    );
  }
}
