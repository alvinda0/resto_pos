import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/models/dashboard/dashboard_model.dart';

class WeeklyChartWidget extends StatelessWidget {
  final WeeklyStats weeklyStats;

  const WeeklyChartWidget({
    super.key,
    required this.weeklyStats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_getCardPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
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
