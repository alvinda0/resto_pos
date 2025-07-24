import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/user/user_controller.dart';
import 'package:pos/models/role/role_model.dart';
import 'package:pos/models/user/user_model.dart';
import 'package:intl/intl.dart';

class AkunRoleUsersScreen extends StatefulWidget {
  const AkunRoleUsersScreen({super.key});

  @override
  State<AkunRoleUsersScreen> createState() => _AkunRoleUsersScreenState();
}

class _AkunRoleUsersScreenState extends State<AkunRoleUsersScreen> {
  late Role role;
  late UserController userController;
  final TextEditingController _searchController = TextEditingController();
  List<User> localFilteredUsers = [];

  @override
  void initState() {
    super.initState();
    // Ambil role dari arguments
    role = Get.arguments as Role;

    // Initialize UserController
    userController = Get.put(UserController());

    // Load users by role
    _loadUsersByRole();

    // Setup search listener
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsersByRole() async {
    await userController.loadUsersByRole(role.id);
    _updateLocalFilteredUsers();
  }

  void _updateLocalFilteredUsers() {
    setState(() {
      localFilteredUsers = List.from(userController.users);
    });
  }

  void _onSearchChanged() {
    // Filter users based on search query
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        localFilteredUsers = List.from(userController.users);
      } else {
        localFilteredUsers = userController.users.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _showAddUserDialog() {
    userController.clearForm();
    userController.setSelectedRole(
        role.id); // Set role_id dari role yang sedang ditampilkan
    _showUserDialog(isEdit: false);
  }

  void _showEditUserDialog(User user) {
    userController.setEditMode(user);
    userController.setSelectedRole(role.id); // Pastikan role_id tetap sama
    _showUserDialog(isEdit: true);
  }

  void _showUserDialog({required bool isEdit}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              // Add this line

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Akun' : 'Tambah Akun Baru',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Form
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      const Text(
                        'Nama',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: userController.nameController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama lengkap',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: userController.emailController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      Text(
                        isEdit
                            ? 'Password Baru (Kosongkan jika tidak ingin mengubah)'
                            : 'Password',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: userController.passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: isEdit
                              ? 'Masukkan password baru'
                              : 'Masukkan password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      const Text(
                        'Konfirmasi Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: userController.confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Konfirmasi password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Role Info (Read-only)
                      const Text(
                        'Role',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          role.name,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Staff Status
                      Obx(() => Row(
                            children: [
                              Checkbox(
                                value: userController.isStaff,
                                onChanged: (value) =>
                                    userController.toggleIsStaff(),
                                activeColor: Colors.red[500],
                              ),
                              const Text('Is Staff'),
                            ],
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
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 12),
                      Obx(() => ElevatedButton(
                            onPressed: (isEdit
                                    ? userController.isUpdating
                                    : userController.isCreating)
                                ? null
                                : () => _handleSaveUser(isEdit),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[500],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: (isEdit
                                    ? userController.isUpdating
                                    : userController.isCreating)
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(isEdit ? 'Update' : 'Simpan'),
                          )),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Future<void> _handleSaveUser(bool isEdit) async {
    if (isEdit && userController.selectedUser != null) {
      await userController.updateUser(userController.selectedUser!.id);
    } else {
      await userController.createUser();
    }

    // Reload users after save
    await _loadUsersByRole();
    Get.back(); // Close dialog
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus akun "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          Obx(() => ElevatedButton(
                onPressed: userController.isDeleting
                    ? null
                    : () => _handleDeleteUser(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: userController.isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Hapus'),
              )),
        ],
      ),
    );
  }

  Future<void> _handleDeleteUser(User user) async {
    await userController.deleteUser(user.id);
    await _loadUsersByRole();
    Get.back(); // Close dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan breadcrumb
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: Text('Daftar Pengguna Role: ${role.name}'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search dan Add Button
            Row(
              children: [
                // Search Field
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari Akun',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Add Button
                ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Akun'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[500],
                    foregroundColor: Colors.white,
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
            const SizedBox(height: 24),

            // Table
            Expanded(
              child: Container(
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
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: const Row(
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
                              'Nama',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Staff',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Tanggal Dibuat',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              'Aksi',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.grey),

                    // Content
                    Expanded(
                      child: Obx(() => _buildContent()),
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

  Widget _buildContent() {
    if (userController.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data akun...'),
          ],
        ),
      );
    }

    if (localFilteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              color: Colors.grey[400],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Tidak ada akun yang ditemukan'
                  : 'Tidak ada akun dengan role ini',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: localFilteredUsers.length,
      itemBuilder: (context, index) {
        final user = localFilteredUsers[index];

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // No
              SizedBox(
                width: 60,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Name
              Expanded(
                flex: 2,
                child: Text(
                  user.name.isNotEmpty ? user.name : 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Email
              Expanded(
                flex: 3,
                child: Text(
                  user.email.isNotEmpty ? user.email : 'No email',
                  style: TextStyle(
                    color: user.email.isNotEmpty
                        ? Colors.black87
                        : Colors.grey[500],
                  ),
                ),
              ),

              // Staff Status
              Expanded(
                flex: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isStaff ? Colors.green[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isStaff ? 'Staff' : 'Non-Staff',
                    style: TextStyle(
                      color:
                          user.isStaff ? Colors.green[700] : Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Tanggal Dibuat
              Expanded(
                flex: 2,
                child: Text(
                  user.createdAt != null
                      ? _formatDateTime(user.createdAt!)
                      : '-',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),

              // Aksi
              SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _showEditUserDialog(user),
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.blue[600],
                      ),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(user),
                      icon: Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red[600],
                      ),
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
