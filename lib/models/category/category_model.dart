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

// models/pagination_metadata.dart
class PaginationMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
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
  final PaginationMetadata? metadata;

  ApiResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    this.data,
    this.error,
    this.metadata,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
      metadata: json['metadata'] != null
          ? PaginationMetadata.fromJson(json['metadata'])
          : null,
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

// models/categories_response.dart - Updated to handle direct array response
class CategoriesResponse {
  final List<Category> categories;
  final PaginationMetadata? metadata;

  CategoriesResponse({
    required this.categories,
    this.metadata,
  });

  // Updated to handle direct array from API response
  factory CategoriesResponse.fromJson(dynamic json,
      {PaginationMetadata? metadata}) {
    List<Category> categories = [];

    if (json is List) {
      // Direct array response
      categories = json.map((category) => Category.fromJson(category)).toList();
    } else if (json is Map<String, dynamic> && json['categories'] != null) {
      // Wrapped in categories object (fallback)
      categories = (json['categories'] as List)
          .map((category) => Category.fromJson(category))
          .toList();
    }

    return CategoriesResponse(
      categories: categories,
      metadata: metadata,
    );
  }
}
