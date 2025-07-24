// promotion_model.dart - Fixed model
import 'package:intl/intl.dart';

class Promotion {
  final String id;
  final String name;
  final String description;
  final String discountType;
  final double discountValue;
  final double maxDiscount;
  final String timeType;
  final DateTime startDate;
  final DateTime? endDate; // Make nullable for daily type
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
    this.endDate,
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
      endDate:
          json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
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
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'description': description,
      'discount_type': discountType,
      'discount_value': discountValue,
      'max_discount': maxDiscount,
      'time_type': timeType,
      'start_date': startDate.toIso8601String(),
      'days': days,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'promo_code': promoCode,
      'usage_limit': usageLimit,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    // Only include end_date for period type
    if (timeType == 'period' && endDate != null) {
      data['end_date'] = endDate!.toIso8601String();
    }

    return data;
  }

  // Create a copy with updated fields (for updates)
  Promotion copyWith({
    String? id,
    String? name,
    String? description,
    String? discountType,
    double? discountValue,
    double? maxDiscount,
    String? timeType,
    DateTime? startDate,
    DateTime? endDate,
    String? days,
    DateTime? startTime,
    DateTime? endTime,
    String? promoCode,
    int? usageLimit,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Promotion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      timeType: timeType ?? this.timeType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      days: days ?? this.days,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      promoCode: promoCode ?? this.promoCode,
      usageLimit: usageLimit ?? this.usageLimit,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedDiscount {
    if (discountType == 'percent') {
      return '${discountValue.toInt()}%';
    } else {
      return 'Rp ${NumberFormat('#,###').format(discountValue)}';
    }
  }

  String get formattedMaxDiscount {
    return 'Rp ${NumberFormat('#,###').format(maxDiscount)}';
  }

  String get formattedPeriod {
    if (timeType == 'period' && endDate != null) {
      return '${_formatDate(startDate)} - ${_formatDate(endDate!)}';
    } else {
      return 'Harian';
    }
  }

  String get formattedDays {
    if (days.isEmpty) return 'Setiap Hari';

    // Convert comma-separated days to readable format
    final daysList = days.split(',');
    final dayNames = <String>[];

    for (String day in daysList) {
      switch (day.trim().toLowerCase()) {
        case 'monday':
          dayNames.add('Senin');
          break;
        case 'tuesday':
          dayNames.add('Selasa');
          break;
        case 'wednesday':
          dayNames.add('Rabu');
          break;
        case 'thursday':
          dayNames.add('Kamis');
          break;
        case 'friday':
          dayNames.add('Jumat');
          break;
        case 'saturday':
          dayNames.add('Sabtu');
          break;
        case 'sunday':
          dayNames.add('Minggu');
          break;
        default:
          dayNames.add(day.trim());
      }
    }

    return dayNames.join(', ');
  }

  String get formattedTimeRange {
    final startTimeStr = DateFormat('HH:mm').format(startTime);
    final endTimeStr = DateFormat('HH:mm').format(endTime);
    return '$startTimeStr - $endTimeStr';
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
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Helper method to check if promotion is currently valid
  bool get isCurrentlyActive {
    if (status.toLowerCase() != 'active') return false;

    final now = DateTime.now();

    if (timeType == 'period') {
      if (endDate != null && now.isAfter(endDate!)) return false;
    }

    // Check if current day is in allowed days
    if (days.isNotEmpty) {
      final currentDay = _getCurrentDayName();
      final allowedDays =
          days.toLowerCase().split(',').map((d) => d.trim()).toList();
      if (!allowedDays.contains(currentDay)) return false;
    }

    // Check time range
    final currentTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final todayStart = DateTime(
        now.year, now.month, now.day, startTime.hour, startTime.minute);
    final todayEnd =
        DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

    return currentTime.isAfter(todayStart) && currentTime.isBefore(todayEnd);
  }

  String _getCurrentDayName() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return '';
    }
  }
}

// Updated response models to match your API structure
class PromotionMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PromotionMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PromotionMetadata.fromJson(Map<String, dynamic> json) {
    return PromotionMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}

class PromotionResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<Promotion> promotions;
  final PromotionMetadata? metadata;

  PromotionResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.promotions,
    this.metadata,
  });

  factory PromotionResponse.fromJson(Map<String, dynamic> json) {
    return PromotionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      promotions: (json['data'] as List? ?? [])
          .map((item) => Promotion.fromJson(item))
          .toList(),
      metadata: json['metadata'] != null
          ? PromotionMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

// For single promotion response (used in getById, create, update)
class SinglePromotionResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final Promotion promotion;

  SinglePromotionResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.promotion,
  });

  factory SinglePromotionResponse.fromJson(Map<String, dynamic> json) {
    return SinglePromotionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      promotion: Promotion.fromJson(json['data']),
    );
  }
}
