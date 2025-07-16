// models/role_model.dart
class Permission {
  final String id;
  final String name;
  final String description;

  Permission({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class Role {
  final String id;
  final String name;
  final String description;
  final int position;
  final bool isSystem;
  final bool isStaff;
  final List<Permission> permissions;
  final int userCount;

  Role({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
    required this.isSystem,
    required this.isStaff,
    required this.permissions,
    required this.userCount,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      position: json['position'] ?? 0,
      isSystem: json['is_system'] ?? false,
      isStaff: json['is_staff'] ?? false,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((permission) => Permission.fromJson(permission))
              .toList() ??
          [],
      userCount: json['user_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'position': position,
      'is_system': isSystem,
      'is_staff': isStaff,
      'permissions':
          permissions.map((permission) => permission.toJson()).toList(),
      'user_count': userCount,
    };
  }
}

class RoleResponse {
  final String message;
  final int status;
  final List<Role> data;

  RoleResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory RoleResponse.fromJson(Map<String, dynamic> json) {
    return RoleResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((role) => Role.fromJson(role))
              .toList() ??
          [],
    );
  }
}
