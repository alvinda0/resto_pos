import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/category/category_model.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get category from arguments
    final Category category = Get.arguments as Category;

    return Column(
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
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: 16),
              Text(
                'Menu - ${category.name}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Content (sama seperti ProductListScreen sebelumnya tapi tanpa Scaffold dan AppBar)
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(24),
            child: category.products == null || category.products!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada menu dalam kategori ini',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: category.products!.length,
                    itemBuilder: (context, index) {
                      final product = category.products![index];
                      // Product card implementation sama seperti sebelumnya
                      return Container(/* ... */);
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
