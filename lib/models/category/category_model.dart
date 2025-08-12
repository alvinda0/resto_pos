class Product {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final String imageUrl;
  final int basePrice;
  final int hpp;
  final bool isAvailable;
  final int position;

  Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.basePrice,
    required this.hpp,
    required this.isAvailable,
    required this.position,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      basePrice: json['base_price']?.toInt() ?? 0,
      hpp: json['hpp']?.toInt() ?? 0,
      isAvailable: json['is_available'] ?? false,
      position: json['position']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'base_price': basePrice,
      'hpp': hpp,
      'is_available': isAvailable,
      'position': position,
    };
  }
}

class Category {
  final String id;
  final String storeId;
  final String name;
  final bool isActive;
  final int position;
  final List<Product> products;

  Category({
    required this.id,
    required this.storeId,
    required this.name,
    required this.isActive,
    required this.position,
    required this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? false,
      position: json['position']?.toInt() ?? 0,
      products: (json['products'] as List<dynamic>?)
              ?.map((product) => Product.fromJson(product))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'is_active': isActive,
      'position': position,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

class CategoryMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  CategoryMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory CategoryMetadata.fromJson(Map<String, dynamic> json) {
    return CategoryMetadata(
      page: json['page']?.toInt() ?? 1,
      limit: json['limit']?.toInt() ?? 10,
      total: json['total']?.toInt() ?? 0,
      totalPages: json['total_pages']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
    };
  }
}

class CategoryResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<Category> data;
  final CategoryMetadata metadata;

  CategoryResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status']?.toInt() ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((category) => Category.fromJson(category))
              .toList() ??
          [],
      metadata: CategoryMetadata.fromJson(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'timestamp': timestamp,
      'data': data.map((category) => category.toJson()).toList(),
      'metadata': metadata.toJson(),
    };
  }
}
