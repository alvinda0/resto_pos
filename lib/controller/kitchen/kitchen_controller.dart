// controllers/kitchen_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:pos/models/kitchen/kitchen_model.dart';
import 'package:pos/services/kitchen/kitchen_service.dart';

class KitchenController extends GetxController {
  final KitchenService _kitchenService = KitchenService();
  Timer? _autoRefreshTimer;

  // Observable variables
  var kitchens = <KitchenModel>[].obs;
  var filteredKitchens = <KitchenModel>[].obs;
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var searchQuery = ''.obs;
  var selectedStatus = 'Semua Status'.obs;
  var selectedMethod = 'Semua Metode'.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalItems = 0.obs;
  var itemsPerPage = 10.obs;

  // Auto refresh settings
  var isAutoRefreshEnabled = true.obs;
  final int autoRefreshInterval = 1; // seconds

  // Filter options
  final List<String> statusOptions = [
    'Semua Status',
    'PENDING',
    'PAID',
    'CANCELLED',
    'COMPLETED'
  ];

  final List<String> methodOptions = [
    'Semua Metode',
    'Tunai',
    'Qris',
  ];

  final List<int> itemsPerPageOptions = [10, 20, 50, 100];

  @override
  void onInit() {
    super.onInit();
    fetchKitchens();
    startAutoRefresh();

    // Listen to search query changes
    debounce(searchQuery, (_) => filterKitchens(),
        time: Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    stopAutoRefresh();
    super.onClose();
  }

  // Start auto refresh timer
  void startAutoRefresh() {
    if (_autoRefreshTimer != null) {
      _autoRefreshTimer!.cancel();
    }

    _autoRefreshTimer = Timer.periodic(
      Duration(seconds: autoRefreshInterval),
      (timer) {
        if (isAutoRefreshEnabled.value &&
            !isLoading.value &&
            !isRefreshing.value) {
          fetchKitchens(showLoading: false, isAutoRefresh: true);
        }
      },
    );
  }

  // Stop auto refresh timer
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  // Toggle auto refresh
  void toggleAutoRefresh() {
    isAutoRefreshEnabled.value = !isAutoRefreshEnabled.value;
    if (isAutoRefreshEnabled.value) {
      startAutoRefresh();
    } else {
      stopAutoRefresh();
    }
  }

  // Fetch kitchens from API
  Future<void> fetchKitchens(
      {bool showLoading = true, bool isAutoRefresh = false}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }

      final response = await _kitchenService.getKitchens(
        status: selectedStatus.value != 'Semua Status'
            ? selectedStatus.value
            : null,
        method: selectedMethod.value != 'Semua Metode'
            ? selectedMethod.value
            : null,
        page: currentPage.value,
        limit: itemsPerPage.value,
      );

      // Only update if data actually changed (optional optimization)
      if (!isAutoRefresh || !_isKitchensEqual(kitchens, response.data)) {
        kitchens.value = response.data;

        // Update pagination info - assuming response has pagination metadata
        // If your API doesn't provide this, you might need to calculate it
        // totalItems.value = response.totalItems ?? response.data.length;
        // totalPages.value = response.totalPages ??
        //     ((response.totalItems ?? response.data.length) / itemsPerPage.value)
        //         .ceil();

        filterKitchens();
      }
    } catch (e) {
      // Only show error snackbar if it's not auto refresh
      if (!isAutoRefresh) {
        Get.snackbar(
          'Error',
          'Gagal memuat data dapur: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
        );
      }
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  // Helper method to check if kitchens data has changed
  bool _isKitchensEqual(
      List<KitchenModel> oldKitchens, List<KitchenModel> newKitchens) {
    if (oldKitchens.length != newKitchens.length) return false;

    for (int i = 0; i < oldKitchens.length; i++) {
      if (oldKitchens[i].id != newKitchens[i].id ||
          oldKitchens[i].status != newKitchens[i].status ||
          oldKitchens[i].totalAmount != newKitchens[i].totalAmount) {
        return false;
      }
    }
    return true;
  }

  // Refresh kitchens (manual refresh)
  Future<void> refreshKitchens() async {
    isRefreshing.value = true;
    await fetchKitchens(showLoading: false);
    isRefreshing.value = false;
  }

  // Filter kitchens based on search query
  void filterKitchens() {
    if (searchQuery.value.isEmpty) {
      filteredKitchens.value = kitchens;
    } else {
      filteredKitchens.value = kitchens.where((kitchen) {
        final query = searchQuery.value.toLowerCase();
        return kitchen.customerName.toLowerCase().contains(query) ||
            kitchen.displayId.toLowerCase().contains(query) ||
            kitchen.customerPhone.contains(query);
      }).toList();
    }
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Update status filter
  void updateStatusFilter(String status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    // Stop auto refresh temporarily when user changes filter
    stopAutoRefresh();
    fetchKitchens().then((_) {
      if (isAutoRefreshEnabled.value) {
        startAutoRefresh();
      }
    });
  }

  // Update method filter
  void updateMethodFilter(String method) {
    selectedMethod.value = method;
    currentPage.value = 1;
    // Stop auto refresh temporarily when user changes filter
    stopAutoRefresh();
    fetchKitchens().then((_) {
      if (isAutoRefreshEnabled.value) {
        startAutoRefresh();
      }
    });
  }

  // Update items per page
  void updateItemsPerPage(int items) {
    itemsPerPage.value = items;
    currentPage.value = 1;
    // Stop auto refresh temporarily when user changes items per page
    stopAutoRefresh();
    fetchKitchens().then((_) {
      if (isAutoRefreshEnabled.value) {
        startAutoRefresh();
      }
    });
  }

  // Navigate to page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      // Stop auto refresh temporarily when user changes page
      stopAutoRefresh();
      fetchKitchens().then((_) {
        if (isAutoRefreshEnabled.value) {
          startAutoRefresh();
        }
      });
    }
  }

