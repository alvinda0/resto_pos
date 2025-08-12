// screens/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/account/account_controller.dart';
import 'package:pos/models/account/account_model.dart';
import 'package:pos/widgets/pagination_widget.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Get.find() instead of Get.put() to avoid recreating
    final UserController controller =
        Get.put(UserController(), permanent: false);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.2),
              ),
            ),
            child: Row(
              children: [
                // Title
                const Text(
                  'Manajemen User',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),

                // Search field
                Container(
                  width: 300,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Cari user...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.grey.shade600, size: 20),
                      suffixIcon: Obx(
                        () => controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    size: 16, color: Colors.grey.shade600),
                                onPressed: controller.clearSearch,
                              )
                            : const SizedBox(),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Add user button
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to add user screen
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text('Tambah User',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                            width: 60,
                            child: Text('No',
                                style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(
                            flex: 2,
                            child: Text('Nama',
                                style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(
                            flex: 3,
                            child: Text('Email',
                                style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(
                            flex: 2,
                            child: Text('Role',
                                style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(
                            flex: 1,
                            child: Text('Type',
                                style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(
                            flex: 2,
                            child: Text('Tanggal Bergabung',
                                style: TextStyle(fontWeight: FontWeight.w600))),
                        SizedBox(
                            width: 60,
                            child: Text('Aksi',
                                style: TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),

                  // Table content with proper error handling
                  Expanded(
                    child: Obx(() {
                      // Show loading indicator
                      if (controller.isLoading.value) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Memuat data user...'),
                            ],
                          ),
                        );
                      }

                      // Show searching indicator
                      if (controller.isSearching.value) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Mencari user...'),
                            ],
                          ),
                        );
                      }

                      // Show error message
                      if (controller.errorMessage.isNotEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48, color: Colors.red.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'Terjadi kesalahan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  controller.errorMessage.value,
                                  style: TextStyle(color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: controller.refreshUsers,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text('Coba Lagi',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Show empty state
                      if (controller.users.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  controller.searchQuery.isEmpty
                                      ? 'Belum ada user'
                                      : 'Tidak ada user yang sesuai',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (controller.searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pencarian: "${controller.searchQuery.value}"',
                                    style:
                                        TextStyle(color: Colors.grey.shade500),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: controller.clearSearch,
                                    child: const Text('Hapus pencarian'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }

                      // Show user list
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: controller.users.length,
                        itemBuilder: (context, index) {
                          final user = controller.users[index];
                          final rowNumber = controller.startIndex + index;

                          return _buildUserRow(user, rowNumber, controller);
                        },
                      );
                    }),
                  ),

                  // Pagination - only show when there are users
                  Obx(() => controller.users.isNotEmpty
                      ? PaginationWidget(
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
                          onPreviousPage: controller.goToPreviousPage,
                          onNextPage: controller.goToNextPage,
                          onPageSelected: controller.goToPage,
                        )
                      : const SizedBox()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(User user, int rowNumber, UserController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          // Number
          SizedBox(
            width: 60,
            child: Text(
              rowNumber.toString(),
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),

          // Name with icon
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.name.isNotEmpty ? user.name : 'Nama tidak tersedia',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Email
          Expanded(
            flex: 3,
            child: Text(
              user.email.isNotEmpty ? user.email : 'Email tidak tersedia',
              style: TextStyle(color: Colors.blue.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Role
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.role.name.isNotEmpty
                      ? user.role.name
                      : 'Role tidak tersedia',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.role.description.isNotEmpty)
                  Text(
                    user.role.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Type badge
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: controller.getUserTypeColor(user),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                controller.getUserTypeText(user),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Created date
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(user.createdAt),
              style: TextStyle(color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Actions
          SizedBox(
            width: 60,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _showUserDetails(user);
                    break;
                  case 'edit':
                    _editUser(user);
                    break;
                  case 'delete':
                    _confirmDeleteUser(user, controller);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Lihat Detail'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  void _showUserDetails(User user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Detail User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${user.name}'),
            Text('Email: ${user.email}'),
            Text('Role: ${user.role.name}'),
            Text('Type: ${user.isStaff ? "Staff" : "User"}'),
            Text('Store ID: ${user.storeId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _editUser(User user) {
    // Navigate to edit user screen
    Get.snackbar('Info', 'Fitur edit user akan segera hadir');
  }

  void _confirmDeleteUser(User user, UserController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus user "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Implement delete functionality
              Get.snackbar('Info', 'Fitur hapus user akan segera hadir');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
