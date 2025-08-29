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
      // Parse time fields correctly - they might contain full datetime or just time
      startTime: _parseTimeField(json['start_time']) ?? DateTime.now(),
      endTime: _parseTimeField(json['end_time']) ?? DateTime.now(),
      promoCode: json['promo_code'] ?? '',
      usageLimit: json['usage_limit'] ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper method to parse time fields that might be full datetime or just time
  static DateTime? _parseTimeField(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;

    try {
      // Try to parse as full datetime first
      final parsed = DateTime.tryParse(timeString);
      if (parsed != null) return parsed;

      // If that fails, try to parse as time only (HH:mm format)
      final timeRegex = RegExp(r'^(\d{2}):(\d{2})(?::(\d{2}))?$');
      final match = timeRegex.firstMatch(timeString);
      if (match != null) {
        final hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        final second = match.group(3) != null ? int.parse(match.group(3)!) : 0;

        // Use today's date with the parsed time
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute, second);
      }

      return null;
    } catch (e) {
      return null;
    }
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
    print('=== DEBUGGING PROMO VALIDATION ===');
    print('Promo Code: $promoCode');
    print('Status: $status');
    print('Time Type: $timeType');
    print('Start Date: $startDate');
    print('End Date: $endDate');
    print('Start Time: $startTime');
    print('End Time: $endTime');
    print('Days: $days');

    final now = DateTime.now();
    print('Current Time: $now');

    // 1. Check basic status
    if (status.toLowerCase() != 'active') {
      print('❌ Status tidak aktif: $status');
      return false;
    }
    print('✅ Status aktif');

    // 2. Check date range for period type
    if (timeType == 'period') {
      // Check start date
      final startDateOnly =
          DateTime(startDate.year, startDate.month, startDate.day);
      final nowDateOnly = DateTime(now.year, now.month, now.day);

      if (nowDateOnly.isBefore(startDateOnly)) {
        print('❌ Belum dimulai. Start: $startDateOnly, Now: $nowDateOnly');
        return false;
      }
      print('✅ Sudah dimulai');

      // Check end date
      if (endDate != null) {
        final endDateOnly =
            DateTime(endDate!.year, endDate!.month, endDate!.day);
        if (nowDateOnly.isAfter(endDateOnly)) {
          print('❌ Sudah berakhir. End: $endDateOnly, Now: $nowDateOnly');
          return false;
        }
        print('✅ Belum berakhir');
      }
    }

    // 3. Check allowed days (only if days is not empty)
    if (days.isNotEmpty) {
      final currentDay = _getCurrentDayName();
      final allowedDays =
          days.toLowerCase().split(',').map((d) => d.trim()).toList();
      print('Current Day: $currentDay, Allowed Days: $allowedDays');

      if (!allowedDays.contains(currentDay)) {
        print('❌ Hari ini tidak termasuk hari yang diizinkan');
        return false;
      }
      print('✅ Hari ini diizinkan');
    } else {
      print('✅ Tidak ada pembatasan hari (berlaku setiap hari)');
    }

    // 4. FIXED: Check time range - handle cross-timezone properly
    // For period type, we need to handle full datetime comparison differently
    if (timeType == 'period') {
      // For period type, compare with full datetime
      if (now.isBefore(startTime)) {
        print('❌ Belum waktunya. Start: $startTime, Now: $now');
        return false;
      }

      if (now.isAfter(endTime)) {
        print('❌ Sudah lewat waktu. End: $endTime, Now: $now');
        return false;
      }
      print('✅ Masih dalam rentang waktu periode');
    } else {
      // For daily type, only compare time portion
      final currentTimeOfDay = DateTime(
          now.year, now.month, now.day, now.hour, now.minute, now.second);
      final todayStart = DateTime(now.year, now.month, now.day, startTime.hour,
          startTime.minute, startTime.second);
      final todayEnd = DateTime(now.year, now.month, now.day, endTime.hour,
          endTime.minute, endTime.second);

      print('Current Time of Day: $currentTimeOfDay');
      print('Today Start: $todayStart');
      print('Today End: $todayEnd');

      if (currentTimeOfDay.isBefore(todayStart)) {
        print('❌ Belum waktunya hari ini');
        return false;
      }

      if (currentTimeOfDay.isAfter(todayEnd)) {
        print('❌ Sudah lewat waktu hari ini');
        return false;
      }
      print('✅ Masih dalam rentang waktu hari ini');
    }

    print('✅ PROMO VALID DAN AKTIF');
    return true;
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
