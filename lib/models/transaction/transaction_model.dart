// models/transaction.dart
class TransactionItem {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double hpp;

  TransactionItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.hpp,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      hpp: (json['hpp'] ?? 0).toDouble(),
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
      'hpp': hpp,
    };
  }
}

class Transaction {
  final String id;
  final String storeId;
  final String orderId;
  final double productPrice;
  final double inventoryHpp;
  final double baseAmount;
  final double taxAmount;
  final double taxRate;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TransactionItem> items;

  Transaction({
    required this.id,
    required this.storeId,
    required this.orderId,
    required this.productPrice,
    required this.inventoryHpp,
    required this.baseAmount,
    required this.taxAmount,
    required this.taxRate,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      orderId: json['order_id'] ?? '',
      productPrice: (json['product_price'] ?? 0).toDouble(),
      inventoryHpp: (json['inventory_hpp'] ?? 0).toDouble(),
      baseAmount: (json['base_amount'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      taxRate: (json['tax_rate'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => TransactionItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'order_id': orderId,
      'product_price': productPrice,
      'inventory_hpp': inventoryHpp,
      'base_amount': baseAmount,
      'tax_amount': taxAmount,
      'tax_rate': taxRate,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Helper methods untuk UI
  String get formattedOrderId {
    // Extract last 6 characters dari order_id untuk display
    return orderId.length > 6
        ? orderId.substring(orderId.length - 6).toUpperCase()
        : orderId.toUpperCase();
  }

  String get formattedDate {
    return "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}";
  }

  double get subtotal {
    return baseAmount;
  }

  double get discount {
    return 0; // Dari response API tidak ada field discount
  }

  double get taxPercentage {
    return taxRate * 100; // Convert ke percentage
  }

  double get ppnAmount {
    return taxAmount;
  }

  double get totalPayment {
    return totalAmount;
  }
}

class TransactionMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  TransactionMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory TransactionMetadata.fromJson(Map<String, dynamic> json) {
    return TransactionMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
    };
  }
}

class TransactionResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<Transaction> data;
  final TransactionMetadata metadata;

  TransactionResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((transaction) => Transaction.fromJson(transaction))
              .toList() ??
          [],
      metadata: TransactionMetadata.fromJson(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'timestamp': timestamp,
      'data': data.map((transaction) => transaction.toJson()).toList(),
      'metadata': metadata.toJson(),
    };
  }
}
