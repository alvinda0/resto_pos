// controllers/order_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:shao_kao/models/order/order_model.dart';
import 'package:shao_kao/services/order/order_service.dart';

class OrderController extends GetxController {
  final OrderService _orderService = OrderService();
  Timer? _autoRefreshTimer;

  // Observable variables
  var orders = <OrderModel>[].obs;
  var filteredOrders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var searchQuery = ''.obs;
  var selectedStatus = 'Semua Status'.obs;
  var selectedMethod = 'Semua Metode'.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
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
    fetchOrders();
    startAutoRefresh();

    // Listen to search query changes
    debounce(searchQuery, (_) => filterOrders(),
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
          fetchOrders(showLoading: false, isAutoRefresh: true);
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

  // Fetch orders from API
  Future<void> fetchOrders(
      {bool showLoading = true, bool isAutoRefresh = false}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }

      final response = await _orderService.getOrders(
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
      if (!isAutoRefresh || !_isOrdersEqual(orders, response.data)) {
        orders.value = response.data;
        filterOrders();
      }
    } catch (e) {
      // Only show error snackbar if it's not auto refresh
      if (!isAutoRefresh) {
        Get.snackbar(
          'Error',
          'Gagal memuat data pesanan: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
        );
      }
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  // Helper method to check if orders data has changed
  bool _isOrdersEqual(List<OrderModel> oldOrders, List<OrderModel> newOrders) {
    if (oldOrders.length != newOrders.length) return false;

    for (int i = 0; i < oldOrders.length; i++) {
      if (oldOrders[i].id != newOrders[i].id ||
          oldOrders[i].status != newOrders[i].status ||
          oldOrders[i].totalAmount != newOrders[i].totalAmount) {
        return false;
      }
    }
    return true;
  }

  // Refresh orders (manual refresh)
  Future<void> refreshOrders() async {
    isRefreshing.value = true;
    await fetchOrders(showLoading: false);
    isRefreshing.value = false;
  }

  // Filter orders based on search query
  void filterOrders() {
    if (searchQuery.value.isEmpty) {
      filteredOrders.value = orders;
    } else {
      filteredOrders.value = orders.where((order) {
        final query = searchQuery.value.toLowerCase();
        return order.customerName.toLowerCase().contains(query) ||
            order.displayId.toLowerCase().contains(query) ||
            order.customerPhone.contains(query);
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
    fetchOrders().then((_) {
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
    fetchOrders().then((_) {
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
    fetchOrders().then((_) {
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
      fetchOrders().then((_) {
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
      fetchOrders().then((_) {
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
      fetchOrders().then((_) {
        if (isAutoRefreshEnabled.value) {
          startAutoRefresh();
        }
      });
    }
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
