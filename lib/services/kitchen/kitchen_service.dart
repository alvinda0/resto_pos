// services/kitchen_service.dart
import 'dart:convert';
import 'package:pos/http_client.dart';
import 'package:pos/models/kitchen/complete_order_model.dart';
import 'package:pos/models/kitchen/kitchen_model.dart';

class KitchenService {
  final HttpClient _httpClient = HttpClient.instance;

  // Dapatkan semua data kitchen dengan filter status pesanan
  Future<KitchenResponse> getKitchens({
    String? statusPesanan, // Parameter yang benar sesuai API
    String? method,
    int? page,
    int? limit,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {};

      // Filter berdasarkan status pesanan jika ada
      if (statusPesanan != null && statusPesanan.isNotEmpty) {
        queryParams['status_pesanan'] = statusPesanan;
      } else {
        // Default tampilkan pesanan yang sudah PROCESSED untuk dapur
        // Jika ingin tampilkan semua status, hapus baris ini
        queryParams['status_pesanan'] = 'PROCESSED';
      }

      if (method != null && method.isNotEmpty) {
        queryParams['method'] = method;
      }

      if (page != null) {
        queryParams['page'] = page.toString();
      }

      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      // Build endpoint dengan query parameters
      String endpoint = '/orders';
      if (queryParams.isNotEmpty) {
        final queryString =
            queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
        endpoint += '?$queryString';
      }

      final response = await _httpClient.get(endpoint);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Konversi API response ke format KitchenResponse
        final List<dynamic> ordersData = jsonData['data'];
        final List<KitchenModel> kitchens =
            ordersData.map((order) => KitchenModel.fromJson(order)).toList();

        // Ekstrak metadata untuk pagination
        final metadata = jsonData['metadata'];

        return KitchenResponse(
          message: jsonData['message'] ?? 'Berhasil',
          status: jsonData['status'] ?? 200,
          data: kitchens,
          metadata:
              metadata != null ? PaginationMetadata.fromJson(metadata) : null,
        );
      } else {
        throw Exception('Gagal memuat data dapur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan saat mengambil data dapur: $e');
    }
  }

  // Method untuk mendapatkan detail pesanan
  Future<KitchenModel> getOrderDetail(String orderId) async {
    try {
      final response = await _httpClient.get('/orders/$orderId');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return KitchenModel.fromJson(jsonData['data']);
      } else {
        throw Exception('Gagal memuat detail pesanan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan saat mengambil detail pesanan: $e');
    }
  }

  // Method untuk menyelesaikan pesanan
  Future<CompleteOrderResponse> completeOrder(String orderId) async {
    try {
      // Perbaiki: tambahkan body parameter (bisa kosong jika tidak diperlukan data)
      final response = await _httpClient.post(
        '/orders/$orderId/complete',
        {}, // Body kosong atau bisa ditambahkan data jika diperlukan
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CompleteOrderResponse.fromJson(jsonData);
      } else {
        final jsonData = jsonDecode(response.body);
        throw Exception(jsonData['message'] ??
            'Gagal menyelesaikan pesanan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan saat menyelesaikan pesanan: $e');
    }
  }
}
