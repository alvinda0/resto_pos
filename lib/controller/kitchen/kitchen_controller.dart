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
      30; // detik (ubah dari 1 detik menjadi 30 detik)

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

    _autoRefreshTimer = Timer.periodic(
      Duration(seconds: autoRefreshInterval),
      (timer) {
        if (isAutoRefreshEnabled.value &&
            !isLoading.value &&
            !isRefreshing.value &&
            !isCompletingOrder.value) {
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
        statusPesanan: selectedStatus.value != 'Semua Status'
            ? selectedStatus.value
            : null,
        method: selectedMethod.value != 'Semua Metode'
            ? selectedMethod.value
            : null,
        page: currentPage.value,
        limit: itemsPerPage.value,
      );

      // Update data jika berubah atau bukan auto refresh
      if (!isAutoRefresh || !_isKitchensEqual(kitchens, response.data)) {
        kitchens.value = response.data;

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
      }
    } catch (e) {
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
