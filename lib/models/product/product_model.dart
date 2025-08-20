// models/product/product_model.dart
class Product {
  final String id;
  final String storeId;
  final String categoryId;
  final String categoryName;
  final String? recipeId;
  final String sku;
  final String name;
  final String description;
  final String? imageUrl;
  final int basePrice;
  final double hpp;
  final bool isAvailable;
  final int position;

  Product({
    required this.id,
    required this.storeId,
    required this.categoryId,
    required this.categoryName,
    this.recipeId,
    required this.sku,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.basePrice,
    required this.hpp,
    required this.isAvailable,
    required this.position,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      recipeId: json['recipe_id'],
      sku: json['sku'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      basePrice: json['base_price'] ?? 0,
      hpp: (json['hpp'] ?? 0).toDouble(),
      isAvailable: json['is_available'] ?? false,
      position: json['position'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'category_id': categoryId,
      'category_name': categoryName,
      'recipe_id': recipeId,
      'sku': sku,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'base_price': basePrice,
      'hpp': hpp,
      'is_available': isAvailable,
      'position': position,
    };
  }

  Product copyWith({
    String? id,
    String? storeId,
    String? categoryId,
    String? categoryName,
    String? recipeId,
    String? sku,
    String? name,
    String? description,
    String? imageUrl,
    int? basePrice,
    double? hpp,
    bool? isAvailable,
    int? position,
  }) {
    return Product(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      recipeId: recipeId ?? this.recipeId,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      basePrice: basePrice ?? this.basePrice,
      hpp: hpp ?? this.hpp,
      isAvailable: isAvailable ?? this.isAvailable,
      position: position ?? this.position,
    );
  }
}

class ProductResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<Product> data;
  final ProductMetadata metadata;

  ProductResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: ProductMetadata.fromJson(json['metadata'] ?? {}),
    );
  }
}

class ProductCreateResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final Product data;

  ProductCreateResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory ProductCreateResponse.fromJson(Map<String, dynamic> json) {
    return ProductCreateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: Product.fromJson(json['data']),
    );
  }
}

class ProductUpdateResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final Product data;

  ProductUpdateResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory ProductUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProductUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: Product.fromJson(json['data']),
    );
  }
}

class ProductMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  ProductMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory ProductMetadata.fromJson(Map<String, dynamic> json) {
    return ProductMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

class ProductCategory {
  final String id;
  final String name;

  ProductCategory({
    required this.id,
    required this.name,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
