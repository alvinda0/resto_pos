// controllers/reward_controller.dart
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
