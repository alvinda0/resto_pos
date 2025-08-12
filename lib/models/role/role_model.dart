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
              ?.map((permissionJson) => Permission.fromJson(permissionJson))
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

class RoleListResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<Role> data;
  final RoleMetadata metadata;

  RoleListResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory RoleListResponse.fromJson(Map<String, dynamic> json) {
    return RoleListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((roleJson) => Role.fromJson(roleJson))
              .toList() ??
          [],
      metadata: RoleMetadata.fromJson(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'timestamp': timestamp,
      'data': data.map((role) => role.toJson()).toList(),
      'metadata': metadata.toJson(),
    };
  }
}

class RoleMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  RoleMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory RoleMetadata.fromJson(Map<String, dynamic> json) {
    return RoleMetadata(
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
