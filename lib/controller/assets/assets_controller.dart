import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/assets/assets_model.dart';
import 'package:pos/services/assets/assets_service.dart';
import 'package:pos/storage_service.dart';

class AssetController extends GetxController {
  final AssetService _assetService = AssetService.instance;
  final StorageService _storage = StorageService.instance;

  // Observable variables
  final RxList<Asset> assets = <Asset>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStoreId = ''.obs;
  final RxString errorMessage = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxList<int> availablePageSizes = [10, 25, 50, 100].obs;

  // Selection
  final RxList<String> selectedAssetIds = <String>[].obs;
  final RxBool isSelectionMode = false.obs;

  // Filtering
  final RxString selectedType = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedStatus = ''.obs;
  final RxList<String> availableCategories = <String>[].obs;

  // Text controllers for search
  late TextEditingController searchController;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    selectedStoreId.value = _storage.getStoreIdWithFallback() ?? '';
    loadAssets();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Load assets with pagination and search
  Future<void> loadAssets({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      assets.clear();
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _assetService.getAssets(
        page: currentPage.value,
        limit: itemsPerPage.value,
        search: searchQuery.value,
        storeId:
            selectedStoreId.value.isNotEmpty ? selectedStoreId.value : null,
      );

      if (response.success) {
        assets.assignAll(response.data);
        if (response.metadata != null) {
          totalItems.value = response.metadata!.total;
          totalPages.value = response.metadata!.totalPages;
        }

        // Update available categories
        availableCategories.value = _assetService.getUniqueCategories(assets);
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Search assets
  void searchAssets(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    loadAssets();
  }

  // Change page size
  void changePageSize(int newSize) {
    itemsPerPage.value = newSize;
    currentPage.value = 1;
    loadAssets();
  }

  // Navigate to page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadAssets();
    }
  }

  // Previous page
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadAssets();
    }
  }

  // Next page
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadAssets();
    }
  }

  // Get pagination data
  Map<String, dynamic> get paginationData {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value + 1;
    final endIndex =
        (currentPage.value * itemsPerPage.value).clamp(0, totalItems.value);

    // Generate page numbers for pagination widget
    List<int> pageNumbers = [];
    int start = (currentPage.value - 2).clamp(1, totalPages.value);
    int end = (currentPage.value + 2).clamp(1, totalPages.value);

    for (int i = start; i <= end; i++) {
      pageNumbers.add(i);
    }

    return {
      'startIndex': startIndex,
      'endIndex': endIndex,
      'hasPreviousPage': currentPage.value > 1,
      'hasNextPage': currentPage.value < totalPages.value,
      'pageNumbers': pageNumbers,
    };
  }

  // Create asset
  Future<bool> createAsset(Asset asset) async {
    try {
      isLoading.value = true;

      final response = await _assetService.createAsset(
        asset,
        storeId:
            selectedStoreId.value.isNotEmpty ? selectedStoreId.value : null,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Asset created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        loadAssets(refresh: true);
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update asset
  Future<bool> updateAsset(String id, Asset asset) async {
    try {
      isLoading.value = true;

      final response = await _assetService.updateAsset(
        id,
        asset,
        storeId:
            selectedStoreId.value.isNotEmpty ? selectedStoreId.value : null,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Asset updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        loadAssets(refresh: true);
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete asset
  Future<bool> deleteAsset(String id) async {
    try {
      isLoading.value = true;

      final response = await _assetService.deleteAsset(
        id,
        storeId:
            selectedStoreId.value.isNotEmpty ? selectedStoreId.value : null,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Asset deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        loadAssets(refresh: true);
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete multiple assets
  Future<void> deleteSelectedAssets() async {
    if (selectedAssetIds.isEmpty) return;

    try {
      Get.dialog(
        AlertDialog(
          title: const Text('Delete Assets'),
          content: Text(
              'Are you sure you want to delete ${selectedAssetIds.length} asset(s)?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                isLoading.value = true;

                final responses = await _assetService.deleteMultipleAssets(
                  selectedAssetIds,
                  storeId: selectedStoreId.value.isNotEmpty
                      ? selectedStoreId.value
                      : null,
                );

                final successCount = responses.where((r) => r.success).length;

                Get.snackbar(
                  'Result',
                  'Deleted $successCount of ${selectedAssetIds.length} assets',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: successCount == selectedAssetIds.length
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  colorText: successCount == selectedAssetIds.length
                      ? Colors.green
                      : Colors.orange,
                );

                clearSelection();
                loadAssets(refresh: true);
                isLoading.value = false;
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Selection methods
  void toggleSelection(String assetId) {
    if (selectedAssetIds.contains(assetId)) {
      selectedAssetIds.remove(assetId);
    } else {
      selectedAssetIds.add(assetId);
    }

    if (selectedAssetIds.isEmpty) {
      isSelectionMode.value = false;
    }
  }

  void selectAll() {
    selectedAssetIds.assignAll(assets.map((asset) => asset.id).toList());
    isSelectionMode.value = true;
  }

  void clearSelection() {
    selectedAssetIds.clear();
    isSelectionMode.value = false;
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      clearSelection();
    }
  }

  // Filtering methods
  void filterByType(String type) {
    selectedType.value = type;
    applyFilters();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    applyFilters();
  }

  void clearFilters() {
    selectedType.value = '';
    selectedCategory.value = '';
    selectedStatus.value = '';
    loadAssets(refresh: true);
  }

  void applyFilters() {
    // Apply filters to current assets list
    var filteredAssets = List<Asset>.from(assets);

    if (selectedType.value.isNotEmpty) {
      filteredAssets =
          _assetService.filterAssetsByType(filteredAssets, selectedType.value);
    }

    if (selectedCategory.value.isNotEmpty) {
      filteredAssets = _assetService.filterAssetsByCategory(
          filteredAssets, selectedCategory.value);
    }

    if (selectedStatus.value.isNotEmpty) {
      filteredAssets = _assetService.filterAssetsByStatus(
          filteredAssets, selectedStatus.value);
    }

    assets.assignAll(filteredAssets);
  }

  // Utility methods
  String formatCurrency(int amount) {
    return _assetService.formatCurrency(amount);
  }

  double calculateBookValue(Asset asset) {
    return _assetService.calculateBookValue(asset);
  }

  double calculateDepreciationPercentage(Asset asset) {
    return _assetService.calculateDepreciationPercentage(asset);
  }

  // Refresh data
  Future<void> refresh() async {
    await loadAssets(refresh: true);
  }
}
