import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/employee/employe_model.dart';

class EmployeeService extends GetxService {
  static EmployeeService get instance {
    if (!Get.isRegistered<EmployeeService>()) {
      Get.put(EmployeeService());
    }
    return Get.find<EmployeeService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  // Get all employees with pagination
  Future<EmployeeResponse> getEmployees({
    int page = 1,
    int limit = 10,
    String? storeId,
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _httpClient.get(
        '/employees',
        queryParameters: queryParameters,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return EmployeeResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get employees');
      }
    } catch (e) {
      throw Exception('Error getting employees: ${e.toString()}');
    }
  }

  // Get single employee by ID
  Future<SingleEmployeeResponse> getEmployee(String id,
      {String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '/employees/$id',
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SingleEmployeeResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get employee');
      }
    } catch (e) {
      throw Exception('Error getting employee: ${e.toString()}');
    }
  }

  // Create new employee
  Future<SingleEmployeeResponse> createEmployee(
    Employee employee, {
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.post(
        '/employees',
        employee.toCreateJson(),
        storeId: storeId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return SingleEmployeeResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create employee');
      }
    } catch (e) {
      throw Exception('Error creating employee: ${e.toString()}');
    }
  }

  // Update employee
  Future<SingleEmployeeResponse> updateEmployee(
    String id,
    Employee employee, {
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.put(
        '/employees/$id',
        employee.toUpdateJson(),
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SingleEmployeeResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update employee');
      }
    } catch (e) {
      throw Exception('Error updating employee: ${e.toString()}');
    }
  }

  // Delete employee
  Future<DeleteEmployeeResponse> deleteEmployee(String id,
      {String? storeId}) async {
    try {
      final response = await _httpClient.delete(
        '/employees/$id',
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return DeleteEmployeeResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete employee');
      }
    } catch (e) {
      throw Exception('Error deleting employee: ${e.toString()}');
    }
  }

  // Search employees (if backend supports search)
  Future<EmployeeResponse> searchEmployees({
    String? query,
    int page = 1,
    int limit = 10,
    String? storeId,
  }) async {
    try {
      final queryParameters = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (query != null && query.isNotEmpty) {
        queryParameters['search'] = query;
      }

      final response = await _httpClient.get(
        '/employees',
        queryParameters: queryParameters,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return EmployeeResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to search employees');
      }
    } catch (e) {
      throw Exception('Error searching employees: ${e.toString()}');
    }
  }

  // Validate employee data before sending
  String? validateEmployee(Employee employee) {
    if (employee.name.trim().isEmpty) {
      return 'Name is required';
    }

    if (employee.email.trim().isEmpty) {
      return 'Email is required';
    }

    // Basic email validation
    if (!GetUtils.isEmail(employee.email)) {
      return 'Invalid email format';
    }

    if (employee.phone.trim().isEmpty) {
      return 'Phone is required';
    }

    if (employee.position.trim().isEmpty) {
      return 'Position is required';
    }

    if (employee.baseSalary <= 0) {
      return 'Base salary must be greater than 0';
    }

    return null; // No validation errors
  }

  // Format currency for display
  String formatSalary(double salary) {
    return 'Rp ${salary.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // Parse salary from formatted string
  double parseSalary(String formattedSalary) {
    return double.tryParse(
            formattedSalary.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0.0;
  }
}
