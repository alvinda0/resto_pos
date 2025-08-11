// models/kitchen/complete_order_model.dart
class CompleteOrderResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;

  CompleteOrderResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
  });

  factory CompleteOrderResponse.fromJson(Map<String, dynamic> json) {
    return CompleteOrderResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'CompleteOrderResponse(success: $success, message: $message, status: $status, timestamp: $timestamp)';
  }
}
