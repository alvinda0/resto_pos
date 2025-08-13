import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/recipe/recipe_model.dart';
import 'package:pos/models/inventory/inventory_model.dart';
import 'package:pos/screens/recipe/CreateRecipeDialog.dart';
import 'package:pos/screens/recipe/EditRecipeDialog.dart'; // Import the EditRecipeDialog
import 'package:pos/services/recipe/recipe_service.dart';
import 'package:pos/controller/inventory/inventory_controller.dart';

class RecipeController extends GetxController {
  final RecipeService _recipeService = RecipeService.instance;

  // Observable variables
  final RxList<Recipe> recipes = <Recipe>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isOperationLoading = false.obs; // For CRUD operations
  final RxString errorMessage = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxList<int> availablePageSizes = [10, 25, 50, 100].obs;

  // Search and filter variables
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // Store ID (optional)
  final RxString storeId = ''.obs;

  // Form controllers for create/edit recipe
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxList<RecipeItem> recipeItems = <RecipeItem>[].obs;

  // Available inventories for selection
  final RxList<InventoryModel> availableInventories = <InventoryModel>[].obs;

  // Track if we're in edit mode
  final RxBool isEditMode = false.obs;
  final Rx<Recipe?> currentEditingRecipe = Rx<Recipe?>(null);

  // Computed properties for pagination
  bool get hasNextPage => currentPage.value < totalPages.value;
  bool get hasPreviousPage => currentPage.value > 1;

  int get startIndex {
    if (totalItems.value == 0) return 0;
    return ((currentPage.value - 1) * itemsPerPage.value) + 1;
  }

  int get endIndex {
    final end = currentPage.value * itemsPerPage.value;
    return end > totalItems.value ? totalItems.value : end;
  }

  List<int> get pageNumbers {
    List<int> pages = [];
    int start = 1;
    int end = totalPages.value;

    // Show maximum 5 page numbers
    if (totalPages.value > 5) {
      if (currentPage.value <= 3) {
        start = 1;
        end = 5;
      } else if (currentPage.value >= totalPages.value - 2) {
        start = totalPages.value - 4;
        end = totalPages.value;
      } else {
        start = currentPage.value - 2;
        end = currentPage.value + 2;
      }
    }

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    return pages;
  }

  // Helper methods for UI
  bool get hasRecipes => recipes.isNotEmpty;
  bool get hasError => errorMessage.value.isNotEmpty;
  bool get isEmpty => !isLoading.value && !hasRecipes && !hasError;

