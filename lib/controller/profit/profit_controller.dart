// controllers/profit_report_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/profit/profit_model.dart';
import 'package:pos/services/profit/profit_service.dart';

class ProfitReportController extends GetxController
    with GetTickerProviderStateMixin {
  final ProfitReportService _profitReportService = ProfitReportService.instance;

  // Tab controller
  late TabController tabController;

  // Observable variables
  final _isLoading = false.obs;
  final _isExporting = false.obs;
  final _reports = <ProfitReport>[].obs;
  final _allReports = <ProfitReport>[].obs; // For summary calculation
  final _totalItems = 0.obs;
  final _currentPage = 1.obs;
  final _itemsPerPage = 10.obs;
  final _periodType = PeriodType.monthly.obs;
  final _startDate = DateTime.now().obs;
  final _endDate = DateTime.now().obs;
  final _summaryData = <String, double>{}.obs;

  // Available page sizes
  final List<int> availablePageSizes = [5, 10, 25, 50];

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isExporting => _isExporting.value;
  List<ProfitReport> get reports => _reports;
  int get totalItems => _totalItems.value;
  int get currentPage => _currentPage.value;
  int get itemsPerPage => _itemsPerPage.value;
  PeriodType get periodType => _periodType.value;
  DateTime get startDate => _startDate.value;
  DateTime get endDate => _endDate.value;
  Map<String, double> get summaryData => _summaryData;

  // Pagination getters
  int get totalPages => (totalItems / itemsPerPage).ceil();
  int get startIndex =>
      totalItems == 0 ? 0 : (currentPage - 1) * itemsPerPage + 1;
  int get endIndex => (currentPage * itemsPerPage).clamp(0, totalItems);
  bool get hasPreviousPage => currentPage > 1;
  bool get hasNextPage => currentPage < totalPages;

  List<int> get pageNumbers {
    if (totalPages <= 1) return [1];

    List<int> pages = [];
    for (int i = 1; i <= totalPages; i++) {
      pages.add(i);
    }
    return pages;
  }

  @override
  void onInit() {
    super.onInit();

    // Initialize tab controller
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_onTabChanged);

    // Set default date range
    _initializeDateRange();

    // Load initial data
    loadProfitReports();
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) return;

    final newPeriodType =
        tabController.index == 0 ? PeriodType.monthly : PeriodType.yearly;
    if (newPeriodType != _periodType.value) {
      _periodType.value = newPeriodType;
      _currentPage.value = 1;
      _initializeDateRange();
      loadProfitReports();
    }
  }

  void _initializeDateRange() {
    final dateRange =
        _profitReportService.getDefaultDateRange(_periodType.value);
    _startDate.value = dateRange['startDate']!;
    _endDate.value = dateRange['endDate']!;
  }

  // Load profit reports
  Future<void> loadProfitReports() async {
    try {
      _isLoading.value = true;

      final response = await _profitReportService.getProfitReports(
        periodType: _periodType.value,
        startDate: _startDate.value,
        endDate: _endDate.value,
        page: _currentPage.value,
        limit: _itemsPerPage.value,
      );

      _reports.value = response.reports;
      _totalItems.value = response.total;

      // Load all reports for summary calculation
      await _loadAllReportsForSummary();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat laporan laba rugi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load all reports for summary calculation (without pagination)
  Future<void> _loadAllReportsForSummary() async {
    try {
      final allReports = await _profitReportService.getAllProfitReports(
        periodType: _periodType.value,
        startDate: _startDate.value,
        endDate: _endDate.value,
      );

      _allReports.value = allReports;
      _summaryData.value = _profitReportService.getSummaryData(allReports);
    } catch (e) {
      print('Error loading all reports for summary: $e');
      _summaryData.value = {};
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    _currentPage.value = 1;
    await loadProfitReports();
  }

  // Pagination methods
  void onPageSizeChanged(int newSize) {
    _itemsPerPage.value = newSize;
    _currentPage.value = 1;
    loadProfitReports();
  }

  void onPreviousPage() {
    if (hasPreviousPage) {
      _currentPage.value--;
      loadProfitReports();
    }
  }

  void onNextPage() {
    if (hasNextPage) {
      _currentPage.value++;
      loadProfitReports();
    }
  }

  void onPageSelected(int page) {
    if (page != _currentPage.value && page >= 1 && page <= totalPages) {
      _currentPage.value = page;
      loadProfitReports();
    }
  }

  // Date range selection
  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange:
          DateTimeRange(start: _startDate.value, end: _endDate.value),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _startDate.value = picked.start;
      _endDate.value = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
      );
      _currentPage.value = 1;
      await loadProfitReports();
    }
  }

  // Export to CSV
  Future<void> exportToCsv() async {
    try {
      _isExporting.value = true;

      await _profitReportService.exportAndSaveCsv(
        startDate: _startDate.value,
        endDate: _endDate.value,
        periodType: _periodType.value,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengekspor file CSV: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      _isExporting.value = false;
    }
  }

  // Switch period type programmatically
  void switchPeriodType(PeriodType newPeriodType) {
    if (newPeriodType != _periodType.value) {
      _periodType.value = newPeriodType;
      tabController.animateTo(newPeriodType == PeriodType.monthly ? 0 : 1);
      _currentPage.value = 1;
      _initializeDateRange();
      loadProfitReports();
    }
  }

  // Format currency for summary
  String formatCurrency(double amount) {
    if (amount == 0) return 'Rp 0';

    final isNegative = amount < 0;
    final absAmount = amount.abs();

    String formatted = '';
    if (absAmount >= 1000000000) {
      formatted = 'Rp ${(absAmount / 1000000000).toStringAsFixed(1)}B';
    } else if (absAmount >= 1000000) {
      formatted = 'Rp ${(absAmount / 1000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000) {
      formatted = 'Rp ${(absAmount / 1000).toStringAsFixed(1)}K';
    } else {
      formatted = 'Rp ${absAmount.toStringAsFixed(0)}';
    }

    return isNegative ? '-$formatted' : formatted;
  }

  // Get formatted date range for display
  String get formattedDateRange {
    final startFormatted =
        '${_startDate.value.day}/${_startDate.value.month}/${_startDate.value.year}';
    final endFormatted =
        '${_endDate.value.day}/${_endDate.value.month}/${_endDate.value.year}';
    return '$startFormatted - $endFormatted';
  }
}
