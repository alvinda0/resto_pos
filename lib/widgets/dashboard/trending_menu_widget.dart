import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/models/dashboard/dashboard_model.dart';

class TrendingMenuWidget extends StatelessWidget {
  final List<TrendingItem> trendingItems;

  const TrendingMenuWidget({
    super.key,
    required this.trendingItems,
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
}
