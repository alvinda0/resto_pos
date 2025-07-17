// lib/models/user/user_model.dart

class CurrentUserResponse {
  final String message;
  final int status;
  final CurrentUserData data;

  CurrentUserResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory CurrentUserResponse.fromJson(Map<String, dynamic> json) {
    return CurrentUserResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: CurrentUserData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'data': data.toJson(),
    };
  }
}

class CurrentUserData {
  final CurrentUser user;
  final List<String> permissions;

  CurrentUserData({
    required this.user,
    required this.permissions,
  });

  factory CurrentUserData.fromJson(Map<String, dynamic> json) {
    return CurrentUserData(
      user: CurrentUser.fromJson(json['user'] ?? {}),
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'permissions': permissions,
    };
  }
}

class CurrentUser {
  final String id;
  final String? storeId;
  final String name;
  final String email;
  final bool isStaff;
  final UserRole? role;
  final String createdAt;
  final String? lastLoginAt;

  CurrentUser({
    required this.id,
    this.storeId,
    required this.name,
    required this.email,
    required this.isStaff,
    this.role,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'] ?? '',
      storeId: json['store_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isStaff: json['is_staff'] ?? false,
      role: json['role'] != null ? UserRole.fromJson(json['role']) : null,
      createdAt: json['created_at'] ?? '',
      lastLoginAt: json['last_login_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'email': email,
      'is_staff': isStaff,
      'role': role?.toJson(),
      'created_at': createdAt,
      'last_login_at': lastLoginAt,
    };
  }
}

class UserRole {
  final String id;
  final String? storeId;
  final String name;
  final String? description;

  UserRole({
    required this.id,
    this.storeId,
    required this.name,
    this.description,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] ?? '',
      storeId: json['store_id'],
      name: json['name'] ?? '',
      description: json['description'],
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

// Generic API Response wrapper
class ApiResponse<T> {
  final String message;
  final int status;
  final T? data;
  final bool success;

  ApiResponse({
    required this.message,
    required this.status,
    this.data,
    required this.success,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T? data) {
    return ApiResponse<T>(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: data,
      success: json['status'] == 200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'data': data,
      'success': success,
    };
  }
}
