import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/promotion/promotion_model.dart';
import 'package:pos/services/promotion/promotion_service.dart';
import 'package:pos/storage_service.dart';

class PromotionController extends GetxController {
  final PromotionService _promotionService = PromotionService();
  final StorageService _storageService = StorageService.instance;

  // Observable variables
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var promotions = <Promotion>[].obs;
  var filteredPromotions = <Promotion>[].obs;
  var selectedFilter = 'Semua'.obs;
  var searchQuery = ''.obs;

  // Pagination variables
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalPromotions = 0.obs;
  var limit = 10.obs;
  var hasMoreData = true.obs;

  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Scroll controller for pagination
  final ScrollController scrollController = ScrollController();

  // Filter options
  final List<String> filterOptions = [
    'Semua',
    'Aktif',
    'Tidak Aktif',
    'Kedaluwarsa'
  ];

  // Debounce timer for search
  Timer? _searchDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    // Initialize data loading
    loadPromotions();

    // Listen to search changes with debounce
    searchController.addListener(_onSearchChanged);

    // Listen to scroll for pagination
    scrollController.addListener(_onScrollChanged);
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    scrollController.removeListener(_onScrollChanged);
    scrollController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    _debounceSearch();
  }

  void changePageSize(int newSize) {
    limit.value = newSize;
    currentPage.value = 1; // Reset ke halaman pertama
    loadPromotions(); // Reload data dengan page size baru
  }

  void _onScrollChanged() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value &&
          hasMoreData.value &&
          searchQuery.value.isEmpty) {
        loadMorePromotions();
      }
    }
  }

  // Debounce untuk search agar tidak terlalu sering hit API
  void _debounceSearch() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (searchQuery.value.isNotEmpty) {
        searchPromotions();
      } else {
        resetAndLoadPromotions();
      }
    });
  }

  // Load promotions from API (first page)
  Future<void> loadPromotions() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      hasMoreData.value = true;

      final storeId = _storageService.getStoreIdWithFallback();

      final result = await _promotionService.getPromotionsWithMetadata(
        storeId: storeId,
        page: currentPage.value,
        limit: limit.value,
      );

      promotions.value = result.promotions;
      totalPages.value = result.metadata?.totalPages ?? 1;
      totalPromotions.value = result.metadata?.total ?? 0;
      hasMoreData.value = currentPage.value < totalPages.value;

      filterPromotions();
    } catch (e) {
      _showErrorSnackbar('Gagal memuat data promosi', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Load more promotions (pagination)
  Future<void> loadMorePromotions() async {
    if (!hasMoreData.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final storeId = _storageService.getStoreIdWithFallback();

      final result = await _promotionService.getPromotionsWithMetadata(
        storeId: storeId,
        page: currentPage.value,
        limit: limit.value,
      );

      // Append new promotions to existing list
      promotions.addAll(result.promotions);
      hasMoreData.value =
          currentPage.value < (result.metadata?.totalPages ?? 1);

      filterPromotions();
    } catch (e) {
      currentPage.value--; // Rollback page increment
      _showErrorSnackbar('Gagal memuat data promosi selanjutnya', e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Search promotions
  Future<void> searchPromotions() async {
    if (searchQuery.value.isEmpty) {
      resetAndLoadPromotions();
      return;
    }

    try {
      isLoading.value = true;

      final storeId = _storageService.getStoreIdWithFallback();

      final result = await _promotionService.searchPromotions(
        searchQuery.value,
        storeId: storeId,
        page: 1,
        limit: 100, // Load more results for search
      );

      promotions.value = result;
      hasMoreData.value = false; // Disable pagination for search results

      filterPromotions();
    } catch (e) {
      _showErrorSnackbar('Gagal mencari promosi', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Reset and load promotions (used when clearing search)
  Future<void> resetAndLoadPromotions() async {
    currentPage.value = 1;
    hasMoreData.value = true;
    await loadPromotions();
  }

  // Filter promotions based on status filter (local filtering)
  void filterPromotions() {
    List<Promotion> filtered = promotions.toList();

    // Apply status filter (local filtering, tidak hit API)
    if (selectedFilter.value != 'Semua') {
      filtered = filtered.where((promotion) {
        switch (selectedFilter.value) {
          case 'Aktif':
            return promotion.status.toLowerCase() == 'active';
          case 'Tidak Aktif':
            return promotion.status.toLowerCase() == 'inactive';
          case 'Kedaluwarsa':
            return promotion.status.toLowerCase() == 'expired';
          default:
            return true;
        }
      }).toList();
    }

    filteredPromotions.value = filtered;
  }

  // Change filter
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    filterPromotions();
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    resetAndLoadPromotions();
  }

  // Delete promotion
  Future<void> deletePromotion(String id) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin menghapus promosi ini?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isLoading.value = true;

        final storeId = _storageService.getStoreIdWithFallback();
        await _promotionService.deletePromotion(id, storeId: storeId);

        // Remove from local list
        promotions.removeWhere((promotion) => promotion.id == id);
        totalPromotions.value--;
        filterPromotions();

        _showSuccessSnackbar('Promosi berhasil dihapus');
      }
    } catch (e) {
      _showErrorSnackbar('Gagal menghapus promosi', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle promotion status
  Future<void> togglePromotionStatus(String id, String currentStatus) async {
    try {
      isLoading.value = true;

      final newStatus =
          currentStatus.toLowerCase() == 'active' ? 'inactive' : 'active';
      final storeId = _storageService.getStoreIdWithFallback();

      await _promotionService.togglePromotionStatus(id, newStatus,
          storeId: storeId);

      // Update local list
      final index = promotions.indexWhere((promotion) => promotion.id == id);
      if (index != -1) {
        promotions[index] = promotions[index].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        filterPromotions();
      }

      _showSuccessSnackbar('Status promosi berhasil diubah');
    } catch (e) {
      _showErrorSnackbar('Gagal mengubah status promosi', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh promotions (pull to refresh)
  Future<void> refreshPromotions() async {
    await resetAndLoadPromotions();
  }

  // Get promotion by ID
  Future<Promotion?> getPromotionById(String id) async {
    try {
      final storeId = _storageService.getStoreIdWithFallback();
      return await _promotionService.getPromotionById(id, storeId: storeId);
    } catch (e) {
      _showErrorSnackbar('Gagal memuat detail promosi', e.toString());
      return null;
    }
  }

  // Navigation methods (implement as needed)
  void navigateToAddPromotion() {
    // TODO: Navigate to add promotion screen
    Get.snackbar('Info', 'Fitur tambah promosi akan segera tersedia');
  }

  void navigateToEditPromotion(String id) {
    // TODO: Navigate to edit promotion screen
    Get.snackbar('Info', 'Fitur edit promosi akan segera tersedia');
  }

  // Update limit and reload data
  void updateLimit(int newLimit) {
    limit.value = newLimit;
    resetAndLoadPromotions();
  }

  // Get promotion count by status (from current loaded data)
  int getPromotionCountByStatus(String status) {
    if (status == 'Semua') return promotions.length;

    return promotions.where((promotion) {
      switch (status) {
        case 'Aktif':
          return promotion.status.toLowerCase() == 'active';
        case 'Tidak Aktif':
          return promotion.status.toLowerCase() == 'inactive';
        case 'Kedaluwarsa':
          return promotion.status.toLowerCase() == 'expired';
        default:
          return false;
      }
    }).length;
  }

  // Jump to specific page
  Future<void> jumpToPage(int page) async {
    if (page < 1 || page > totalPages.value || page == currentPage.value)
      return;

    try {
      isLoading.value = true;
      currentPage.value = page;

      final storeId = _storageService.getStoreIdWithFallback();
      final result = await _promotionService.getPromotionsWithMetadata(
        storeId: storeId,
        page: currentPage.value,
        limit: limit.value,
      );

      promotions.value = result.promotions;
      hasMoreData.value =
          currentPage.value < (result.metadata?.totalPages ?? 1);

      filterPromotions();

      // Scroll to top
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memuat halaman', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods for pagination info
  bool get isFirstPage => currentPage.value == 1;
  bool get isLastPage => currentPage.value >= totalPages.value;

  String get paginationInfo {
    final start = (currentPage.value - 1) * limit.value + 1;
    final end =
        (currentPage.value * limit.value).clamp(0, totalPromotions.value);
    return 'Menampilkan $start-$end dari ${totalPromotions.value} promosi';
  }

  // Helper methods for snackbar
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  // Additional helper methods
  String getDisplayedItemsInfo() {
    if (filteredPromotions.isEmpty) return 'Tidak ada data';

    final start = (currentPage.value - 1) * limit.value + 1;
    final end =
        (start + filteredPromotions.length - 1).clamp(0, totalPromotions.value);

    return 'Menampilkan $start-$end dari ${totalPromotions.value}';
  }

  bool get canLoadMore =>
      hasMoreData.value && !isLoadingMore.value && searchQuery.value.isEmpty;
}
