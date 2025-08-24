class QRISPaymentResult {
  final String transactionId;
  final String qrisData;
  final double amount;
  final String status;
  final String orderId;
  final DateTime expiresAt;

  QRISPaymentResult({
    required this.transactionId,
    required this.qrisData,
    required this.amount,
    required this.status,
    required this.orderId,
    required this.expiresAt,
  });

  factory QRISPaymentResult.fromJson(Map<String, dynamic> json) {
    return QRISPaymentResult(
      transactionId: json['transaction_id'],
      qrisData: json['qris_data'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      orderId: json['order_id'],
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'qris_data': qrisData,
      'amount': amount,
      'status': status,
      'order_id': orderId,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) {
      return Duration.zero;
    }
    return expiresAt.difference(now);
  }
}

class QRISStatusResult {
  final String orderId;
  final String transactionId;
  final String status;
  final String method;

  QRISStatusResult({
    required this.orderId,
    required this.transactionId,
    required this.status,
    required this.method,
  });

  factory QRISStatusResult.fromJson(Map<String, dynamic> json) {
    return QRISStatusResult(
      orderId: json['order_id'],
      transactionId: json['transaction_id'] ?? '',
      status: json['status'],
      method: json['method'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'transaction_id': transactionId,
      'status': status,
      'method': method,
    };
  }

  bool get isSuccess => status.toUpperCase() == 'SUCCESS';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isFailed =>
      status.toUpperCase() == 'FAILED' || status.toUpperCase() == 'CANCELLED';
}
