// controllers/reward_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/models/rewards/rewards_model.dart';
import 'package:pos/services/rewards/rewards_service.dart';

class RewardController extends GetxController {
  final RewardService _rewardService = RewardService();
  final ImagePicker _imagePicker = ImagePicker();

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
  final RxBool isToggling = false.obs;

  // Image picker state
  final Rx<File?> selectedImage = Rx<File?>(null);

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
      print('Error fetching rewards: $e'); // Debug log
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        print('Image selected: ${image.path}'); // Debug log
      }
    } catch (e) {
      print('Error picking image from gallery: $e'); // Debug log
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        print('Image captured: ${image.path}'); // Debug log
      }
    } catch (e) {
      print('Error capturing image: $e'); // Debug log
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Clear selected image
  void clearSelectedImage() {
    selectedImage.value = null;
    print('Selected image cleared'); // Debug log
  }

  // Show image picker options
  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Gambar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      pickImageFromGallery();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.photo_library, size: 32),
                          SizedBox(height: 8),
                          Text('Galeri'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      pickImageFromCamera();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt, size: 32),
                          SizedBox(height: 8),
                          Text('Kamera'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (selectedImage.value != null) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Get.back();
                  clearSelectedImage();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus Gambar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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

      // Debug logging
      print('Creating reward:');
      print('- Name: $name');
      print('- Description: $description');
      print('- Points Cost: $pointsCost');
      print('- Has Image: ${image != null}');
      if (image != null) {
        print('- Image Path: ${image.path}');
        print('- Image exists: ${await image.exists()}');
      }

      await _rewardService.createReward(
        name: name,
        description: description,
        pointsCost: pointsCost,
        image: image,
      );

      // Clear selected image
      clearSelectedImage();

      // Refresh the list
      await fetchRewards(showLoading: false);

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Hadiah berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('Reward created successfully'); // Debug log
    } catch (e) {
      error.value = e.toString();
      print('Error creating reward: $e'); // Debug log
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
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

      // Debug logging
      print('Updating reward:');
      print('- ID: $rewardId');
      print('- Name: $name');
      print('- Description: $description');
      print('- Points Cost: $pointsCost');
      print('- Has Image: ${image != null}');
      if (image != null) {
        print('- Image Path: ${image.path}');
        print('- Image exists: ${await image.exists()}');
      }

      await _rewardService.updateReward(
        rewardId: rewardId,
        name: name,
        description: description,
        pointsCost: pointsCost,
        image: image,
      );

      // Clear selected image
      clearSelectedImage();

      // Refresh the list
      await fetchRewards(showLoading: false);

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Hadiah berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('Reward updated successfully'); // Debug log
    } catch (e) {
      error.value = e.toString();
      print('Error updating reward: $e'); // Debug log
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // Toggle reward status
  Future<void> toggleRewardStatus(String rewardId, bool currentStatus) async {
    try {
      isToggling.value = true;

      print(
          'Toggling reward status: $rewardId, current: $currentStatus, new: ${!currentStatus}'); // Debug log

      await _rewardService.toggleRewardStatus(
        rewardId: rewardId,
        isActive: !currentStatus,
      );

      // Refresh the list
      await fetchRewards(showLoading: false);

      // Show success message
      Get.snackbar(
        'Berhasil',
        currentStatus
            ? 'Hadiah berhasil dinonaktifkan'
            : 'Hadiah berhasil diaktifkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      print('Error toggling reward status: $e'); // Debug log
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isToggling.value = false;
    }
  }

  // Delete reward
  Future<void> deleteReward(String rewardId) async {
    try {
      isDeleting.value = true;
      error.value = '';

      print('Deleting reward: $rewardId'); // Debug log

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
      print('Error deleting reward: $e'); // Debug log
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
          Obx(() {
            return TextButton(
              onPressed: isDeleting.value
                  ? null
                  : () {
                      Get.back();
                      deleteReward(rewardId);
                    },
              child: isDeleting.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.red),
                    ),
            );
          }),
        ],
      ),
    );
  }

  // Show toggle status confirmation dialog
  void showToggleStatusConfirmation(
      String rewardId, String rewardName, bool currentStatus) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Ubah Status'),
        content: Text(
          currentStatus
              ? 'Apakah Anda yakin ingin menonaktifkan hadiah "$rewardName"?'
              : 'Apakah Anda yakin ingin mengaktifkan hadiah "$rewardName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          Obx(() {
            return TextButton(
              onPressed: isToggling.value
                  ? null
                  : () {
                      Get.back();
                      toggleRewardStatus(rewardId, currentStatus);
                    },
              child: isToggling.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      currentStatus ? 'Nonaktifkan' : 'Aktifkan',
                      style: TextStyle(
                        color: currentStatus ? Colors.orange : Colors.green,
                      ),
                    ),
            );
          }),
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
