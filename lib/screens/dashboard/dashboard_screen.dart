import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardPageContent();
  }
}

class _DashboardPageContent extends StatelessWidget {
  const _DashboardPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate a refresh action
          await Future.delayed(const Duration(seconds: 1));
        },
        child: _buildDashboardContent(context),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    // Mock data for demonstration
    final stats = DashboardStats(
      weeklyStats: [10, 20, 30, 40, 50, 60, 70],
      trendingItems: ['Item 1', 'Item 2', 'Item 3'],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(_getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          StatisticsCardsWidget(stats: stats),
          SizedBox(height: _getSpacing(context)),

          // Charts and Menu Section
          _buildChartsAndMenuSection(context, stats),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Beranda'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: _isTabletOrDesktop(context) ? 16 : 8),
          child: Row(
            children: [
              if (_isTabletOrDesktop(context)) ...[
                Text(
                  'Pages / ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'Beranda',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartsAndMenuSection(
      BuildContext context, DashboardStats stats) {
    if (_isMobile(context)) {
      // Mobile: Stack vertically
      return Column(
        children: [
          WeeklyChartWidget(weeklyStats: stats.weeklyStats),
          SizedBox(height: _getSpacing(context)),
          TrendingMenuWidget(trendingItems: stats.trendingItems),
        ],
      );
    } else {
      // Tablet/Desktop: Side by side
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: _isDesktop(context) ? 2 : 1,
            child: WeeklyChartWidget(weeklyStats: stats.weeklyStats),
          ),
          SizedBox(width: _getSpacing(context)),
          Expanded(
            flex: 1,
            child: TrendingMenuWidget(trendingItems: stats.trendingItems),
          ),
        ],
      );
    }
  }

  // Helper methods for responsive design
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  bool _isTabletOrDesktop(BuildContext context) {
    return !_isMobile(context);
  }

  double _getPadding(BuildContext context) {
    if (_isMobile(context)) {
      return 16.0;
    } else if (_isTablet(context)) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  double _getSpacing(BuildContext context) {
    if (_isMobile(context)) {
      return 16.0;
    } else if (_isTablet(context)) {
      return 20.0;
    } else {
      return 24.0;
    }
  }
}

// Mock classes for demonstration
class DashboardStats {
  final List<int> weeklyStats;
  final List<String> trendingItems;

  DashboardStats({required this.weeklyStats, required this.trendingItems});
}

class StatisticsCardsWidget extends StatelessWidget {
  final DashboardStats stats;

  const StatisticsCardsWidget({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Statistics: ${stats.weeklyStats.join(', ')}'),
      ),
    );
  }
}

class WeeklyChartWidget extends StatelessWidget {
  final List<int> weeklyStats;

  const WeeklyChartWidget({required this.weeklyStats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Weekly Chart: ${weeklyStats.join(', ')}'),
      ),
    );
  }
}

class TrendingMenuWidget extends StatelessWidget {
  final List<String> trendingItems;

  const TrendingMenuWidget({required this.trendingItems});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trending Items:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...trendingItems.map((item) => Text(item)).toList(),
          ],
        ),
      ),
    );
  }
}
