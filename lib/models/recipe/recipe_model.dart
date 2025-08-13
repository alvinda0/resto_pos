class RecipeItem {
  final String inventoryId;
  final String inventoryName;
  final String inventorySku;
  final String inventoryUnit;
  final double requiredQuantity;
  final String requiredUnit;
  final double costPerUnit;
  final double totalCost;
  final String notes; // Ensure notes is defined here
  final double hpp;

  RecipeItem({
    required this.inventoryId,
    required this.inventoryName,
    required this.inventorySku,
    required this.inventoryUnit,
    required this.requiredQuantity,
    required this.requiredUnit,
    required this.costPerUnit,
    required this.totalCost,
    required this.notes, // Include notes in the constructor
    required this.hpp,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      inventoryId: json['inventory_id'] ?? '',
      inventoryName: json['inventory_name'] ?? '',
      inventorySku: json['inventory_sku'] ?? '',
      inventoryUnit: json['inventory_unit'] ?? '',
      requiredQuantity: (json['required_quantity'] ?? 0).toDouble(),
      requiredUnit: json['required_unit'] ?? '',
      costPerUnit: (json['cost_per_unit'] ?? 0).toDouble(),
      totalCost: (json['total_cost'] ?? 0).toDouble(),
      notes: json['notes'] ?? '', // Ensure notes is included here
      hpp: (json['hpp'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventory_id': inventoryId,
      'inventory_name': inventoryName,
      'inventory_sku': inventorySku,
      'inventory_unit': inventoryUnit,
      'required_quantity': requiredQuantity,
      'required_unit': requiredUnit,
      'cost_per_unit': costPerUnit,
      'total_cost': totalCost,
      'notes': notes, // Ensure notes is included here
      'hpp': hpp,
    };
  }
}

class Recipe {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final List<RecipeItem> items;
  final double totalCost;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.items,
    required this.totalCost,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => RecipeItem.fromJson(item))
              .toList() ??
          [],
      totalCost: (json['total_cost'] ?? 0).toDouble(),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
      'total_cost': totalCost,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class RecipeMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  RecipeMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory RecipeMetadata.fromJson(Map<String, dynamic> json) {
    return RecipeMetadata(
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

class RecipeResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<Recipe> data;
  final RecipeMetadata metadata;

  RecipeResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory RecipeResponse.fromJson(Map<String, dynamic> json) {
    return RecipeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((recipe) => Recipe.fromJson(recipe))
              .toList() ??
          [],
      metadata: RecipeMetadata.fromJson(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'timestamp': timestamp,
      'data': data.map((recipe) => recipe.toJson()).toList(),
      'metadata': metadata.toJson(),
    };
  }
}
