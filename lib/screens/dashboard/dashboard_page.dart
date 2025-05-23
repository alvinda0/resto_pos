import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/blocs/auth/auth_bloc.dart';
import 'package:pos/blocs/auth/auth_state.dart';
import 'package:pos/blocs/dashboard/dashboard_bloc.dart';
import 'package:pos/blocs/dashboard/dashboard_event.dart';
import 'package:pos/blocs/dashboard/dashboard_state.dart';
import 'package:pos/models/dashboard/dashboard_model.dart';
import 'package:pos/repositories/dashboard/dashboard_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return BlocProvider(
            create: (context) => DashboardBloc(
              dashboardRepository: DashboardRepository(),
              token: authState.token,
            )..add(
                const DashboardLoadRequested()), // Move the event trigger here
            child: const _DashboardPageContent(),
          );
        }

        // Handle unauthenticated state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
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
          context.read<DashboardBloc>().add(const DashboardRefreshRequested());
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is DashboardError) {
              return _buildErrorWidget(context, state);
            } else if (state is DashboardLoaded) {
              return _buildDashboardContent(context, state.stats);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, DashboardError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${state.error.message}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DashboardBloc>().add(const DashboardLoadRequested());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardStats stats) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          _buildStatisticsSection(context, stats),
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

  Widget _buildStatisticsSection(BuildContext context, DashboardStats stats) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    if (_isMobile(context)) {
      // Mobile: Stack cards vertically
      return Column(
        children: [
          _buildStatCard(
            'Total Pendapatan Hari ini',
            formatter.format(stats.dailyStats.totalEarnings),
            Icons.attach_money,
            Colors.green,
            context,
          ),
          SizedBox(height: _getSpacing(context)),
          _buildStatCard(
            'Total Order Hari ini',
            '${stats.dailyStats.totalOrders}',
            Icons.shopping_cart_outlined,
            Colors.purple,
            context,
          ),
          SizedBox(height: _getSpacing(context)),
          _buildStatCard(
            'Total Kategori',
            '${stats.categoryCount}',
            Icons.grid_view_outlined,
            Colors.blue,
            context,
          ),
          SizedBox(height: _getSpacing(context)),
          _buildStatCard(
            'Total Menu',
            '${stats.productCount}',
            Icons.restaurant_menu_outlined,
            Colors.orange,
            context,
          ),
        ],
      );
    } else {
      // Tablet/Desktop: 2x2 grid
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Pendapatan Hari ini',
                  formatter.format(stats.dailyStats.totalEarnings),
                  Icons.attach_money,
                  Colors.green,
                  context,
                ),
              ),
              SizedBox(width: _getSpacing(context)),
              Expanded(
                child: _buildStatCard(
                  'Total Order Hari ini',
                  '${stats.dailyStats.totalOrders}',
                  Icons.shopping_cart_outlined,
                  Colors.purple,
                  context,
                ),
              ),
            ],
          ),
          SizedBox(height: _getSpacing(context)),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Kategori',
                  '${stats.categoryCount}',
                  Icons.grid_view_outlined,
                  Colors.blue,
                  context,
                ),
              ),
              SizedBox(width: _getSpacing(context)),
              Expanded(
                child: _buildStatCard(
                  'Total Menu',
                  '${stats.productCount}',
                  Icons.restaurant_menu_outlined,
                  Colors.orange,
                  context,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildChartsAndMenuSection(
      BuildContext context, DashboardStats stats) {
    if (_isMobile(context)) {
      // Mobile: Stack vertically
      return Column(
        children: [
          _buildChartCard(context, stats.weeklyStats),
          SizedBox(height: _getSpacing(context)),
          _buildTrendingMenuCard(context, stats.trendingItems),
        ],
      );
    } else {
      // Tablet/Desktop: Side by side
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: _isDesktop(context) ? 2 : 1,
            child: _buildChartCard(context, stats.weeklyStats),
          ),
          SizedBox(width: _getSpacing(context)),
          Expanded(
            flex: 1,
            child: _buildTrendingMenuCard(context, stats.trendingItems),
          ),
        ],
      );
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_getCardPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: _getFontSize(context, 14),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: _getFontSize(context, 28),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.all(_isMobile(context) ? 8 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: _isMobile(context) ? 20 : 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, WeeklyStats weeklyStats) {
    return Container(
      padding: EdgeInsets.all(_getCardPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Order Mingguan',
            style: TextStyle(
              fontSize: _getFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: _getSpacing(context)),

          // Chart Area
          SizedBox(
            height: _getChartHeight(context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weeklyStats.dailyBreakdown.map((dayData) {
                final dayName = _getDayName(dayData.date);
                return _buildChartBar(
                  dayName,
                  dayData.totalOrders,
                  Colors.blue,
                  context,
                  dayData: dayData,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(
    String day,
    int value,
    Color color,
    BuildContext context, {
    DailyBreakdown? dayData,
  }) {
    double maxHeight = _getChartHeight(context) - 50;
    final maxValue = _getMaxValue(dayData?.totalOrders ?? 0);
    double barHeight = value == 0 ? 4 : (value / maxValue) * maxHeight;
    double barWidth = _isMobile(context) ? 24 : 32;

    return GestureDetector(
      onTap: dayData != null
          ? () {
              _showDayDetails(context, day, dayData);
            }
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: barWidth,
            height: barHeight.clamp(4.0, maxHeight),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day,
            style: TextStyle(
              fontSize: _getFontSize(context, 12),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetails(
      BuildContext context, String day, DailyBreakdown dayData) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail $day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal: ${dayData.date}'),
            const SizedBox(height: 8),
            Text('Total Order: ${dayData.totalOrders}x'),
            const SizedBox(height: 8),
            Text('Pendapatan: ${formatter.format(dayData.totalEarnings)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingMenuCard(
      BuildContext context, List<TrendingItem> trendingItems) {
    return Container(
      padding: EdgeInsets.all(_getCardPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu Trending hari ini',
            style: TextStyle(
              fontSize: _getFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: _getSpacing(context)),

          // Menu Items
          if (trendingItems.isNotEmpty) ...[
            ...trendingItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildMenuItem(item, index + 1, context),
                  if (index < trendingItems.length - 1)
                    SizedBox(height: _getSpacing(context) / 1.5),
                ],
              );
            }),
          ] else ...[
            Center(
              child: Text(
                'Tidak ada menu trending hari ini',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: _getFontSize(context, 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(TrendingItem item, int rank, BuildContext context) {
    double imageSize = _isMobile(context) ? 40 : 48;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    Color rankColor;
    switch (rank) {
      case 1:
        rankColor = Colors.orange;
        break;
      case 2:
        rankColor = Colors.blue;
        break;
      default:
        rankColor = Colors.grey;
    }

    return Row(
      children: [
        // Food Image
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: item.imageUrl != null && item.imageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.restaurant,
                        color: Colors.grey[400],
                        size: imageSize * 0.5,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.restaurant,
                  color: Colors.grey[400],
                  size: imageSize * 0.5,
                ),
        ),
        SizedBox(width: _isMobile(context) ? 8 : 12),

        // Menu Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: _getFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                formatter.format(item.totalRevenue),
                style: TextStyle(
                  fontSize: _getFontSize(context, 12),
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Orders: ${item.orderCount}x',
                style: TextStyle(
                  fontSize: _getFontSize(context, 12),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Rank Badge
        Container(
          width: _isMobile(context) ? 24 : 28,
          height: _isMobile(context) ? 24 : 28,
          decoration: BoxDecoration(
            color: rankColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: Colors.white,
                fontSize: _getFontSize(context, 12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
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

  double _getCardPadding(BuildContext context) {
    if (_isMobile(context)) {
      return 16.0;
    } else if (_isTablet(context)) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  double _getFontSize(BuildContext context, double baseSize) {
    if (_isMobile(context)) {
      return baseSize;
    } else if (_isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  double _getChartHeight(BuildContext context) {
    if (_isMobile(context)) {
      return 200.0;
    } else if (_isTablet(context)) {
      return 250.0;
    } else {
      return 300.0;
    }
  }

  String _getDayName(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      final List<String> dayNames = [
        'Min',
        'Sen',
        'Sel',
        'Rab',
        'Kam',
        'Jum',
        'Sab'
      ];
      return dayNames[dateTime.weekday % 7];
    } catch (e) {
      return 'N/A';
    }
  }

  int _getMaxValue(int currentValue) {
    // Calculate max value for chart scaling
    // This is a simple implementation, you might want to make it more sophisticated
    if (currentValue == 0) return 50;
    return (currentValue * 1.2).ceil();
  }
}
