// models/api_key_model.dart
class ApiKeyModel {
  final String? id;
  final String name;
  final String? key;
  final String? secret;
  final String? callbackUrl;
  final bool? isActive;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApiKeyModel({
    this.id,
    required this.name,
    this.key,
    this.secret,
    this.callbackUrl,
    this.isActive,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiKeyModel.fromJson(Map<String, dynamic> json) {
    return ApiKeyModel(
      id: json['id'],
      name: json['name'] ?? '',
      key: json['key'],
      secret: json['secret'],
      callbackUrl: json['callback_url'],
      isActive: json['is_active'],
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
    };

    if (description != null && description!.isNotEmpty) {
      data['description'] = description;
    }
    if (callbackUrl != null && callbackUrl!.isNotEmpty) {
      data['callback_url'] = callbackUrl;
    }
    if (key != null && key!.isNotEmpty) {
      data['key'] = key;
    }
    if (secret != null && secret!.isNotEmpty) {
      data['secret'] = secret;
    }

    return data;
  }

  ApiKeyModel copyWith({
    String? id,
    String? name,
    String? key,
    String? secret,
    String? callbackUrl,
    bool? isActive,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApiKeyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      key: key ?? this.key,
      secret: secret ?? this.secret,
      callbackUrl: callbackUrl ?? this.callbackUrl,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ApiKeyModel{id: $id, name: $name, key: $key, secret: $secret, callbackUrl: $callbackUrl, isActive: $isActive, description: $description, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

// Response model for API operations
class ApiKeyResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final dynamic data;

  ApiKeyResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    this.data,
  });

  factory ApiKeyResponse.fromJson(Map<String, dynamic> json) {
    return ApiKeyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: json['data'],
    );
  }
}
