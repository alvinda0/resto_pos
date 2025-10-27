class WasteProduct {
  final String id;
  final String name;
  final String sku;

  WasteProduct({
    required this.id,
    required this.name,
    required this.sku,
  });

  factory WasteProduct.fromJson(Map<String, dynamic> json) {
    return WasteProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
    };
  }
}

class WasteRecord {
  final String id;
  final String storeId;
  final String productId;
  final WasteProduct product;
  final int quantity;
  final String unit;
  final String reason;
  final double cost;
  final DateTime date;
  final String? notes;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  WasteRecord({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.unit,
    required this.reason,
    required this.cost,
    required this.date,
    this.notes,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WasteRecord.fromJson(Map<String, dynamic> json) {
    return WasteRecord(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      productId: json['product_id'] ?? '',
      product: WasteProduct.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      reason: json['reason'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
      createdBy: json['created_by'] ?? '',
      createdByName: json['created_by_name'] ?? '',
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
      'product_id': productId,
      'product': product.toJson(),
      'quantity': quantity,
      'unit': unit,
      'reason': reason,
      'cost': cost,
      'date': date.toIso8601String(),
      'notes': notes,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class WasteMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  WasteMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory WasteMetadata.fromJson(Map<String, dynamic> json) {
    return WasteMetadata(
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
}

class WasteResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<WasteRecord> data;
  final WasteMetadata metadata;

  WasteResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory WasteResponse.fromJson(Map<String, dynamic> json) {
    return WasteResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => WasteRecord.fromJson(item))
              .toList() ??
          [],
      metadata: WasteMetadata.fromJson(json['metadata'] ?? {}),
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
