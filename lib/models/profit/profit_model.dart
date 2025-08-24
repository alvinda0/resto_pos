// models/profit/profit_model.dart
class ProfitReport {
  final String period;
  final double revenue;
  final double cogs;
  final double grossProfit;
  final double depreciation;
  final double payroll;
  final double netProfit;

  ProfitReport({
    required this.period,
    required this.revenue,
    required this.cogs,
    required this.grossProfit,
    required this.depreciation,
    required this.payroll,
    required this.netProfit,
  });

  factory ProfitReport.fromJson(Map<String, dynamic> json) {
    return ProfitReport(
      period: json['period']?.toString() ?? '',
      revenue: _parseDouble(json['revenue']),
      cogs: _parseDouble(json['cogs']),
      grossProfit: _parseDouble(json['gross_profit']),
      depreciation: _parseDouble(json['depreciation']),
      payroll: _parseDouble(json['payroll']),
      netProfit: _parseDouble(json['net_profit']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'revenue': revenue,
      'cogs': cogs,
      'gross_profit': grossProfit,
      'depreciation': depreciation,
      'payroll': payroll,
      'net_profit': netProfit,
    };
  }

  // Helper method untuk format tanggal bulanan
  String get formattedPeriod {
    try {
      final date = DateTime.parse(period);
      return '${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return period;
    }
  }

  // Helper method untuk format tanggal tahunan
  String get formattedYearPeriod {
    try {
      final date = DateTime.parse(period);
      return '${date.year}';
    } catch (e) {
      return period;
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return month > 0 && month < months.length ? months[month] : '';
  }

  // Helper methods for formatting currency (Indonesian Rupiah)
  String get formattedRevenue => _formatCurrency(revenue);
  String get formattedCogs => _formatCurrency(cogs);
  String get formattedGrossProfit => _formatCurrency(grossProfit);
  String get formattedDepreciation => _formatCurrency(depreciation);
  String get formattedPayroll => _formatCurrency(payroll);
  String get formattedNetProfit => _formatCurrency(netProfit);

  String _formatCurrency(double amount) {
    if (amount == 0) return 'Rp 0';

    final isNegative = amount < 0;
    final absAmount = amount.abs();

    String formatted = '';
    if (absAmount >= 1000000000) {
      final value = absAmount / 1000000000;
      formatted = 'Rp ${_formatNumber(value)}M';
    } else if (absAmount >= 1000000) {
      final value = absAmount / 1000000;
      formatted = 'Rp ${_formatNumber(value)}Jt';
    } else if (absAmount >= 1000) {
      final value = absAmount / 1000;
      formatted = 'Rp ${_formatNumber(value)}Rb';
    } else {
      formatted = 'Rp ${_formatNumber(absAmount)}';
    }

    return isNegative ? '-$formatted' : formatted;
  }

  String _formatNumber(double number) {
    if (number == number.toInt().toDouble()) {
      return number.toInt().toString();
    } else {
      return number.toStringAsFixed(1);
    }
  }

  // Get raw formatted currency without abbreviation (for detailed view)
  String _formatFullCurrency(double amount) {
    if (amount == 0) return 'Rp 0';

    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = absAmount.toStringAsFixed(0);

    // Add thousand separators
    final parts = <String>[];
    for (int i = formatted.length; i > 0; i -= 3) {
      int start = i - 3 < 0 ? 0 : i - 3;
      parts.insert(0, formatted.substring(start, i));
    }

    final result = 'Rp ${parts.join('.')}';
    return isNegative ? '-$result' : result;
  }

  String get fullFormattedRevenue => _formatFullCurrency(revenue);
  String get fullFormattedCogs => _formatFullCurrency(cogs);
  String get fullFormattedGrossProfit => _formatFullCurrency(grossProfit);
  String get fullFormattedDepreciation => _formatFullCurrency(depreciation);
  String get fullFormattedPayroll => _formatFullCurrency(payroll);
  String get fullFormattedNetProfit => _formatFullCurrency(netProfit);
}

class ProfitReportResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<ProfitReport> reports;
  final int total;

  ProfitReportResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.reports,
    required this.total,
  });

  factory ProfitReportResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final reportsList = data['reports'] as List? ?? [];

    return ProfitReportResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp']?.toString() ?? '',
      reports: reportsList
          .map(
              (report) => ProfitReport.fromJson(report as Map<String, dynamic>))
          .toList(),
      total: data['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'timestamp': timestamp,
      'data': {
        'reports': reports.map((report) => report.toJson()).toList(),
        'total': total,
      },
    };
  }
}

// Enum untuk period type
enum PeriodType { monthly, yearly }

extension PeriodTypeExtension on PeriodType {
  String get value {
    switch (this) {
      case PeriodType.monthly:
        return 'monthly';
      case PeriodType.yearly:
        return 'yearly';
    }
  }

  String get displayName {
    switch (this) {
      case PeriodType.monthly:
        return 'Bulanan';
      case PeriodType.yearly:
        return 'Tahunan';
    }
  }
}

// Request model untuk export
class ProfitReportExportRequest {
  final String startDate;
  final String endDate;
  final String periodType;

  ProfitReportExportRequest({
    required this.startDate,
    required this.endDate,
    required this.periodType,
  });

  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate,
      'end_date': endDate,
      'period_type': periodType,
    };
  }

  factory ProfitReportExportRequest.fromDateTime({
    required DateTime startDate,
    required DateTime endDate,
    required PeriodType periodType,
  }) {
    return ProfitReportExportRequest(
      startDate: '${startDate.toIso8601String().split('.')[0]}Z',
      endDate: '${endDate.toIso8601String().split('.')[0]}Z',
      periodType: periodType.value,
    );
  }
}
