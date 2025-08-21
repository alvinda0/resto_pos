class Employee {
  final String id;
  final String storeId;
  final String name;
  final String email;
  final String phone;
  final String position;
  final double baseSalary;

  Employee({
    required this.id,
    required this.storeId,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.baseSalary,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      position: json['position'] ?? '',
      baseSalary: (json['base_salary'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'base_salary': baseSalary,
    };
  }

  // For creating new employee (without id and store_id)
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'base_salary': baseSalary,
    };
  }

  // For updating employee
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'base_salary': baseSalary,
    };
  }

  Employee copyWith({
    String? id,
    String? storeId,
    String? name,
    String? email,
    String? phone,
    String? position,
    double? baseSalary,
  }) {
    return Employee(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      baseSalary: baseSalary ?? this.baseSalary,
    );
  }

  @override
  String toString() {
    return 'Employee{id: $id, name: $name, email: $email, position: $position}';
  }
}

class EmployeeResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<Employee> data;
  final EmployeeMetadata? metadata;

  EmployeeResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    this.metadata,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Employee.fromJson(item))
              .toList() ??
          [],
      metadata: json['metadata'] != null
          ? EmployeeMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

class SingleEmployeeResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final Employee data;

  SingleEmployeeResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory SingleEmployeeResponse.fromJson(Map<String, dynamic> json) {
    return SingleEmployeeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: Employee.fromJson(json['data']),
    );
  }
}

class DeleteEmployeeResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final Map<String, String> data;

  DeleteEmployeeResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory DeleteEmployeeResponse.fromJson(Map<String, dynamic> json) {
    return DeleteEmployeeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: Map<String, String>.from(json['data'] ?? {}),
    );
  }
}

class EmployeeMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  EmployeeMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory EmployeeMetadata.fromJson(Map<String, dynamic> json) {
    return EmployeeMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
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
