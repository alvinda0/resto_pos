// controllers/inventory_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/inventory/inventory_model.dart';
import 'package:pos/services/inventory/inventory_service.dart';

class InventoryController extends GetxController {
  final InventoryService _inventoryService = InventoryService.instance;

  // Observable variables
  final RxList<InventoryModel> inventories = <InventoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'Semua'.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;

  // Available page sizes
  final List<int> availablePageSizes = [5, 10, 25, 50, 100];

  // Pagination metadata
  Rx<PaginationMetadata?> paginationMetadata = Rx<PaginationMetadata?>(null);

  // Text editing controllers for form
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController minimumStockController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Unit options
  final List<String> unitOptions = ['kg', 'gram', 'liter', 'mili', 'pcs'];

  // Status filter options

  @override
  void onInit() {
    super.onInit();
    loadInventories();

    // Listen to search query changes with debounce
    debounce(searchQuery, (_) => _performSearch(),
        time: const Duration(milliseconds: 800));

    // Listen to status filter changes
    ever(selectedStatus, (_) => _performSearch());
  }

  @override
  void onClose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    minimumStockController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // Load inventories with pagination
  Future<void> loadInventories({bool resetPage = false}) async {
    try {
      isLoading.value = true;

      if (resetPage) {
        currentPage.value = 1;
      }

      final result = await _inventoryService.getInventories(
        page: currentPage.value,
        limit: itemsPerPage.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: selectedStatus.value != 'Semua' ? selectedStatus.value : null,
      );

      inventories.value = result.data;
      paginationMetadata.value = result.metadata;
      totalItems.value = result.metadata.total;
      totalPages.value = result.metadata.totalPages;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Perform search with current filters
  Future<void> _performSearch() async {
    await loadInventories(resetPage: true);
  }

  // Pagination controls
  void goToPage(int page) {
    if (page != currentPage.value && page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadInventories();
    }
  }

  void goToNextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadInventories();
    }
  }

  void goToPreviousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadInventories();
    }
  }

  void changeItemsPerPage(int newSize) {
    if (newSize != itemsPerPage.value) {
      itemsPerPage.value = newSize;
      currentPage.value = 1; // Reset to first page
      loadInventories();
    }
  }

  // Get pagination data for widget
  Map<String, dynamic> get paginationData {
    final metadata = paginationMetadata.value;
    if (metadata == null) {
      return {
        'currentPage': 1,
        'totalItems': 0,
        'itemsPerPage': itemsPerPage.value,
        'availablePageSizes': availablePageSizes,
        'startIndex': 0,
        'endIndex': 0,
        'hasPreviousPage': false,
        'hasNextPage': false,
        'pageNumbers': <int>[],
      };
    }

    return {
      'currentPage': metadata.page,
      'totalItems': metadata.total,
      'itemsPerPage': metadata.limit,
      'availablePageSizes': availablePageSizes,
      'startIndex': metadata.startIndex,
      'endIndex': metadata.endIndex,
      'hasPreviousPage': metadata.hasPreviousPage,
      'hasNextPage': metadata.hasNextPage,
      'pageNumbers': metadata.getPageNumbers(),
    };
  }

  // Create new inventory
  Future<void> createInventory() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final request = CreateInventoryRequest(
        name: nameController.text.trim(),
        quantity: double.parse(quantityController.text),
        unit: unitController.text,
        minimumStock: double.parse(minimumStockController.text),
      );

      await _inventoryService.createInventory(request);

      Get.back(); // Close form dialog
      Get.snackbar(
        'Berhasil',
        'Inventori berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearForm();
      loadInventories(); // Reload data
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update inventory
  Future<void> updateInventory(String id) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final request = UpdateInventoryRequest(
        name: nameController.text.trim(),
        quantity: double.parse(quantityController.text),
        unit: unitController.text,
        minimumStock: double.parse(minimumStockController.text),
      );

      await _inventoryService.updateInventory(id, request);

      Get.back(); // Close form dialog
      Get.snackbar(
        'Berhasil',
        'Inventori berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearForm();
      loadInventories(); // Reload data
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete inventory
  Future<void> deleteInventory(String id, String name) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      isLoading.value = true;
      await _inventoryService.deleteInventory(id);

      Get.snackbar(
        'Berhasil',
        'Inventori berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      loadInventories(); // Reload data
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load inventory data for editing
  void loadInventoryForEdit(InventoryModel inventory) {
    nameController.text = inventory.name;
    quantityController.text = inventory.quantity.toString();
    unitController.text = inventory.unit;
    minimumStockController.text = inventory.minimumStock.toString();
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    quantityController.clear();
    unitController.text = unitOptions.isNotEmpty ? unitOptions.first : 'pcs';
    minimumStockController.clear();
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    searchController.text = query;
  }

  // Update status filter
  void updateStatusFilter(String status) {
    selectedStatus.value = status;
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadInventories();
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
  }

  // Clear all filters
  void clearAllFilters() {
    searchQuery.value = '';
    searchController.clear();
    selectedStatus.value = 'Semua';
    currentPage.value = 1;
    loadInventories();
  }

  // Validators
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    return null;
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jumlah tidak boleh kosong';
    }
    if (double.tryParse(value) == null || double.parse(value) < 0) {
      return 'Jumlah harus berupa angka positif';
    }
    return null;
  }

  String? validateMinimumStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Stok minimum tidak boleh kosong';
    }
    if (double.tryParse(value) == null || double.parse(value) < 0) {
      return 'Stok minimum harus berupa angka positif';
    }
    return null;
  }
}
