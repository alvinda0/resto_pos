import 'dart:convert';
import 'package:pos/http_client.dart';
import 'package:pos/models/payroll/payroll_model.dart';

class PayrollService {
  final HttpClient _httpClient = HttpClient.instance;

  static PayrollService get instance => PayrollService();

  // Get payrolls dengan pagination
  Future<PayrollResponse> getPayrolls({
    int page = 1,
    int limit = 10,
    String? storeId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _httpClient.get(
        '/payroll',
        queryParameters: queryParams,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PayrollResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch payrolls');
      }
    } catch (e) {
      throw Exception('Error fetching payrolls: $e');
    }
  }

  // Generate payroll
  Future<PayrollGenerateResponse> generatePayroll(
    PayrollGenerateRequest request, {
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.post(
        '/payroll/generate',
        request.toJson(),
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PayrollGenerateResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to generate payroll');
      }
    } catch (e) {
      throw Exception('Error generating payroll: $e');
    }
  }

  // Get payroll by ID
  Future<Payroll> getPayrollById(String id, {String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '/payroll/$id',
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Payroll.fromJson(jsonData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch payroll');
      }
    } catch (e) {
      throw Exception('Error fetching payroll: $e');
    }
  }

  // Update payroll
  Future<Payroll> updatePayroll(
    String id,
    Map<String, dynamic> data, {
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.put(
        '/payroll/$id',
        data,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Payroll.fromJson(jsonData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update payroll');
      }
    } catch (e) {
      throw Exception('Error updating payroll: $e');
    }
  }

  // Delete payroll
  Future<bool> deletePayroll(String id, {String? storeId}) async {
    try {
      final response = await _httpClient.delete(
        '/payroll/$id',
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete payroll');
      }
    } catch (e) {
      throw Exception('Error deleting payroll: $e');
    }
  }

  // Get payrolls by employee
  Future<PayrollResponse> getPayrollsByEmployee(
    String employeeId, {
    int page = 1,
    int limit = 10,
    String? storeId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'employee_id': employeeId,
      };

      final response = await _httpClient.get(
        '/payroll',
        queryParameters: queryParams,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PayrollResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch payrolls');
      }
    } catch (e) {
      throw Exception('Error fetching payrolls: $e');
    }
  }

  // Get payrolls by month
  Future<PayrollResponse> getPayrollsByMonth(
    String month, {
    int page = 1,
    int limit = 10,
    String? storeId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'month': month,
      };

      final response = await _httpClient.get(
        '/payroll',
        queryParameters: queryParams,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PayrollResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch payrolls');
      }
    } catch (e) {
      throw Exception('Error fetching payrolls: $e');
    }
  }
}
