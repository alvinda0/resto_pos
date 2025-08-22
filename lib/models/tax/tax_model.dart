// models/tax_model.dart
class TaxModel {
  final String id;
  final String name;
  final String type;
  final double percentage;
  final String description;
  final bool isActive;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaxModel({
    required this.id,
    required this.name,
    required this.type,
    required this.percentage,
    required this.description,
    required this.isActive,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
      priority: json['priority'] ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'percentage': percentage,
      'description': description,
      'is_active': isActive,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'type': type,
      'percentage': percentage,
      'description': description,
      'is_active': isActive,
      if (priority != 0) 'priority': priority,
    };
  }

  TaxModel copyWith({
    String? id,
    String? name,
    String? type,
    double? percentage,
    String? description,
    bool? isActive,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      percentage: percentage ?? this.percentage,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case 'VAT':
        return 'VAT';
      case 'SERVICE_CHARGE':
        return 'Service Charge';
      case 'REGIONAL_TAX':
        return 'Regional Tax';
      default:
        return type;
    }
  }

  String get statusText => isActive ? 'Active' : 'Inactive';
}

// Response models
class TaxListResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<TaxModel> data;
  final TaxMetadata metadata;

  TaxListResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory TaxListResponse.fromJson(Map<String, dynamic> json) {
    return TaxListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => TaxModel.fromJson(item))
              .toList() ??
          [],
      metadata: TaxMetadata.fromJson(json['metadata'] ?? {}),
    );
  }
}

class TaxResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final TaxModel? data;

  TaxResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    this.data,
  });

  factory TaxResponse.fromJson(Map<String, dynamic> json) {
    return TaxResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: json['data'] != null ? TaxModel.fromJson(json['data']) : null,
    );
  }
}

class TaxMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  TaxMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory TaxMetadata.fromJson(Map<String, dynamic> json) {
    return TaxMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}

// Enum for tax types
enum TaxType {
  VAT('VAT'),
  SERVICE_CHARGE('SERVICE_CHARGE'),
  REGIONAL_TAX('REGIONAL_TAX');

  const TaxType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case TaxType.VAT:
        return 'VAT';
      case TaxType.SERVICE_CHARGE:
        return 'Service Charge';
      case TaxType.REGIONAL_TAX:
        return 'Regional Tax';
    }
  }

  static TaxType fromString(String value) {
    return TaxType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TaxType.VAT,
    );
  }
}
