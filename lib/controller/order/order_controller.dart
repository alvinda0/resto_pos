// controllers/order_controller.dart
import 'package:get/get.dart';
import 'package:pos/models/order/order_model.dart';
import 'package:pos/services/order/order_service.dart';

class OrderController extends GetxController {
  final OrderService _orderService = OrderService();

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
    'Transfer',
    'Kartu Kredit'
  ];

  final List<int> itemsPerPageOptions = [10, 20, 50, 100];

  @override
  void onInit() {
    super.onInit();
    fetchOrders();

    // Listen to search query changes
    debounce(searchQuery, (_) => filterOrders(),
        time: Duration(milliseconds: 500));
  }

  // Fetch orders from API
  Future<void> fetchOrders({bool showLoading = true}) async {
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

      orders.value = response.data;
      filterOrders();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data pesanan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  // Refresh orders
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
    fetchOrders();
  }

  // Update method filter
  void updateMethodFilter(String method) {
    selectedMethod.value = method;
    currentPage.value = 1;
    fetchOrders();
  }

  // Update items per page
  void updateItemsPerPage(int items) {
    itemsPerPage.value = items;
    currentPage.value = 1;
    fetchOrders();
  }

  // Navigate to page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchOrders();
    }
  }

  // Next page
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchOrders();
    }
  }

  // Previous page
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchOrders();
    }
  }

  // Pay order
  Future<void> payOrder(
      String orderId, Map<String, dynamic> paymentData) async {
    try {
      isLoading.value = true;

      await _orderService.payOrder(orderId, paymentData);

      Get.snackbar(
        'Sukses',
        'Pembayaran berhasil diproses',
        snackPosition: SnackPosition.TOP,
      );

      // Refresh orders
      await fetchOrders(showLoading: false);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memproses pembayaran: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      isLoading.value = true;

      await _orderService.updateOrderStatus(orderId, status);

      Get.snackbar(
        'Sukses',
        'Status pesanan berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
      );

      // Refresh orders
      await fetchOrders(showLoading: false);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui status pesanan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete order
  Future<void> deleteOrder(String orderId) async {
    try {
      isLoading.value = true;

      await _orderService.deleteOrder(orderId);

      Get.snackbar(
        'Sukses',
        'Pesanan berhasil dihapus',
        snackPosition: SnackPosition.TOP,
      );

      // Refresh orders
      await fetchOrders(showLoading: false);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus pesanan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      return await _orderService.getOrderById(orderId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat detail pesanan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return null;
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
