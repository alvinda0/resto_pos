// controllers/transaction_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/transaction/transaction_model.dart';
import 'package:pos/services/transaction/transaction_service.dart';

class TransactionController extends GetxController {
  final TransactionService _transactionService = TransactionService.instance;

  // Observable variables
  final RxList<Transaction> _transactions = <Transaction>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _isLoadingRekap = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _itemsPerPage = 10.obs;
  final RxInt _totalItems = 0.obs;
  final RxInt _totalPages = 0.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedTab = 'rinci'.obs;

  // Rekap data
  final RxList<Map<String, dynamic>> _rekapData = <Map<String, dynamic>>[].obs;

  // Available page sizes
  final List<int> availablePageSizes = [5, 10, 20, 50, 100];

  // Date filter
  final Rxn<DateTime> _startDate = Rxn<DateTime>();
  final Rxn<DateTime> _endDate = Rxn<DateTime>();

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get isLoadingRekap => _isLoadingRekap.value;
  String get errorMessage => _errorMessage.value;
  int get currentPage => _currentPage.value;
  int get itemsPerPage => _itemsPerPage.value;
  int get totalItems => _totalItems.value;
  int get totalPages => _totalPages.value;
  String get searchQuery => _searchQuery.value;
  DateTime? get startDate => _startDate.value;
  DateTime? get endDate => _endDate.value;
  String get selectedTab => _selectedTab.value;
  List<Map<String, dynamic>> get rekapData => _rekapData;

  // Rekap summary getters
  double get totalRevenue {
    return _rekapData.fold(
        0.0, (sum, data) => sum + (data['total'] as double? ?? 0.0));
  }

  double get averageTransaction {
    if (_rekapData.isEmpty) return 0.0;
    int totalTransactions =
        _rekapData.fold(0, (sum, data) => sum + (data['count'] as int? ?? 0));
    return totalTransactions > 0 ? totalRevenue / totalTransactions : 0.0;
  }

  // Pagination helpers
  bool get hasPreviousPage => _currentPage.value > 1;
  bool get hasNextPage => _currentPage.value < _totalPages.value;
  int get startIndex => totalItems == 0
      ? 0
      : ((_currentPage.value - 1) * _itemsPerPage.value) + 1;
  int get endIndex => totalItems == 0
      ? 0
      : (_currentPage.value * _itemsPerPage.value > totalItems)
          ? totalItems
          : _currentPage.value * _itemsPerPage.value;

  // Generate page numbers for pagination widget
  List<int> get pageNumbers {
    if (_totalPages.value <= 7) {
      return List.generate(_totalPages.value, (index) => index + 1);
    }

    List<int> pages = [];
    int current = _currentPage.value;
    int total = _totalPages.value;

    // Always include first page
    pages.add(1);

    if (current > 4) {
      pages.add(-1); // Ellipsis placeholder
    }

    // Add pages around current page
    int start = (current - 2).clamp(2, total - 1);
    int end = (current + 2).clamp(2, total - 1);

    for (int i = start; i <= end; i++) {
      if (!pages.contains(i)) {
        pages.add(i);
      }
    }

    if (current < total - 3) {
      pages.add(-1); // Ellipsis placeholder
    }

    // Always include last page
    if (total > 1 && !pages.contains(total)) {
      pages.add(total);
    }

    return pages.where((page) => page != -1).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
    // Load rekap data on initialization so it's ready when tab is clicked
    loadRekapData();
  }

  /// Switch between tabs
  Future<void> switchTab(String tab) async {
    if (_selectedTab.value != tab) {
      _selectedTab.value = tab;
      if (tab == 'rekap' && _rekapData.isEmpty) {
        // Only load rekap data if it's empty
        await loadRekapData();
      }
    }
  }

  /// Generate rekap data from currently loaded transactions (for initial load)
  void _generateRekapDataFromCurrentTransactions() {
    if (_transactions.isNotEmpty) {
      _generateRekapData(_transactions);
    }
  }

  /// Load rekap/summary data
  Future<void> loadRekapData() async {
    try {
      _isLoadingRekap.value = true;

      // If we already have transactions loaded and no filters applied,
      // use existing data to avoid unnecessary API calls
      if (_transactions.isNotEmpty &&
          _searchQuery.value.isEmpty &&
          _startDate.value == null &&
          _endDate.value == null &&
          _currentPage.value == 1) {
        _generateRekapData(_transactions);
        _isLoadingRekap.value = false;
        return;
      }

      // Get all transactions for summary (without pagination)
      TransactionResponse response;

      if (_searchQuery.value.isNotEmpty) {
        response = await _transactionService.searchTransactions(
          query: _searchQuery.value,
          page: 1,
          limit: 1000, // Get more records for summary
        );
      } else if (_startDate.value != null || _endDate.value != null) {
        response = await _transactionService.getTransactionsByDateRange(
          startDate: _startDate.value,
          endDate: _endDate.value,
          page: 1,
          limit: 1000,
        );
      } else {
        response = await _transactionService.getTransactions(
          page: 1,
          limit: 1000,
        );
      }

      if (response.success) {
        _generateRekapData(response.data);
      } else {
        _errorMessage.value = response.message;
      }
    } catch (e) {
      _errorMessage.value = 'Error loading rekap data: $e';
    } finally {
      _isLoadingRekap.value = false;
    }
  }

