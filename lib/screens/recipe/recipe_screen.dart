import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/recipe/recipe_controller.dart';
import 'package:pos/models/recipe/recipe_model.dart';

import 'package:pos/widgets/pagination_widget.dart';

class RecipeManagementScreen extends StatelessWidget {
  const RecipeManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecipeController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manajemen Resep'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Header with search and buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manajemen Resep',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Search field
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: controller.searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari Resep',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                            suffixIcon: Obx(
                                () => controller.searchQuery.value.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey.shade500,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            controller.clearSearch(),
                                      )
                                    : const SizedBox.shrink()),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onChanged: (value) {
                            // Debounce search to avoid too many API calls
                            if (controller.searchQuery.value != value) {
                              controller.searchRecipes(value);
                            }
                          },
                          onSubmitted: (value) {
                            controller.searchRecipes(value);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Refresh button
                    Container(
                      height: 40,
                      child: Obx(() => IconButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.refreshRecipes(),
                            icon: controller.isLoading.value
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.grey.shade600,
                                    ),
                                  )
                                : Icon(
                                    Icons.refresh,
                                    color: Colors.grey.shade600,
                                  ),
                            style: IconButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )),
                    ),

                    const SizedBox(width: 8),

                    // Add recipe button
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Obx(() => ElevatedButton.icon(
                            onPressed: controller.isOperationLoading.value
                                ? null
                                : () {
                                    controller.showCreateRecipeDialog();
                                  },
                            icon: controller.isOperationLoading.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                            label: const Text(
                              'Tambah Resep',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content area
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        // NAMA RESEP column
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Text(
                                  'NAMA RESEP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // DESKRIPSI column
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              'DESKRIPSI',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        // JUMLAH BAHAN column
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              'JUMLAH BAHAN',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        // TOTAL BIAYA column
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              'TOTAL BIAYA',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        // AKSI column
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              'AKSI',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table content
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (controller.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Terjadi Kesalahan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                controller.errorMessage.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => controller.loadRecipes(),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (controller.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                controller.searchQuery.value.isNotEmpty
                                    ? 'Tidak ada resep yang cocok'
                                    : 'Tidak ada resep',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                controller.searchQuery.value.isNotEmpty
                                    ? 'Coba ubah kata kunci pencarian'
                                    : 'Mulai dengan menambahkan resep pertama Anda',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (controller.searchQuery.value.isNotEmpty)
                                OutlinedButton(
                                  onPressed: () => controller.clearSearch(),
                                  child: const Text('Hapus Filter'),
                                )
                              else
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      controller.showCreateRecipeDialog(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Tambah Resep'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: controller.recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = controller.recipes[index];
                          return _buildRecipeRow(recipe, index, controller);
                        },
                      );
                    }),
                  ),

                  // Pagination
                  Obx(() {
                    if (controller.totalItems.value == 0) {
                      return const SizedBox.shrink();
                    }

                    return PaginationWidget(
                      currentPage: controller.currentPage.value,
                      totalItems: controller.totalItems.value,
                      itemsPerPage: controller.itemsPerPage.value,
                      availablePageSizes: controller.availablePageSizes,
                      startIndex: controller.startIndex,
                      endIndex: controller.endIndex,
                      hasPreviousPage: controller.hasPreviousPage,
                      hasNextPage: controller.hasNextPage,
                      pageNumbers: controller.pageNumbers,
                      onPageSizeChanged: (newSize) =>
                          controller.changePageSize(newSize),
                      onPreviousPage: () => controller.goToPreviousPage(),
                      onNextPage: () => controller.goToNextPage(),
                      onPageSelected: (page) => controller.goToPage(page),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeRow(
      Recipe recipe, int index, RecipeController controller) {
    return InkWell(
      onTap: () => controller.showRecipeDetails(recipe),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            // NAMA RESEP column
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // DESKRIPSI column
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  recipe.description.isEmpty ? '-' : recipe.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: recipe.description.isEmpty
                        ? Colors.grey.shade500
                        : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // JUMLAH BAHAN column
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${recipe.items.length} bahan',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            // TOTAL BIAYA column
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Rp ${recipe.totalCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // AKSI column
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // More actions menu
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            controller.showEditRecipeDialog(recipe);
                            break;

                          case 'delete':
                            controller.deleteRecipe(recipe);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Hapus',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
