// models/redemption_model.dart
import 'package:flutter/material.dart';

class Redemption {
  final String id;
  final String customerId;
  final String rewardId;
  final int pointsUsed;
  final RedemptionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Redemption({
    required this.id,
    required this.customerId,
    required this.rewardId,
    required this.pointsUsed,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Redemption.fromJson(Map<String, dynamic> json) {
    return Redemption(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      rewardId: json['reward_id'] ?? '',
      pointsUsed: json['points_used']?.toInt() ?? 0,
      status: RedemptionStatus.fromString(json['status'] ?? 'PENDING'),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'reward_id': rewardId,
      'points_used': pointsUsed,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Redemption copyWith({
    String? id,
    String? customerId,
    String? rewardId,
    int? pointsUsed,
    RedemptionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Redemption(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      rewardId: rewardId ?? this.rewardId,
      pointsUsed: pointsUsed ?? this.pointsUsed,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Redemption(id: $id, customerId: $customerId, rewardId: $rewardId, pointsUsed: $pointsUsed, status: ${status.value})';
  }
}

enum RedemptionStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED');

  const RedemptionStatus(this.value);
  final String value;

  static RedemptionStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return RedemptionStatus.pending;
      case 'APPROVED':
        return RedemptionStatus.approved;
      case 'REJECTED':
        return RedemptionStatus.rejected;
      default:
        return RedemptionStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case RedemptionStatus.pending:
        return 'Pending';
      case RedemptionStatus.approved:
        return 'Approved';
      case RedemptionStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case RedemptionStatus.pending:
        return Colors.orange;
      case RedemptionStatus.approved:
        return Colors.green;
      case RedemptionStatus.rejected:
        return Colors.red;
    }
  }
}

class RedemptionResponse {
  final bool success;
  final String message;
  final int status;
  final List<Redemption> data;
  final RedemptionMetadata metadata;

  RedemptionResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.data,
    required this.metadata,
  });

  factory RedemptionResponse.fromJson(Map<String, dynamic> json) {
    return RedemptionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Redemption.fromJson(item))
              .toList() ??
          [],
      metadata: RedemptionMetadata.fromJson(json['metadata'] ?? {}),
    );
  }
}

class RedemptionMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  RedemptionMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory RedemptionMetadata.fromJson(Map<String, dynamic> json) {
    return RedemptionMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

class UpdateRedemptionStatusRequest {
  final RedemptionStatus status;

  UpdateRedemptionStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status.value,
    };
  }
}
