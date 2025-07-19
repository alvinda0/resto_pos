// models/inventory_model.dart
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

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'minimum_stock': minimumStock,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
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
  String get formattedQuantity => '$quantity $unit';

  // Helper method to get formatted minimum stock with unit
  String get formattedMinimumStock => '$minimumStock $unit';

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
