class Customer {
  final String id;
  final String storeId;
  final String name;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.storeId,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Customer{id: $id, name: $name, phone: $phone}';
  }
}

class CustomerResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<Customer> data;
  final CustomerMetadata metadata;

  CustomerResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    required this.metadata,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Customer.fromJson(item))
              .toList() ??
          [],
      metadata: CustomerMetadata.fromJson(json['metadata'] ?? {}),
    );
  }
}

class CustomerMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  CustomerMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory CustomerMetadata.fromJson(Map<String, dynamic> json) {
    return CustomerMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}

class DeleteCustomerResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final Customer data;

  DeleteCustomerResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory DeleteCustomerResponse.fromJson(Map<String, dynamic> json) {
    return DeleteCustomerResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: Customer.fromJson(json['data']),
    );
  }
}
