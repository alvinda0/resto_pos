import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/recipe/recipe_model.dart';
import 'package:pos/services/recipe/recipe_service.dart';

class RecipeController extends GetxController {
  final RecipeService _recipeService = RecipeService.instance;

  // Observable variables
  final RxList<Recipe> recipes = <Recipe>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxList<int> availablePageSizes = [10, 25, 50, 100].obs;

  // Search
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // Store ID (optional)
  final RxString storeId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecipes();
  }

  @override
  void onClose() {
    searchController.dispose();
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
      errorMessage.value = 'Error loading recipes: $e';
      print('Error in loadRecipes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh recipes
  Future<void> refreshRecipes() async {
    await loadRecipes(showLoading: false, isRefresh: true);
  }

  // Search recipes
  void searchRecipes(String query) {
    searchQuery.value = query;
    currentPage.value = 1; // Reset to first page when searching
    loadRecipes();
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

  void changePageSize(int newPageSize) {
    if (availablePageSizes.contains(newPageSize) &&
        newPageSize != itemsPerPage.value) {
      itemsPerPage.value = newPageSize;
      currentPage.value = 1; // Reset to first page
      loadRecipes();
    }
  }

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

  // Helper methods for UI
  bool get hasRecipes => recipes.isNotEmpty;
  bool get hasError => errorMessage.value.isNotEmpty;
  bool get isEmpty => !isLoading.value && !hasRecipes && !hasError;
}
