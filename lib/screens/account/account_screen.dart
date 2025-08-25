// screens/user_management_screen.dart - MOBILE RESPONSIVE VERSION
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1024;
          final isTablet =
              constraints.maxWidth > 768 && constraints.maxWidth <= 1024;
          final isMobile = constraints.maxWidth <= 768;

          return Column(
            children: [
              // Header section - responsive
              _buildHeader(userController, roleController, isDesktop, isTablet,
                  isMobile),

              // Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(isMobile ? 12 : 24),
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
                      // Mobile filter section
                      if (isMobile) _buildMobileFilterSection(userController),

                      // Content based on screen size
                      Expanded(
                        child: isMobile || isTablet
                            ? _buildMobileContent(
                                userController, roleController, isMobile)
                            : _buildDesktopContent(
                                userController, roleController),
                      ),

                      // Pagination - responsive
                      Obx(() => userController.users.isNotEmpty
                          ? _buildResponsivePagination(userController, isMobile)
                          : const SizedBox()),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // Floating Action Button for mobile
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 768;
          return isMobile
              ? FloatingActionButton(
                  onPressed: () =>
                      _showUserForm(userController, roleController, null),
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeader(
      UserController userController,
      RoleController roleController,
      bool isDesktop,
      bool isTablet,
      bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: isMobile
          ? _buildMobileHeader(userController, roleController)
          : _buildDesktopHeader(userController, roleController),
    );
  }

  Widget _buildMobileHeader(
      UserController userController, RoleController roleController) {
    return Column(
      children: [
        Container(
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
              prefixIcon:
                  Icon(Icons.search, color: Colors.grey.shade600, size: 20),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(
      UserController userController, RoleController roleController) {
    return Row(
      children: [
        // Search field - now takes full available space on the left
        Expanded(
          child: Container(
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
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey.shade600, size: 20),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Add button - fixed width on the right
        ElevatedButton.icon(
          onPressed: () => _showUserForm(userController, roleController, null),
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label:
              const Text('Tambah User', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFilterSection(UserController userController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => Text(
                  userController.users.isEmpty
                      ? 'Tidak ada user'
                      : '${userController.users.length} user ditemukan',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                )),
          ),
          // Filter/Sort buttons can be added here
          IconButton(
            onPressed: () {
              // Add filter functionality
            },
            icon: Icon(Icons.filter_list, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContent(UserController userController,
      RoleController roleController, bool isMobile) {
    return Obx(() {
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
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: userController.clearSearch,
                    child: const Text('Hapus pencarian'),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      // Show user list as cards for mobile
      return ListView.builder(
        padding: EdgeInsets.all(isMobile ? 8 : 16),
        itemCount: userController.users.length,
        itemBuilder: (context, index) {
          final user = userController.users[index];
          final rowNumber = userController.startIndex + index;
          return _buildUserCard(
              user, rowNumber, userController, roleController, isMobile);
        },
      );
    });
  }

  Widget _buildDesktopContent(
      UserController userController, RoleController roleController) {
    return Column(
      children: [
        // Table header columns
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
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

        // Table content
        Expanded(
          child: Obx(() {
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
                            backgroundColor: Colors.blue),
                        child: const Text('Coba Lagi',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            }

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
                          style: TextStyle(color: Colors.grey.shade500),
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
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Tambah User Pertama',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

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
      ],
    );
  }

  Widget _buildUserCard(User user, int rowNumber, UserController userController,
      RoleController roleController, bool isMobile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with avatar and actions
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.person,
                        size: 20, color: Colors.blue.shade600),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isNotEmpty
                              ? user.name
                              : 'Nama tidak tersedia',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.email.isNotEmpty
                              ? user.email
                              : 'Email tidak tersedia',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Actions menu
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: Colors.grey.shade600, size: 20),
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
                            Icon(Icons.edit_outlined,
                                color: Colors.blue, size: 18),
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
                            Icon(Icons.delete_outline,
                                color: Colors.red, size: 18),
                            SizedBox(width: 12),
                            Text('Hapus User',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Role and date info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Role',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.role.name.isNotEmpty
                              ? user.role.name
                              : 'Role tidak tersedia',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bergabung',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(user.createdAt),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
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
      ),
    );
  }

  Widget _buildUserRow(User user, int rowNumber, UserController userController,
      RoleController roleController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              rowNumber.toString(),
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
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
                  child:
                      Icon(Icons.person, size: 16, color: Colors.blue.shade600),
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
          Expanded(
            flex: 3,
            child: Text(
              user.email.isNotEmpty ? user.email : 'Email tidak tersedia',
              style: TextStyle(color: Colors.blue.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
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
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(user.createdAt),
              style: TextStyle(color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 80,
            child: PopupMenuButton<String>(
              icon:
                  Icon(Icons.more_vert, color: Colors.grey.shade600, size: 20),
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

  Widget _buildResponsivePagination(
      UserController userController, bool isMobile) {
    return Obx(() => PaginationWidget(
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
        ));
  }

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = MediaQuery.of(context).size.width <= 768;

            return Container(
              width: isMobile ? double.infinity : 400,
              constraints: isMobile
                  ? BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    )
                  : null,
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: SingleChildScrollView(
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
                          child:
                              Icon(Icons.person, color: Colors.blue.shade600),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: isMobile ? 12 : 14,
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
                    _buildDetailRow(
                        'Tanggal Bergabung', _formatDate(user.createdAt)),

                    const SizedBox(height: 24),

                    // Actions - responsive layout for mobile
                    if (isMobile) ...[
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.back();
                                _showUserForm(Get.find<UserController>(),
                                    Get.find<RoleController>(), user);
                              },
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text('Edit User',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                              child: const Text('Tutup'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                              child: const Text('Tutup'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();
                                _showUserForm(Get.find<UserController>(),
                                    Get.find<RoleController>(), user);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Edit',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 300;

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }

          return Row(
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
          );
        },
      ),
    );
  }
}
