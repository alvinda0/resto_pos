import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/category/category_controller.dart';
import 'package:pos/models/category/category_model.dart';
import 'package:pos/models/routes.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final CategoryController categoryController = Get.find<CategoryController>();
  final TextEditingController searchController = TextEditingController();
  String selectedFilter = 'Semua';

  List<String> statusFilters = ['Semua', 'Aktif', 'Tidak Aktif'];

  @override
  void initState() {
    super.initState();
    // Load categories when screen is initialized
    categoryController.loadCategories();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Category> getFilteredCategories() {
    List<Category> filteredList = categoryController.categories;

    // Filter by search
    if (searchController.text.isNotEmpty) {
      filteredList = filteredList
          .where((category) => category.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    }

    // Filter by status
    if (selectedFilter == 'Aktif') {
      filteredList =
          filteredList.where((category) => category.isActive).toList();
    } else if (selectedFilter == 'Tidak Aktif') {
      filteredList =
          filteredList.where((category) => !category.isActive).toList();
    }

    // Sort by position
    filteredList.sort((a, b) => a.position.compareTo(b.position));

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manajemen Kategori',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Search Field
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari Kategori',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon:
                                Icon(Icons.search, color: Colors.grey.shade500),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Filter Dropdown
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedFilter,
                          decoration: InputDecoration(
                            hintText: 'Filter Status',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(Icons.filter_alt,
                                color: Colors.grey.shade500),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          items: statusFilters.map((String filter) {
                            return DropdownMenuItem<String>(
                              value: filter,
                              child: Text(filter),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedFilter = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Add Category Button
                    ElevatedButton.icon(
                      onPressed: () {
                        _showAddCategoryDialog();
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Tambah Kategori',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(() {
                if (categoryController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredCategories = getFilteredCategories();

                return Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                              width: 60,
                              child: Text('No.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          const Expanded(
                              flex: 2,
                              child: Text('NAMA KATEGORI',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          const SizedBox(
                              width: 80,
                              child: Text('POSISI',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          const SizedBox(
                              width: 100,
                              child: Text('STATUS',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          const SizedBox(
                              width: 120,
                              child: Text('JUMLAH MENU',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          const SizedBox(
                              width: 120,
                              child: Text('AKSI',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          const SizedBox(width: 50), // For menu button
                        ],
                      ),
                    ),

                    // Table Body
                    Expanded(
                      child: filteredCategories.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada kategori ditemukan',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCategories.length,
                              itemBuilder: (context, index) {
                                final category = filteredCategories[index];
                                final productCount =
                                    category.products?.length ?? 0;

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade200),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // No.
                                      SizedBox(
                                        width: 60,
                                        child: Text('${index + 1}'),
                                      ),

                                      // Nama Kategori
                                      Expanded(
                                        flex: 2,
                                        child: Text(category.name),
                                      ),

                                      // Posisi
                                      SizedBox(
                                        width: 80,
                                        child: Text('${category.position}'),
                                      ),

                                      // Status
                                      SizedBox(
                                        width: 100,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: category.isActive
                                                ? Colors.green
                                                : Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            category.isActive
                                                ? 'AKTIF'
                                                : 'TIDAK AKTIF',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),

                                      // Jumlah Menu
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          '$productCount',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      // Aksi - Navigate using route name to maintain sidebar
                                      SizedBox(
                                        width: 120,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Navigate using route name with parameters
                                            AppRoutes.toProductList(category);

                                            // Alternative: jika menggunakan parameter dalam route
                                            // Get.toNamed('/product-list/${category.id}');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            'Lihat Menu',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Menu Button
                                      SizedBox(
                                        width: 50,
                                        child: PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert,
                                              color: Colors.grey),
                                          onSelected: (String value) {
                                            switch (value) {
                                              case 'edit':
                                                _showEditCategoryDialog(
                                                    category);
                                                break;
                                              case 'toggle':
                                                categoryController
                                                    .toggleCategoryStatus(
                                                  category.id,
                                                  !category.isActive,
                                                );
                                                break;
                                              case 'delete':
                                                categoryController
                                                    .showDeleteConfirmation(
                                                        category);
                                                break;
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              [
                                            const PopupMenuItem<String>(
                                              value: 'edit',
                                              child: ListTile(
                                                leading:
                                                    Icon(Icons.edit, size: 18),
                                                title: Text('Edit'),
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'toggle',
                                              child: ListTile(
                                                leading: Icon(
                                                  category.isActive
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  size: 18,
                                                ),
                                                title: Text(category.isActive
                                                    ? 'Nonaktifkan'
                                                    : 'Aktifkan'),
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'delete',
                                              child: ListTile(
                                                leading: Icon(Icons.delete,
                                                    size: 18,
                                                    color: Colors.red),
                                                title: Text('Hapus',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    categoryController.nameController.clear();
    categoryController.isActive.value = true;
    categoryController.position.value =
        categoryController.categories.length + 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController.nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Posisi',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        categoryController.position.value =
                            int.tryParse(value) ?? 1;
                      },
                      controller: TextEditingController(
                          text: '${categoryController.position.value}'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => SwitchListTile(
                          title: const Text('Status Aktif'),
                          value: categoryController.isActive.value,
                          onChanged: (value) {
                            categoryController.isActive.value = value;
                          },
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          Obx(() => ElevatedButton(
                onPressed: categoryController.isCreating.value
                    ? null
                    : () {
                        categoryController.createCategory();
                        Navigator.pop(context);
                      },
                child: categoryController.isCreating.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              )),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    categoryController.prepareForEdit(category);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Kategori'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController.nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Posisi',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        categoryController.position.value =
                            int.tryParse(value) ?? 1;
                      },
                      controller: TextEditingController(
                          text: '${categoryController.position.value}'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => SwitchListTile(
                          title: const Text('Status Aktif'),
                          value: categoryController.isActive.value,
                          onChanged: (value) {
                            categoryController.isActive.value = value;
                          },
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          Obx(() => ElevatedButton(
                onPressed: categoryController.isUpdating.value
                    ? null
                    : () {
                        categoryController.updateCategory();
                        Navigator.pop(context);
                      },
                child: categoryController.isUpdating.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update'),
              )),
        ],
      ),
    );
  }
}
