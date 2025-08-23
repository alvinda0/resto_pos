// screens/product_management_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/product/product_controller.dart';
import 'package:pos/models/product/product_model.dart';
import 'package:pos/screens/product/add_product_dialog.dart';
import 'package:pos/screens/product/edit_product_dialog.dart';
import 'package:pos/widgets/pagination_widget.dart';

// Responsive Breakpoints Utility Class
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobile) return DeviceType.mobile;
    if (width < desktop) return DeviceType.tablet;
    return DeviceType.desktop;
  }
}

enum DeviceType { mobile, tablet, desktop }

// Responsive Values Utility Class
class ResponsiveValues {
  static double padding(BuildContext context) {
    switch (ResponsiveBreakpoints.getDeviceType(context)) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 20;
      case DeviceType.desktop:
        return 24;
    }
  }

  static double cardPadding(BuildContext context) {
    switch (ResponsiveBreakpoints.getDeviceType(context)) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 14;
      case DeviceType.desktop:
        return 16;
    }
  }

  static double spacing(BuildContext context) {
    switch (ResponsiveBreakpoints.getDeviceType(context)) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 16;
      case DeviceType.desktop:
        return 20;
    }
  }

  static double buttonHeight(BuildContext context) {
    switch (ResponsiveBreakpoints.getDeviceType(context)) {
      case DeviceType.mobile:
        return 36;
      case DeviceType.tablet:
        return 40;
      case DeviceType.desktop:
        return 44;
    }
  }

  static double fontSize(BuildContext context,
      {required double mobile,
      required double tablet,
      required double desktop}) {
    switch (ResponsiveBreakpoints.getDeviceType(context)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  static int gridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < ResponsiveBreakpoints.mobile) return 1; // Mobile: 1 column
    if (width < ResponsiveBreakpoints.tablet)
      return 2; // Small tablet: 2 columns
    if (width < ResponsiveBreakpoints.desktop)
      return 3; // Large tablet: 3 columns
    if (width < 1600) return 4; // Desktop: 4 columns
    return 5; // Large desktop: 5 columns
  }

  static double cardAspectRatio(BuildContext context) {
    switch (ResponsiveBreakpoints.getDeviceType(context)) {
      case DeviceType.mobile:
        return 2.2; // More horizontal for mobile cards
      case DeviceType.tablet:
        return 0.9;
      case DeviceType.desktop:
        return 0.8;
    }
  }
}

class ProductManagementScreen extends StatelessWidget {
  ProductManagementScreen({Key? key}) : super(key: key);

  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildSearchAndFilter(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.error.value.isNotEmpty &&
                  controller.products.isEmpty) {
                return _buildErrorView(context);
              }

