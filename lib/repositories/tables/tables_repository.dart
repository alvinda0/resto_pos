// repositories/table/table_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/models/auth/auth_model.dart';
import 'package:pos/models/tables/model_tables.dart';
import 'package:pos/config/config.dart'; // Import Config class Anda

abstract class TableRepository {
  Future<TableResponseModel> getTables(String token);
  Future<QrCodeModel> createTable(String token, String tableNumber);
  Future<void> deleteTable(String token, String tableId);
  Future<QrCodeModel> updateTable(
      String token, String tableId, Map<String, dynamic> data);
}

class TableRepositoryImpl implements TableRepository {
  final String baseUrl;
  final http.Client _client;

  // Constructor dengan default baseUrl dari Config
  TableRepositoryImpl({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? Config.publicBackEndUrl,
        _client = client ?? http.Client();

  // Factory constructor untuk kemudahan instantiation
  factory TableRepositoryImpl.create() {
    return TableRepositoryImpl();
  }

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<TableResponseModel> getTables(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/qr-codes'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return TableResponseModel.fromJson(jsonResponse);
      } else {
        final errorResponse = json.decode(response.body);
        throw ApiError(
          message: errorResponse['message'] ?? 'Failed to fetch tables',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Network error: $e');
    }
  }

  @override
  Future<QrCodeModel> createTable(String token, String tableNumber) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/v1/qr-codes'),
        headers: _getHeaders(token),
        body: json.encode({
          'table_number': tableNumber,
          'type': 'menu',
          'menu_url': 'https://example.com/',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return QrCodeModel.fromJson(jsonResponse['data']);
      } else {
        final errorResponse = json.decode(response.body);
        throw ApiError(
          message: errorResponse['message'] ?? 'Failed to create table',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Network error: $e');
    }
  }

  @override
  Future<void> deleteTable(String token, String tableId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/api/v1/qr-codes/$tableId'),
        headers: _getHeaders(token),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorResponse = json.decode(response.body);
        throw ApiError(
          message: errorResponse['message'] ?? 'Failed to delete table',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Network error: $e');
    }
  }

  @override
  Future<QrCodeModel> updateTable(
      String token, String tableId, Map<String, dynamic> data) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/api/v1/qr-codes/$tableId'),
        headers: _getHeaders(token),
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return QrCodeModel.fromJson(jsonResponse['data']);
      } else {
        final errorResponse = json.decode(response.body);
        throw ApiError(
          message: errorResponse['message'] ?? 'Failed to update table',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Network error: $e');
    }
  }

  // Method untuk dispose client jika diperlukan
  void dispose() {
    _client.close();
  }
}
