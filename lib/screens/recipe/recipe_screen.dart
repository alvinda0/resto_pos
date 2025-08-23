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
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 768;

          return Column(
            children: [
              // Header with search and buttons
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manajemen Resep',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // Mobile: Stack search and buttons vertically
                    if (isMobile) ...[
                      // Search field (full width on mobile)
                      Container(
                        height: 48,
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
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            if (controller.searchQuery.value != value) {
                              controller.searchRecipes(value);
                            }
                          },
                          onSubmitted: (value) {
                            controller.searchRecipes(value);
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Buttons row on mobile
                      Row(
                        children: [
                          // Refresh button
                          Expanded(
                            child: Container(
                              height: 44,
                              child: Obx(() => OutlinedButton.icon(
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
                                            size: 18,
                                          ),
                                    label: const Text('Refresh'),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: Colors.grey.shade300),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Add recipe button (mobile - icon only)
                          Container(
                            width: 44,
                            height: 44,
                            child: Obx(() => ElevatedButton(
                                  onPressed: controller.isOperationLoading.value
                                      ? null
                                      : () {
                                          controller.showCreateRecipeDialog();
                                        },
                                  child: controller.isOperationLoading.value
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
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Desktop: Horizontal layout
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
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade500),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey.shade500,
                                    size: 20,
                                  ),
                                  suffixIcon: Obx(() =>
                                      controller.searchQuery.value.isNotEmpty
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
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Content area
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 0,
                      isMobile ? 16 : 24, isMobile ? 16 : 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Show table header only on desktop
                      if (!isMobile) ...[
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                      ],

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
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 16 : 24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: isMobile ? 40 : 48,
                                      color: Colors.red.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Terjadi Kesalahan',
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      controller.errorMessage.value,
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
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
                              ),
                            );
                          }

                          if (controller.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 16 : 24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_outlined,
                                      size: isMobile ? 40 : 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      controller.searchQuery.value.isNotEmpty
                                          ? 'Tidak ada resep yang cocok'
                                          : 'Tidak ada resep',
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      controller.searchQuery.value.isNotEmpty
                                          ? 'Coba ubah kata kunci pencarian'
                                          : 'Mulai dengan menambahkan resep pertama Anda',
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        color: Colors.grey.shade500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    if (controller.searchQuery.value.isNotEmpty)
                                      OutlinedButton(
                                        onPressed: () =>
                                            controller.clearSearch(),
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
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: controller.recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = controller.recipes[index];
                              return isMobile
                                  ? _buildMobileRecipeCard(
                                      recipe, index, controller)
                                  : _buildRecipeRow(recipe, index, controller);
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
          );
        },
      ),
    );
  }

  // Desktop table row (existing implementation)
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

  // New mobile card layout
  Widget _buildMobileRecipeCard(
      Recipe recipe, int index, RecipeController controller) {
    return InkWell(
      onTap: () => controller.showRecipeDetails(recipe),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe name and actions row
            Row(
              children: [
                Expanded(
                  child: Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade600,
                    size: 20,
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
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            if (recipe.description.isNotEmpty) ...[
              Text(
                recipe.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],

            // Stats row
            Row(
              children: [
                // Ingredients count
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.items.length} bahan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Total cost
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 14,
                        color: Colors.green.shade700,
                      ),
                      Text(
                        'Rp ${recipe.totalCost.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
