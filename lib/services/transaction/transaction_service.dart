// services/transaction_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/transaction/transaction_model.dart';

class TransactionService extends GetxService {
  static TransactionService get instance {
    if (!Get.isRegistered<TransactionService>()) {
      Get.put(TransactionService());
    }
    return Get.find<TransactionService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  /// Get transactions with pagination
  Future<TransactionResponse> getTransactions({
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
        '/transactions',
        queryParameters: queryParameters,
        storeId: storeId,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TransactionResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting transactions: $e');
    }
  }

  /// Export tax reports
  Future<Map<String, dynamic>?> exportTaxReport({
    required DateTime startDate,
    required DateTime endDate,
    double? newTaxRate,
    bool realTax = false,
  }) async {
    try {
      // Format dates to match API expectation (with Z timezone)
      final String startTimeFormatted =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}T00:00:00Z';
      final String endTimeFormatted =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}T23:59:59Z';

      Map<String, dynamic> requestBody;

      if (realTax) {
        // Real Tax format
        requestBody = {
          'start_time': startTimeFormatted,
          'end_time': endTimeFormatted,
          'new_tax_rate': 0,
          'real_tax': true,
        };
      } else {
        // Manipulated Tax format
        requestBody = {
          'start_time': startTimeFormatted,
          'end_time': endTimeFormatted,
          'new_tax_rate': newTaxRate ?? 0.05, // Default 5% if not provided
        };
        // Don't include real_tax field for manipulated tax
      }

      final response = await _httpClient.post(
        '/tax-reports/export',
        requestBody,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Handle different response formats
        if (jsonData['status'] == 'success' || jsonData['success'] == true) {
          String? downloadUrl;

          // Try different possible locations for download URL
          if (jsonData['download_url'] != null) {
            downloadUrl = jsonData['download_url'] as String;
          } else if (jsonData['data'] != null &&
              jsonData['data']['download_url'] != null) {
            downloadUrl = jsonData['data']['download_url'] as String;
          } else if (jsonData['url'] != null) {
            downloadUrl = jsonData['url'] as String;
          }

          return {
            'success': true,
            'download_url': downloadUrl,
            'message': jsonData['message'] ?? 'Export successful',
          };
        }
      }

      // Handle error responses
      String errorMessage = 'Failed to export tax report';

      if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ??
              errorData['error'] ??
              'Bad Request - Invalid parameters';
        } catch (e) {
          errorMessage = 'Bad Request - Invalid request format';
        }
      } else if (response.statusCode == 401) {
        errorMessage = 'Unauthorized - Please login again';
      } else if (response.statusCode == 403) {
        errorMessage = 'Forbidden - Access denied';
      } else if (response.statusCode == 404) {
        errorMessage = 'Not Found - Export endpoint not available';
      } else if (response.statusCode >= 500) {
        errorMessage = 'Server Error - Please try again later';
      }

      return {
        'success': false,
        'message': '$errorMessage (Status: ${response.statusCode})',
        'status_code': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Get transaction by ID
  Future<Transaction?> getTransactionById(String transactionId,
      {String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '/transactions/$transactionId',
        storeId: storeId,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] && jsonData['data'] != null) {
          return Transaction.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error getting transaction: $e');
    }
  }

  /// Search transactions (if API supports search)
  Future<TransactionResponse> searchTransactions({
    required String query,
    int page = 1,
    int limit = 10,
    String? storeId,
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
        'search': query,
      };

      final response = await _httpClient.get(
        '/transactions',
        queryParameters: queryParameters,
        storeId: storeId,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TransactionResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to search transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching transactions: $e');
    }
  }

  /// Get transactions by date range
  Future<TransactionResponse> getTransactionsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
    String? storeId,
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (startDate != null) {
        queryParameters['start_date'] =
            startDate.toIso8601String().split('T')[0];
      }

      if (endDate != null) {
        queryParameters['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _httpClient.get(
        '/transactions',
        queryParameters: queryParameters,
        storeId: storeId,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TransactionResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load transactions by date range: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting transactions by date range: $e');
    }
  }

  /// Get transaction statistics (if API supports it)
  Future<Map<String, dynamic>?> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
    String? storeId,
  }) async {
    try {
      final queryParameters = <String, String>{};

      if (startDate != null) {
        queryParameters['start_date'] =
            startDate.toIso8601String().split('T')[0];
      }

      if (endDate != null) {
        queryParameters['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _httpClient.get(
        '/transactions/stats',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
        storeId: storeId,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          return jsonData['data'];
        }
      }
      return null;
    } catch (e) {
      // Stats endpoint might not exist, return null instead of throwing
      return null;
    }
  }

  /// Helper method to format currency
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  /// Helper method to calculate total from items
  double calculateItemsTotal(List<TransactionItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Helper method to get transaction type/status
  String getTransactionStatus(Transaction transaction) {
    // Since API doesn't provide status, we can determine based on data
    if (transaction.totalAmount > 0) {
      return 'Completed';
    } else {
      return 'Pending';
    }
  }

  /// Export transactions (placeholder for future implementation)
  Future<bool> exportTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'excel', // excel, pdf, csv
    String? storeId,
  }) async {
    try {
      // This would be implemented when export API is available
      final queryParameters = {
        'format': format,
      };

      if (startDate != null) {
        queryParameters['start_date'] =
            startDate.toIso8601String().split('T')[0];
      }

      if (endDate != null) {
        queryParameters['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _httpClient.get(
        '/transactions/export',
        queryParameters: queryParameters,
        storeId: storeId,
        requireAuth: true,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
