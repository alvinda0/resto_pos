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
  var promotions = <Promotion>[].obs;
  var filteredPromotions = <Promotion>[].obs;
  var selectedFilter = 'Semua'.obs;
  var searchQuery = ''.obs;

  // Search controller
  final TextEditingController searchController = TextEditingController();

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
      filterPromotions();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Load promotions from API
  Future<void> loadPromotions() async {
    try {
      isLoading.value = true;

      final storeId = _storageService.getStoreIdWithFallback();
      print('🏪 Loading promotions for store: $storeId');

      final result = await _promotionService.getPromotions(storeId: storeId);

      promotions.value = result;
      filterPromotions();

      print('✅ Loaded ${result.length} promotions');
    } catch (e) {
      print('❌ Error loading promotions: $e');
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

  // Filter promotions based on search and filter
  void filterPromotions() {
    List<Promotion> filtered = promotions.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((promotion) {
        final query = searchQuery.value.toLowerCase();
        return promotion.name.toLowerCase().contains(query) ||
            promotion.promoCode.toLowerCase().contains(query) ||
            promotion.description.toLowerCase().contains(query);
      }).toList();
    }

    // Apply status filter
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
    filterPromotions();
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
      print('❌ Error deleting promotion: $e');
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
      print('❌ Error toggling promotion status: $e');
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

  // Refresh promotions
  Future<void> refreshPromotions() async {
    await loadPromotions();
  }

  // Get promotion by ID
  Future<Promotion?> getPromotionById(String id) async {
    try {
      final storeId = _storageService.getStoreIdWithFallback();
      return await _promotionService.getPromotionById(id, storeId: storeId);
    } catch (e) {
      print('❌ Error getting promotion by ID: $e');
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
    print('🎯 Navigate to add promotion');
  }

  // Navigate to edit promotion screen
  void navigateToEditPromotion(String id) {
    // Navigate to edit promotion screen
    // Get.toNamed('/edit-promotion/$id');
    print('🎯 Navigate to edit promotion: $id');
  }

  // Get promotion count by status
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
}
