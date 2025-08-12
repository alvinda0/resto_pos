// models/reward_model.dart
class RewardModel {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final String? imageUrl;
  final int pointsCost;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RewardModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.pointsCost,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      pointsCost: json['points_cost'] ?? 0,
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'points_cost': pointsCost,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class RewardResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<RewardModel> data;
  final RewardMetadata metadata;

  RewardResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory RewardResponse.fromJson(Map<String, dynamic> json) {
    return RewardResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => RewardModel.fromJson(item))
              .toList() ??
          [],
      metadata: RewardMetadata.fromJson(json['metadata'] ?? {}),
    );
  }
}

class RewardMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  RewardMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory RewardMetadata.fromJson(Map<String, dynamic> json) {
    return RewardMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}
