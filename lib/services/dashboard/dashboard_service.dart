// services/statistics_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/dashboard/dashboard_model.dart';

class StatisticsService extends GetxService {
  static StatisticsService get instance {
    if (!Get.isRegistered<StatisticsService>()) {
      Get.put(StatisticsService());
    }
    return Get.find<StatisticsService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  /// Get dashboard statistics
  /// Mengambil data statistik dashboard termasuk:
  /// - Daily stats (pendapatan dan order hari ini)
  /// - Weekly stats dengan breakdown harian
  /// - Jumlah kategori dan produk
  /// - Menu trending
  Future<StatisticsModel> getStatistics({String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '/statistics',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return StatisticsModel.fromJson(data);
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting statistics: $e');
    }
  }

  /// Get statistics with retry mechanism
  /// Mencoba mengambil data statistik dengan retry jika gagal
  Future<StatisticsModel> getStatisticsWithRetry({
    String? storeId,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        attempts++;
        return await getStatistics(storeId: storeId);
      } catch (e) {
        lastException = Exception('Attempt $attempts failed: $e');

        if (attempts < maxRetries) {
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: attempts));
        }
      }
    }

    throw lastException ?? Exception('Failed after $maxRetries attempts');
  }

  /// Format currency untuk display
  String formatCurrency(int amount) {
    return 'Rp${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  /// Get day name dalam bahasa Indonesia
  String getDayName(String date) {
    try {
      final dateTime = DateTime.parse(date);
      const dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
      return dayNames[dateTime.weekday % 7];
    } catch (e) {
      return 'N/A';
    }
  }

  /// Calculate percentage change (untuk growth indicators)
  double calculateGrowthPercentage(int current, int previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  /// Get chart data untuk weekly chart
  List<ChartData> getWeeklyChartData(List<DailyBreakdown> dailyBreakdown) {
    return dailyBreakdown.map((breakdown) {
      return ChartData(
        day: getDayName(breakdown.date),
        orders: breakdown.totalOrders,
        earnings: breakdown.totalEarnings,
        date: breakdown.date,
      );
    }).toList();
  }
}

// Helper class untuk chart data
class ChartData {
  final String day;
  final int orders;
  final int earnings;
  final String date;

  ChartData({
    required this.day,
    required this.orders,
    required this.earnings,
    required this.date,
  });
}
