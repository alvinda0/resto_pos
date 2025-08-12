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
      body: Column(
        children: [
          // Header
          _buildHeader(controller),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
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
                  _buildSearchAndFilter(controller),

                  // Data Table
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
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada data kategori',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildDataTable(controller);
                    }),
                  ),

                  // Pagination
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200, width: 1),
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
      ),
    );
  }

  Widget _buildHeader(CategoryController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Manajemen Kategori',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement add category
            },
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
      ),
    );
  }

  Widget _buildSearchAndFilter(CategoryController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            flex: 3,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: (value) {
                  // Debounce search
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
                  suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
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
          ),

          const SizedBox(width: 20),

          // Status Filter
          Container(
            height: 48,
            width: 220,
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
      ),
    );
  }

  Widget _buildDataTable(CategoryController controller) {
    return Container(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: MediaQuery.of(Get.context!).size.width -
                96, // Full width minus margins
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
                DataColumn(
                  label: Text('No.'),
                ),
                DataColumn(
                  label: Text('NAMA KATEGORI'),
                ),
                DataColumn(
                  label: Row(
                    children: [
                      Text('POSISI'),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_upward,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                DataColumn(
                  label: Text('STATUS'),
                ),
                DataColumn(
                  label: Text('JUMLAH PRODUK'),
                ),
                DataColumn(
                  label: Text('AKSI'),
                ),
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
                              color:
                                  controller.getStatusColor(category.isActive),
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
                              controller.getProductCount(category) == 1
                                  ? '${controller.getProductCount(category)}'
                                  : controller
                                      .getProductCount(category)
                                      .toString(),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
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
                              // TODO: Implement edit and delete actions
                              switch (value) {
                                case 'edit':
                                  // Navigate to edit screen
                                  break;
                                case 'delete':
                                  // Show delete confirmation dialog
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
        ));
  }
}
