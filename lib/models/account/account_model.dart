// models/user.dart
class User {
  final String id;
  final String storeId;
  final String name;
  final String email;
  final bool isStaff;
  final Role role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.storeId,
    required this.name,
    required this.email,
    required this.isStaff,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isStaff: json['is_staff'] == true || json['is_staff'] == 'true',
      role: json['role'] != null
          ? Role.fromJson(Map<String, dynamic>.from(json['role']))
          : Role.empty(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'email': email,
      'is_staff': isStaff,
      'role': role.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Role {
  final String id;
  final String storeId;
  final String name;
  final String description;

  Role({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  // Empty constructor for fallback
  factory Role.empty() {
    return Role(
      id: '',
      storeId: '',
      name: '',
      description: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'description': description,
    };
  }
}

class UserListResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<User> data;
  final UserMetadata metadata;

  UserListResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      success: json['success'] == true || json['success'] == 'true',
      message: json['message']?.toString() ?? '',
      status: int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      timestamp: json['timestamp']?.toString() ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) {
                if (item is Map<String, dynamic>) {
                  return User.fromJson(item);
                }
                return null;
              })
              .where((user) => user != null)
              .cast<User>()
              .toList() ??
          [],
      metadata: json['metadata'] != null
          ? UserMetadata.fromJson(Map<String, dynamic>.from(json['metadata']))
          : UserMetadata.empty(),
    );
  }
}

class UserMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  UserMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory UserMetadata.fromJson(Map<String, dynamic> json) {
    return UserMetadata(
      page: int.tryParse(json['page']?.toString() ?? '1') ?? 1,
      limit: int.tryParse(json['limit']?.toString() ?? '10') ?? 10,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      totalPages: int.tryParse(json['total_pages']?.toString() ?? '0') ?? 0,
    );
  }

  // Empty constructor for fallback
  factory UserMetadata.empty() {
    return UserMetadata(
      page: 1,
      limit: 10,
      total: 0,
      totalPages: 0,
    );
  }
}
