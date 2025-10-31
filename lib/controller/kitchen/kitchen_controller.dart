// controllers/kitchen_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shao_kao/models/kitchen/kitchen_model.dart';
import 'package:shao_kao/services/kitchen/kitchen_service.dart';
import 'package:shao_kao/services/order/PrintServiceOrder.dart';
import 'package:shao_kao/screens/printer/BluetoothPrinterManager.dart';

class KitchenController extends GetxController {
  final KitchenService _kitchenService = KitchenService();
  final PrintService _printService = PrintService();
  Timer? _autoRefreshTimer;

  // Observable variables
  var kitchens = <KitchenModel>[].obs;
  var filteredKitchens = <KitchenModel>[].obs;
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var isCompletingOrder = false.obs; // Loading state untuk complete order
  var searchQuery = ''.obs;
  var selectedStatus = 'Semua Status'.obs;
  var selectedMethod = 'Semua Metode'.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalItems = 0.obs;
  var itemsPerPage = 10.obs;

  // Auto refresh settings
  var isAutoRefreshEnabled = true.obs;
  final int autoRefreshInterval =
      10; // detik (ubah ke 10 detik untuk lebih responsif)

  // Auto print settings
  var isAutoPrintEnabled = true.obs;
  Set<String> _printedOrderIds = <String>{}; // Track printed orders

