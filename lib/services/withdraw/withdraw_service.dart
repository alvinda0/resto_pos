// services/withdrawal_service.dart
import 'dart:convert';

import 'package:pos/http_client.dart';
import 'package:pos/models/withdraw/withdraw_model.dart';

class WithdrawalService {
  final HttpClient _httpClient = HttpClient.instance;

  // Get all withdrawals
  Future<WithdrawalResponse> getWithdrawals({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {};

      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sort_order'] = sortOrder;
      }

      // Build query string
      String queryString = '';
      if (queryParams.isNotEmpty) {
        queryString = '?' +
            queryParams.entries
                .map((entry) =>
                    '${entry.key}=${Uri.encodeComponent(entry.value)}')
                .join('&');
      }

      final response = await _httpClient.get(
        '/wallets/withdrawals$queryString',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return WithdrawalResponse.fromJson(jsonResponse);
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ??
            'Failed to fetch withdrawals';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error fetching withdrawals: ${e.toString()}');
    }
  }

  // Update withdrawal status
  Future<WithdrawalUpdateResponse> updateWithdrawalStatus(
    String withdrawalId,
    String status,
    String note,
  ) async {
    try {
      final request = WithdrawalUpdateRequest(
        status: status,
        note: note,
      );

      final response = await _httpClient.patch(
        '/wallets/withdraw/$withdrawalId',
        request.toJson(),
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return WithdrawalUpdateResponse.fromJson(jsonResponse);
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ??
            'Failed to update withdrawal status';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error updating withdrawal status: ${e.toString()}');
    }
  }

  // Approve withdrawal
  Future<WithdrawalUpdateResponse> approveWithdrawal(
    String withdrawalId, {
    String note = 'Approved by admin',
  }) async {
    return await updateWithdrawalStatus(withdrawalId, 'APPROVED', note);
  }

  // Reject withdrawal
  Future<WithdrawalUpdateResponse> rejectWithdrawal(
    String withdrawalId, {
    String note = 'Rejected by admin',
  }) async {
    return await updateWithdrawalStatus(withdrawalId, 'REJECTED', note);
  }

  // Get withdrawal by ID
  Future<WithdrawalModel> getWithdrawalById(String withdrawalId) async {
    try {
      final response = await _httpClient.get(
        '/wallets/withdraw/$withdrawalId',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return WithdrawalModel.fromJson(jsonResponse['data']);
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ??
            'Failed to fetch withdrawal';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error fetching withdrawal: ${e.toString()}');
    }
  }

  // Get withdrawals by status
  Future<WithdrawalResponse> getWithdrawalsByStatus(
    String status, {
    int page = 1,
    int limit = 10,
  }) async {
    return await getWithdrawals(
      page: page,
      limit: limit,
      status: status,
    );
  }

  // Search withdrawals
  Future<WithdrawalResponse> searchWithdrawals(
    String searchTerm, {
    int page = 1,
    int limit = 10,
  }) async {
    return await getWithdrawals(
      page: page,
      limit: limit,
      search: searchTerm,
    );
  }
}