  // Next page
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      // Stop auto refresh temporarily when user changes page
      stopAutoRefresh();
      fetchKitchens().then((_) {
        if (isAutoRefreshEnabled.value) {
          startAutoRefresh();
        }
      });
    }
  }

  // Previous page
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      // Stop auto refresh temporarily when user changes page
      stopAutoRefresh();
      fetchKitchens().then((_) {
        if (isAutoRefreshEnabled.value) {
          startAutoRefresh();
        }
      });
    }
  }

  // Pagination helper methods
  int get startIndex {
    if (totalItems.value == 0) return 0;
    return ((currentPage.value - 1) * itemsPerPage.value) + 1;
  }

  int get endIndex {
    final end = currentPage.value * itemsPerPage.value;
    return end > totalItems.value ? totalItems.value : end;
  }

  bool get hasPreviousPage {
    return currentPage.value > 1;
  }

  bool get hasNextPage {
    return currentPage.value < totalPages.value;
  }

  List<int> get pageNumbers {
    final List<int> pages = [];
    const int maxVisible = 5; // Maximum visible page numbers

    if (totalPages.value <= maxVisible) {
      // If total pages is less than max visible, show all pages
      for (int i = 1; i <= totalPages.value; i++) {
        pages.add(i);
      }
    } else {
      // Calculate range around current page
      int start =
          (currentPage.value - (maxVisible ~/ 2)).clamp(1, totalPages.value);
      int end = (start + maxVisible - 1).clamp(1, totalPages.value);

      // Adjust start if we're near the end
      if (end == totalPages.value) {
        start = (end - maxVisible + 1).clamp(1, totalPages.value);
      }

      for (int i = start; i <= end; i++) {
        pages.add(i);
      }
    }

    return pages;
  }

  // Helper methods
  String formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  // Get status color
  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return '#10B981'; // Green
      case 'pending':
        return '#F59E0B'; // Yellow
      case 'cancelled':
        return '#EF4444'; // Red
      case 'completed':
        return '#3B82F6'; // Blue
      default:
        return '#6B7280'; // Gray
    }
  }

  // Get status text color
  String getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return '#FFFFFF';
      case 'pending':
        return '#FFFFFF';
      case 'cancelled':
        return '#FFFFFF';
      case 'completed':
        return '#FFFFFF';
      default:
        return '#FFFFFF';
    }
  }
}
