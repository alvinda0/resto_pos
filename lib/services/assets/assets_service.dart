import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pos/http_client.dart';
import 'package:pos/models/assets/assets_model.dart';

class AssetService extends GetxService {
  static AssetService get instance {
    if (!Get.isRegistered<AssetService>()) {
      Get.put(AssetService());
    }
    return Get.find<AssetService>();
  }

  final HttpClient _httpClient = HttpClient.instance;

  // Get all assets with pagination and search
  Future<AssetResponse> getAssets({
    int page = 1,
    int limit = 100,
    String search = '',
    String? storeId,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'search': search,
      };

      final response = await _httpClient.get(
        '/assets',
        queryParameters: queryParams,
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AssetResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to get assets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting assets: $e');
    }
  }

  // Get single asset by ID
  Future<AssetSingleResponse> getAsset(String id, {String? storeId}) async {
    try {
      final response = await _httpClient.get(
        '/assets/$id',
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AssetSingleResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to get asset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting asset: $e');
    }
  }

  // Create new asset
  Future<AssetSingleResponse> createAsset(
    Asset asset, {
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.post(
        '/assets',
        asset.toJson(),
        storeId: storeId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return AssetSingleResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to create asset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating asset: $e');
    }
  }

  // Update existing asset
  Future<AssetSingleResponse> updateAsset(
    String id,
    Asset asset, {
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.put(
        '/assets/$id',
        asset.toUpdateJson(),
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AssetSingleResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to update asset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating asset: $e');
    }
  }

  // Delete asset
  Future<AssetDeleteResponse> deleteAsset(
    String id, {
    String? storeId,
  }) async {
    try {
      final response = await _httpClient.delete(
        '/assets/$id',
        storeId: storeId,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AssetDeleteResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to delete asset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting asset: $e');
    }
  }

  // Batch operations
  Future<List<AssetSingleResponse>> createMultipleAssets(
    List<Asset> assets, {
    String? storeId,
  }) async {
    final List<AssetSingleResponse> responses = [];

    for (final asset in assets) {
      try {
        final response = await createAsset(asset, storeId: storeId);
        responses.add(response);
      } catch (e) {
        // Continue with other assets even if one fails
        print('Failed to create asset ${asset.name}: $e');
      }
    }

    return responses;
  }

  Future<List<AssetDeleteResponse>> deleteMultipleAssets(
    List<String> assetIds, {
    String? storeId,
  }) async {
    final List<AssetDeleteResponse> responses = [];

    for (final id in assetIds) {
      try {
        final response = await deleteAsset(id, storeId: storeId);
        responses.add(response);
      } catch (e) {
        // Continue with other assets even if one fails
        print('Failed to delete asset $id: $e');
      }
    }

    return responses;
  }

  // Helper methods for filtering and validation
  List<Asset> filterAssetsByType(List<Asset> assets, String type) {
    return assets.where((asset) => asset.type == type).toList();
  }

  List<Asset> filterAssetsByCategory(List<Asset> assets, String category) {
    return assets.where((asset) => asset.category == category).toList();
  }

  List<Asset> filterAssetsByStatus(List<Asset> assets, String status) {
    return assets.where((asset) => asset.status == status).toList();
  }

  bool validateAsset(Asset asset) {
    // Basic validation
    if (asset.name.isEmpty) return false;
    if (asset.category.isEmpty) return false;
    if (asset.cost <= 0) return false;
    if (asset.usefulLifeMonths <= 0) return false;
    if (!AssetType.all.contains(asset.type)) return false;
    if (!DepreciationMethod.all.contains(asset.depMethod)) return false;

    // Type-specific validation
    if (asset.type == AssetType.prepaidExpense &&
        asset.coverageEndDate == null) {
      return false;
    }

    return true;
  }

  // Calculate current book value
  double calculateBookValue(Asset asset) {
    return (asset.cost - asset.accumulatedDepreciation).toDouble();
  }

  // Calculate depreciation percentage
  double calculateDepreciationPercentage(Asset asset) {
    if (asset.cost == 0) return 0;
    return (asset.accumulatedDepreciation / asset.cost) * 100;
  }

  // Get unique categories from assets list
  List<String> getUniqueCategories(List<Asset> assets) {
    final categories = assets.map((asset) => asset.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Format currency
  String formatCurrency(int amount) {
    // Indonesian Rupiah formatting
    final formatter = amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]}.',
        );
    return 'Rp $formatter';
  }
}
