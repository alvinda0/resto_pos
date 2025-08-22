class Theme {
  final String id;
  final String name;
  final String primaryColor;
  final String logoUrl;
  final String faviconUrl;
  final String pageTitle;
  final bool isDefault;

  Theme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.logoUrl,
    required this.faviconUrl,
    required this.pageTitle,
    required this.isDefault,
  });

  factory Theme.fromJson(Map<String, dynamic> json) {
    return Theme(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      primaryColor: json['primary_color'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      faviconUrl: json['favicon_url'] ?? '',
      pageTitle: json['page_title'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primary_color': primaryColor,
      'logo_url': logoUrl,
      'favicon_url': faviconUrl,
      'page_title': pageTitle,
      'is_default': isDefault,
    };
  }

  Theme copyWith({
    String? id,
    String? name,
    String? primaryColor,
    String? logoUrl,
    String? faviconUrl,
    String? pageTitle,
    bool? isDefault,
  }) {
    return Theme(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      logoUrl: logoUrl ?? this.logoUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      pageTitle: pageTitle ?? this.pageTitle,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class ThemeListResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<Theme> data;
  final Metadata metadata;

  ThemeListResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory ThemeListResponse.fromJson(Map<String, dynamic> json) {
    return ThemeListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Theme.fromJson(item))
              .toList() ??
          [],
      metadata: Metadata.fromJson(json['metadata'] ?? {}),
    );
  }
}

class ThemeResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final Theme? data;
  final ErrorDetail? error;

  ThemeResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    this.data,
    this.error,
  });

  factory ThemeResponse.fromJson(Map<String, dynamic> json) {
    return ThemeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: json['data'] != null ? Theme.fromJson(json['data']) : null,
      error: json['error'] != null ? ErrorDetail.fromJson(json['error']) : null,
    );
  }
}

class Metadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Metadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

class ErrorDetail {
  final String code;
  final String details;

  ErrorDetail({
    required this.code,
    required this.details,
  });

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      code: json['code'] ?? '',
      details: json['details'] ?? '',
    );
  }
}

class CreateThemeRequest {
  final String name;
  final String primaryColor;
  final String pageTitle;
  final bool isDefault;

  CreateThemeRequest({
    required this.name,
    required this.primaryColor,
    required this.pageTitle,
    required this.isDefault,
  });

  Map<String, String> toMultipartFields() {
    return {
      'name': name,
      'primaryColor': primaryColor,
      'pageTitle': pageTitle,
      'isDefault': isDefault.toString(),
    };
  }
}
