// controllers/statistics_controller.dart
import 'package:get/get.dart';
import 'package:pos/models/dashboard/dashboard_model.dart';
import 'package:pos/services/dashboard/dashboard_service.dart';

class StatisticsController extends GetxController {
  final StatisticsService _statisticsService = StatisticsService.instance;

  // Observable variables
  final Rx<StatisticsModel?> _statistics = Rx<StatisticsModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  StatisticsModel? get statistics => _statistics.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;

  // Chart data untuk weekly breakdown
  RxList<ChartData> chartData = <ChartData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStatistics();
  }

  /// Fetch statistics data
  Future<void> fetchStatistics({String? storeId}) async {
    try {
      _setLoading(true);
      _setError(false, '');

      final result = await _statisticsService.getStatisticsWithRetry(
        storeId: storeId,
      );

      _statistics.value = result;

      // Update chart data
      chartData.value = _statisticsService.getWeeklyChartData(
        result.data.weeklyStats.dailyBreakdown,
      );

      _setLoading(false);
    } catch (e) {
      _setError(true, e.toString());
      _setLoading(false);
    }
  }

  /// Refresh data (pull to refresh)
  Future<void> refreshStatistics() async {
    await fetchStatistics();
  }

  /// Retry loading data
  Future<void> retryLoad() async {
    await fetchStatistics();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _setError(bool error, String message) {
    _hasError.value = error;
    _errorMessage.value = message;
  }

  // Getter methods untuk UI
  String get todayEarnings {
    if (statistics == null) return 'Rp0';
    return _statisticsService.formatCurrency(
      statistics!.data.dailyStats.totalEarnings,
    );
  }

  String get todayOrders {
    if (statistics == null) return '0';
    return statistics!.data.dailyStats.totalOrders.toString();
  }

  String get totalCategories {
    if (statistics == null) return '0';
    return statistics!.data.categoryCount.toString();
  }

  String get totalProducts {
    if (statistics == null) return '0';
    return statistics!.data.productCount.toString();
  }

  String get weeklyEarnings {
    if (statistics == null) return 'Rp0';
    return _statisticsService.formatCurrency(
      statistics!.data.weeklyStats.totalEarnings,
    );
  }

  String get weeklyOrders {
    if (statistics == null) return '0';
    return statistics!.data.weeklyStats.totalOrders.toString();
  }

  List<TrendingItem> get trendingItems {
    if (statistics == null) return [];
    return statistics!.data.trendingItems;
  }

  // Calculate max value untuk chart scaling
  int get maxChartValue {
    if (chartData.isEmpty) return 20;
    final maxOrders = chartData.map((e) => e.orders).reduce(
          (a, b) => a > b ? a : b,
        );
    return (maxOrders * 1.2).ceil(); // Add 20% padding
  }

  // Check if data is available
  bool get hasData => statistics != null && !hasError;

  // Check if trending items available
  bool get hasTrendingItems => trendingItems.isNotEmpty;

  // Format number dengan K, M suffix untuk chart
  String formatChartNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Get growth indicator (bisa digunakan untuk showing trend)
  String getGrowthIndicator() {
    if (statistics == null || chartData.length < 2) return '';

    final today = chartData.last.orders;
    final yesterday = chartData[chartData.length - 2].orders;

    if (today > yesterday) return '↗️';
    if (today < yesterday) return '↘️';
    return '➡️';
  }

  @override
  void onClose() {
    super.onClose();
  }
}