  // Filter options - disesuaikan dengan API
  final List<String> statusOptions = [
    'Semua Status',
    'RECEIVED',
    'PROCESSED',
    'COMPLETED',
    'CANCELLED'
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

    print('KitchenController: Starting auto refresh with ${autoRefreshInterval}s interval');
    
    _autoRefreshTimer = Timer.periodic(
      Duration(seconds: autoRefreshInterval),
      (timer) {
        print('KitchenController: Auto refresh tick - enabled: ${isAutoRefreshEnabled.value}, loading: ${isLoading.value}, refreshing: ${isRefreshing.value}, completing: ${isCompletingOrder.value}');
        
        if (isAutoRefreshEnabled.value &&
            !isLoading.value &&
            !isRefreshing.value &&
            !isCompletingOrder.value) {
          print('KitchenController: Executing auto refresh...');
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
      Get.snackbar(
        'Auto Refresh',
        'Auto refresh diaktifkan - data akan diperbarui setiap ${autoRefreshInterval} detik',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade600,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } else {
      stopAutoRefresh();
      Get.snackbar(
        'Auto Refresh',
        'Auto refresh dinonaktifkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.grey.shade600,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Toggle auto print
  void toggleAutoPrint() {
    isAutoPrintEnabled.value = !isAutoPrintEnabled.value;
    
    // Debug info
    print('KitchenController: Auto print toggled to: ${isAutoPrintEnabled.value}');
    print('KitchenController: Printed orders count: ${_printedOrderIds.length}');
    
    Get.snackbar(
      'Auto Print',
      isAutoPrintEnabled.value 
        ? 'Auto print diaktifkan - pesanan PROCESSED akan otomatis dicetak'
        : 'Auto print dinonaktifkan',
      snackPosition: SnackPosition.TOP,
      backgroundColor: isAutoPrintEnabled.value 
        ? Get.theme.primaryColor 
        : Get.theme.colorScheme.secondary,
      colorText: Get.theme.primaryColorLight,
      duration: Duration(seconds: 3),
    );
  }

  // Reset printed orders (for testing)
  void resetPrintedOrders() {
    _printedOrderIds.clear();
    print('KitchenController: Printed orders list cleared');
    Get.snackbar(
      'Debug',
      'Daftar pesanan yang sudah dicetak direset',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  // Check printer status
  Future<void> checkPrinterStatus() async {
    try {
      bool connected = await _printService.checkPrinterConnection();
      Map<String, dynamic> status = _printService.getPrinterStatus();
      
      print('KitchenController: Printer status - Connected: $connected');
      print('KitchenController: Printer details: $status');
      
      Get.snackbar(
        'Status Printer',
        connected 
          ? 'Printer terhubung (${status['connectedCount']} printer)'
          : 'Printer tidak terhubung',
        snackPosition: SnackPosition.TOP,
        backgroundColor: connected ? Colors.green.shade600 : Colors.red.shade600,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('KitchenController: Error checking printer status: $e');
    }
  }

  // Check for status changes and print newly processed orders
  Future<void> _checkAndPrintStatusChanges(List<KitchenModel> oldOrders, List<KitchenModel> newOrders) async {
    try {
      print('KitchenController: Checking for status changes - Old: ${oldOrders.length}, New: ${newOrders.length}');
      
      // Create map of old orders for quick lookup
      Map<String, KitchenModel> oldOrdersMap = {
        for (var order in oldOrders) order.id: order
      };
      
      List<KitchenModel> ordersToProcess = [];
      
      // Check each new order
      for (var newOrder in newOrders) {
        KitchenModel? oldOrder = oldOrdersMap[newOrder.id];
        
        if (oldOrder == null) {
          // This is a completely new order
          if (newOrder.dishStatus.toLowerCase() == 'processed' && 
              !_printedOrderIds.contains(newOrder.id)) {
            print('KitchenController: New order ${newOrder.displayId} with PROCESSED status');
            ordersToProcess.add(newOrder);
          }
        } else {
          // This order existed before, check for status change
          bool statusChanged = oldOrder.dishStatus.toLowerCase() != newOrder.dishStatus.toLowerCase();
          bool nowProcessed = newOrder.dishStatus.toLowerCase() == 'processed';
          bool notPrinted = !_printedOrderIds.contains(newOrder.id);
          
          print('KitchenController: Order ${newOrder.displayId} - Old status: ${oldOrder.dishStatus}, New status: ${newOrder.dishStatus}');
          print('KitchenController: Status changed: $statusChanged, Now processed: $nowProcessed, Not printed: $notPrinted');
          
          if (statusChanged && nowProcessed && notPrinted) {
            print('KitchenController: Order ${newOrder.displayId} status changed to PROCESSED - will print');
            ordersToProcess.add(newOrder);
          }
        }
      }

      print('KitchenController: Found ${ordersToProcess.length} orders with status changes to print');

      if (ordersToProcess.isNotEmpty) {
        for (KitchenModel order in ordersToProcess) {
          print('KitchenController: Auto printing order ${order.displayId} (status changed to ${order.dishStatus})');
          
          bool printSuccess = await _printKitchenOrder(order);
          
          if (printSuccess) {
            _printedOrderIds.add(order.id);
            print('KitchenController: Successfully auto printed order ${order.displayId}');
            
            // Show success notification
            Get.snackbar(
              '🖨️ Auto Print',
              'Pesanan ${order.displayId} berubah ke PROCESSED - berhasil dicetak otomatis',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green.shade600,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
              icon: Icon(Icons.print, color: Colors.white),
            );
          } else {
            print('KitchenController: Failed to auto print order ${order.displayId}');
            
            // Show error notification
            Get.snackbar(
              '⚠️ Auto Print Gagal',
              'Gagal mencetak pesanan ${order.displayId} - cek koneksi printer',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.orange.shade600,
              colorText: Colors.white,
              duration: Duration(seconds: 4),
              icon: Icon(Icons.warning, color: Colors.white),
            );
          }
        }
      } else {
        print('KitchenController: No status changes to PROCESSED detected');
      }
    } catch (e) {
      print('KitchenController: Error in status change detection: $e');
    }
  }

  // Print kitchen order
  Future<bool> _printKitchenOrder(KitchenModel kitchenOrder) async {
    try {
      // Convert KitchenModel to format expected by BluetoothPrinterManager
      final orderData = {
        'displayId': kitchenOrder.displayId,
        'date': formatDate(kitchenOrder.createdAt),
        'customerName': kitchenOrder.customerName,
        'customerPhone': kitchenOrder.customerPhone,
        'tableNumber': kitchenOrder.tableNumber.toString(),
        'status': 'Kitchen Order',
        'dishStatus': kitchenOrder.dishStatus,
        'notes': kitchenOrder.notes ?? '',
        'formattedTotal': 'Rp${_formatPrice(kitchenOrder.totalAmount.round())}',
        'items': kitchenOrder.items.map((item) => {
          'productName': item.productName,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'note': item.note ?? '',
        }).toList(),
      };

      // Print using kitchen-specific format
      return await _printKitchenReceipt(orderData);
    } catch (e) {
      print('KitchenController: Error printing kitchen order: $e');
      return false;
    }
  }

  // Print kitchen receipt with kitchen-specific format
  Future<bool> _printKitchenReceipt(Map<String, dynamic> orderData) async {
    try {
      bool connectionOk = await _printService.checkPrinterConnection();
      
      if (!connectionOk) {
        print('KitchenController: No printer connected for kitchen print');
        return false;
      }

      // Use the existing print service method with kitchen-specific data
      // The BluetoothPrinterManager will handle role-specific printing
      final printerManager = BluetoothPrinterManager();
      Map<String, bool> results = await printerManager.printToAllWithContent(orderData);
      
      // Return true if at least one printer succeeded
      return results.values.any((success) => success);
    } catch (e) {
      print('KitchenController: Error printing kitchen receipt: $e');
      return false;
    }
  }





  // Fetch kitchens from API
  Future<void> fetchKitchens(
      {bool showLoading = true, bool isAutoRefresh = false}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }

      print('KitchenController: Fetching kitchens - autoRefresh: $isAutoRefresh, showLoading: $showLoading');

      final response = await _kitchenService.getKitchens(
        statusPesanan: selectedStatus.value != 'Semua Status'
            ? selectedStatus.value
            : null,
        method: selectedMethod.value != 'Semua Metode'
            ? selectedMethod.value
            : null,
        page: currentPage.value,
        limit: itemsPerPage.value,
      );

      print('KitchenController: API response received - ${response.data.length} items');

      // Update data jika berubah atau bukan auto refresh
      bool dataChanged = !_isKitchensEqual(kitchens, response.data);
      print('KitchenController: Data changed: $dataChanged, isAutoRefresh: $isAutoRefresh');
      print('KitchenController: Auto print enabled: ${isAutoPrintEnabled.value}');
      
      // Check for new orders BEFORE updating data (always check if auto print enabled)
      if (isAutoPrintEnabled.value && isAutoRefresh) {
        print('KitchenController: Checking for status changes to print...');
        await _checkAndPrintStatusChanges(kitchens, response.data);
      }
      
      if (!isAutoRefresh || dataChanged) {

        kitchens.value = response.data;
        print('KitchenController: Updated kitchens list with ${response.data.length} items');

        // Update pagination info dari metadata
        if (response.metadata != null) {
          totalItems.value = response.metadata!.total;
          totalPages.value = response.metadata!.totalPages;
          currentPage.value = response.metadata!.page;
        } else {
          // Fallback jika tidak ada metadata
          totalItems.value = response.data.length;
          totalPages.value = 1;
        }

        filterKitchens();
      } else {
        print('KitchenController: No data changes detected, skipping update');
      }
    } catch (e) {
      print('KitchenController: Error fetching kitchens: $e');
      // Hanya tampilkan error snackbar jika bukan auto refresh
      if (!isAutoRefresh) {
        Get.snackbar(
          'Kesalahan',
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

  // Helper method untuk cek apakah data kitchens berubah
  bool _isKitchensEqual(
      List<KitchenModel> oldKitchens, List<KitchenModel> newKitchens) {
    if (oldKitchens.length != newKitchens.length) return false;

    for (int i = 0; i < oldKitchens.length; i++) {
      if (oldKitchens[i].id != newKitchens[i].id ||
          oldKitchens[i].status != newKitchens[i].status ||
          oldKitchens[i].dishStatus != newKitchens[i].dishStatus ||
          oldKitchens[i].totalAmount != newKitchens[i].totalAmount) {
        return false;
      }
    }
    return true;
  }

  // Method untuk menyelesaikan pesanan
  Future<void> completeOrder(String orderId, String displayId) async {
    try {
      isCompletingOrder.value = true;

      // Hentikan auto refresh sementara
      stopAutoRefresh();

      final response = await _kitchenService.completeOrder(orderId);

      if (response.success) {
        Get.snackbar(
          'Berhasil',
          'Pesanan $displayId berhasil diselesaikan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.primaryColor,
          colorText: Get.theme.primaryColorLight,
          duration: Duration(seconds: 3),
        );

        // Refresh data untuk mendapatkan status terbaru
        await fetchKitchens(showLoading: false);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      Get.snackbar(
        'Kesalahan',
        'Gagal menyelesaikan pesanan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: Duration(seconds: 5),
      );
    } finally {
      isCompletingOrder.value = false;

      // Restart auto refresh jika masih diaktifkan
      if (isAutoRefreshEnabled.value) {
        startAutoRefresh();
      }
    }
  }

  // Refresh kitchens (manual refresh)
  Future<void> refreshKitchens() async {
    isRefreshing.value = true;
    await fetchKitchens(showLoading: false);
    isRefreshing.value = false;
  }

  // Filter kitchens berdasarkan search query
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
    // Hentikan auto refresh sementara ketika user mengubah filter
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
    // Hentikan auto refresh sementara ketika user mengubah filter
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
    // Hentikan auto refresh sementara ketika user mengubah items per page
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
      // Hentikan auto refresh sementara ketika user mengubah halaman
      stopAutoRefresh();
      fetchKitchens().then((_) {
        if (isAutoRefreshEnabled.value) {
          startAutoRefresh();
        }
      });
    }
  }

  // Halaman berikutnya
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      // Hentikan auto refresh sementara ketika user mengubah halaman
      stopAutoRefresh();
      fetchKitchens().then((_) {
        if (isAutoRefreshEnabled.value) {
          startAutoRefresh();
        }
      });
    }
  }

  // Halaman sebelumnya
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      // Hentikan auto refresh sementara ketika user mengubah halaman
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
    const int maxVisible = 5; // Maksimal nomor halaman yang terlihat

    if (totalPages.value <= maxVisible) {
      // Jika total halaman kurang dari max visible, tampilkan semua halaman
      for (int i = 1; i <= totalPages.value; i++) {
        pages.add(i);
      }
    } else {
      // Hitung range sekitar halaman saat ini
      int start =
          (currentPage.value - (maxVisible ~/ 2)).clamp(1, totalPages.value);
      int end = (start + maxVisible - 1).clamp(1, totalPages.value);

      // Sesuaikan start jika mendekati akhir
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

  String _formatPrice(int price) {
    try {
      return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    } catch (e) {
      print('Error formatting price: $e');
      return price.toString();
    }
  }

  // Dapatkan warna status masakan
  String getDishStatusColor(String dishStatus) {
    switch (dishStatus.toLowerCase()) {
      case 'received':
        return '#6366F1'; // Indigo
      case 'processed':
        return '#3B82F6'; // Biru
      case 'completed':
        return '#10B981'; // Hijau
      case 'cancelled':
        return '#EF4444'; // Merah
      default:
        return '#6B7280'; // Abu-abu
    }
  }

  // Dapatkan warna teks status masakan
  String getDishStatusTextColor(String dishStatus) {
    return '#FFFFFF'; // Selalu putih untuk kontras yang lebih baik
  }

  // Method untuk mendapatkan label status dalam bahasa Indonesia
  String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return 'Diterima';
      case 'processed':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  // Method untuk mendapatkan ikon status
  String getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return '📝';
      case 'processed':
        return '🍳';
      case 'completed':
        return '✅';
      case 'cancelled':
        return '❌';
      default:
        return '❓';
    }
  }

  // Method untuk mengecek apakah pesanan bisa diselesaikan
  bool canCompleteOrder(String dishStatus) {
    return dishStatus.toLowerCase() == 'processed';
  }
}
