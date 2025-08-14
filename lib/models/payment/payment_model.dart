// models/payment/payment_model.dart
class PaymentModel {
  final String id;
  final String orderId;
  final String method;
  final double amount;
  final String status;
  final String transactionRef;
  final DateTime createdAt;
  final DateTime? paidAt;
  final PaymentTracking tracking;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.method,
    required this.amount,
    required this.status,
    required this.transactionRef,
    required this.createdAt,
    this.paidAt,
    required this.tracking,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      method: json['method'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      transactionRef: json['transaction_ref'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      tracking: PaymentTracking.fromJson(json['tracking'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'method': method,
      'amount': amount,
      'status': status,
      'transaction_ref': transactionRef,
      'created_at': createdAt.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'tracking': tracking.toJson(),
    };
  }
}

class PaymentTracking {
  final TrackingEvent created;
  final TrackingEvent lastModified;
  final TrackingEvent? paid;
  final TrackingEvent? refunded;

  PaymentTracking({
    required this.created,
    required this.lastModified,
    this.paid,
    this.refunded,
  });

  factory PaymentTracking.fromJson(Map<String, dynamic> json) {
    return PaymentTracking(
      created: TrackingEvent.fromJson(json['created'] ?? {}),
      lastModified: TrackingEvent.fromJson(json['last_modified'] ?? {}),
      paid: json['paid'] != null ? TrackingEvent.fromJson(json['paid']) : null,
      refunded: json['refunded'] != null
          ? TrackingEvent.fromJson(json['refunded'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created': created.toJson(),
      'last_modified': lastModified.toJson(),
      if (paid != null) 'paid': paid!.toJson(),
      if (refunded != null) 'refunded': refunded!.toJson(),
    };
  }
}

class TrackingEvent {
  final DateTime at;
  final String? by;
  final String? byType;

  TrackingEvent({
    required this.at,
    this.by,
    this.byType,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      at: DateTime.parse(json['at'] ?? DateTime.now().toIso8601String()),
      by: json['by'],
      byType: json['by_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'at': at.toIso8601String(),
      if (by != null) 'by': by,
      if (byType != null) 'by_type': byType,
    };
  }
}

// models/order/order_update_request.dart
class OrderUpdateRequest {
  final OrderUpdateInfo order;
  final List<OrderDetailRequest> orderDetails;
  final List<PaymentRequest> payments;

  OrderUpdateRequest({
    required this.order,
    required this.orderDetails,
    required this.payments,
  });

  Map<String, dynamic> toJson() {
    return {
      'order': order.toJson(),
      'order_details': orderDetails.map((e) => e.toJson()).toList(),
      'payments': payments.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderUpdateInfo {
  final String customerName;
  final String customerPhone;
  final int tableNumber;
  final String? notes;

  OrderUpdateInfo({
    required this.customerName,
    required this.customerPhone,
    required this.tableNumber,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'table_number': tableNumber,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

class OrderDetailRequest {
  final String productId;
  final int quantity;
  final String? note;

  OrderDetailRequest({
    required this.productId,
    required this.quantity,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}

class PaymentRequest {
  final String method;

  PaymentRequest({
    required this.method,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
    };
  }
}
