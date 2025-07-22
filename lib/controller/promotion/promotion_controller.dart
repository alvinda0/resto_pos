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

  @override
  void onInit() {
    super.onInit();
    loadPromotions();

    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _debounceSearch();
    });

    // Listen to scroll for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore.value &&
            hasMoreData.value &&
            searchQuery.value.isEmpty) {
          loadMorePromotions();
        }
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // Debounce untuk search agar tidak terlalu sering hit API
  Timer? _searchDebounceTimer;
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
      Get.snackbar(
        'Error',
        'Gagal memuat data promosi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      Get.snackbar(
        'Error',
        'Gagal memuat data promosi selanjutnya: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      Get.snackbar(
        'Error',
        'Gagal mencari promosi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

        Get.snackbar(
          'Berhasil',
          'Promosi berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus promosi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        final updatedPromotion = Promotion(
          id: promotions[index].id,
          name: promotions[index].name,
          description: promotions[index].description,
          discountType: promotions[index].discountType,
          discountValue: promotions[index].discountValue,
          maxDiscount: promotions[index].maxDiscount,
          timeType: promotions[index].timeType,
          startDate: promotions[index].startDate,
          endDate: promotions[index].endDate,
          days: promotions[index].days,
          startTime: promotions[index].startTime,
          endTime: promotions[index].endTime,
          promoCode: promotions[index].promoCode,
          usageLimit: promotions[index].usageLimit,
          status: newStatus,
          createdAt: promotions[index].createdAt,
          updatedAt: DateTime.now(),
        );

        promotions[index] = updatedPromotion;
        filterPromotions();
      }

      Get.snackbar(
        'Berhasil',
        'Status promosi berhasil diubah',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah status promosi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      Get.snackbar(
        'Error',
        'Gagal memuat detail promosi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Navigate to add promotion screen
  void navigateToAddPromotion() {
    // Navigate to add promotion screen
    // Get.toNamed('/add-promotion');
  }
// Add this method to your PromotionController class
  void updateLimit(int newLimit) {
    limit.value = newLimit;
    resetAndLoadPromotions();
  }

  // Navigate to edit promotion screen
  void navigateToEditPromotion(String id) {
    // Navigate to edit promotion screen
    // Get.toNamed('/edit-promotion/$id');
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

  // Change page size
  void changePageSize(int newLimit) {
    limit.value = newLimit;
    resetAndLoadPromotions();
  }

  // Jump to specific page
  Future<void> jumpToPage(int page) async {
    if (page < 1 || page > totalPages.value) return;

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
      print('❌ Error jumping to page: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat halaman: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods for pagination info
  bool get isFirstPage => currentPage.value == 1;
  bool get isLastPage => currentPage.value >= totalPages.value;
  String get paginationInfo =>
      'Halaman ${currentPage.value} dari ${totalPages.value} (${totalPromotions.value} total)';
}
