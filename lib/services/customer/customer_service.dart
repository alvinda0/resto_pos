import 'dart:convert';
import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/customer/customer_model.dart';

class CustomerService extends GetxService {
  static CustomerService get instance {
    if (!Get.isRegistered<CustomerService>()) {
      Get.put(CustomerService());
    }
    return Get.find<CustomerService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  /// Get all customers with pagination
  Future<CustomerResponse> getAllCustomers({
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
        '/customers',
        requireAuth: true,
        storeId: storeId,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return CustomerResponse.fromJson(jsonResponse);
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Failed to fetch customers';
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      if (e.toString().contains('HTTP')) {
        rethrow;
      }
      throw Exception(
          'Network error: Unable to fetch customers. Please check your connection.');
    }
  }

  /// Delete customer by ID
  Future<DeleteCustomerResponse> deleteCustomer(
    String customerId, {
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.delete(
        '/customers/$customerId',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return DeleteCustomerResponse.fromJson(jsonResponse);
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Failed to delete customer';
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      if (e.toString().contains('HTTP')) {
        rethrow;
      }
      throw Exception(
          'Network error: Unable to delete customer. Please check your connection.');
    }
  }

  /// Get customer by ID (if needed in the future)
  Future<Customer> getCustomerById(
    String customerId, {
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.get(
        '/customers/$customerId',
        requireAuth: true,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Customer.fromJson(jsonResponse['data']);
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Failed to fetch customer';
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      if (e.toString().contains('HTTP')) {
        rethrow;
      }
      throw Exception(
          'Network error: Unable to fetch customer. Please check your connection.');
    }
  }
}
