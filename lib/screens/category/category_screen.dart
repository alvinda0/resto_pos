import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/category/category_controller.dart';
import 'package:pos/widgets/pagination_widget.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 768;
          final isDesktop = constraints.maxWidth >= 1024;

          return Column(
            children: [
              // Header
              _buildHeader(controller, isTablet),

              // Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(isTablet ? 24 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search and Filter Section
                      _buildSearchAndFilter(controller, isTablet),

                      // Data Content
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            );
                          }

                          if (controller.categories.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open_outlined,
                                    size: isTablet ? 64 : 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(height: isTablet ? 16 : 12),
                                  Text(
                                    'Tidak ada data kategori',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return isDesktop
                              ? _buildDataTable(controller)
                              : _buildMobileList(controller, isTablet);
                        }),
                      ),

                      // Pagination
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                                color: Colors.grey.shade200, width: 1),
                          ),
                        ),
                        child: Obx(() => PaginationWidget(
                              currentPage: controller.currentPage.value,
                              totalItems: controller.totalItems.value,
                              itemsPerPage: controller.itemsPerPage.value,
                              availablePageSizes: controller.availablePageSizes,
                              startIndex: controller.startIndex,
                              endIndex: controller.endIndex,
                              hasPreviousPage: controller.hasPreviousPage,
                              hasNextPage: controller.hasNextPage,
                              pageNumbers: controller.pageNumbers,
                              onPageSizeChanged: controller.onPageSizeChanged,
                              onPreviousPage: controller.goToPreviousPage,
                              onNextPage: controller.goToNextPage,
                              onPageSelected: controller.onPageChanged,
                            )),
                      ),
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

  Widget _buildHeader(CategoryController controller, bool isTablet) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 24 : 16,
        isTablet ? 32 : 24,
        isTablet ? 24 : 16,
        0,
      ),
      child: isTablet
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manajemen Kategori',
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateCategoryDialog(controller),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text(
                    'Tambah Kategori',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    elevation: 2,
                    shadowColor: Colors.blue.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manajemen Kategori',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                FloatingActionButton(
                  mini: true,
                  onPressed: () => _showCreateCategoryDialog(controller),
                  backgroundColor: Colors.blue.shade600,
                  elevation: 3,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchAndFilter(CategoryController controller, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: isTablet
          ? Column(
              children: [
                // Search Field for tablet
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (value) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (controller.searchController.text == value) {
                          controller.onSearchChanged(value);
                        }
                      });
                    },
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari kategori...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.normal,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                        size: 22,
                      ),
                      suffixIcon:
                          Obx(() => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey.shade500,
                                    size: 20,
                                  ),
                                  onPressed: controller.clearSearch,
                                )
                              : const SizedBox.shrink()),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Status Filter for tablet
                Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Obx(() => DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.statusFilter.value.isEmpty
                              ? ''
                              : controller.statusFilter.value,
                          hint: Text(
                            'Filter Status',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          isExpanded: true,
                          isDense: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          items: controller.statusOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'] as String,
                              child: Text(option['label'] as String),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              controller.onStatusFilterChanged(value);
                            }
                          },
                        ),
                      )),
                ),
              ],
            )
          : Row(
              children: [
                // Search Field for mobile (70% width)
                Expanded(
                  flex: 7,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade50,
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: (value) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (controller.searchController.text == value) {
                            controller.onSearchChanged(value);
                          }
                        });
                      },
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade500,
                          size: 18,
                        ),
                        suffixIcon:
                            Obx(() => controller.searchQuery.value.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey.shade500,
                                      size: 16,
                                    ),
                                    onPressed: controller.clearSearch,
                                  )
                                : const SizedBox.shrink()),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Status Filter for mobile (30% width)
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade50,
                    ),
                    child: Obx(() => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.statusFilter.value.isEmpty
                                ? ''
                                : controller.statusFilter.value,
                            hint: Text(
                              'Status',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            isExpanded: true,
                            isDense: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            items: controller.statusOptions.map((option) {
                              return DropdownMenuItem<String>(
                                value: option['value'] as String,
                                child: Text(
                                  option['label'] as String,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                controller.onStatusFilterChanged(value);
                              }
                            },
                          ),
                        )),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMobileList(CategoryController controller, bool isTablet) {
    return ListView.separated(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      itemCount: controller.categories.length,
      separatorBuilder: (context, index) => SizedBox(height: isTablet ? 12 : 8),
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        final rowNumber = controller.startIndex + index;

        return Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row - Compact
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Number and Name in one line
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$rowNumber',
                            style: TextStyle(
                              fontSize: isTablet ? 11 : 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions Menu - Smaller
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Hapus',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditCategoryDialog(controller, category);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(controller, category);
                          break;
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 10 : 8),

              // Compact Details Row
              Row(
                children: [
                  // Position
                  _buildCompactDetailItem(
                    'Pos',
                    category.position.toString(),
                    Colors.blue.shade50,
                    Colors.blue.shade700,
                    isTablet,
                  ),
                  const SizedBox(width: 8),
                  // Status
                  _buildCompactDetailItem(
                    'Status',
                    controller.getStatusText(category.isActive),
                    controller.getStatusColor(category.isActive),
                    Colors.white,
                    isTablet,
                  ),
                  const SizedBox(width: 8),
                  // Product Count
                  _buildCompactDetailItem(
                    'Produk',
                    controller.getProductCount(category).toString(),
                    controller.getProductCount(category) > 0
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
                    controller.getProductCount(category) > 0
                        ? Colors.green.shade700
                        : Colors.black54,
                    isTablet,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactDetailItem(
    String label,
    String value,
    Color backgroundColor,
    Color textColor,
    bool isTablet,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 8 : 6,
          vertical: isTablet ? 6 : 4,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: backgroundColor == Colors.white
                ? Colors.grey.shade300
                : backgroundColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 10 : 9,
                fontWeight: FontWeight.w500,
                color: textColor == Colors.white
                    ? Colors.white70
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(CategoryController controller) {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(Get.context!).size.width - 96,
          child: DataTable(
            headingRowHeight: 64,
            dataRowHeight: 72,
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
            columnSpacing: 20,
            horizontalMargin: 24,
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
            dataTextStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontSize: 14,
            ),
            border: TableBorder(
              horizontalInside: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            columns: const [
              DataColumn(label: Text('No.')),
              DataColumn(label: Text('NAMA KATEGORI')),
              DataColumn(
                label: Row(
                  children: [
                    Text('POSISI'),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_upward, size: 16, color: Colors.grey),
                  ],
                ),
              ),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('JUMLAH PRODUK')),
              DataColumn(label: Text('AKSI')),
            ],
            rows: controller.categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final rowNumber = controller.startIndex + index;

              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 50,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          rowNumber.toString(),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            category.position.toString(),
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: controller.getStatusColor(category.isActive),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            controller.getStatusText(category.isActive),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 140,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: controller.getProductCount(category) > 0
                                ? Colors.green.shade50
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: controller.getProductCount(category) > 0
                                  ? Colors.green.shade200
                                  : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            controller.getProductCount(category).toString(),
                            style: TextStyle(
                              color: controller.getProductCount(category) > 0
                                  ? Colors.green.shade700
                                  : Colors.black54,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: PopupMenuButton<String>(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.grey,
                              size: 18,
                            ),
                          ),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit,
                                      size: 18, color: Colors.blue),
                                  SizedBox(width: 12),
                                  Text(
                                    'Edit',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 12),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _showEditCategoryDialog(controller, category);
                                break;
                              case 'delete':
                                _showDeleteConfirmation(controller, category);
                                break;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Create Category Dialog
  void _showCreateCategoryDialog(CategoryController controller) {
    controller.prepareCreateForm();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Kategori Baru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Name Field
              _buildFormField(
                label: 'Nama Kategori *',
                controller: controller.nameController,
                hintText: 'Masukkan nama kategori',
              ),

              const SizedBox(height: 16),

              // Position Field
              _buildFormField(
                label: 'Posisi (Opsional)',
                controller: controller.positionController,
                hintText: 'Masukkan urutan posisi',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // Status Toggle
              Row(
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => Switch(
                        value: controller.isActiveForm.value,
                        onChanged: (value) =>
                            controller.isActiveForm.value = value,
                        activeColor: Colors.green,
                      )),
                  const SizedBox(width: 8),
                  Obx(() => Text(
                        controller.isActiveForm.value ? 'Aktif' : 'Tidak Aktif',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: controller.isActiveForm.value
                              ? Colors.green
                              : Colors.red,
                        ),
                      )),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isCreating.value
                            ? null
                            : controller.submitCreateForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isCreating.value
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Simpan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Edit Category Dialog
  void _showEditCategoryDialog(CategoryController controller, category) {
    controller.prepareEditForm(category);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Kategori',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Name Field
              _buildFormField(
                label: 'Nama Kategori *',
                controller: controller.nameController,
                hintText: 'Masukkan nama kategori',
              ),

              const SizedBox(height: 16),

              // Position Field
              _buildFormField(
                label: 'Posisi (Opsional)',
                controller: controller.positionController,
                hintText: 'Masukkan urutan posisi',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // Status Toggle
              Row(
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => Switch(
                        value: controller.isActiveForm.value,
                        onChanged: (value) =>
                            controller.isActiveForm.value = value,
                        activeColor: Colors.green,
                      )),
                  const SizedBox(width: 8),
                  Obx(() => Text(
                        controller.isActiveForm.value ? 'Aktif' : 'Tidak Aktif',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: controller.isActiveForm.value
                              ? Colors.green
                              : Colors.red,
                        ),
                      )),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isUpdating.value
                            ? null
                            : () => controller.submitEditForm(category.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isUpdating.value
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Update',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Delete Confirmation Dialog
  void _showDeleteConfirmation(CategoryController controller, category) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Konfirmasi Hapus',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus kategori "${category.name}"?',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isDeleting.value
                    ? null
                    : () async {
                        final success =
                            await controller.deleteCategory(category.id);
                        if (success) {
                          Get.back(); // Close dialog
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.isDeleting.value
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Hapus',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              )),
        ],
      ),
    );
  }

  // Helper method to build form fields
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.normal,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
