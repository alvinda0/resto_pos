// models/inventory_model.dart
class InventoryModel {
  final String id;
  final String storeId;
  final String name;
  final String sku;
  final int quantity;
  final String unit;
  final double price;
  final int minimumStock;
  final bool isAvailable;
  final String vendorName;
  final String vendorPaymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.sku,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.minimumStock,
    required this.isAvailable,
    required this.vendorName,
    required this.vendorPaymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      quantity: _parseToInt(json['quantity']),
      unit: json['unit'] ?? '',
      price: _parseToDouble(json['price']),
      minimumStock: _parseToInt(json['minimum_stock']),
      isAvailable: json['is_available'] ?? false,
      vendorName: json['vendor_name'] ?? '',
      vendorPaymentStatus: json['vendor_payment_status'] ?? 'UNPAID',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper methods for safe parsing
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'sku': sku,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'minimum_stock': minimumStock,
      'is_available': isAvailable,
      'vendor_name': vendorName,
      'vendor_payment_status': vendorPaymentStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  String get formattedPrice {
    if (price >= 1000000) {
      return 'Rp ${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return 'Rp ${(price / 1000).toStringAsFixed(0)}K';
    } else {
      return 'Rp ${price.toStringAsFixed(0)}';
    }
  }

  String get stockDisplay => '$quantity $unit';
  String get minimumStockDisplay => '$minimumStock $unit';

  bool get isLowStock => quantity <= minimumStock;

  String get statusDisplay {
    if (!isAvailable) return 'TIDAK AKTIF';
    if (isLowStock) return 'STOK HABIS';
    return 'CUKUP';
  }

  String get paymentStatusDisplay {
    switch (vendorPaymentStatus.toUpperCase()) {
      case 'PAID':
        return 'DIKETAHUI';
      case 'UNPAID':
      default:
        return 'TIDAK DIKETAHUI';
    }
  }
}

class InventoryResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<InventoryModel> data;
  final InventoryMetadata metadata;

  InventoryResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory InventoryResponse.fromJson(Map<String, dynamic> json) {
    return InventoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => InventoryModel.fromJson(item))
          .toList(),
      metadata: InventoryMetadata.fromJson(json['metadata'] ?? {}),
    );
  }
}

class InventoryMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  InventoryMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory InventoryMetadata.fromJson(Map<String, dynamic> json) {
    return InventoryMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}