              if (controller.products.isEmpty) {
                return _buildEmptyView(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshProducts,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding:
                          EdgeInsets.all(ResponsiveValues.padding(context)),
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

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: ResponsiveValues.fontSize(context,
                  mobile: 40, tablet: 44, desktop: 48),
              color: Colors.grey.shade400),
          SizedBox(height: ResponsiveValues.spacing(context)),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveValues.padding(context)),
            child: Text(
              controller.error.value,
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: ResponsiveValues.fontSize(context,
                      mobile: 14, tablet: 15, desktop: 16)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: ResponsiveValues.spacing(context)),
          SizedBox(
            height: ResponsiveValues.buttonHeight(context),
            child: ElevatedButton(
              onPressed: () => controller.refreshProducts(),
              child: Text(
                'Coba Lagi',
                style: TextStyle(
                    fontSize: ResponsiveValues.fontSize(context,
                        mobile: 12, tablet: 13, desktop: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: ResponsiveValues.fontSize(context,
                  mobile: 56, tablet: 60, desktop: 64),
              color: Colors.grey.shade400),
          SizedBox(height: ResponsiveValues.spacing(context)),
          Text(
            'Tidak ada produk ditemukan',
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: ResponsiveValues.fontSize(context,
                    mobile: 14, tablet: 15, desktop: 16)),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau tambah produk baru',
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: ResponsiveValues.fontSize(context,
                    mobile: 12, tablet: 13, desktop: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(ResponsiveValues.padding(context)),
      child: _buildResponsiveSearch(context),
    );
  }

  Widget _buildResponsiveSearch(BuildContext context) {
    final deviceType = ResponsiveBreakpoints.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return _buildMobileSearch(context);
      case DeviceType.tablet:
        return _buildTabletSearch(context);
      case DeviceType.desktop:
        return _buildDesktopSearch(context);
    }
  }

  Widget _buildMobileSearch(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(context),
        SizedBox(height: ResponsiveValues.spacing(context) * 0.75),
        Row(
          children: [
            Expanded(flex: 2, child: _buildCategoryFilter(context)),
            SizedBox(width: ResponsiveValues.spacing(context) * 0.75),
            _buildClearFilterButton(context),
            SizedBox(width: ResponsiveValues.spacing(context) * 0.5),
            _buildAddButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletSearch(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 3, child: _buildSearchField(context)),
            SizedBox(width: ResponsiveValues.spacing(context)),
            Expanded(flex: 2, child: _buildCategoryFilter(context)),
          ],
        ),
        SizedBox(height: ResponsiveValues.spacing(context) * 0.75),
        Row(
          children: [
            const Spacer(),
            _buildClearFilterButton(context),
            SizedBox(width: ResponsiveValues.spacing(context)),
            _buildAddButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopSearch(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildSearchField(context)),
        SizedBox(width: ResponsiveValues.spacing(context)),
        Expanded(flex: 2, child: _buildCategoryFilter(context)),
        SizedBox(width: ResponsiveValues.spacing(context)),
        _buildClearFilterButton(context),
        SizedBox(width: ResponsiveValues.spacing(context)),
        _buildAddButton(context),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: ResponsiveValues.buttonHeight(context),
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
        style: TextStyle(
            fontSize: ResponsiveValues.fontSize(context,
                mobile: 14, tablet: 15, desktop: 16)),
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: ResponsiveValues.fontSize(context,
                  mobile: 14, tablet: 15, desktop: 16)),
          prefixIcon: Icon(Icons.search,
              color: Colors.grey.shade500,
              size: ResponsiveValues.fontSize(context,
                  mobile: 18, tablet: 20, desktop: 22)),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: Colors.grey.shade500,
                      size: ResponsiveValues.fontSize(context,
                          mobile: 16, tablet: 18, desktop: 20)),
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

  Widget _buildCategoryFilter(BuildContext context) {
    return Container(
      height: ResponsiveValues.buttonHeight(context),
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
                      fontSize: ResponsiveValues.fontSize(context,
                          mobile: 14, tablet: 15, desktop: 16))),
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              icon:
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: ResponsiveValues.fontSize(context,
                      mobile: 14, tablet: 15, desktop: 16)),
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

  Widget _buildClearFilterButton(BuildContext context) {
    return Obx(() => (controller.searchQuery.value.isNotEmpty ||
            controller.selectedCategory.value.isNotEmpty)
        ? SizedBox(
            width: ResponsiveValues.buttonHeight(context),
            height: ResponsiveValues.buttonHeight(context),
            child: IconButton(
              onPressed: controller.clearFilters,
              icon: Icon(Icons.filter_list_off,
                  color: Colors.grey.shade600,
                  size: ResponsiveValues.fontSize(context,
                      mobile: 18, tablet: 20, desktop: 22)),
              tooltip: 'Hapus Filter',
            ),
          )
        : const SizedBox.shrink());
  }

  Widget _buildAddButton(BuildContext context) {
    final deviceType = ResponsiveBreakpoints.getDeviceType(context);

    if (deviceType == DeviceType.mobile) {
      return SizedBox(
        width: ResponsiveValues.buttonHeight(context),
        height: ResponsiveValues.buttonHeight(context),
        child: ElevatedButton(
          onPressed: () => Get.dialog(const AddProductDialog()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Icon(Icons.add,
              size: ResponsiveValues.fontSize(context,
                  mobile: 18, tablet: 20, desktop: 22)),
        ),
      );
    }

    return SizedBox(
      height: ResponsiveValues.buttonHeight(context),
      child: ElevatedButton.icon(
        onPressed: () => Get.dialog(const AddProductDialog()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveValues.spacing(context), vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(Icons.add,
            size: ResponsiveValues.fontSize(context,
                mobile: 16, tablet: 18, desktop: 20)),
        label: Text(
            deviceType == DeviceType.tablet ? 'Tambah' : 'Tambah Produk',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: ResponsiveValues.fontSize(context,
                    mobile: 12, tablet: 13, desktop: 14))),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    final crossAxisCount = ResponsiveValues.gridCrossAxisCount(context);
    final spacing = ResponsiveValues.spacing(context);
    final aspectRatio = ResponsiveValues.cardAspectRatio(context);

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
    final deviceType = ResponsiveBreakpoints.getDeviceType(context);

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
      child: deviceType == DeviceType.mobile
          ? _buildMobileCard(product, context)
          : _buildDesktopCard(product, context),
    );
  }

  Widget _buildMobileCard(Product product, BuildContext context) {
    final cardPadding = ResponsiveValues.cardPadding(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust image size based on screen width
    final imageSize = screenWidth < 360 ? 70.0 : 80.0;

    return Padding(
      padding: EdgeInsets.all(cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          _buildProductImage(
              product, imageSize, imageSize, BorderRadius.circular(8), context),
          SizedBox(width: cardPadding),

          // Product Info - Use Flexible to prevent overflow
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge and Price Row
                Row(
                  children: [
                    // Status Badge - constrained width
                    SizedBox(
                      width: screenWidth * 0.25, // Max 25% of screen width
                      child: _buildStatusBadge(product, context),
                    ),
                    const Spacer(),
                    // Price - flexible to fit available space
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          controller.formatCurrency(product.basePrice),
                          style: TextStyle(
                            fontSize: screenWidth < 360 ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Product Name - constrained
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth -
                        imageSize -
                        (cardPadding * 3), // Available width
                  ),
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 13 : 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 4),

                // Product Description - constrained
                if (product.description.isNotEmpty &&
                    product.description != '-') ...[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth - imageSize - (cardPadding * 3),
                    ),
                    child: Text(
                      product.description,
                      style: TextStyle(
                          fontSize: screenWidth < 360 ? 11 : 12,
                          color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // HPP and Position Info - constrained
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth - imageSize - (cardPadding * 3),
                  ),
                  child: Text(
                    'HPP: ${controller.formatCurrency(product.hpp.toInt())} • Pos: ${product.position}',
                    style: TextStyle(
                        fontSize: screenWidth < 360 ? 10 : 11,
                        color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(height: screenWidth < 360 ? 8 : 12),

                // Action Buttons - constrained
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth - imageSize - (cardPadding * 3),
                  ),
                  child: _buildActionButtons(product, context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCard(Product product, BuildContext context) {
    final cardPadding = ResponsiveValues.cardPadding(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImage(
            product,
            double.infinity,
            ResponsiveValues.fontSize(context,
                mobile: 100, tablet: 110, desktop: 120),
            const BorderRadius.vertical(top: Radius.circular(12)),
            context),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusBadge(product, context),
                    const SizedBox(height: 6),
                    Text(
                      product.name,
                      style: TextStyle(
                          fontSize: ResponsiveValues.fontSize(context,
                              mobile: 13, tablet: 14, desktop: 15),
                          fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.description.isNotEmpty &&
                        product.description != '-') ...[
                      const SizedBox(height: 2),
                      Text(
                        product.description,
                        style: TextStyle(
                            fontSize: ResponsiveValues.fontSize(context,
                                mobile: 10, tablet: 11, desktop: 12),
                            color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'HPP: ${controller.formatCurrency(product.hpp.toInt())} • Pos: ${product.position}',
                      style: TextStyle(
                          fontSize: ResponsiveValues.fontSize(context,
                              mobile: 9, tablet: 10, desktop: 11),
                          color: Colors.grey.shade600),
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
                      style: TextStyle(
                        fontSize: ResponsiveValues.fontSize(context,
                            mobile: 14, tablet: 15, desktop: 16),
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildActionButtons(product, context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(Product product, double width, double height,
      BorderRadius borderRadius, BuildContext context) {
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
                    _buildPlaceholderImage(context),
              )
            : _buildPlaceholderImage(context),
      ),
    );
  }

  Widget _buildStatusBadge(Product product, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth < 360 ? 4 : 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            product.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              product.isAvailable ? Colors.green.shade200 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          product.isAvailable ? 'TERSEDIA' : 'TIDAK',
          style: TextStyle(
            color: product.isAvailable
                ? Colors.green.shade700
                : Colors.red.shade700,
            fontSize: screenWidth < 360 ? 7 : 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Product product, BuildContext context) {
    final deviceType = ResponsiveBreakpoints.getDeviceType(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // More conservative button height for very small screens
    final buttonHeight = deviceType == DeviceType.mobile
        ? screenWidth < 360
            ? 28.0 // Very small screens
            : 32.0 // Normal mobile
        : ResponsiveValues.buttonHeight(context) * 0.75;

    // Smaller font size to prevent overflow
    final fontSize = screenWidth < 360 ? 9.0 : 10.0;

    // Tighter spacing
    final buttonSpacing = screenWidth < 360 ? 4.0 : 6.0;

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: () => _showEditDialog(product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  minimumSize: const Size(0, 0),
                  elevation: 0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: buttonSpacing),
          Expanded(
            child: Container(
              height: buttonHeight,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isDeleting.value
                        ? null
                        : () => _showDeleteConfirmation(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      minimumSize: const Size(0, 0),
                      elevation: 0,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: controller.isDeleting.value
                        ? SizedBox(
                            width: fontSize,
                            height: fontSize,
                            child: const CircularProgressIndicator(
                              strokeWidth: 1,
                              color: Colors.white,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Hapus',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                          ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined,
              size: ResponsiveValues.fontSize(context,
                  mobile: 24, tablet: 28, desktop: 32),
              color: Colors.grey.shade400),
          const SizedBox(height: 4),
          Text('Tidak ada gambar',
              style: TextStyle(
                  fontSize: ResponsiveValues.fontSize(context,
                      mobile: 8, tablet: 9, desktop: 10),
                  color: Colors.grey.shade500)),
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
