import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/assets/assets_controller.dart';
import 'package:pos/models/assets/assets_model.dart';
import 'package:pos/widgets/pagination_widget.dart';

class AssetScreen extends StatelessWidget {
  const AssetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AssetController controller = Get.put(AssetController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header with search and buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mobile layout adjustments
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 768;

                    if (isMobile) {
                      return _buildMobileHeader(controller);
                    } else {
                      return _buildDesktopHeader(controller);
                    }
                  },
                ),
              ],
            ),
          ),

          // Content area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 768;

                return Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Table header (desktop only)
                      if (!isMobile) _buildTableHeader(controller),

                      // Content
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value &&
                              controller.assets.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (controller.errorMessage.value.isNotEmpty &&
                              controller.assets.isEmpty) {
                            return _buildErrorState(controller);
                          }

                          if (controller.assets.isEmpty) {
                            return _buildEmptyState(controller);
                          }

                          // Switch between mobile cards and desktop table
                          if (isMobile) {
                            return _buildMobileCardList(controller, context);
                          } else {
                            return _buildDesktopTable(controller, context);
                          }
                        }),
                      ),

                      // Pagination
                      Obx(() {
                        if (controller.totalItems.value == 0) {
                          return const SizedBox.shrink();
                        }

                        final paginationData = controller.paginationData;
                        return PaginationWidget(
                          currentPage: controller.currentPage.value,
                          totalItems: controller.totalItems.value,
                          itemsPerPage: controller.itemsPerPage.value,
                          availablePageSizes: controller.availablePageSizes,
                          startIndex: paginationData['startIndex'],
                          endIndex: paginationData['endIndex'],
                          hasPreviousPage: paginationData['hasPreviousPage'],
                          hasNextPage: paginationData['hasNextPage'],
                          pageNumbers: paginationData['pageNumbers'],
                          onPageSizeChanged: controller.changePageSize,
                          onPreviousPage: controller.previousPage,
                          onNextPage: controller.nextPage,
                          onPageSelected: controller.goToPage,
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(AssetController controller) {
    return Column(
      children: [
        // Search field with Add button
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
                    hintText: 'Cari aset...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    suffixIcon:
                        Obx(() => controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey.shade500,
                                  size: 20,
                                ),
                                onPressed: () {
                                  controller.searchController.clear();
                                  controller.searchAssets('');
                                },
                              )
                            : const SizedBox.shrink()),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onChanged: (value) {
                    controller.searchAssets(value);
                  },
                  onSubmitted: (value) {
                    controller.searchAssets(value);
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Add asset button
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(Get.context!, controller),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text(
                  'Tambah',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Filter row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterButton(
                'Jenis',
                controller.selectedType.value.isEmpty
                    ? 'Semua'
                    : controller.selectedType.value.replaceAll('_', ' '),
                () => _showTypeFilter(Get.context!, controller),
              ),
              const SizedBox(width: 8),
              _buildFilterButton(
                'Kategori',
                controller.selectedCategory.value.isEmpty
                    ? 'Semua'
                    : controller.selectedCategory.value,
                () => _showCategoryFilter(Get.context!, controller),
              ),
              const SizedBox(width: 8),
              _buildFilterButton(
                'Status',
                controller.selectedStatus.value.isEmpty
                    ? 'Semua'
                    : controller.selectedStatus.value,
                () => _showStatusFilter(Get.context!, controller),
              ),
              const SizedBox(width: 8),
              _buildRefreshButton(controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(AssetController controller) {
    return Row(
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
                hintText: 'Cari aset...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.searchAssets('');
                        },
                      )
                    : const SizedBox.shrink()),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onChanged: (value) {
                controller.searchAssets(value);
              },
              onSubmitted: (value) {
                controller.searchAssets(value);
              },
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Filter buttons
        _buildFilterButton(
          'Jenis',
          controller.selectedType.value.isEmpty
              ? 'Semua Jenis'
              : controller.selectedType.value.replaceAll('_', ' '),
          () => _showTypeFilter(Get.context!, controller),
        ),
        const SizedBox(width: 8),
        _buildFilterButton(
          'Kategori',
          controller.selectedCategory.value.isEmpty
              ? 'Semua Kategori'
              : controller.selectedCategory.value,
          () => _showCategoryFilter(Get.context!, controller),
        ),
        const SizedBox(width: 8),
        _buildFilterButton(
          'Status',
          controller.selectedStatus.value.isEmpty
              ? 'Semua Status'
              : controller.selectedStatus.value,
          () => _showStatusFilter(Get.context!, controller),
        ),

        const SizedBox(width: 8),

        // Clear filters button
        _buildIconButton(Icons.clear_all, controller.clearFilters),
        const SizedBox(width: 8),

        // Selection mode button
        Obx(() => !controller.isSelectionMode.value
            ? _buildIconButton(Icons.checklist, controller.toggleSelectionMode)
            : Row(
                children: [
                  Text(
                    '${controller.selectedAssetIds.length} dipilih',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                      Icons.delete, controller.deleteSelectedAssets,
                      color: Colors.red),
                  const SizedBox(width: 8),
                  _buildIconButton(Icons.close, controller.clearSelection),
                ],
              )),

        const SizedBox(width: 8),

        // Refresh button
        _buildRefreshButton(controller),

        const SizedBox(width: 8),

        // Add asset button
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton.icon(
            onPressed: () => _showAddEditDialog(Get.context!, controller),
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text('Tambah Aset',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed,
      {Color? color}) {
    return Container(
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color ?? Colors.grey.shade600),
        style: IconButton.styleFrom(
          side: BorderSide(color: color ?? Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(AssetController controller) {
    return Container(
      height: 40,
      child: Obx(() => IconButton(
            onPressed:
                controller.isLoading.value ? null : () => controller.refresh(),
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
    );
  }

  Widget _buildTableHeader(AssetController controller) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Selection column
          Obx(() => controller.isSelectionMode.value
              ? Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Checkbox(
                    value: controller.selectedAssetIds.length ==
                            controller.assets.length &&
                        controller.assets.isNotEmpty,
                    onChanged: (value) {
                      if (value == true) {
                        for (var asset in controller.assets) {
                          if (!controller.selectedAssetIds.contains(asset.id)) {
                            controller.toggleSelection(asset.id);
                          }
                        }
                      } else {
                        controller.clearSelection();
                      }
                    },
                  ),
                )
              : const SizedBox.shrink()),

          // Table headers
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'NAMA ASET',
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
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'JENIS & KATEGORI',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'SKU',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'HARGA',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'NILAI BUKU',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'STATUS',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
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
    );
  }

  Widget _buildMobileCardList(
      AssetController controller, BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.assets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final asset = controller.assets[index];
        return _buildAssetCard(asset, controller, context);
      },
    );
  }

  Widget _buildAssetCard(
      Asset asset, AssetController controller, BuildContext context) {
    final bookValue = controller.calculateBookValue(asset);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => controller.isSelectionMode.value
            ? controller.toggleSelection(asset.id)
            : _showAssetDetails(context, asset, controller),
        onLongPress: () {
          controller.isSelectionMode.value = true;
          controller.toggleSelection(asset.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Selection checkbox
                  Obx(() => controller.isSelectionMode.value
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Checkbox(
                            value:
                                controller.selectedAssetIds.contains(asset.id),
                            onChanged: (value) =>
                                controller.toggleSelection(asset.id),
                          ),
                        )
                      : const SizedBox.shrink()),

                  // Asset icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getAssetColor(asset.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAssetIcon(asset.type),
                      color: _getAssetColor(asset.type),
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Asset name and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          asset.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(asset.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      asset.status,
                      style: TextStyle(
                        color: _getStatusColor(asset.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Menu button
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showAddEditDialog(context, controller, asset: asset);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context, controller, asset);
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

              const SizedBox(height: 16),

              // Asset details
              Row(
                children: [
                  Expanded(
                    child: _buildCardDetailItem('SKU', asset.sku),
                  ),
                  Expanded(
                    child: _buildCardDetailItem(
                        'Jenis', asset.type.replaceAll('_', ' ')),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildCardDetailItem(
                        'Harga', controller.formatCurrency(asset.cost)),
                  ),
                  Expanded(
                    child: _buildCardDetailItem('Nilai Buku',
                        controller.formatCurrency(bookValue.round())),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'Akuisisi: ${_formatDate(asset.acquisitionDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTable(AssetController controller, BuildContext context) {
    return ListView.builder(
      itemCount: controller.assets.length,
      itemBuilder: (context, index) {
        final asset = controller.assets[index];
        return _buildAssetRow(asset, index, controller, context);
      },
    );
  }

  Widget _buildErrorState(AssetController controller) {
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
            onPressed: () => controller.refresh(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AssetController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'Tidak ada aset yang cocok'
                : 'Tidak ada aset',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'Coba ubah kata kunci pencarian'
                : 'Mulai dengan menambahkan aset pertama Anda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          if (controller.searchQuery.value.isNotEmpty)
            OutlinedButton(
              onPressed: () {
                controller.searchController.clear();
                controller.searchAssets('');
              },
              child: const Text('Hapus Filter'),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(Get.context!, controller),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Aset'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value, VoidCallback onTap) {
    return Container(
      height: 40,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$label: $value',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetRow(Asset asset, int index, AssetController controller,
      BuildContext context) {
    final bookValue = controller.calculateBookValue(asset);
    final depreciationPercentage =
        controller.calculateDepreciationPercentage(asset);

    return InkWell(
      onTap: () => controller.isSelectionMode.value
          ? controller.toggleSelection(asset.id)
          : _showAssetDetails(context, asset, controller),
      onLongPress: () {
        controller.isSelectionMode.value = true;
        controller.toggleSelection(asset.id);
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            // Selection checkbox
            Obx(() => controller.isSelectionMode.value
                ? Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Checkbox(
                      value: controller.selectedAssetIds.contains(asset.id),
                      onChanged: (value) =>
                          controller.toggleSelection(asset.id),
                    ),
                  )
                : const SizedBox.shrink()),

            // NAMA ASET column
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getAssetColor(asset.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getAssetIcon(asset.type),
                        color: _getAssetColor(asset.type),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        asset.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // JENIS & KATEGORI column
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      asset.type.replaceAll('_', ' '),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      asset.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SKU column
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  asset.sku,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            // HARGA column
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  controller.formatCurrency(asset.cost),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // NILAI BUKU column
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  controller.formatCurrency(bookValue.round()),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // STATUS column
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(asset.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    asset.status,
                    style: TextStyle(
                      color: _getStatusColor(asset.status),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            // ACTION column
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _showAddEditDialog(context, controller,
                                asset: asset);
                            break;
                          case 'delete':
                            _showDeleteConfirmation(context, controller, asset);
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

  // Filter dialogs
  void _showTypeFilter(BuildContext context, AssetController controller) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter berdasarkan Jenis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...AssetType.all.map((type) => ListTile(
                    title: Text(type.replaceAll('_', ' ')),
                    onTap: () {
                      controller.filterByType(type);
                      Get.back();
                    },
                  )),
              ListTile(
                title: const Text('Semua Jenis'),
                onTap: () {
                  controller.filterByType('');
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryFilter(BuildContext context, AssetController controller) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter berdasarkan Kategori',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...controller.availableCategories.map((category) => ListTile(
                    title: Text(category),
                    onTap: () {
                      controller.filterByCategory(category);
                      Get.back();
                    },
                  )),
              ListTile(
                title: const Text('Semua Kategori'),
                onTap: () {
                  controller.filterByCategory('');
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusFilter(BuildContext context, AssetController controller) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter berdasarkan Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...AssetStatus.all.map((status) => ListTile(
                    title: Text(status),
                    onTap: () {
                      controller.filterByStatus(status);
                      Get.back();
                    },
                  )),
              ListTile(
                title: const Text('Semua Status'),
                onTap: () {
                  controller.filterByStatus('');
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Keep existing methods but remove the card-specific parts
  void _showDeleteConfirmation(
      BuildContext context, AssetController controller, Asset asset) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Aset'),
        content:
            Text('Apakah Anda yakin ingin menghapus aset "${asset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAsset(asset.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showAssetDetails(
      BuildContext context, Asset asset, AssetController controller) {
    final bookValue = controller.calculateBookValue(asset);
    final depreciationPercentage =
        controller.calculateDepreciationPercentage(asset);

    Get.dialog(
      Dialog(
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getAssetColor(asset.type),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getAssetIcon(asset.type),
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asset.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            asset.category,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('SKU', asset.sku),
                      _buildDetailRow('Jenis', asset.type.replaceAll('_', ' ')),
                      _buildDetailRow('Status', asset.status),
                      _buildDetailRow('Tanggal Akuisisi',
                          _formatDate(asset.acquisitionDate)),
                      if (asset.coverageEndDate != null)
                        _buildDetailRow('Tanggal Berakhir Cakupan',
                            _formatDate(asset.coverageEndDate!)),
                      const Divider(),
                      _buildDetailRow(
                          'Biaya', controller.formatCurrency(asset.cost)),
                      _buildDetailRow('Nilai Residu',
                          controller.formatCurrency(asset.residualValue)),
                      _buildDetailRow('Nilai Buku',
                          controller.formatCurrency(bookValue.round())),
                      _buildDetailRow(
                          'Akumulasi Penyusutan',
                          controller
                              .formatCurrency(asset.accumulatedDepreciation)),
                      _buildDetailRow('Persentase Penyusutan',
                          '${depreciationPercentage.toStringAsFixed(1)}%'),
                      const Divider(),
                      _buildDetailRow(
                          'Masa Manfaat', '${asset.usefulLifeMonths} bulan'),
                      _buildDetailRow('Metode Penyusutan',
                          asset.depMethod.replaceAll('_', ' ')),
                      _buildDetailRow(
                          'Faktor Penyusutan', asset.depFactor.toString()),
                      if (asset.lastDepreciatedAt != null)
                        _buildDetailRow('Terakhir Disusutkan',
                            _formatDate(asset.lastDepreciatedAt!)),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        _showAddEditDialog(context, controller, asset: asset);
                      },
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        _showDeleteConfirmation(context, controller, asset);
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Hapus'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, AssetController controller,
      {Asset? asset}) {
    final isEdit = asset != null;

    // Form controllers
    final nameController = TextEditingController(text: asset?.name ?? '');
    final categoryController =
        TextEditingController(text: asset?.category ?? '');
    final costController =
        TextEditingController(text: asset?.cost.toString() ?? '');
    final residualValueController =
        TextEditingController(text: asset?.residualValue.toString() ?? '');
    final usefulLifeController =
        TextEditingController(text: asset?.usefulLifeMonths.toString() ?? '');
    final depFactorController =
        TextEditingController(text: asset?.depFactor.toString() ?? '');

    String selectedType = asset?.type ?? AssetType.fixedTangible;
    String selectedDepMethod =
        asset?.depMethod ?? DepreciationMethod.straightLine;
    DateTime acquisitionDate = asset?.acquisitionDate ?? DateTime.now();
    DateTime? coverageEndDate = asset?.coverageEndDate;

    Get.dialog(
      Dialog(
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isEdit ? Icons.edit : Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEdit ? 'Edit Aset' : 'Tambah Aset Baru',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Aset *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Kategori *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Jenis Aset *',
                            border: OutlineInputBorder(),
                          ),
                          items: AssetType.all
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type.replaceAll('_', ' ')),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                              if (selectedType == AssetType.fixedTangible) {
                                coverageEndDate = null;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: costController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Biaya *',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: residualValueController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Nilai Residu',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: usefulLifeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Masa Manfaat (bulan) *',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedDepMethod,
                                decoration: const InputDecoration(
                                  labelText: 'Metode Penyusutan *',
                                  border: OutlineInputBorder(),
                                ),
                                items: DepreciationMethod.all
                                    .map((method) => DropdownMenuItem(
                                          value: method,
                                          child:
                                              Text(method.replaceAll('_', ' ')),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedDepMethod = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: depFactorController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Faktor Penyusutan',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: acquisitionDate,
                              firstDate: DateTime(2000),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                acquisitionDate = date;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Akuisisi *',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_formatDate(acquisitionDate)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (selectedType == AssetType.prepaidExpense)
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: coverageEndDate ??
                                    DateTime.now()
                                        .add(const Duration(days: 365)),
                                firstDate: acquisitionDate,
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setState(() {
                                  coverageEndDate = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Tanggal Berakhir Cakupan *',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(coverageEndDate != null
                                  ? _formatDate(coverageEndDate!)
                                  : 'Pilih tanggal'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _submitAsset(
                          controller,
                          isEdit,
                          asset,
                          nameController,
                          categoryController,
                          selectedType,
                          costController,
                          residualValueController,
                          usefulLifeController,
                          selectedDepMethod,
                          depFactorController,
                          acquisitionDate,
                          coverageEndDate,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isEdit ? 'Perbarui' : 'Buat'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitAsset(
    AssetController controller,
    bool isEdit,
    Asset? existingAsset,
    TextEditingController nameController,
    TextEditingController categoryController,
    String selectedType,
    TextEditingController costController,
    TextEditingController residualValueController,
    TextEditingController usefulLifeController,
    String selectedDepMethod,
    TextEditingController depFactorController,
    DateTime acquisitionDate,
    DateTime? coverageEndDate,
  ) {
    // Validation
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Nama aset wajib diisi');
      return;
    }
    if (categoryController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Kategori wajib diisi');
      return;
    }
    if (costController.text.trim().isEmpty ||
        int.tryParse(costController.text) == null) {
      Get.snackbar('Error', 'Biaya harus diisi dengan angka yang valid');
      return;
    }
    if (usefulLifeController.text.trim().isEmpty ||
        int.tryParse(usefulLifeController.text) == null) {
      Get.snackbar('Error', 'Masa manfaat harus diisi dengan angka yang valid');
      return;
    }
    if (selectedType == AssetType.prepaidExpense && coverageEndDate == null) {
      Get.snackbar('Error',
          'Tanggal berakhir cakupan wajib diisi untuk beban dibayar dimuka');
      return;
    }

    // Format dates to UTC and ensure proper ISO format
    final formattedAcquisitionDate = DateTime.utc(
      acquisitionDate.year,
      acquisitionDate.month,
      acquisitionDate.day,
      0, 0, 0, 0, // Set time to 00:00:00.000
    );

    final DateTime? formattedCoverageEndDate = coverageEndDate != null
        ? DateTime.utc(
            coverageEndDate.year,
            coverageEndDate.month,
            coverageEndDate.day,
            23, 59, 59, 999, // Set to end of day
          )
        : null;

    // Create asset with proper field mapping
    final newAsset = Asset(
      id: existingAsset?.id ?? '',
      storeId: existingAsset?.storeId ?? '',
      type: selectedType,
      name: nameController.text.trim(),
      category: categoryController.text.trim(),
      sku: existingAsset?.sku ?? '',
      acquisitionDate: formattedAcquisitionDate,
      coverageEndDate: selectedType == AssetType.fixedTangible
          ? null
          : formattedCoverageEndDate,
      cost: int.parse(costController.text),
      residualValue: int.tryParse(residualValueController.text) ?? 0,
      usefulLifeMonths: int.parse(usefulLifeController.text),
      depMethod: selectedDepMethod,
      depFactor: double.tryParse(depFactorController.text) ??
          (selectedDepMethod == DepreciationMethod.decliningBalance
              ? 2.0
              : 1.0),
      accumulatedDepreciation: existingAsset?.accumulatedDepreciation ?? 0,
      lastDepreciatedAt: existingAsset?.lastDepreciatedAt,
      status: existingAsset?.status ?? AssetStatus.active,
    );

    Get.back();

    if (isEdit && existingAsset != null) {
      controller.updateAsset(existingAsset.id, newAsset);
    } else {
      controller.createAsset(newAsset);
    }
  }

  Color _getAssetColor(String type) {
    switch (type) {
      case AssetType.fixedTangible:
        return Colors.blue;
      case AssetType.prepaidExpense:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getAssetIcon(String type) {
    switch (type) {
      case AssetType.fixedTangible:
        return Icons.business_center;
      case AssetType.prepaidExpense:
        return Icons.schedule;
      default:
        return Icons.inventory_2;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AssetStatus.active:
        return Colors.green;
      case AssetStatus.inactive:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
