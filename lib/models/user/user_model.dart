// models/user/user_model.dart
class UserRole {
  final String id;
  final String storeId;
  final String name;
  final String description;

  UserRole({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
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

class User {
  final String id;
  final String storeId;
  final String name;
  final String email;
  final bool isStaff;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.storeId,
    required this.name,
    required this.email,
    required this.isStaff,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isStaff: json['is_staff'] ?? false,
      role: UserRole.fromJson(json['role'] ?? {}),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
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
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
}

class CreateUserRequest {
  final String name;
  final String email;
  final String password;
  final bool isStaff;
  final String roleId;

  CreateUserRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.isStaff,
    required this.roleId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'is_staff': isStaff,
      'role_id': roleId,
    };
  }
}

class UpdateUserRequest {
  final String name;
  final String email;
  final String? password;
  final bool isStaff;
  final String roleId;

  UpdateUserRequest({
    required this.name,
    required this.email,
    this.password,
    required this.isStaff,
    required this.roleId,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'email': email,
      'is_staff': isStaff,
      'role_id': roleId,
    };

    if (password != null && password!.isNotEmpty) {
      data['password'] = password!;
    }

    return data;
  }
}

class UserResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<User> data;
  final UserMetadata? metadata;

  UserResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    this.metadata,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((user) => User.fromJson(user))
              .toList() ??
          [],
      metadata: json['metadata'] != null
          ? UserMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

class SingleUserResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final User data;

  SingleUserResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory SingleUserResponse.fromJson(Map<String, dynamic> json) {
    return SingleUserResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: User.fromJson(json['data'] ?? {}),
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
