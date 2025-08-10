// models/statistics_model.dart
class StatisticsModel {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final StatisticsData data;

  StatisticsModel({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: StatisticsData.fromJson(json['data'] ?? {}),
    );
  }
}

class StatisticsData {
  final String storeId;
  final int categoryCount;
  final int productCount;
  final DailyStats dailyStats;
  final WeeklyStats weeklyStats;
  final List<TrendingItem> trendingItems;

  StatisticsData({
    required this.storeId,
    required this.categoryCount,
    required this.productCount,
    required this.dailyStats,
    required this.weeklyStats,
    required this.trendingItems,
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
      storeId: json['store_id'] ?? '',
      categoryCount: json['category_count'] ?? 0,
      productCount: json['product_count'] ?? 0,
      dailyStats: DailyStats.fromJson(json['daily_stats'] ?? {}),
      weeklyStats: WeeklyStats.fromJson(json['weekly_stats'] ?? {}),
      trendingItems: (json['trending_items'] as List?)
              ?.map((item) => TrendingItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class DailyStats {
  final int totalEarnings;
  final int totalOrders;
  final String date;

  DailyStats({
    required this.totalEarnings,
    required this.totalOrders,
    required this.date,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      totalEarnings: json['total_earnings'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      date: json['date'] ?? '',
    );
  }
}

class WeeklyStats {
  final int totalEarnings;
  final int totalOrders;
  final String startDate;
  final String endDate;
  final List<DailyBreakdown> dailyBreakdown;

  WeeklyStats({
    required this.totalEarnings,
    required this.totalOrders,
    required this.startDate,
    required this.endDate,
    required this.dailyBreakdown,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      totalEarnings: json['total_earnings'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      dailyBreakdown: (json['daily_breakdown'] as List?)
              ?.map((item) => DailyBreakdown.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class DailyBreakdown {
  final int totalEarnings;
  final int totalOrders;
  final String date;

  DailyBreakdown({
    required this.totalEarnings,
    required this.totalOrders,
    required this.date,
  });

  factory DailyBreakdown.fromJson(Map<String, dynamic> json) {
    return DailyBreakdown(
      totalEarnings: json['total_earnings'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      date: json['date'] ?? '',
    );
  }
}

class TrendingItem {
  final String id;
  final String name;
  final int orderCount;
  final int totalRevenue;
  final String imageUrl;
  final String categoryName;

  TrendingItem({
    required this.id,
    required this.name,
    required this.orderCount,
    required this.totalRevenue,
    required this.imageUrl,
    required this.categoryName,
  });

  factory TrendingItem.fromJson(Map<String, dynamic> json) {
    return TrendingItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      orderCount: json['order_count'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      categoryName: json['category_name'] ?? '',
    );
  }
}
