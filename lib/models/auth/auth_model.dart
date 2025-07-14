// lib/models/auth_model.dart
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  final String message;
  final int status;
  final LoginData data;

  LoginResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: LoginData.fromJson(json['data'] ?? {}),
    );
  }
}

class LoginData {
  final String token;

  LoginData({
    required this.token,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] ?? '',
    );
  }
}

class User {
  final String userId;
  final String roleId;
  final String roleName;
  final bool isStaff;
  final List<String> permissions;
  final String storeId;
  final int exp;
  final int nbf;
  final int iat;

  User({
    required this.userId,
    required this.roleId,
    required this.roleName,
    required this.isStaff,
    required this.permissions,
    required this.storeId,
    required this.exp,
    required this.nbf,
    required this.iat,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      roleId: json['role_id'] ?? '',
      roleName: json['role_name'] ?? '',
      isStaff: json['is_staff'] ?? false,
      permissions: List<String>.from(json['permissions'] ?? []),
      storeId: json['store_id'] ?? '',
      exp: json['exp'] ?? 0,
      nbf: json['nbf'] ?? 0,
      iat: json['iat'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role_id': roleId,
      'role_name': roleName,
      'is_staff': isStaff,
      'permissions': permissions,
      'store_id': storeId,
      'exp': exp,
      'nbf': nbf,
      'iat': iat,
    };
  }
}

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
}
