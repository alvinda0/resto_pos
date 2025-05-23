import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Map<String, dynamic>> products = [
    {
      'name': 'Nasi Goreng',
      'price': 15000,
      'stock': 50,
      'category': 'Makanan',
      'image':
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=300&h=200&fit=crop'
    },
    {
      'name': 'Mie Ayam',
      'price': 12000,
      'stock': 30,
      'category': 'Makanan',
      'image':
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300&h=200&fit=crop'
    },
    {
      'name': 'Es Teh',
      'price': 5000,
      'stock': 100,
      'category': 'Minuman',
      'image':
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=300&h=200&fit=crop'
    },
    {
      'name': 'Ayam Bakar',
      'price': 20000,
      'stock': 25,
      'category': 'Makanan',
      'image':
          'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=300&h=200&fit=crop'
    },
  ];

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final categoryController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar',
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty &&
                  stockController.text.isNotEmpty &&
                  categoryController.text.isNotEmpty) {
                setState(() {
                  products.add({
                    'name': nameController.text,
                    'price': int.parse(priceController.text),
                    'stock': int.parse(stockController.text),
                    'category': categoryController.text,
                    'image': imageController.text.isNotEmpty
                        ? imageController.text
                        : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300&h=200&fit=crop',
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(int index) {
    final product = products[index];
    final nameController = TextEditingController(text: product['name']);
    final priceController =
        TextEditingController(text: product['price'].toString());
    final stockController =
        TextEditingController(text: product['stock'].toString());
    final categoryController = TextEditingController(text: product['category']);
    final imageController = TextEditingController(text: product['image']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Produk'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar',
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty &&
                  stockController.text.isNotEmpty &&
                  categoryController.text.isNotEmpty) {
                setState(() {
                  products[index] = {
                    'name': nameController.text,
                    'price': int.parse(priceController.text),
                    'stock': int.parse(stockController.text),
                    'category': categoryController.text,
                    'image': imageController.text.isNotEmpty
                        ? imageController.text
                        : products[index]['image'],
                  };
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
            'Apakah Anda yakin ingin menghapus "${products[index]['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                products.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Function to build product rows (4 products per row)
  List<Widget> _buildProductRows() {
    List<Widget> rows = [];

    for (int i = 0; i < products.length; i += 4) {
      List<Map<String, dynamic>> rowProducts = [];
      List<int> rowIndices = [];

      // Get up to 4 products for this row
      for (int j = 0; j < 4 && (i + j) < products.length; j++) {
        rowProducts.add(products[i + j]);
        rowIndices.add(i + j);
      }

      rows.add(_buildProductRow(rowProducts, rowIndices));
      if (i + 4 < products.length) {
        rows.add(const SizedBox(height: 12));
      }
    }

    return rows;
  }

  Widget _buildProductRow(
      List<Map<String, dynamic>> rowProducts, List<int> indices) {
    return Row(
      children: rowProducts.asMap().entries.map((entry) {
        int localIndex = entry.key;
        Map<String, dynamic> product = entry.value;
        int globalIndex = indices[localIndex];

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: localIndex < rowProducts.length - 1 ? 8 : 0,
            ),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        product['image'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          product['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product['category'],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Price
                        Text(
                          'Rp ${product['price']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Stock and Actions
                        Row(
                          children: [
                            // Stock indicator
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: product['stock'] < 10
                                      ? Colors.red.shade100
                                      : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Stok: ${product['stock']}',
                                  style: TextStyle(
                                    color: product['stock'] < 10
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => _showEditProductDialog(globalIndex),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _deleteProduct(globalIndex),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.delete,
                                  size: 16,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _showAddProductDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Daftar Produk',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'Total: ${products.length} produk',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Products List in Rows
            Expanded(
              child: products.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada produk',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: _buildProductRows(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
