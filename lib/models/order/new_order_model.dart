// models/order/order_model.dart
class Order {
  final String id;
  final String storeId;
  final String customerName;
  final String customerPhone;
  final int tableNumber;
  final String status;
  final String dishStatus;
  final double baseAmount;
  final double discountRate;
  final double discountAmount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String notes;
  final String promoCode;
  final String referralCode;
  final String commissionStatus;
  final DateTime createdAt;
  final OrderTracking tracking;
  final List<PaymentMethod> paymentMethods;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.storeId,
    required this.customerName,
    required this.customerPhone,
    required this.tableNumber,
    required this.status,
    required this.dishStatus,
    required this.baseAmount,
    required this.discountRate,
    required this.discountAmount,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    required this.notes,
    required this.promoCode,
    required this.referralCode,
    required this.commissionStatus,
    required this.createdAt,
    required this.tracking,
    required this.paymentMethods,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      tableNumber: json['table_number'] ?? 0,
      status: json['status'] ?? '',
      dishStatus: json['dish_status'] ?? '',
      baseAmount: (json['base_amount'] ?? 0).toDouble(),
      discountRate: (json['discount_rate'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      taxRate: (json['tax_rate'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      notes: json['notes'] ?? '',
      promoCode: json['promo_code'] ?? '',
      referralCode: json['referral_code'] ?? '',
      commissionStatus: json['commission_status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      tracking: OrderTracking.fromJson(json['tracking'] ?? {}),
      paymentMethods: (json['payment_methods'] as List?)
              ?.map((item) => PaymentMethod.fromJson(item))
              .toList() ??
          [],
      items: (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class OrderTracking {
  final TrackingInfo created;
  final TrackingInfo lastModified;
  final TrackingInfo? cancelled;
  final TrackingInfo? paid;

  OrderTracking({
    required this.created,
    required this.lastModified,
    this.cancelled,
    this.paid,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      created: TrackingInfo.fromJson(json['created'] ?? {}),
      lastModified: TrackingInfo.fromJson(json['last_modified'] ?? {}),
      cancelled:
          json['cancelled'] != null && (json['cancelled'] as Map).isNotEmpty
              ? TrackingInfo.fromJson(json['cancelled'])
              : null,
      paid: json['paid'] != null && (json['paid'] as Map).isNotEmpty
          ? TrackingInfo.fromJson(json['paid'])
          : null,
    );
  }
}

class TrackingInfo {
  final DateTime? at;
  final String? by;
  final String? byType;

  TrackingInfo({
    this.at,
    this.by,
    this.byType,
  });

  factory TrackingInfo.fromJson(Map<String, dynamic> json) {
    return TrackingInfo(
      at: json['at'] != null ? DateTime.parse(json['at']) : null,
      by: json['by'],
      byType: json['by_type'],
    );
  }
}

class PaymentMethod {
  final String id;
  final String method;
  final double amount;
  final String status;
  final String transactionRef;

  PaymentMethod({
    required this.id,
    required this.method,
    required this.amount,
    required this.status,
    required this.transactionRef,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      method: json['method'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      transactionRef: json['transaction_ref'] ?? '',
    );
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double hpp;
  final String note;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.hpp,
    required this.note,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      hpp: (json['hpp'] ?? 0).toDouble(),
      note: json['note'] ?? '',
    );
  }
}

// Request Models
class CreateOrderRequest {
  final OrderDetails order;
  final List<OrderDetailRequest> orderDetails;
  final List<PaymentRequest> payments;

  CreateOrderRequest({
    required this.order,
    required this.orderDetails,
    required this.payments,
  });

  Map<String, dynamic> toJson() {
    return {
      'order': order.toJson(),
      'order_details': orderDetails.map((item) => item.toJson()).toList(),
      'payments': payments.map((payment) => payment.toJson()).toList(),
    };
  }
}

class OrderDetails {
  final String customerName;
  final String customerPhone;
  final int tableNumber;
  final String notes;
  final String referralCode;
  final String promoCode;

  OrderDetails({
    required this.customerName,
    required this.customerPhone,
    required this.tableNumber,
    required this.notes,
    required this.referralCode,
    required this.promoCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'table_number': tableNumber,
      'notes': notes,
      'referral_code': referralCode,
      'promo_code': promoCode,
    };
  }
}

class OrderDetailRequest {
  final String productId;
  final int quantity;
  final String note;

  OrderDetailRequest({
    required this.productId,
    required this.quantity,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'note': note,
    };
  }
}

class PaymentRequest {
  final String method;

  PaymentRequest({required this.method});

  Map<String, dynamic> toJson() {
    return {
      'method': method,
    };
  }
}

// QRIS Models
class QrisPaymentResponse {
  final String transactionId;
  final String qrisData;
  final double amount;
  final String status;
  final String orderId;
  final DateTime expiresAt;

  QrisPaymentResponse({
    required this.transactionId,
    required this.qrisData,
    required this.amount,
    required this.status,
    required this.orderId,
    required this.expiresAt,
  });

  factory QrisPaymentResponse.fromJson(Map<String, dynamic> json) {
    return QrisPaymentResponse(
      transactionId: json['transaction_id'] ?? '',
      qrisData: json['qris_data'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      orderId: json['order_id'] ?? '',
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}

class QrisStatusResponse {
  final String orderId;
  final String transactionId;
  final String status;
  final String method;

  QrisStatusResponse({
    required this.orderId,
    required this.transactionId,
    required this.status,
    required this.method,
  });

  factory QrisStatusResponse.fromJson(Map<String, dynamic> json) {
    return QrisStatusResponse(
      orderId: json['order_id'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      status: json['status'] ?? '',
      method: json['method'] ?? '',
    );
  }
}

// Payment Response
class PaymentResponse {
  final String id;
  final String orderId;
  final String method;
  final double amount;
  final String status;
  final String transactionRef;
  final DateTime createdAt;
  final DateTime? paidAt;

  PaymentResponse({
    required this.id,
    required this.orderId,
    required this.method,
    required this.amount,
    required this.status,
    required this.transactionRef,
    required this.createdAt,
    this.paidAt,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      method: json['method'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      transactionRef: json['transaction_ref'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }
}
