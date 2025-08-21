// controllers/reward_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/rewards/rewards_model.dart';
import 'package:pos/services/rewards/rewards_service.dart';

class RewardController extends GetxController {
  final RewardService _rewardService = RewardService();

  // Observable variables
  final RxList<RewardModel> rewards = <RewardModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 1.obs;

  // Available page sizes
  final List<int> availablePageSizes = [5, 10, 25, 50];

  // Form loading states
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRewards();
  }

  // Fetch rewards from API
  Future<void> fetchRewards({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      error.value = '';

      final response = await _rewardService.getRewards(
        page: currentPage.value,
        limit: itemsPerPage.value,
      );

      rewards.value = response.data;
      totalItems.value = response.metadata.total;
      totalPages.value = response.metadata.totalPages;
    } catch (e) {
      error.value = e.toString();
      rewards.clear();
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  // Create reward
  Future<void> createReward({
    required String name,
    required String description,
    required int pointsCost,
    File? image,
  }) async {
    try {
      isCreating.value = true;
      error.value = '';

      await _rewardService.createReward(
        name: name,
        description: description,
        pointsCost: pointsCost,
        image: image,
      );

      // Refresh the list
      await fetchRewards(showLoading: false);

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Hadiah berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreating.value = false;
    }
  }

  // Update reward
  Future<void> updateReward({
    required String rewardId,
    required String name,
    required String description,
    required int pointsCost,
    File? image,
  }) async {
    try {
      isUpdating.value = true;
      error.value = '';

      await _rewardService.updateReward(
        rewardId: rewardId,
        name: name,
        description: description,
        pointsCost: pointsCost,
        image: image,
      );

      // Refresh the list
      await fetchRewards(showLoading: false);

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Hadiah berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // Toggle reward status
  Future<void> toggleRewardStatus(String rewardId, bool currentStatus) async {
    try {
      await _rewardService.toggleRewardStatus(
        rewardId: rewardId,
        isActive: !currentStatus,
      );

      // Refresh the list
      await fetchRewards(showLoading: false);

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Status hadiah berhasil diubah',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Delete reward
  Future<void> deleteReward(String rewardId) async {
    try {
      isDeleting.value = true;
      error.value = '';

      await _rewardService.deleteReward(rewardId: rewardId);

      // Refresh the list
      await fetchRewards(showLoading: false);

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Hadiah berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  // Show delete confirmation dialog
  void showDeleteConfirmation(String rewardId, String rewardName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content:
            Text('Apakah Anda yakin ingin menghapus hadiah "$rewardName"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteReward(rewardId);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Refresh data
  Future<void> refreshData() async {
    currentPage.value = 1;
    await fetchRewards();
  }

  // Change page size
  void changePageSize(int newSize) {
    itemsPerPage.value = newSize;
    currentPage.value = 1; // Reset to first page
    fetchRewards();
  }

  // Go to previous page
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchRewards();
    }
  }

  // Go to next page
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchRewards();
    }
  }

  // Go to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchRewards();
    }
  }

  // Computed properties for pagination
  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => currentPage.value < totalPages.value;

  int get startIndex {
    if (totalItems.value == 0) return 0;
    return (currentPage.value - 1) * itemsPerPage.value + 1;
  }

  int get endIndex {
    final end = currentPage.value * itemsPerPage.value;
    return end > totalItems.value ? totalItems.value : end;
  }

  // Get page numbers for pagination widget
  List<int> get pageNumbers {
    final List<int> pages = [];
    final int maxVisiblePages = 5;
    final int totalPagesValue = totalPages.value;
    final int currentPageValue = currentPage.value;

    if (totalPagesValue <= maxVisiblePages) {
      // Show all pages if total is small
      for (int i = 1; i <= totalPagesValue; i++) {
        pages.add(i);
      }
    } else {
      // Show smart pagination
      int startPage = currentPageValue - 2;
      int endPage = currentPageValue + 2;

      if (startPage < 1) {
        startPage = 1;
        endPage = maxVisiblePages;
      }

      if (endPage > totalPagesValue) {
        endPage = totalPagesValue;
        startPage = totalPagesValue - maxVisiblePages + 1;
        if (startPage < 1) startPage = 1;
      }

      for (int i = startPage; i <= endPage; i++) {
        pages.add(i);
      }
    }

    return pages;
  }

  // Check if reward is active
  bool isRewardActive(RewardModel reward) {
    return reward.isActive;
  }

  // Format points display
  String formatPoints(int points) {
    return '$points PTS';
  }

  // Format status display
  String formatStatus(bool isActive) {
    return isActive ? 'AKTIF' : 'NONAKTIF';
  }
}
