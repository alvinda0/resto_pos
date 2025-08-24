// screens/profit_report_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/profit/profit_controller.dart';
import 'package:pos/models/profit/profit_model.dart';
import 'package:pos/widgets/pagination_widget.dart';

class ProfitReportScreen extends StatelessWidget {
  const ProfitReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfitReportController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller, context),
            _buildTabBar(controller),
            Expanded(
              child: _buildContent(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ProfitReportController controller, BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(() => Text(
                      controller.formattedDateRange,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  InkWell(
                    onTap: () => controller.selectDateRange(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.calendar_today,
                              color: Colors.red, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Ubah Periode',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => InkWell(
                        onTap: controller.isExporting
                            ? null
                            : () => controller.exportToCsv(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: controller.isExporting
                                    ? Colors.grey
                                    : Colors.red,
                                width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              controller.isExporting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : const Icon(Icons.file_download,
                                      color: Colors.red, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Export CSV',
                                style: TextStyle(
                                  color: controller.isExporting
                                      ? Colors.grey
                                      : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCards(controller),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ProfitReportController controller) {
    return Obx(() {
      final summary = controller.summaryData;
      if (summary.isEmpty) {
        return const SizedBox.shrink();
      }

      return Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Pendapatan',
              controller.formatCurrency(summary['totalRevenue'] ?? 0),
              Colors.green.shade50,
              Colors.green.shade800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Laba Bersih',
              controller.formatCurrency(summary['totalNetProfit'] ?? 0),
              (summary['totalNetProfit'] ?? 0) >= 0
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              (summary['totalNetProfit'] ?? 0) >= 0
                  ? Colors.green.shade800
                  : Colors.red.shade800,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard(
      String title, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ProfitReportController controller) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(height: 1, color: Colors.grey),
          TabBar(
            controller: controller.tabController,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.red,
            tabs: const [
              Tab(text: 'Bulanan'),
              Tab(text: 'Tahunan'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ProfitReportController controller) {
    return Container(
      color: Colors.grey.shade50,
      child: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }

        return Column(
          children: [
            Expanded(
              child: controller.reports.isEmpty
                  ? _buildEmptyState()
                  : _buildReportList(controller),
            ),
            _buildPagination(controller),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data laporan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada transaksi pada periode ini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(ProfitReportController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      color: Colors.red,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.reports.length,
        itemBuilder: (context, index) {
          final report = controller.reports[index];
          return _buildReportCard(report, controller.periodType);
        },
      ),
    );
  }

  Widget _buildReportCard(ProfitReport report, PeriodType periodType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with period
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  periodType == PeriodType.monthly
                      ? report.formattedPeriod
                      : report.formattedYearPeriod,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: report.netProfit >= 0
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.netProfit >= 0 ? 'Untung' : 'Rugi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: report.netProfit >= 0
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Financial metrics
            _buildMetricRow('Pendapatan', report.formattedRevenue, Colors.blue),
            _buildMetricRow('HPP', report.formattedCogs, Colors.orange),
            _buildMetricRow(
                'Laba Kotor', report.formattedGrossProfit, Colors.green),
            const Divider(height: 20),
            _buildMetricRow(
                'Depresiasi', report.formattedDepreciation, Colors.purple),
            _buildMetricRow(
                'Gaji Karyawan', report.formattedPayroll, Colors.indigo),
            const Divider(height: 20),
            _buildMetricRow(
              'Laba Bersih',
              report.formattedNetProfit,
              report.netProfit >= 0 ? Colors.green : Colors.red,
              isHighlighted: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlighted ? 14 : 13,
              color: Colors.grey.shade700,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 14 : 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(ProfitReportController controller) {
    return Obx(() => PaginationWidget(
          currentPage: controller.currentPage,
          totalItems: controller.totalItems,
          itemsPerPage: controller.itemsPerPage,
          availablePageSizes: controller.availablePageSizes,
          startIndex: controller.startIndex,
          endIndex: controller.endIndex,
          hasPreviousPage: controller.hasPreviousPage,
          hasNextPage: controller.hasNextPage,
          pageNumbers: controller.pageNumbers,
          onPageSizeChanged: controller.onPageSizeChanged,
          onPreviousPage: controller.onPreviousPage,
          onNextPage: controller.onNextPage,
          onPageSelected: controller.onPageSelected,
        ));
  }
}
