class PointConfig {
  final String id;
  final String storeId;
  final int amount;
  final int points;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  PointConfig({
    required this.id,
    required this.storeId,
    required this.amount,
    required this.points,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PointConfig.fromJson(Map<String, dynamic> json) {
    return PointConfig(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      amount: json['amount'] ?? 0,
      points: json['points'] ?? 0,
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'amount': amount,
      'points': points,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  PointConfig copyWith({
    String? id,
    String? storeId,
    int? amount,
    int? points,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return PointConfig(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      amount: amount ?? this.amount,
      points: points ?? this.points,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PointConfigRequest {
  final int amount;
  final int points;
  final bool? isActive;

  PointConfigRequest({
    required this.amount,
    required this.points,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'amount': amount,
      'points': points,
    };

    // Send boolean value instead of integer
    if (isActive != null) {
      json['is_active'] = isActive!;
    }

    return json;
  }
}

class PointConfigToggleRequest {
  final bool isActive;

  PointConfigToggleRequest({required this.isActive});

  Map<String, dynamic> toJson() {
    return {
      'is_active': isActive, // Keep as boolean
    };
  }
}

class PointConfigResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<PointConfig> data;
  final PointConfigMetadata? metadata;

  PointConfigResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    this.metadata,
  });

  factory PointConfigResponse.fromJson(Map<String, dynamic> json) {
    List<PointConfig> dataList = [];

    if (json['data'] != null) {
      if (json['data'] is List) {
        dataList = (json['data'] as List)
            .map((item) => PointConfig.fromJson(item))
            .toList();
      } else if (json['data'] is Map<String, dynamic>) {
        // Single item response
        dataList = [PointConfig.fromJson(json['data'])];
      }
    }

    return PointConfigResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: dataList,
      metadata: json['metadata'] != null
          ? PointConfigMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

class PointConfigMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PointConfigMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PointConfigMetadata.fromJson(Map<String, dynamic> json) {
    return PointConfigMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}
