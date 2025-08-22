class Payroll {
  final String id;
  final String storeId;
  final String employeeId;
  final double baseSalary;
  final double bonus;
  final double deductions;
  final double taxAmount;
  final double netSalary;
  final DateTime payrollMonth;

  Payroll({
    required this.id,
    required this.storeId,
    required this.employeeId,
    required this.baseSalary,
    required this.bonus,
    required this.deductions,
    required this.taxAmount,
    required this.netSalary,
    required this.payrollMonth,
  });

  factory Payroll.fromJson(Map<String, dynamic> json) {
    return Payroll(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      baseSalary: (json['base_salary'] ?? 0).toDouble(),
      bonus: (json['bonus'] ?? 0).toDouble(),
      deductions: (json['deductions'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      netSalary: (json['net_salary'] ?? 0).toDouble(),
      payrollMonth: DateTime.parse(json['payroll_month']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'employee_id': employeeId,
      'base_salary': baseSalary,
      'bonus': bonus,
      'deductions': deductions,
      'tax_amount': taxAmount,
      'net_salary': netSalary,
      'payroll_month': payrollMonth.toIso8601String(),
    };
  }
}

class PayrollMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PayrollMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PayrollMetadata.fromJson(Map<String, dynamic> json) {
    return PayrollMetadata(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}

class PayrollResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final List<Payroll> data;
  final PayrollMetadata? metadata;

  PayrollResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
    this.metadata,
  });

  factory PayrollResponse.fromJson(Map<String, dynamic> json) {
    return PayrollResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Payroll.fromJson(item))
              .toList() ??
          [],
      metadata: json['metadata'] != null
          ? PayrollMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

class PayrollOverride {
  final String employeeId;
  final double? bonus;
  final double? deductions;

  PayrollOverride({
    required this.employeeId,
    this.bonus,
    this.deductions,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'employee_id': employeeId,
    };

    if (bonus != null) json['bonus'] = bonus;
    if (deductions != null) json['deductions'] = deductions;

    return json;
  }
}

class PayrollGenerateRequest {
  final String payrollMonth;
  final double? bonus;
  final double? deductions;
  final List<PayrollOverride>? overrides;

  PayrollGenerateRequest({
    required this.payrollMonth,
    this.bonus,
    this.deductions,
    this.overrides,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'payroll_month': payrollMonth,
    };

    if (bonus != null) json['bonus'] = bonus;
    if (deductions != null) json['deductions'] = deductions;
    if (overrides != null && overrides!.isNotEmpty) {
      json['overrides'] =
          overrides!.map((override) => override.toJson()).toList();
    }

    return json;
  }
}

class PayrollGenerateResponse {
  final bool success;
  final String message;
  final int status;
  final String timestamp;
  final PayrollGenerateData data;

  PayrollGenerateResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.data,
  });

  factory PayrollGenerateResponse.fromJson(Map<String, dynamic> json) {
    return PayrollGenerateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: PayrollGenerateData.fromJson(json['data'] ?? {}),
    );
  }
}

class PayrollGenerateData {
  final int count;

  PayrollGenerateData({required this.count});

  factory PayrollGenerateData.fromJson(Map<String, dynamic> json) {
    return PayrollGenerateData(
      count: json['count'] ?? 0,
    );
  }
}
