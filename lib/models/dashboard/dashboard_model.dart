import 'package:equatable/equatable.dart';

class DashboardResponse extends Equatable {
  final String message;
  final int status;
  final DashboardStats data;

  const DashboardResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: DashboardStats.fromJson(json['data'] ?? {}),
    );
  }

  @override
  List<Object> get props => [message, status, data];
}

class DashboardStats extends Equatable {
  final DailyStats dailyStats;
  final WeeklyStats weeklyStats;
  final int categoryCount;
  final int productCount;
  final List<TrendingItem> trendingItems;

  const DashboardStats({
    required this.dailyStats,
    required this.weeklyStats,
    required this.categoryCount,
    required this.productCount,
    required this.trendingItems,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      dailyStats: DailyStats.fromJson(json['daily_stats'] ?? {}),
      weeklyStats: WeeklyStats.fromJson(json['weekly_stats'] ?? {}),
      categoryCount: json['category_count'] ?? 0,
      productCount: json['product_count'] ?? 0,
      trendingItems: (json['trending_items'] as List<dynamic>?)
              ?.map((item) => TrendingItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  @override
  List<Object> get props => [
        dailyStats,
        weeklyStats,
        categoryCount,
        productCount,
        trendingItems,
      ];
}

class DailyStats extends Equatable {
  final int totalEarnings;
  final int totalOrders;
  final String date;

  const DailyStats({
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

  @override
  List<Object> get props => [totalEarnings, totalOrders, date];
}

class WeeklyStats extends Equatable {
  final List<DailyBreakdown> dailyBreakdown;
  final int totalEarnings;
  final int totalOrders;
  final String startDate;
  final String endDate;

  const WeeklyStats({
    required this.dailyBreakdown,
    required this.totalEarnings,
    required this.totalOrders,
    required this.startDate,
    required this.endDate,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      dailyBreakdown: (json['daily_breakdown'] as List<dynamic>?)
              ?.map((item) => DailyBreakdown.fromJson(item))
              .toList() ??
          [],
      totalEarnings: json['total_earnings'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }

  @override
  List<Object> get props => [
        dailyBreakdown,
        totalEarnings,
        totalOrders,
        startDate,
        endDate,
      ];
}

class DailyBreakdown extends Equatable {
  final int totalEarnings;
  final int totalOrders;
  final String date;

  const DailyBreakdown({
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

  @override
  List<Object> get props => [totalEarnings, totalOrders, date];
}

class TrendingItem extends Equatable {
  final String id;
  final String name;
  final int orderCount;
  final int totalRevenue;
  final String? imageUrl;
  final String categoryName;

  const TrendingItem({
    required this.id,
    required this.name,
    required this.orderCount,
    required this.totalRevenue,
    this.imageUrl,
    required this.categoryName,
  });

  factory TrendingItem.fromJson(Map<String, dynamic> json) {
    return TrendingItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      orderCount: json['order_count'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
      imageUrl: json['image_url'],
      categoryName: json['category_name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        orderCount,
        totalRevenue,
        imageUrl,
        categoryName,
      ];
}
