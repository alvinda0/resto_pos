import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/debt/debt_model.dart';

class DebtService extends GetxService {
  static DebtService get instance {
    if (!Get.isRegistered<DebtService>()) {
      Get.put(DebtService());
    }
    return Get.find<DebtService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  /// Get all debts
  Future<DebtResponse> getDebts({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _httpClient.get(
        '/debts',
        requireAuth: true,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return DebtResponse.fromJson(responseBody);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to fetch debts');
      }
    } catch (e) {
      throw Exception('Error fetching debts: $e');
    }
  }

  /// Update debt
  Future<DebtSingleResponse> updateDebt(String debtId, Debt debt) async {
    try {
      final response = await _httpClient.put(
        '/debts/$debtId',
        debt.toUpdateJson(),
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return DebtSingleResponse.fromJson(responseBody);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to update debt');
      }
    } catch (e) {
      throw Exception('Error updating debt: $e');
    }
  }

  /// Delete debt
  Future<Map<String, dynamic>> deleteDebt(String debtId) async {
    try {
      final response = await _httpClient.delete(
        '/debts/$debtId',
        requireAuth: true,
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Debt deleted successfully',
        };
      } else {
        // Handle specific error cases
        if (response.statusCode == 500) {
          final error = responseBody['error'];
          if (error != null && error['details'] == 'Cannot delete paid debts') {
            throw Exception('Cannot delete paid debts');
          }
        }
        throw Exception(responseBody['message'] ?? 'Failed to delete debt');
      }
    } catch (e) {
      throw Exception('Error deleting debt: $e');
    }
  }

  /// Mark debt as paid - Updated to use the correct endpoint
  Future<DebtSingleResponse> markAsPaid(String debtId) async {
    try {
      final response = await _httpClient.post(
        '/debts/$debtId/pay',
        {}, // Empty body since it's just marking as paid
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return DebtSingleResponse.fromJson(responseBody);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to mark debt as paid');
      }
    } catch (e) {
      throw Exception('Error marking debt as paid: $e');
    }
  }

  /// Mark debt as unpaid - Keep using PUT method for consistency
  Future<DebtSingleResponse> markAsUnpaid(String debtId) async {
    try {
      final response = await _httpClient.put(
        '/debts/$debtId',
        {'vendor_payment_status': 'UNPAID'},
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return DebtSingleResponse.fromJson(responseBody);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            errorBody['message'] ?? 'Failed to mark debt as unpaid');
      }
    } catch (e) {
      throw Exception('Error marking debt as unpaid: $e');
    }
  }

  /// Get debt statistics
  Future<Map<String, dynamic>> getDebtStatistics() async {
    try {
      final response = await _httpClient.get(
        '/debts/statistics',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to fetch statistics');
      }
    } catch (e) {
      throw Exception('Error fetching debt statistics: $e');
    }
  }
}
