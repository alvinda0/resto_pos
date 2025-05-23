import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/models/dashboard/dashboard_model.dart';

class StatisticsCardsWidget extends StatelessWidget {
  final DashboardStats stats;

  const StatisticsCardsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_getCardPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_getCardBorderRadius(context)),
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
                  borderRadius:
                      BorderRadius.circular(_getIconBorderRadius(context)),
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

  // Enhanced border radius methods
  double _getCardBorderRadius(BuildContext context) {
    if (_isMobile(context)) {
      return 16.0; // Increased from 12
    } else if (_isTablet(context)) {
      return 18.0; // Responsive scaling
    } else {
      return 20.0; // Larger for desktop
    }
  }

  double _getIconBorderRadius(BuildContext context) {
    if (_isMobile(context)) {
      return 14.0; // Increased from 12
    } else if (_isTablet(context)) {
      return 16.0; // Responsive scaling
    } else {
      return 18.0; // Larger for desktop
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
}
