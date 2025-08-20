// screens/product_management_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/product/product_controller.dart';
import 'package:pos/models/product/product_model.dart';
import 'package:pos/screens/product/add_product_dialog.dart';
import 'package:pos/screens/product/edit_product_dialog.dart';
import 'package:pos/widgets/pagination_widget.dart';

class ProductManagementScreen extends StatelessWidget {
  ProductManagementScreen({Key? key}) : super(key: key);

  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Manajemen Produk',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(isMobile),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.error.value.isNotEmpty &&
                  controller.products.isEmpty) {
                return _buildErrorView();
              }

              if (controller.products.isEmpty) {
                return _buildEmptyView();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshProducts,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(isMobile ? 12 : 24),
                      sliver: _buildProductGrid(context),
                    ),
                  ],
                ),
              );
            }),
          ),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              controller.error.value,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.refreshProducts(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Tidak ada produk ditemukan',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau tambah produk baru',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: isMobile ? _buildMobileSearch() : _buildDesktopSearch(),
    );
  }

  Widget _buildMobileSearch() {
    return Column(
      children: [
        _buildSearchField(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(flex: 2, child: _buildCategoryFilter(true)),
            const SizedBox(width: 12),
            _buildClearFilterButton(),
            const SizedBox(width: 8),
            _buildAddButton(true),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopSearch() {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildSearchField()),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildCategoryFilter(false)),
        const SizedBox(width: 16),
        _buildClearFilterButton(),
        const SizedBox(width: 16),
        _buildAddButton(false),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: (value) {
          // Debounce search
          if (controller.searchQuery.value != value) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (controller.searchController.text == value) {
                controller.searchProducts(value);
              }
            });
          }
        },
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon:
                      Icon(Icons.clear, color: Colors.grey.shade500, size: 18),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.searchProducts('');
                  },
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isMobile) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedCategory.value.isEmpty
                  ? null
                  : controller.selectedCategory.value,
              hint: Text('Semua Kategori',
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: isMobile ? 14 : 16)),
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              icon:
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
              items: [
                const DropdownMenuItem<String>(
                    value: '', child: Text('Semua Kategori')),
                ...controller.categories.map((category) =>
                    DropdownMenuItem<String>(
                        value: category.id, child: Text(category.name))),
              ],
              onChanged: (String? value) =>
                  controller.filterByCategory(value ?? ''),
            ),
          )),
    );
  }

  Widget _buildClearFilterButton() {
    return Obx(() => (controller.searchQuery.value.isNotEmpty ||
            controller.selectedCategory.value.isNotEmpty)
        ? IconButton(
            onPressed: controller.clearFilters,
            icon: Icon(Icons.filter_list_off, color: Colors.grey.shade600),
            tooltip: 'Hapus Filter',
          )
        : const SizedBox.shrink());
  }

  Widget _buildAddButton(bool isMobile) {
    if (isMobile) {
      return ElevatedButton(
        onPressed: () =>
            Get.dialog(const AddProductDialog()), // Fixed: Added Get.dialog()
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(0, 40),
        ),
        child: const Icon(Icons.add, size: 18),
      );
    }

    return ElevatedButton.icon(
      onPressed: () =>
          Get.dialog(const AddProductDialog()), // Fixed: Added Get.dialog()
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Tambah Produk',
          style: TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600
        ? 1
        : screenWidth < 900
            ? 2
            : screenWidth < 1200
                ? 3
                : 4;
    double spacing = screenWidth < 600 ? 12 : 20;
    double aspectRatio = screenWidth < 600 ? 1.0 : 0.8;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) =>
            _buildProductCard(controller.products[index], context),
        childCount: controller.products.length,
      ),
    );
  }

  Widget _buildProductCard(Product product, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile ? _buildMobileCard(product) : _buildDesktopCard(product),
    );
  }

  Widget _buildMobileCard(Product product) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildProductImage(product, 80, 80, BorderRadius.circular(8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatusBadge(product, 9),
                        const Spacer(),
                        Text(
                          controller.formatCurrency(product.basePrice),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (product.description.isNotEmpty &&
                        product.description != '-') ...[
                      const SizedBox(height: 2),
                      Text(product.description,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      'HPP: ${controller.formatCurrency(product.hpp.toInt())} • Pos: ${product.position}',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildActionButtons(product, 28, 11, 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCard(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImage(product, double.infinity, 120,
            const BorderRadius.vertical(top: Radius.circular(12))),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusBadge(product, 10),
                    const SizedBox(height: 6),
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (product.description.isNotEmpty &&
                        product.description != '-') ...[
                      const SizedBox(height: 2),
                      Text(product.description,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'HPP: ${controller.formatCurrency(product.hpp.toInt())} • Pos: ${product.position}',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      controller.formatCurrency(product.basePrice),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildActionButtons(product, 32, 12, 6),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(
      Product product, double width, double height, BorderRadius borderRadius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius: borderRadius, color: Colors.grey.shade100),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: product.imageUrl != null && product.imageUrl!.isNotEmpty
            ? Image.network(
                product.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderImage(),
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildStatusBadge(Product product, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            product.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        product.isAvailable ? 'TERSEDIA' : 'TIDAK TERSEDIA',
        style: TextStyle(
          color:
              product.isAvailable ? Colors.green.shade700 : Colors.red.shade700,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      Product product, double height, double fontSize, double borderRadius) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: height,
            child: ElevatedButton(
              onPressed: () => _showEditDialog(product),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius)),
                minimumSize: Size.zero,
              ),
              child: Text('Edit',
                  style: TextStyle(
                      fontSize: fontSize, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: height,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isDeleting.value
                      ? null
                      : () => _showDeleteConfirmation(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius)),
                    minimumSize: Size.zero,
                  ),
                  child: controller.isDeleting.value
                      ? SizedBox(
                          width: fontSize + 2,
                          height: fontSize + 2,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Hapus',
                          style: TextStyle(
                              fontSize: fontSize, fontWeight: FontWeight.w500)),
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 32, color: Colors.grey.shade400),
          const SizedBox(height: 4),
          Text('Tidak ada gambar',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Obx(() {
      if (controller.totalItems.value > 0) {
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
          onPageSizeChanged: controller.changePageSize,
          onPreviousPage: controller.previousPage,
          onNextPage: controller.nextPage,
          onPageSelected: controller.goToPage,
        );
      }
      return const SizedBox.shrink();
    });
  }

  void _showAddMenuDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Tambah Produk Baru'),
        content: const Text('Fitur tambah produk akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Product product) {
    Get.dialog(
      EditProductDialog(product: product),
      barrierDismissible: false,
    );
  }

  void _showDeleteConfirmation(Product product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteProduct(product.id);
              if (!success) {
                Get.snackbar(
                  'Error',
                  'Gagal menghapus produk',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade800,
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
