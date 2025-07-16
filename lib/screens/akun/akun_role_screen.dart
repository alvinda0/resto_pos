import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/role/role_controller.dart';
import 'package:pos/models/role/role_model.dart';
import 'package:pos/services/role/role_service.dart';

class AkunRoleScreen extends StatefulWidget {
  const AkunRoleScreen({super.key});

  @override
  State<AkunRoleScreen> createState() => _AkunRoleScreenState();
}

class _AkunRoleScreenState extends State<AkunRoleScreen> {
  final RoleController _roleController = Get.put(RoleController());

  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    _roleController.loadRoles();
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
            // Header
            const Text(
              'Daftar Role',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Search and Add Button Row
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
                      controller: _roleController.searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari Role',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Add Role Button
                ElevatedButton.icon(
                  onPressed: () => _showAddRoleDialog(),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Tambah Role',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 50, child: Text('No.')),
                          Expanded(flex: 2, child: Text('Nama Role')),
                          Expanded(flex: 3, child: Text('Deskripsi')),
                          Expanded(flex: 1, child: Text('Izin')),
                          Expanded(flex: 1, child: Text('Jumlah Akun')),
                          SizedBox(width: 100, child: Text('Aksi')),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Table Body
                    Expanded(
                      child: Obx(() {
                        if (_roleController.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (_roleController.paginatedRoles.isEmpty) {
                          return const Center(
                            child: Text('Tidak ada data role'),
                          );
                        }

                        return ListView.builder(
                          itemCount: _roleController.paginatedRoles.length,
                          itemBuilder: (context, index) {
                            final role = _roleController.paginatedRoles[index];
                            final globalIndex =
                                (_roleController.currentPage - 1) *
                                        _roleController.itemsPerPage +
                                    index +
                                    1;

                            return Container(
                              padding: const EdgeInsets.all(16),
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
                                  SizedBox(
                                    width: 50,
                                    child: Text(globalIndex.toString()),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      role.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(role.description),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                        role.permissions.length.toString()),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(role.userCount.toString()),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Row(
                                      children: [
                                        // View Users Button
                                        TextButton(
                                          onPressed: () =>
                                              _showUsersDialog(role),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              side: BorderSide(
                                                color: Colors.red[400]!,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            'Lihat Akun',
                                            style: TextStyle(
                                              color: Colors.red[400],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // More Actions Button
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _showEditRoleDialog(role);
                                            } else if (value == 'delete') {
                                              _showDeleteConfirmation(role);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, size: 16),
                                                  SizedBox(width: 8),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete, size: 16),
                                                  SizedBox(width: 8),
                                                  Text('Hapus'),
                                                ],
                                              ),
                                            ),
                                          ],
                                          child: const Icon(
                                            Icons.more_vert,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ),

                    // Pagination
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRoleDialog() {
    _roleController.nameController.clear();
    _roleController.descriptionController.clear();
    List<Permission> selectedPermissions = [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Role'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _roleController.nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Role',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _roleController.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Permissions would be added here
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final roleData = {
                'name': _roleController.nameController.text,
                'description': _roleController.descriptionController.text,
                'permissions': selectedPermissions.map((p) => p.id).toList(),
              };
              _roleController.createRole(roleData);
              Navigator.of(context).pop();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditRoleDialog(Role role) {
    _roleController.nameController.text = role.name;
    _roleController.descriptionController.text = role.description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Role'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _roleController.nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Role',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _roleController.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final roleData = {
                'name': _roleController.nameController.text,
                'description': _roleController.descriptionController.text,
              };
              _roleController.updateRole(role.id, roleData);
              Navigator.of(context).pop();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Role role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus role "${role.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _roleController.deleteRole(role.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showUsersDialog(Role role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Akun dengan Role: ${role.name}'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: RoleService.instance.getUsersByRole(role.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final users = snapshot.data ?? [];

              if (users.isEmpty) {
                return const Center(
                    child: Text('Tidak ada akun dengan role ini'));
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(user['name'] ?? 'Unknown'),
                    subtitle: Text(user['email'] ?? ''),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