  @override
  void onInit() {
    super.onInit();

    // Ensure InventoryController is available
    if (!Get.isRegistered<InventoryController>()) {
      Get.put(InventoryController());
    }

    loadRecipes();
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Load recipes
  Future<void> loadRecipes({
    bool showLoading = true,
    bool isRefresh = false,
  }) async {
    try {
      if (showLoading && !isRefresh) {
        isLoading.value = true;
      }

      errorMessage.value = '';

      final response = await _recipeService.getRecipes(
        page: currentPage.value,
        limit: itemsPerPage.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        storeId: storeId.value.isEmpty ? null : storeId.value,
      );

      if (response.success) {
        recipes.value = response.data;
        totalItems.value = response.metadata.total;
        totalPages.value = response.metadata.totalPages;
        currentPage.value = response.metadata.page;
        itemsPerPage.value = response.metadata.limit;
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = 'Error loading recipes: $errorMsg';

      // Show user-friendly error message
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );

      print('Error in loadRecipes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh recipes
  Future<void> refreshRecipes() async {
    currentPage.value = 1;
    await loadRecipes(showLoading: false, isRefresh: true);
  }

  // Search recipes with debounce
  void searchRecipes(String query) {
    searchQuery.value = query;
    currentPage.value = 1; // Reset to first page when searching
    _debounceSearch();
  }

  void _debounceSearch() {
    // Simple debounce implementation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchController.text == searchQuery.value) {
        loadRecipes();
      }
    });
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    loadRecipes();
  }

  // Pagination methods
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      currentPage.value = page;
      loadRecipes();
    }
  }

  void goToNextPage() {
    if (hasNextPage) {
      goToPage(currentPage.value + 1);
    }
  }

  void goToPreviousPage() {
    if (hasPreviousPage) {
      goToPage(currentPage.value - 1);
    }
  }

  void onPageSizeChanged(int newSize) {
    itemsPerPage.value = newSize;
    currentPage.value = 1;
    loadRecipes();
  }

  void changePageSize(int newPageSize) {
    if (availablePageSizes.contains(newPageSize) &&
        newPageSize != itemsPerPage.value) {
      itemsPerPage.value = newPageSize;
      currentPage.value = 1; // Reset to first page
      loadRecipes();
    }
  }

  // Recipe specific methods
  Recipe? getRecipeById(String id) {
    try {
      return recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  int getRecipeItemCount(Recipe recipe) {
    return recipe.items.length;
  }

  String getRecipeItemCountText(Recipe recipe) {
    final count = getRecipeItemCount(recipe);
    return '$count bahan';
  }

  // Set store ID
  void setStoreId(String id) {
    storeId.value = id;
    currentPage.value = 1;
    loadRecipes();
  }

  // Load available inventories for recipe creation
  Future<void> loadAvailableInventories() async {
    try {
      // Check if InventoryController is already registered, if not register it
      InventoryController inventoryController;
      if (Get.isRegistered<InventoryController>()) {
        inventoryController = Get.find<InventoryController>();
      } else {
        inventoryController = Get.put(InventoryController());
      }

      // Simply use the current inventories from InventoryController
      // This will use whatever data is currently loaded there
      if (inventoryController.inventories.isNotEmpty) {
        availableInventories.value = inventoryController.inventories.toList();
      } else {
        // If inventory controller doesn't have data, trigger a load
        await inventoryController.loadInventories(showLoading: false);
        availableInventories.value = inventoryController.inventories.toList();
      }
    } catch (e) {
      print('Error loading inventories: $e');
      // Clear available inventories on error
      availableInventories.clear();

      // Show error message to user
      Get.snackbar(
        'Warning',
        'Gagal memuat daftar inventory. Pastikan data inventory sudah tersedia.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.warning_outlined, color: Colors.orange),
      );
    }
  }

  // Clear form controllers
  void clearFormControllers() {
    nameController.clear();
    descriptionController.clear();
    recipeItems.clear();
    isEditMode.value = false;
    currentEditingRecipe.value = null;
  }

  // Add recipe item
  void addRecipeItem() {
    recipeItems.add(RecipeItem(
      inventoryId: '',
      inventoryName: '',
      inventorySku: '',
      inventoryUnit: '',
      requiredQuantity: 0,
      requiredUnit: '',
      costPerUnit: 0,
      totalCost: 0,
      notes: '',
      hpp: 0,
    ));
  }

  // Remove recipe item
  void removeRecipeItem(int index) {
    if (index >= 0 && index < recipeItems.length) {
      recipeItems.removeAt(index);
    }
  }

  // Update recipe item
  void updateRecipeItem(int index, RecipeItem updatedItem) {
    if (index >= 0 && index < recipeItems.length) {
      recipeItems[index] = updatedItem;
      recipeItems.refresh();
    }
  }

  // Create new recipe
  Future<bool> createRecipe() async {
    try {
      // Validate form data
      if (nameController.text.trim().isEmpty) {
        Get.snackbar(
          'Validasi Error',
          'Nama resep harus diisi',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.warning_outlined, color: Colors.orange),
        );
        return false;
      }

      if (recipeItems.isEmpty) {
        Get.snackbar(
          'Validasi Error',
          'Resep harus memiliki minimal 1 bahan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.warning_outlined, color: Colors.orange),
        );
        return false;
      }

      // Validate each recipe item
      for (int i = 0; i < recipeItems.length; i++) {
        final item = recipeItems[i];
        if (item.inventoryId.isEmpty) {
          Get.snackbar(
            'Validasi Error',
            'Bahan ${i + 1}: Pilih inventory',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            icon: const Icon(Icons.warning_outlined, color: Colors.orange),
          );
          return false;
        }

        if (item.requiredQuantity <= 0) {
          Get.snackbar(
            'Validasi Error',
            'Bahan ${i + 1}: Jumlah harus lebih dari 0',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            icon: const Icon(Icons.warning_outlined, color: Colors.orange),
          );
          return false;
        }

        if (item.requiredUnit.isEmpty) {
          Get.snackbar(
            'Validasi Error',
            'Bahan ${i + 1}: Pilih unit',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            icon: const Icon(Icons.warning_outlined, color: Colors.orange),
          );
          return false;
        }
      }

      isOperationLoading.value = true;

      // Prepare request data according to API format
      final List<Map<String, dynamic>> items = recipeItems
          .map((item) => {
                'inventory_id': item.inventoryId,
                'required_quantity': item.requiredQuantity,
                'unit': item.requiredUnit,
                'notes': item.notes.isNotEmpty ? item.notes : null,
              })
          .toList();

      final newRecipe = await _recipeService.createRecipe(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        items: items,
        storeId: storeId.value.isEmpty ? null : storeId.value,
      );

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Resep "${newRecipe.name}" berhasil dibuat',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      );

      // Clear form and refresh list
      clearFormControllers();
      await refreshRecipes();
      return true;
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        'Gagal membuat resep: $errorMsg',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
      return false;
    } finally {
      isOperationLoading.value = false;
    }
  }

  // Update existing recipe
  Future<bool> updateRecipe(String recipeId) async {
    try {
      // Validate form data (same validation as create)
      if (nameController.text.trim().isEmpty) {
        Get.snackbar(
          'Validasi Error',
          'Nama resep harus diisi',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.warning_outlined, color: Colors.orange),
        );
        return false;
      }

      if (recipeItems.isEmpty) {
        Get.snackbar(
          'Validasi Error',
          'Resep harus memiliki minimal 1 bahan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.warning_outlined, color: Colors.orange),
        );
        return false;
      }

      // Validate each recipe item
      for (int i = 0; i < recipeItems.length; i++) {
        final item = recipeItems[i];
        if (item.inventoryId.isEmpty) {
          Get.snackbar(
            'Validasi Error',
            'Bahan ${i + 1}: Pilih inventory',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            icon: const Icon(Icons.warning_outlined, color: Colors.orange),
          );
          return false;
        }

        if (item.requiredQuantity <= 0) {
          Get.snackbar(
            'Validasi Error',
            'Bahan ${i + 1}: Jumlah harus lebih dari 0',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            icon: const Icon(Icons.warning_outlined, color: Colors.orange),
          );
          return false;
        }

        if (item.requiredUnit.isEmpty) {
          Get.snackbar(
            'Validasi Error',
            'Bahan ${i + 1}: Pilih unit',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            icon: const Icon(Icons.warning_outlined, color: Colors.orange),
          );
          return false;
        }
      }

      isOperationLoading.value = true;

      // Prepare request data according to API format
      final List<Map<String, dynamic>> items = recipeItems
          .map((item) => {
                'inventory_id': item.inventoryId,
                'required_quantity': item.requiredQuantity,
                'unit': item.requiredUnit,
                'notes': item.notes.isNotEmpty ? item.notes : null,
              })
          .toList();

      final updatedRecipe = await _recipeService.updateRecipe(
        id: recipeId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        items: items,
        storeId: storeId.value.isEmpty ? null : storeId.value,
      );

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Resep "${updatedRecipe.name}" berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      );

      // Clear form and refresh list
      clearFormControllers();
      await refreshRecipes();
      return true;
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        'Gagal memperbarui resep: $errorMsg',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
      return false;
    } finally {
      isOperationLoading.value = false;
    }
  }

  // Show create recipe dialog
  void showCreateRecipeDialog() {
    clearFormControllers();
    loadAvailableInventories();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: CreateRecipeDialog(controller: this),
      ),
    );
  }

  // Show edit recipe dialog
  void showEditRecipeDialog(Recipe recipe) {
    // Set edit mode
    isEditMode.value = true;
    currentEditingRecipe.value = recipe;

    // Populate form with existing data
    populateFormControllers(recipe);
    loadAvailableInventories();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: EditRecipeDialog(controller: this, recipe: recipe),
      ),
    );
  }

  // Populate form controllers for editing
  void populateFormControllers(Recipe recipe) {
    nameController.text = recipe.name;
    descriptionController.text = recipe.description;
    recipeItems.value = recipe.items.toList();
  }

  // Show recipe details (enhanced version)
  void showRecipeDetails(Recipe recipe) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 600,
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Resep',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recipe name
              Text(
                recipe.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              if (recipe.description.isNotEmpty) ...[
                Text(
                  recipe.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Total cost
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Biaya Resep:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Rp ${recipe.totalCost.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ingredients header
              const Text(
                'Bahan-bahan:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Ingredients list
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: recipe.items.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.inventoryName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'SKU: ${item.inventorySku}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (item.notes.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Catatan: ${item.notes}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${item.requiredQuantity} ${item.requiredUnit}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Rp ${item.totalCost.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Footer with timestamps
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dibuat:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${recipe.createdAt.day}/${recipe.createdAt.month}/${recipe.createdAt.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Diupdate:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${recipe.updatedAt.day}/${recipe.updatedAt.month}/${recipe.updatedAt.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Delete recipe - Now properly implemented
  Future<void> deleteRecipe(Recipe recipe) async {
    // Show confirmation dialog
    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus resep "${recipe.name}"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
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

    if (confirmed != true) return;

    try {
      isOperationLoading.value = true;

      await _recipeService.deleteRecipe(
        recipe.id,
        storeId: storeId.value.isEmpty ? null : storeId.value,
      );

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Resep "${recipe.name}" berhasil dihapus',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      );

      // Refresh list after deletion
      await refreshRecipes();
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        'Gagal menghapus resep: $errorMsg',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    } finally {
      isOperationLoading.value = false;
    }
  }

  // Duplicate recipe functionality
  Future<void> duplicateRecipe(Recipe recipe) async {
    try {
      // Set form controllers with duplicated data
      nameController.text = '${recipe.name} (Copy)';
      descriptionController.text = recipe.description;

      // Deep copy the recipe items
      recipeItems.value = recipe.items
          .map((item) => RecipeItem(
                inventoryId: item.inventoryId,
                inventoryName: item.inventoryName,
                inventorySku: item.inventorySku,
                inventoryUnit: item.inventoryUnit,
                requiredQuantity: item.requiredQuantity,
                requiredUnit: item.requiredUnit,
                costPerUnit: item.costPerUnit,
                totalCost: item.totalCost,
                notes: item.notes,
                hpp: item.hpp,
              ))
          .toList();

      // Load inventories and show create dialog
      await loadAvailableInventories();

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: CreateRecipeDialog(controller: this),
        ),
      );

      // Show info message
      Get.snackbar(
        'Info',
        'Resep "${recipe.name}" telah diduplikasi. Silakan edit dan simpan.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.content_copy, color: Colors.blue),
      );
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        'Gagal menduplikasi resep: $errorMsg',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    }
  }

  // Show recipe actions (edit, delete, etc.) - Updated
  void showRecipeActions(Recipe recipe) {
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
            // Handle bar
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
              leading: const Icon(Icons.visibility),
              title: const Text('Lihat Detail'),
              onTap: () {
                Get.back();
                showRecipeDetails(recipe);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Resep'),
              onTap: () {
                Get.back();
                showEditRecipeDialog(recipe);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplikasi Resep'),
              onTap: () {
                Get.back();
                duplicateRecipe(recipe);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus Resep',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                deleteRecipe(recipe);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Calculate total cost for current recipe items
  double get currentRecipeTotalCost {
    double total = 0;
    for (var item in recipeItems) {
      total += item.totalCost;
    }
    return total;
  }

  // Get formatted total cost string
  String get formattedTotalCost {
    return 'Rp ${currentRecipeTotalCost.toStringAsFixed(0)}';
  }

  // Validate recipe form
  bool validateRecipeForm() {
    if (nameController.text.trim().isEmpty) {
      return false;
    }

    if (recipeItems.isEmpty) {
      return false;
    }

    for (var item in recipeItems) {
      if (item.inventoryId.isEmpty ||
          item.requiredQuantity <= 0 ||
          item.requiredUnit.isEmpty) {
        return false;
      }
    }

    return true;
  }

  // Check if form has unsaved changes
  bool get hasUnsavedChanges {
    if (isEditMode.value && currentEditingRecipe.value != null) {
      final original = currentEditingRecipe.value!;

      // Check if name or description changed
      if (nameController.text != original.name ||
          descriptionController.text != original.description) {
        return true;
      }

      // Check if items changed
      if (recipeItems.length != original.items.length) {
        return true;
      }

      for (int i = 0; i < recipeItems.length; i++) {
        final current = recipeItems[i];
        final orig = original.items[i];

        if (current.inventoryId != orig.inventoryId ||
            current.requiredQuantity != orig.requiredQuantity ||
            current.requiredUnit != orig.requiredUnit ||
            current.notes != orig.notes) {
          return true;
        }
      }

      return false;
    }

    // For create mode, check if any data is entered
    return nameController.text.isNotEmpty ||
        descriptionController.text.isNotEmpty ||
        recipeItems.isNotEmpty;
  }

  // Handle back navigation with unsaved changes check
  Future<bool> handleBackNavigation() async {
    if (!hasUnsavedChanges) {
      return true;
    }

    final bool? shouldDiscard = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Perubahan Belum Disimpan'),
        content: const Text('Anda memiliki perubahan yang belum disimpan. '
            'Apakah Anda yakin ingin keluar tanpa menyimpan?'),
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
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }
}
