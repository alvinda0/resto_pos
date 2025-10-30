import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shao_kao/bloc/category/category_bloc.dart';
import 'package:shao_kao/bloc/category/category_event.dart';
import 'package:shao_kao/bloc/category/category_state.dart';
import 'package:shao_kao/models/category/category_model.dart';

class CategoryListWidget extends StatefulWidget {
  const CategoryListWidget({Key? key}) : super(key: key);

  @override
  State<CategoryListWidget> createState() => _CategoryListWidgetState();
}

class _CategoryListWidgetState extends State<CategoryListWidget> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load categories when widget initializes
    context.read<CategoryBloc>().add(const CategoryLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari kategori...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<CategoryBloc>().add(const CategorySearchCleared());
                },
              ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              context.read<CategoryBloc>().add(CategorySearchChanged(value));
            },
          ),
        ),

        // Category List
        Expanded(
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is CategoryError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CategoryBloc>().add(const CategoryLoadRequested());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is CategoryLoaded) {
                if (state.categories.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada kategori ditemukan',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Category List
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.categories.length,
                        itemBuilder: (context, index) {
                          final category = state.categories[index];
                          return _CategoryListItem(
                            category: category,
                            onEdit: () => _showEditDialog(category),
                            onDelete: () => _showDeleteDialog(category),
                          );
                        },
                      ),
                    ),

                    // Pagination
                    if (state.totalPages > 1) _buildPagination(state),
                  ],
                );
              }

              return const Center(
                child: Text('Memuat kategori...'),
              );
            },
          ),
        ),

        // Add Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Kategori'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPagination(CategoryLoaded state) {
    final bloc = context.read<CategoryBloc>();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${bloc.startIndex}-${bloc.endIndex} of ${state.totalItems}',
            style: const TextStyle(fontSize: 12),
          ),
          Row(
            children: [
              IconButton(
                onPressed: bloc.hasPreviousPage
                    ? () => bloc.add(CategoryPageChanged(state.currentPage - 1))
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('${state.currentPage} / ${state.totalPages}'),
              IconButton(
                onPressed: bloc.hasNextPage
                    ? () => bloc.add(CategoryPageChanged(state.currentPage + 1))
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    context.read<CategoryBloc>().add(const CategoryFormPreparedForCreate());
    _showCategoryDialog(isEdit: false);
  }

  void _showEditDialog(Category category) {
    context.read<CategoryBloc>().add(CategoryFormPreparedForEdit(
      id: category.id,
      name: category.name,
      isActive: category.isActive,
      position: category.position,
    ));
    _showCategoryDialog(isEdit: true, category: category);
  }

  void _showCategoryDialog({required bool isEdit, Category? category}) {
    final nameController = TextEditingController();
    final positionController = TextEditingController();

    if (isEdit && category != null) {
      nameController.text = category.name;
      positionController.text = category.position?.toString() ?? '';
    }

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CategoryBloc>(),
        child: AlertDialog(
          title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(
                  labelText: 'Posisi (opsional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  bool isActive = true;
                  if (state is CategoryFormState) {
                    isActive = state.isActiveValue;
                  }
                  return CheckboxListTile(
                    title: const Text('Aktif'),
                    value: isActive,
                    onChanged: (value) {
                      context.read<CategoryBloc>().add(const CategoryFormActiveToggled());
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            BlocConsumer<CategoryBloc, CategoryState>(
              listener: (context, state) {
                if (state is CategoryOperationSuccess) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is CategoryError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is CategoryOperationLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nama kategori tidak boleh kosong'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final position = int.tryParse(positionController.text.trim());
                          final bloc = context.read<CategoryBloc>();

                          if (isEdit && category != null) {
                            bloc.add(CategoryUpdateRequested(
                              id: category.id,
                              name: name,
                              isActive: bloc.isActiveValue,
                              position: position,
                            ));
                          } else {
                            bloc.add(CategoryCreateRequested(
                              name: name,
                              isActive: bloc.isActiveValue,
                              position: position,
                            ));
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Update' : 'Simpan'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CategoryBloc>().add(CategoryDeleteRequested(id: category.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _CategoryListItem extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryListItem({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.isActive ? Colors.green : Colors.red,
          child: Text(
            category.name.isNotEmpty ? category.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${category.isActive ? 'Aktif' : 'Tidak Aktif'}'),
            if (category.position != null) Text('Posisi: ${category.position}'),
            Text('Produk: ${category.products.length}'),
          ],
        ),
        trailing: PopupMenuButton(
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
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
        ),
      ),
    );
  }
}