  /// Generate rekap data from transactions
  void _generateRekapData(List<Transaction> transactions) {
    Map<String, Map<String, dynamic>> dailyData = {};

    // Group transactions by date
    for (Transaction transaction in transactions) {
      String dateKey = transaction.formattedDate;

      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = {
          'date': dateKey,
          'count': 0,
          'total': 0.0,
          'subtotal': 0.0,
          'tax': 0.0,
        };
      }

      dailyData[dateKey]!['count'] = (dailyData[dateKey]!['count'] as int) + 1;
      dailyData[dateKey]!['total'] =
          (dailyData[dateKey]!['total'] as double) + transaction.totalAmount;
      dailyData[dateKey]!['subtotal'] =
          (dailyData[dateKey]!['subtotal'] as double) + transaction.baseAmount;
      dailyData[dateKey]!['tax'] =
          (dailyData[dateKey]!['tax'] as double) + transaction.taxAmount;
    }

    // Convert to list and calculate averages
    List<Map<String, dynamic>> rekapList = dailyData.values.map((data) {
      final count = data['count'] as int;
      final total = data['total'] as double;
      data['average'] = count > 0 ? total / count : 0.0;
      return data;
    }).toList();

    // Sort by date (newest first)
    rekapList.sort((a, b) {
      // Parse date format dd/mm/yyyy for sorting
      List<String> partsA = (a['date'] as String).split('/');
      List<String> partsB = (b['date'] as String).split('/');

      DateTime dateA = DateTime(
        int.parse(partsA[2]), // year
        int.parse(partsA[1]), // month
        int.parse(partsA[0]), // day
      );

      DateTime dateB = DateTime(
        int.parse(partsB[2]),
        int.parse(partsB[1]),
        int.parse(partsB[0]),
      );

      return dateB.compareTo(dateA); // Newest first
    });

