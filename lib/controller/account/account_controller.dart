// controllers/user_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/account/account_model.dart';
import 'package:pos/services/account/account_service.dart';

class UserController extends GetxController {
  final UserService _userService = UserService.instance;

  // Observable variables
  final RxList<User> users = <User>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxList<int> availablePageSizes = [5, 10, 20, 50].obs;

  // Search controller and debounce timer
  final TextEditingController searchController = TextEditingController();
  Timer? _debounceTimer;

  // Loading flag to prevent multiple simultaneous requests
  bool _isLoadingData = false;

  // Computed properties for pagination
  int get startIndex => ((currentPage.value - 1) * itemsPerPage.value) + 1;
  int get endIndex {
    final end = currentPage.value * itemsPerPage.value;
    return end > totalItems.value ? totalItems.value : end;
  }

  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => currentPage.value < totalPages.value;

  List<int> get pageNumbers {
    const maxVisiblePages = 5;
    final List<int> pages = [];

    if (totalPages.value == 0) return pages;

    int start =
        (currentPage.value - (maxVisiblePages ~/ 2)).clamp(1, totalPages.value);
    int end = (start + maxVisiblePages - 1).clamp(1, totalPages.value);

    // Adjust start if we're near the end
    if (end - start + 1 < maxVisiblePages) {
      start = (end - maxVisiblePages + 1).clamp(1, totalPages.value);
    }

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    return pages;
  }

  @override
  void onInit() {
    super.onInit();

    // Initialize search controller with current search query
    searchController.text = searchQuery.value;

    // Setup search listener with debounce
    searchQuery.listen((value) {
      if (searchController.text != value) {
        searchController.text = value;
      }
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        onSearchChanged();
      });
    });

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadUsers();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Load users with current pagination and search settings
  Future<void> loadUsers({bool showLoading = true}) async {
    // Prevent multiple simultaneous requests
    if (_isLoadingData) {
      print('Already loading data, skipping request');
      return;
    }

    _isLoadingData = true;

    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      print(
          'Loading users - Page: ${currentPage.value}, Limit: ${itemsPerPage.value}, Search: "${searchQuery.value}"');

      final response = await _userService.getUsers(
        page: currentPage.value,
        limit: itemsPerPage.value,
        search: searchQuery.value,
      );

      users.value = response.data;
      totalItems.value = response.metadata.total;
      totalPages.value = response.metadata.totalPages;

      // Validate current page
      if (currentPage.value > totalPages.value && totalPages.value > 0) {
        currentPage.value = totalPages.value;
        // Reload with corrected page
        _isLoadingData = false;
        return loadUsers(showLoading: false);
      }

      print('Loaded ${users.length} users successfully');
    } catch (e) {
      print('Error loading users: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      users.clear();
      totalItems.value = 0;
      totalPages.value = 0;
    } finally {
      isLoading.value = false;
      isSearching.value = false;
      _isLoadingData = false;
    }
  }

  /// Refresh users list
  Future<void> refreshUsers() async {
    currentPage.value = 1;
    await loadUsers();
  }

  /// Handle search input change
  void onSearchChanged() {
    print('Search changed to: "${searchQuery.value}"');
    if (currentPage.value != 1) {
      currentPage.value = 1;
    }
    isSearching.value = true;
    loadUsers(showLoading: false);
  }

  /// Update search query
  void updateSearchQuery(String query) {
    if (searchQuery.value != query) {
      searchQuery.value = query;
    }
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    loadUsers();
  }

  /// Go to previous page
  void goToPreviousPage() {
    if (hasPreviousPage && !_isLoadingData) {
      currentPage.value--;
      loadUsers();
    }
  }

  /// Go to next page
  void goToNextPage() {
    if (hasNextPage && !_isLoadingData) {
      currentPage.value++;
      loadUsers();
    }
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page != currentPage.value &&
        page >= 1 &&
        page <= totalPages.value &&
        !_isLoadingData) {
      currentPage.value = page;
      loadUsers();
    }
  }

  /// Change page size
  void changePageSize(int newSize) {
    if (availablePageSizes.contains(newSize) && !_isLoadingData) {
      itemsPerPage.value = newSize;
      currentPage.value = 1; // Reset to first page
      loadUsers();
    }
  }

  /// Get user type display text
  String getUserTypeText(User user) {
    return user.isStaff ? 'STAFF' : 'USER';
  }

  /// Get user type color
  Color getUserTypeColor(User user) {
    return user.isStaff ? Colors.blue : Colors.grey;
  }

  /// Format creation date
  String formatCreationDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Show user actions menu
  void showUserActions(User user) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Lihat Detail'),
              onTap: () {
                Get.back();
                // Navigate to user detail
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit User'),
              onTap: () {
                Get.back();
                // Navigate to edit user
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title:
                  const Text('Hapus User', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                // Show delete confirmation
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
