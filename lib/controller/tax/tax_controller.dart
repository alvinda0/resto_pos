// controllers/tax_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/tax/tax_model.dart';
import 'package:pos/services/tax/tax_service.dart';

class TaxController extends GetxController {
  // Service instance - dibuat langsung tanpa injection
  late final TaxService _taxService;

  // Observable variables
  final RxList<TaxModel> taxes = <TaxModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxInt itemsPerPage = 10.obs;
  final List<int> availablePageSizes = [5, 10, 25, 50];

  // Filter variables
  final RxString searchQuery = ''.obs;
  final Rx<TaxType?> selectedType = Rx<TaxType?>(null);
  final Rx<bool?> filterActive = Rx<bool?>(null);

  // Selected items for bulk operations
  final RxList<String> selectedIds = <String>[].obs;
  final RxBool isSelectMode = false.obs;

  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Debounce timer untuk search
  Worker? _searchWorker;

  // Getters for pagination widget
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value + 1;
  int get endIndex =>
      (currentPage.value * itemsPerPage.value).clamp(0, totalItems.value);
  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => currentPage.value < totalPages.value;

  List<int> get pageNumbers {
    List<int> pages = [];
    int start = (currentPage.value - 2).clamp(1, totalPages.value);
    int end = (currentPage.value + 2).clamp(1, totalPages.value);

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }
    return pages;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    _setupSearchDebounce();
  }

  void _initializeService() {
    // Buat service langsung tanpa dependency injection
    _taxService = TaxService();

    // Load data setelah widget selesai dibuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadTaxes();
    });
  }

  void _setupSearchDebounce() {
    // Setup worker untuk debounce search
    _searchWorker = debounce(
      searchQuery,
      (String query) {
        currentPage.value = 1;
        loadTaxes();
      },
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchWorker?.dispose();
    super.onClose();
  }

  // Load taxes dengan error handling yang lebih baik
  Future<void> loadTaxes({bool showLoading = true}) async {
    try {
      // Prevent multiple simultaneous requests
      if (isLoading.value && showLoading) return;

      if (showLoading) isLoading.value = true;
      error.value = '';

      final response = await _taxService.getTaxes(
        page: currentPage.value,
        limit: itemsPerPage.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        type: selectedType.value?.value,
        isActive: filterActive.value,
      );

      // Update data dengan memastikan reactive update
      taxes.assignAll(
          response.data); // Gunakan assignAll untuk memastikan update
      totalItems.value = response.metadata.total;
      totalPages.value = response.metadata.totalPages;

      // Clear any previous errors
      error.value = '';

      // Force update UI
      update();
    } catch (e) {
      print('Error loading taxes: $e');
      error.value = _getErrorMessage(e);

      // Set empty data on error
      taxes.clear();
      totalItems.value = 0;
      totalPages.value = 0;
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorStr = error.toString();
    if (errorStr.contains('timeout')) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (errorStr.contains('No route to host')) {
      return 'Cannot connect to server. Please try again later.';
    } else if (errorStr.contains('Exception:')) {
      return errorStr.replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }

  // Refresh data
  Future<void> refreshTaxes() async {
    currentPage.value = 1;
    selectedIds.clear(); // Clear selections saat refresh
    await loadTaxes();
  }

  // Search dengan debounce otomatis
  void searchTaxes(String query) {
    searchQuery.value = query;
    // Debounce akan menangani pemanggilan loadTaxes()
  }

  // Filter methods
  void filterByType(TaxType? type) {
    selectedType.value = type;
    currentPage.value = 1;
    loadTaxes();
  }

  void filterByStatus(bool? isActive) {
    filterActive.value = isActive;
    currentPage.value = 1;
    loadTaxes();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedType.value = null;
    filterActive.value = null;
    searchController.clear();
    currentPage.value = 1;
    loadTaxes();
  }

  // Pagination methods
  void onPageChanged(int page) {
    if (page != currentPage.value && page > 0 && page <= totalPages.value) {
      currentPage.value = page;
      loadTaxes();
    }
  }

  void onPageSizeChanged(int newSize) {
    if (newSize != itemsPerPage.value && availablePageSizes.contains(newSize)) {
      itemsPerPage.value = newSize;
      currentPage.value = 1;
      loadTaxes();
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      currentPage.value--;
      loadTaxes();
    }
  }

  void nextPage() {
    if (hasNextPage) {
      currentPage.value++;
      loadTaxes();
    }
  }

  // CRUD Operations dengan loading state yang lebih baik
  Future<void> createTax(TaxModel tax) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      final response = await _taxService.createTax(tax);

      _showSuccessSnackbar('Tax created successfully');

      // Refresh data untuk memastikan tabel ter-update
      await refreshTaxes();
    } catch (e) {
      _showErrorSnackbar(_getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTax(String id, TaxModel tax) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      final response = await _taxService.updateTax(id, tax);

      _showSuccessSnackbar('Tax updated successfully');

      // Gunakan loadTaxes untuk mempertahankan halaman saat ini
      await loadTaxes(showLoading: false);
    } catch (e) {
      _showErrorSnackbar(_getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTax(String id, String name) async {
    final confirmed = await _showDeleteConfirmation(name);

    if (confirmed == true && !isLoading.value) {
      try {
        isLoading.value = true;
        final success = await _taxService.deleteTax(id);

        if (success) {
          _showSuccessSnackbar('Tax deleted successfully');

          // Jika halaman saat ini akan kosong setelah delete, pindah ke halaman sebelumnya
          if (taxes.length == 1 && currentPage.value > 1) {
            currentPage.value--;
          }

          // Refresh data
          await loadTaxes(showLoading: false);
        }
      } catch (e) {
        _showErrorSnackbar(_getErrorMessage(e));
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(String name) {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Selection methods
  void toggleSelectMode() {
    isSelectMode.value = !isSelectMode.value;
    if (!isSelectMode.value) {
      selectedIds.clear();
    }
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void selectAll() {
    if (selectedIds.length == taxes.length && taxes.isNotEmpty) {
      selectedIds.clear();
    } else {
      selectedIds.value = taxes.map((tax) => tax.id).toList();
    }
  }

  bool isSelected(String id) => selectedIds.contains(id);

  // Bulk operations
  Future<void> bulkUpdateStatus(bool isActive) async {
    if (selectedIds.isEmpty || isLoading.value) return;

    try {
      isLoading.value = true;
      await _taxService.bulkUpdateStatus(selectedIds.toList(), isActive);

      _showSuccessSnackbar('${selectedIds.length} taxes updated successfully');

      selectedIds.clear();
      toggleSelectMode();
      await loadTaxes();
    } catch (e) {
      _showErrorSnackbar(_getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods untuk snackbar
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(8),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(8),
    );
  }
}
