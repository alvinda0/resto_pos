// models/inventory/inventory_model.dart
class InventoryModel {
  final String id;
  final String storeId;
  final String name;
  final String sku;
  final double quantity;
  final String unit;
  final double minimumStock;

  InventoryModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.sku,
    required this.quantity,
    required this.unit,
    required this.minimumStock,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      minimumStock: (json['minimum_stock'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'sku': sku,
      'quantity': quantity,
      'unit': unit,
      'minimum_stock': minimumStock,
    };
  }

  // Helper method to check if stock is low
  bool get isLowStock => quantity <= minimumStock;

  // Helper method to get status
  String get status => isLowStock ? 'MENIPIS' : 'CUKUP';

  // Helper method to get formatted quantity with unit
  String get formattedQuantity => '${quantity.toInt()} $unit';

  // Helper method to get formatted minimum stock with unit
  String get formattedMinimumStock => '${minimumStock.toInt()} $unit';

  InventoryModel copyWith({
    String? id,
    String? storeId,
    String? name,
    String? sku,
    double? quantity,
    String? unit,
    double? minimumStock,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minimumStock: minimumStock ?? this.minimumStock,
    );
  }
}

// Request model for creating inventory
class CreateInventoryRequest {
  final String name;
  final double quantity;
  final String unit;
  final double minimumStock;

  CreateInventoryRequest({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.minimumStock,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'minimum_stock': minimumStock,
    };
  }
}

// Request model for updating inventory
class UpdateInventoryRequest {
  final String name;
  final double quantity;
  final String unit;
  final double minimumStock;

  UpdateInventoryRequest({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.minimumStock,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'minimum_stock': minimumStock,
    };
  }
}

// Pagination metadata model
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
      totalPages: json['total_pages'] ?? 0,
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

  // Helper methods for pagination logic
  bool get hasPreviousPage => page > 1;
  bool get hasNextPage => page < totalPages;

  int get startIndex => total == 0 ? 0 : ((page - 1) * limit) + 1;
  int get endIndex {
    if (total == 0) return 0;
    final end = page * limit;
    return end > total ? total : end;
  }

  // Generate page numbers for pagination UI
  List<int> getPageNumbers({int maxVisible = 5}) {
    if (totalPages <= maxVisible) {
      return List.generate(totalPages, (index) => index + 1);
    }

    List<int> pages = [];
    int start = (page - maxVisible ~/ 2).clamp(1, totalPages - maxVisible + 1);
    int end = (start + maxVisible - 1).clamp(1, totalPages);

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    return pages;
  }
}

// Response model for inventory list with pagination
class InventoryListResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<InventoryModel> data;
  final PaginationMetadata metadata;

  InventoryListResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory InventoryListResponse.fromJson(Map<String, dynamic> json) {
    return InventoryListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => InventoryModel.fromJson(item))
              .toList() ??
          [],
      metadata: PaginationMetadata.fromJson(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'timestamp': timestamp,
      'data': data.map((item) => item.toJson()).toList(),
      'metadata': metadata.toJson(),
    };
  }
}
