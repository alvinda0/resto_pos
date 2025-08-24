// services/profit_report_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/profit/profit_model.dart';

class ProfitReportService extends GetxService {
  static ProfitReportService get instance {
    if (!Get.isRegistered<ProfitReportService>()) {
      Get.put(ProfitReportService());
    }
    return Get.find<ProfitReportService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  // Get profit reports with pagination support
  Future<ProfitReportResponse> getProfitReports({
    required PeriodType periodType,
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final endpoint = periodType == PeriodType.monthly
          ? '/profit-reports/monthly'
          : '/profit-reports/yearly';

      final queryParameters = {
        'start_date': '${startDate.toIso8601String().split('.')[0]}Z',
        'end_date': '${endDate.toIso8601String().split('.')[0]}Z',
        'period_type': periodType.value,
      };

      final response = await _httpClient.get(
        endpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final profitReportResponse =
            ProfitReportResponse.fromJson(jsonResponse);

        // Apply pagination manually since API doesn't support it
        final reports =
            _paginateReports(profitReportResponse.reports, page, limit);

        return ProfitReportResponse(
          success: profitReportResponse.success,
          message: profitReportResponse.message,
          status: profitReportResponse.status,
          timestamp: profitReportResponse.timestamp,
          reports: reports,
          total: profitReportResponse.total,
        );
      } else {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(
            jsonResponse['message'] ?? 'Failed to fetch profit reports');
      }
    } catch (e) {
      throw Exception('Error fetching profit reports: $e');
    }
  }

  // Get all profit reports without pagination (for export)
  Future<List<ProfitReport>> getAllProfitReports({
    required PeriodType periodType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final endpoint = periodType == PeriodType.monthly
          ? '/profit-reports/monthly'
          : '/profit-reports/yearly';

      final queryParameters = {
        'start_date': '${startDate.toIso8601String().split('.')[0]}Z',
        'end_date': '${endDate.toIso8601String().split('.')[0]}Z',
        'period_type': periodType.value,
      };

      final response = await _httpClient.get(
        endpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final profitReportResponse =
            ProfitReportResponse.fromJson(jsonResponse);
        return profitReportResponse.reports;
      } else {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(
            jsonResponse['message'] ?? 'Failed to fetch all profit reports');
      }
    } catch (e) {
      throw Exception('Error fetching all profit reports: $e');
    }
  }

  // Export profit reports to CSV
  Future<String> exportProfitReports({
    required DateTime startDate,
    required DateTime endDate,
    required PeriodType periodType,
  }) async {
    try {
      final requestData = {
        'start_date': '${startDate.toIso8601String().split('.')[0]}Z',
        'end_date': '${endDate.toIso8601String().split('.')[0]}Z',
        'period_type': periodType.value,
      };

      final response = await _httpClient.post(
        '/profit-reports/export',
        requestData,
      );

      if (response.statusCode == 200) {
        // Response is CSV text, not JSON
        return response.body;
      } else {
        try {
          final jsonResponse = jsonDecode(response.body);
          throw Exception(
              jsonResponse['message'] ?? 'Failed to export profit reports');
        } catch (e) {
          throw Exception('Failed to export profit reports: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error exporting profit reports: $e');
    }
  }

  // Export and save CSV file to device
  Future<void> exportAndSaveCsv({
    required DateTime startDate,
    required DateTime endDate,
    required PeriodType periodType,
  }) async {
    try {
      final csvContent = await exportProfitReports(
        startDate: startDate,
        endDate: endDate,
        periodType: periodType,
      );

      // Get directory to save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'profit_report_${periodType.value}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = '${directory.path}/$fileName';

      // Write CSV content to file
      final file = File(filePath);
      await file.writeAsString(csvContent);

      // Share the file using share_plus - FIXED: Use Share.shareXFiles instead of Share.shareXFiles
      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        text: 'Laporan Laba Rugi ${periodType.displayName}',
      );

      Get.snackbar(
        'Berhasil',
        'File CSV berhasil diekspor dan dibagikan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengekspor file CSV: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      throw Exception('Error exporting and saving CSV: $e');
    }
  }

  // Helper method to paginate reports manually
  List<ProfitReport> _paginateReports(
      List<ProfitReport> reports, int page, int limit) {
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;

    if (startIndex >= reports.length) {
      return [];
    }

    return reports.sublist(
      startIndex,
      endIndex > reports.length ? reports.length : endIndex,
    );
  }

  // Helper method to get date ranges
  Map<String, DateTime> getDefaultDateRange(PeriodType periodType) {
    final now = DateTime.now();
    late DateTime startDate;
    late DateTime endDate;

    if (periodType == PeriodType.monthly) {
      // Last 12 months
      startDate = DateTime(now.year - 1, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    } else {
      // Last 5 years
      startDate = DateTime(now.year - 4, 1, 1);
      endDate = DateTime(now.year, 12, 31, 23, 59, 59);
    }

    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  // Get summary data
  Map<String, double> getSummaryData(List<ProfitReport> reports) {
    if (reports.isEmpty) {
      return {
        'totalRevenue': 0,
        'totalCogs': 0,
        'totalGrossProfit': 0,
        'totalDepreciation': 0,
        'totalPayroll': 0,
        'totalNetProfit': 0,
      };
    }

    double totalRevenue = 0;
    double totalCogs = 0;
    double totalGrossProfit = 0;
    double totalDepreciation = 0;
    double totalPayroll = 0;
    double totalNetProfit = 0;

    for (final report in reports) {
      totalRevenue += report.revenue;
      totalCogs += report.cogs;
      totalGrossProfit += report.grossProfit;
      totalDepreciation += report.depreciation;
      totalPayroll += report.payroll;
      totalNetProfit += report.netProfit;
    }

    return {
      'totalRevenue': totalRevenue,
      'totalCogs': totalCogs,
      'totalGrossProfit': totalGrossProfit,
      'totalDepreciation': totalDepreciation,
      'totalPayroll': totalPayroll,
      'totalNetProfit': totalNetProfit,
    };
  }
}
