class Promotion {
  final String id;
  final String name;
  final String description;
  final String discountType;
  final double discountValue;
  final double maxDiscount;
  final String timeType;
  final DateTime startDate;
  final DateTime endDate;
  final String days;
  final DateTime startTime;
  final DateTime endTime;
  final String promoCode;
  final int usageLimit;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Promotion({
    required this.id,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.maxDiscount,
    required this.timeType,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.promoCode,
    required this.usageLimit,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discount_type'] ?? '',
      discountValue: (json['discount_value'] ?? 0).toDouble(),
      maxDiscount: (json['max_discount'] ?? 0).toDouble(),
      timeType: json['time_type'] ?? '',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      days: json['days'] ?? '',
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'] ?? '') ?? DateTime.now(),
      promoCode: json['promo_code'] ?? '',
      usageLimit: json['usage_limit'] ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discount_type': discountType,
      'discount_value': discountValue,
      'max_discount': maxDiscount,
      'time_type': timeType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'days': days,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'promo_code': promoCode,
      'usage_limit': usageLimit,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedDiscount {
    if (discountType == 'percent') {
      return '${discountValue.toInt()}%';
    } else {
      return 'Rp ${discountValue.toStringAsFixed(0)}';
    }
  }

  String get formattedPeriod {
    if (timeType == 'period') {
      return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    } else {
      return 'Setiap Hari';
    }
  }

  String get formattedDays {
    if (days.isEmpty) return 'Setiap Hari';
    return days;
  }

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'active':
        return 'AKTIF';
      case 'inactive':
        return 'TIDAK AKTIF';
      case 'expired':
        return 'KEDALUWARSA';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class PromotionResponse {
  final String message;
  final int status;
  final List<Promotion> promotions;

  PromotionResponse({
    required this.message,
    required this.status,
    required this.promotions,
  });

  factory PromotionResponse.fromJson(Map<String, dynamic> json) {
    return PromotionResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      promotions: (json['data']['promotions'] as List)
          .map((item) => Promotion.fromJson(item))
          .toList(),
    );
  }
}
