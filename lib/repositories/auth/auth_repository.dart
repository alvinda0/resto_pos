import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/config/config.dart';
import 'package:pos/models/auth/auth_model.dart';

class AuthRepository {
  static const String baseUrl = '${Config.publicBackEndUrl}';

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return LoginResponse.fromJson(jsonResponse);
      } else {
        final errorResponse = json.decode(response.body);
        throw ApiError(
          message: errorResponse['message'] ?? 'Login failed',
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
