// screens/transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/transaction/transaction_controller.dart';
import 'package:pos/models/transaction/transaction_model.dart';

import 'package:pos/widgets/pagination_widget.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Laporan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => Container(
                margin: const EdgeInsets.only(right: 16),
                child: ElevatedButton.icon(
                  onPressed: controller.isLoading
                      ? null
                      : () => controller.exportTransactions(),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(controller),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
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
                children: [
                  Obx(() => Expanded(
                        child: controller.selectedTab == 'rinci'
                            ? _buildTransactionTable(controller)
                            : _buildRekapTable(controller), // Changed this line
                      )),
                  Obx(() => controller.selectedTab == 'rinci'
                      ? _buildPagination(controller)
                      : const SizedBox.shrink()), // No pagination for rekap
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TransactionController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Obx(() => Row(
            children: [
              // Tab buttons
              _buildTabButton(
                'Rinci',
                controller.totalItems,
                controller.selectedTab == 'rinci',
                () => controller.switchTab('rinci'),
              ),
              const SizedBox(width: 16),
              _buildTabButton(
                'Rekap',
                controller.rekapData.length,
                controller.selectedTab == 'rekap',
                () => controller.switchTab('rekap'),
              ),
            ],
          )),
    );
  }

  Widget _buildTabButton(
      String title, int count, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          '$title ($count)',
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Updated rekap table to match rinci table structure
  Widget _buildRekapTable(TransactionController controller) {
    return Obx(() {
      if (controller.isLoadingRekap) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.errorMessage.isNotEmpty && controller.rekapData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add method to reload rekap data if needed
                  // controller.loadRekapData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (controller.rekapData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No summary data available',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          // Add method to reload rekap data if needed
          // controller.loadRekapData();
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(Get.context!).size.width - 32,
            ),
            child: DataTable(
              headingRowHeight: 56,
              dataRowHeight: 56,
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
              columnSpacing: 24,
              columns: const [
                DataColumn(
                  label: Text(
                    'No.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Tanggal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'No. Transaksi',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Subtotal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Diskon',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Pajak (%)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'PPN (Rp)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Total Bayar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  numeric: true,
                ),
              ],
              rows: controller.rekapData
                  .asMap()
                  .entries
                  .map((entry) =>
                      _buildRekapDataRow(entry.key, entry.value, controller))
                  .toList(),
            ),
          ),
        ),
      );
    });
  }

  // New method for rekap data rows
  DataRow _buildRekapDataRow(int index, Map<String, dynamic> rekapItem,
      TransactionController controller) {
    final rowNumber = index + 1; // Simple row numbering starting from 1

    return DataRow(
      cells: [
        DataCell(
          Text(
            '$rowNumber',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            rekapItem['date'] ?? '-',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            rekapItem['transaction_id'] ?? '-', // Adjust field name as needed
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DataCell(
          Text(
            controller.formatCurrency(rekapItem['subtotal'] ?? 0),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            '${(rekapItem['discount'] ?? 0).toInt()}',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            '${(rekapItem['tax_percentage'] ?? 0).toInt()}%',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            controller.formatCurrency(rekapItem['ppn_amount'] ?? 0),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            controller.formatCurrency(rekapItem['total'] ?? 0),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTable(TransactionController controller) {
    return Obx(() {
      if (controller.isLoading && controller.transactions.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.errorMessage.isNotEmpty &&
          controller.transactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.refreshTransactions,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (controller.transactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions found',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshTransactions,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(Get.context!).size.width - 32,
            ),
            child: DataTable(
              headingRowHeight: 56,
              dataRowHeight: 56,
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
              columnSpacing: 24,
              columns: const [
                DataColumn(
                  label: Text(
                    'No.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Tanggal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'No. Transaksi',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Subtotal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Diskon',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Pajak (%)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'PPN (Rp)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Total Bayar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  numeric: true,
                ),
              ],
              rows: controller.transactions
                  .asMap()
                  .entries
                  .map((entry) =>
                      _buildDataRow(entry.key, entry.value, controller))
                  .toList(),
            ),
          ),
        ),
      );
    });
  }

  DataRow _buildDataRow(
      int index, Transaction transaction, TransactionController controller) {
    final rowNumber = controller.startIndex + index;

    return DataRow(
      cells: [
        DataCell(
          Text(
            '$rowNumber',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            transaction.formattedDate,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            transaction.formattedOrderId,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DataCell(
          Text(
            controller.formatCurrency(transaction.subtotal),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            '${transaction.discount.toInt()}',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            '${transaction.taxPercentage.toInt()}%',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            controller.formatCurrency(transaction.ppnAmount),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            controller.formatCurrency(transaction.totalPayment),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPagination(TransactionController controller) {
    return Obx(() {
      if (controller.transactions.isEmpty) {
        return const SizedBox.shrink();
      }

      return PaginationWidget(
        currentPage: controller.currentPage,
        totalItems: controller.totalItems,
        itemsPerPage: controller.itemsPerPage,
        availablePageSizes: controller.availablePageSizes,
        startIndex: controller.startIndex,
        endIndex: controller.endIndex,
        hasPreviousPage: controller.hasPreviousPage,
        hasNextPage: controller.hasNextPage,
        pageNumbers: controller.pageNumbers,
        onPageSizeChanged: controller.changeItemsPerPage,
        onPreviousPage: controller.previousPage,
        onNextPage: controller.nextPage,
        onPageSelected: controller.goToPage,
      );
    });
  }
}

// Additional widget for search and filters (optional)
class TransactionFiltersWidget extends StatelessWidget {
  final TransactionController controller;

  const TransactionFiltersWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Search field
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: controller.searchTransactions,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Date range filter
          Obx(() => OutlinedButton.icon(
                onPressed: () => _showDateRangePicker(context),
                icon: const Icon(Icons.date_range),
                label: Text(
                  controller.startDate != null && controller.endDate != null
                      ? '${controller.startDate!.day}/${controller.startDate!.month} - ${controller.endDate!.day}/${controller.endDate!.month}'
                      : 'Date Range',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              )),

          const SizedBox(width: 16),

          // Clear filters button
          Obx(() => controller.searchQuery.isNotEmpty ||
                  controller.startDate != null ||
                  controller.endDate != null
              ? IconButton(
                  onPressed: controller.clearAllFilters,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear filters',
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          controller.startDate != null && controller.endDate != null
              ? DateTimeRange(
                  start: controller.startDate!,
                  end: controller.endDate!,
                )
              : null,
    );

    if (picked != null) {
      controller.filterByDateRange(picked.start, picked.end);
    }
  }
}