    _rekapData.value = rekapList;
  }

  /// Load transactions with current filters
  Future<void> loadTransactions({bool refresh = false}) async {
    try {
      if (refresh || _currentPage.value == 1) {
        _isLoading.value = true;
        _transactions.clear();
      } else {
        _isLoadingMore.value = true;
      }

      _errorMessage.value = '';

      TransactionResponse response;

      if (_searchQuery.value.isNotEmpty) {
        response = await _transactionService.searchTransactions(
          query: _searchQuery.value,
          page: _currentPage.value,
          limit: _itemsPerPage.value,
        );
      } else if (_startDate.value != null || _endDate.value != null) {
        response = await _transactionService.getTransactionsByDateRange(
          startDate: _startDate.value,
          endDate: _endDate.value,
          page: _currentPage.value,
          limit: _itemsPerPage.value,
        );
      } else {
        response = await _transactionService.getTransactions(
          page: _currentPage.value,
          limit: _itemsPerPage.value,
        );
      }

      if (response.success) {
        if (refresh || _currentPage.value == 1) {
          _transactions.value = response.data;
        } else {
          _transactions.addAll(response.data);
        }

        _totalItems.value = response.metadata.total;
        _totalPages.value = response.metadata.totalPages;

        // Always update rekap data when transactions are loaded
        // Use the same response data to avoid duplicate API calls
        _generateRekapDataFromCurrentTransactions();
      } else {
        _errorMessage.value = response.message;
      }
    } catch (e) {
      _errorMessage.value = 'Error loading transactions: $e';
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
    }
  }

  /// Refresh transactions
  Future<void> refreshTransactions() async {
    _currentPage.value = 1;
    await loadTransactions(refresh: true);
  }

  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= _totalPages.value && page != _currentPage.value) {
      _currentPage.value = page;
      await loadTransactions();
    }
  }

  /// Go to next page
  Future<void> nextPage() async {
    if (hasNextPage) {
      await goToPage(_currentPage.value + 1);
    }
  }

  /// Go to previous page
  Future<void> previousPage() async {
    if (hasPreviousPage) {
      await goToPage(_currentPage.value - 1);
    }
  }

  /// Change items per page
  Future<void> changeItemsPerPage(int newItemsPerPage) async {
    if (newItemsPerPage != _itemsPerPage.value) {
      _itemsPerPage.value = newItemsPerPage;
      _currentPage.value = 1;
      await loadTransactions(refresh: true);
    }
  }

  /// Search transactions
  Future<void> searchTransactions(String query) async {
    _searchQuery.value = query;
    _currentPage.value = 1;
    await loadTransactions(refresh: true);
    // Refresh rekap data with new search
    if (_selectedTab.value == 'rekap') {
      await loadRekapData();
    }
  }

  /// Clear search
  Future<void> clearSearch() async {
    _searchQuery.value = '';
    _currentPage.value = 1;
    await loadTransactions(refresh: true);
    // Refresh rekap data
    if (_selectedTab.value == 'rekap') {
      await loadRekapData();
    }
  }

  /// Filter by date range
  Future<void> filterByDateRange(DateTime? start, DateTime? end) async {
    _startDate.value = start;
    _endDate.value = end;
    _currentPage.value = 1;
    await loadTransactions(refresh: true);
    // Refresh rekap data with new date filter
    if (_selectedTab.value == 'rekap') {
      await loadRekapData();
    }
  }

  /// Clear date filter
  Future<void> clearDateFilter() async {
    _startDate.value = null;
    _endDate.value = null;
    _currentPage.value = 1;
    await loadTransactions(refresh: true);
    // Refresh rekap data
    if (_selectedTab.value == 'rekap') {
      await loadRekapData();
    }
  }

  /// Clear all filters
  Future<void> clearAllFilters() async {
    _searchQuery.value = '';
    _startDate.value = null;
    _endDate.value = null;
    _currentPage.value = 1;
    await loadTransactions(refresh: true);
    // Refresh rekap data
    if (_selectedTab.value == 'rekap') {
      await loadRekapData();
    }
  }

  /// Get transaction by ID
  Future<Transaction?> getTransactionById(String id) async {
    try {
      return await _transactionService.getTransactionById(id);
    } catch (e) {
      _errorMessage.value = 'Error getting transaction: $e';
      return null;
    }
  }

  /// Export transactions
  Future<bool> exportTransactions({String format = 'excel'}) async {
    try {
      return await _transactionService.exportTransactions(
        startDate: _startDate.value,
        endDate: _endDate.value,
        format: format,
      );
    } catch (e) {
      _errorMessage.value = 'Error exporting transactions: $e';
      return false;
    }
  }

  /// Format currency helper
  String formatCurrency(double amount) {
    return _transactionService.formatCurrency(amount);
  }

  /// Get transaction status
  String getTransactionStatus(Transaction transaction) {
    return _transactionService.getTransactionStatus(transaction);
  }

  /// Calculate total amount for selected transactions
  double calculateSelectedTotal(List<Transaction> selectedTransactions) {
    return selectedTransactions.fold(
        0.0, (sum, transaction) => sum + transaction.totalAmount);
  }

  /// Calculate subtotal for selected transactions
  double calculateSelectedSubtotal(List<Transaction> selectedTransactions) {
    return selectedTransactions.fold(
        0.0, (sum, transaction) => sum + transaction.subtotal);
  }

  /// Calculate tax for selected transactions
  double calculateSelectedTax(List<Transaction> selectedTransactions) {
    return selectedTransactions.fold(
        0.0, (sum, transaction) => sum + transaction.taxAmount);
  }

  /// Get monthly summary
  Map<String, dynamic> getMonthlySummary() {
    if (_rekapData.isEmpty) {
      return {
        'totalTransactions': 0,
        'totalRevenue': 0.0,
        'averagePerDay': 0.0,
        'averagePerTransaction': 0.0,
      };
    }

    int totalTransactions =
        _rekapData.fold(0, (sum, data) => sum + (data['count'] as int? ?? 0));
    double totalRevenue = _rekapData.fold(
        0.0, (sum, data) => sum + (data['total'] as double? ?? 0.0));
    double averagePerDay = totalRevenue / _rekapData.length;
    double averagePerTransaction =
        totalTransactions > 0 ? totalRevenue / totalTransactions : 0.0;

    return {
      'totalTransactions': totalTransactions,
      'totalRevenue': totalRevenue,
      'averagePerDay': averagePerDay,
      'averagePerTransaction': averagePerTransaction,
    };
  }

  /// Get best performing day
  Map<String, dynamic>? getBestPerformingDay() {
    if (_rekapData.isEmpty) return null;

    Map<String, dynamic> bestDay = _rekapData.first;
    for (Map<String, dynamic> data in _rekapData) {
      final currentTotal = data['total'] as double? ?? 0.0;
      final bestTotal = bestDay['total'] as double? ?? 0.0;
      if (currentTotal > bestTotal) {
        bestDay = data;
      }
    }
    return bestDay;
  }

  /// Get transaction trend (comparing with previous period)
  String getTransactionTrend() {
    if (_rekapData.length < 2) return 'neutral';

    // Compare last 3 days average with previous 3 days average
    int halfLength = (_rekapData.length / 2).floor();

    double recentTotal = _rekapData
        .take(halfLength)
        .fold(0.0, (sum, data) => sum + (data['total'] as double? ?? 0.0));
    double recentAverage = recentTotal / halfLength;

    double previousTotal = _rekapData
        .skip(halfLength)
        .fold(0.0, (sum, data) => sum + (data['total'] as double? ?? 0.0));
    double previousAverage = previousTotal / (_rekapData.length - halfLength);

    if (recentAverage > previousAverage * 1.05) {
      return 'up';
    } else if (recentAverage < previousAverage * 0.95) {
      return 'down';
    } else {
      return 'stable';
    }
  }

  /// Show error message
  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show success message
  void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 3),
    );
  }
}
