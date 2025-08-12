import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/role/role_controller.dart';
import 'package:pos/models/role/role_model.dart';

import 'package:pos/widgets/pagination_widget.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RoleController controller = Get.put(RoleController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title and Search
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daftar Role',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: controller.searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari Role',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            suffixIcon: Obx(
                                () => controller.searchQuery.value.isNotEmpty
                                    ? IconButton(
                                        onPressed: controller.clearSearch,
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey.shade600,
                                          size: 20,
                                        ),
                                      )
                                    : const SizedBox.shrink()),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Add Role Button
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to add role screen
                    Get.snackbar(
                        'Info', 'Fitur tambah role akan segera tersedia');
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Tambah Role',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Content
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.roles.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (controller.error.value.isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                controller.error.value,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: controller.refreshRoles,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (controller.roles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.admin_panel_settings_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                controller.searchQuery.value.isNotEmpty
                                    ? 'Tidak ada role yang ditemukan untuk "${controller.searchQuery.value}"'
                                    : 'Belum ada role yang ditambahkan',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
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
                  Obx(() => PaginationWidget(
                        currentPage: controller.currentPage.value,
                        totalItems: controller.totalItems.value,
                        itemsPerPage: controller.itemsPerPage.value,
                        availablePageSizes: controller.availablePageSizes,
                        startIndex: controller.startIndex,
                        endIndex: controller.endIndex,
                        hasPreviousPage: controller.hasPreviousPage.value,
                        hasNextPage: controller.hasNextPage.value,
                        pageNumbers: controller.pageNumbers,
                        onPageSizeChanged: controller.onPageSizeChanged,
                        onPreviousPage: controller.onPreviousPage,
                        onNextPage: controller.onNextPage,
                        onPageSelected: controller.onPageSelected,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(RoleController controller) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Table Header
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      'No.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Nama Role',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Izin',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Jumlah Akun',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      'Aksi',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Table Rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.roles.length,
            itemBuilder: (context, index) {
              final role = controller.roles[index];
              final rowNumber = controller.startIndex + index;

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          '$rowNumber',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          role.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          role.description,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          '${role.permissions.length}',
                          style: TextStyle(color: Colors.grey.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${role.userCount}',
                          style: TextStyle(color: Colors.grey.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          onSelected: (String action) {
                            _handleRoleAction(role, action, controller);
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 16),
                                  SizedBox(width: 8),
                                  Text('Lihat'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            if (!role.isSystem) ...[
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        size: 16, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Hapus',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Loading More Indicator
          Obx(() => controller.isLoadingMore.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  void _handleRoleAction(Role role, String action, RoleController controller) {
    switch (action) {
      case 'view':
        // TODO: Navigate to role detail screen
        Get.snackbar('Info', 'Lihat detail role: ${role.name}');
        break;
      case 'edit':
        // TODO: Navigate to edit role screen
        Get.snackbar('Info', 'Edit role: ${role.name}');
        break;
      case 'delete':
        _showDeleteConfirmation(role, controller);
        break;
    }
  }

  void _showDeleteConfirmation(Role role, RoleController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus role "${role.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Implement delete functionality
              Get.snackbar('Info', 'Fitur hapus role akan segera tersedia');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
