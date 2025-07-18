// models/category.dart
class Category {
  final String id;
  final String storeId;
  final String name;
  final bool isActive;
  final int position;
  final List<Product>? products;

  Category({
    required this.id,
    required this.storeId,
    required this.name,
    required this.isActive,
    required this.position,
    this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? false,
      position: json['position'] ?? 0,
      products: json['products'] != null
          ? (json['products'] as List)
              .map((product) => Product.fromJson(product))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'is_active': isActive,
      'position': position,
      'products': products?.map((product) => product.toJson()).toList(),
    };
  }

  Category copyWith({
    String? id,
    String? storeId,
    String? name,
    bool? isActive,
    int? position,
    List<Product>? products,
  }) {
    return Category(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      position: position ?? this.position,
      products: products ?? this.products,
    );
  }
}

// models/product.dart
class Product {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final String? imageUrl;
  final int basePrice;
  final bool isAvailable;
  final int position;

  Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.basePrice,
    required this.isAvailable,
    required this.position,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      basePrice: json['base_price'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      position: json['position'] ?? 0,
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
      'is_available': isAvailable,
      'position': position,
    };
  }
}

// models/category_request.dart
class CategoryRequest {
  final String name;
  final bool isActive;
  final int position;

  CategoryRequest({
    required this.name,
    required this.isActive,
    required this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'is_active': isActive,
      'position': position,
    };
  }
}

// models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final T? data;
  final ApiError? error;

  ApiResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
    );
  }
}

// models/api_error.dart
class ApiError {
  final String code;
  final String details;

  ApiError({
    required this.code,
    required this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? '',
      details: json['details'] ?? '',
    );
  }
}

// models/categories_response.dart
class CategoriesResponse {
  final List<Category> categories;

  CategoriesResponse({
    required this.categories,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((category) => Category.fromJson(category))
              .toList()
          : [],
    );
  }
}
