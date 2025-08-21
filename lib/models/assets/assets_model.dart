class Asset {
  final String id;
  final String storeId;
  final String type;
  final String name;
  final String category;
  final String sku;
  final DateTime acquisitionDate;
  final DateTime? coverageEndDate;
  final int cost;
  final int residualValue;
  final int usefulLifeMonths;
  final String depMethod;
  final double depFactor;
  final int accumulatedDepreciation;
  final DateTime? lastDepreciatedAt;
  final String status;

  Asset({
    required this.id,
    required this.storeId,
    required this.type,
    required this.name,
    required this.category,
    required this.sku,
    required this.acquisitionDate,
    this.coverageEndDate,
    required this.cost,
    required this.residualValue,
    required this.usefulLifeMonths,
    required this.depMethod,
    required this.depFactor,
    required this.accumulatedDepreciation,
    this.lastDepreciatedAt,
    required this.status,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      storeId: json['store_id'],
      type: json['type'],
      name: json['name'],
      category: json['category'],
      sku: json['sku'],
      acquisitionDate: DateTime.parse(json['acquisition_date']),
      coverageEndDate: json['coverage_end_date'] != null
          ? DateTime.parse(json['coverage_end_date'])
          : null,
      cost: json['cost'],
      residualValue: json['residual_value'],
      usefulLifeMonths: json['useful_life_months'],
      depMethod: json['dep_method'],
      depFactor: (json['dep_factor'] as num).toDouble(),
      accumulatedDepreciation: json['accumulated_depreciation'],
      lastDepreciatedAt: json['last_depreciated_at'] != null
          ? DateTime.parse(json['last_depreciated_at'])
          : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'category': category,
      'acquisition_date': acquisitionDate.toIso8601String().split('T')[0],
      'coverage_end_date': coverageEndDate?.toIso8601String().split('T')[0],
      'cost': cost,
      'residual_value': residualValue,
      'useful_life_months': usefulLifeMonths,
      'dep_method': depMethod,
      'dep_factor': depFactor,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    final json = <String, dynamic>{};

    json['type'] = type;
    json['name'] = name;
    json['category'] = category;
    json['acquisition_date'] =
        acquisitionDate.toIso8601String().split('T')[0]; // Format: YYYY-MM-DD
    if (coverageEndDate != null) {
      json['coverage_end_date'] = coverageEndDate!
          .toIso8601String()
          .split('T')[0]; // Format: YYYY-MM-DD
    }
    json['cost'] = cost;
    json['residual_value'] = residualValue;
    json['useful_life_months'] = usefulLifeMonths;
    json['dep_method'] = depMethod;
    json['dep_factor'] = depFactor;
    json['status'] = status;

    return json;
  }

  Asset copyWith({
    String? id,
    String? storeId,
    String? type,
    String? name,
    String? category,
    String? sku,
    DateTime? acquisitionDate,
    DateTime? coverageEndDate,
    int? cost,
    int? residualValue,
    int? usefulLifeMonths,
    String? depMethod,
    double? depFactor,
    int? accumulatedDepreciation,
    DateTime? lastDepreciatedAt,
    String? status,
  }) {
    return Asset(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      type: type ?? this.type,
      name: name ?? this.name,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      coverageEndDate: coverageEndDate ?? this.coverageEndDate,
      cost: cost ?? this.cost,
      residualValue: residualValue ?? this.residualValue,
      usefulLifeMonths: usefulLifeMonths ?? this.usefulLifeMonths,
      depMethod: depMethod ?? this.depMethod,
      depFactor: depFactor ?? this.depFactor,
      accumulatedDepreciation:
          accumulatedDepreciation ?? this.accumulatedDepreciation,
      lastDepreciatedAt: lastDepreciatedAt ?? this.lastDepreciatedAt,
      status: status ?? this.status,
    );
  }
}

class AssetResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<Asset> data;
  final AssetMetadata? metadata;

  AssetResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    this.metadata,
  });

  factory AssetResponse.fromJson(Map<String, dynamic> json) {
    return AssetResponse(
      success: json['success'],
      message: json['message'],
      status: json['status'],
      timestamp: json['timestamp'],
      data: (json['data'] as List).map((item) => Asset.fromJson(item)).toList(),
      metadata: json['metadata'] != null
          ? AssetMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

class AssetSingleResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final Asset data;

  AssetSingleResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory AssetSingleResponse.fromJson(Map<String, dynamic> json) {
    return AssetSingleResponse(
      success: json['success'],
      message: json['message'],
      status: json['status'],
      timestamp: json['timestamp'],
      data: Asset.fromJson(json['data']),
    );
  }
}

class AssetMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  AssetMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory AssetMetadata.fromJson(Map<String, dynamic> json) {
    return AssetMetadata(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['total_pages'],
    );
  }
}

class AssetDeleteResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;

  AssetDeleteResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
  });

  factory AssetDeleteResponse.fromJson(Map<String, dynamic> json) {
    return AssetDeleteResponse(
      success: json['success'],
      message: json['message'],
      status: json['status'],
      timestamp: json['timestamp'],
    );
  }
}

// Enums for asset types and depreciation methods
class AssetType {
  static const String fixedTangible = 'FIXED_TANGIBLE';
  static const String prepaidExpense = 'PREPAID_EXPENSE';

  static List<String> get all => [fixedTangible, prepaidExpense];
}

class DepreciationMethod {
  static const String straightLine = 'STRAIGHT_LINE';
  static const String decliningBalance = 'DECLINING_BALANCE';

  static List<String> get all => [straightLine, decliningBalance];
}

class AssetStatus {
  static const String active = 'ACTIVE';
  static const String inactive = 'INACTIVE';

  static List<String> get all => [active, inactive];
}
