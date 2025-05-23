import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/config/config.dart';
import 'package:pos/models/dashboard/dashboard_model.dart';
import 'package:pos/models/auth/auth_model.dart';

class DashboardRepository {
  static const String baseUrl = '${Config.publicBackEndUrl}';

  Future<DashboardResponse> getDashboardStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/admin/dashboard/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return DashboardResponse.fromJson(jsonResponse);
      } else {
        final errorResponse = json.decode(response.body);
        throw ApiError(
          message: errorResponse['message'] ?? 'Failed to load dashboard',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
