// screens/user_management_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/account/account_controller.dart';
import 'package:pos/controller/role/role_controller.dart';
import 'package:pos/models/account/account_model.dart';
import 'package:pos/screens/account/account_form_dialog.dart';
import 'package:pos/widgets/pagination_widget.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final UserController userController =
        Get.put(UserController(), permanent: false);
    final RoleController roleController =
        Get.put(RoleController(), permanent: false);

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
                    controller: userController.searchController,
                    onChanged: userController.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Cari user...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.grey.shade600, size: 20),
                      suffixIcon: Obx(
                        () => userController.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    size: 16, color: Colors.grey.shade600),
                                onPressed: userController.clearSearch,
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
                    _showUserForm(userController, roleController, null);
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
                  // Table header with actions
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
                  ),

                  // Table header columns
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
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
                            width: 80,
                            child: Text('Aksi',
                                style: TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),

                  // Table content with proper error handling
                  Expanded(
                    child: Obx(() {
                      // Show loading indicator
                      if (userController.isLoading.value) {
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
                      if (userController.isSearching.value) {
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
                      if (userController.errorMessage.isNotEmpty) {
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
                                  userController.errorMessage.value,
                                  style: TextStyle(color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: userController.refreshUsers,
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
                      if (userController.users.isEmpty) {
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
                                  userController.searchQuery.isEmpty
                                      ? 'Belum ada user'
                                      : 'Tidak ada user yang sesuai',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (userController.searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pencarian: "${userController.searchQuery.value}"',
                                    style:
                                        TextStyle(color: Colors.grey.shade500),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: userController.clearSearch,
                                    child: const Text('Hapus pencarian'),
                                  ),
                                ],
                                if (userController.searchQuery.isEmpty) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _showUserForm(
                                        userController, roleController, null),
                                    icon: const Icon(Icons.add,
                                        color: Colors.white),
                                    label: const Text('Tambah User Pertama',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
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
                        itemCount: userController.users.length,
                        itemBuilder: (context, index) {
                          final user = userController.users[index];
                          final rowNumber = userController.startIndex + index;

                          return _buildUserRow(
                              user, rowNumber, userController, roleController);
                        },
                      );
                    }),
                  ),

                  // Pagination - only show when there are users
                  Obx(() => userController.users.isNotEmpty
                      ? PaginationWidget(
                          currentPage: userController.currentPage.value,
                          totalItems: userController.totalItems.value,
                          itemsPerPage: userController.itemsPerPage.value,
                          availablePageSizes: userController.availablePageSizes,
                          startIndex: userController.startIndex,
                          endIndex: userController.endIndex,
                          hasPreviousPage: userController.hasPreviousPage,
                          hasNextPage: userController.hasNextPage,
                          pageNumbers: userController.pageNumbers,
                          onPageSizeChanged: userController.changePageSize,
                          onPreviousPage: userController.goToPreviousPage,
                          onNextPage: userController.goToNextPage,
                          onPageSelected: userController.goToPage,
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

  Widget _buildUserRow(User user, int rowNumber, UserController userController,
      RoleController roleController) {
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
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.blue.shade600,
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
                color: userController.getUserTypeColor(user),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                userController.getUserTypeText(user),
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
            width: 80,
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey.shade600,
                size: 20,
              ),
              tooltip: 'Menu',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 8,
              offset: const Offset(0, 8),
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _showUserDetails(user);
                    break;
                  case 'edit':
                    _showUserForm(userController, roleController, user);
                    break;
                  case 'delete':
                    _handleDeleteUser(user, userController);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility_outlined,
                          color: Colors.grey, size: 18),
                      SizedBox(width: 12),
                      Text('Lihat Detail'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                      SizedBox(width: 12),
                      Text('Edit User'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      SizedBox(width: 12),
                      Text('Hapus User', style: TextStyle(color: Colors.red)),
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

  // FIXED: This method now properly loads roles and passes them to the dialog
  void _showUserForm(UserController userController,
      RoleController roleController, User? user) async {
    try {
      // Show loading dialog while fetching roles
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data role...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Load roles if not already loaded or refresh them
      await roleController.loadRoles();

      // Close loading dialog
      Get.back();

      // Check if roles were loaded successfully
      if (roleController.roles.isEmpty &&
          roleController.error.value.isNotEmpty) {
        Get.snackbar(
          'Error',
          'Gagal memuat data role: ${roleController.error.value}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Show the user form dialog with available roles
      UserFormDialog.show(
        user: user,
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat form: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error in _showUserForm: $e');
    }
  }

  void _handleDeleteUser(User user, UserController controller) async {
    final confirmed = await controller.showDeleteConfirmation(user);
    if (confirmed) {
      await controller.deleteUser(user.id);
    }
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
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.person, color: Colors.blue.shade600),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Details
              _buildDetailRow('User ID', user.id),
              _buildDetailRow('Store ID', user.storeId),
              _buildDetailRow('Role', user.role.name),
              if (user.role.description.isNotEmpty)
                _buildDetailRow('Deskripsi Role', user.role.description),
              _buildDetailRow('Status', user.isStaff ? 'Staff' : 'User'),
              _buildDetailRow('Tanggal Bergabung', _formatDate(user.createdAt)),

              const SizedBox(height: 24),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Tutup',
                      style: TextStyle(color: Colors.white)),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
