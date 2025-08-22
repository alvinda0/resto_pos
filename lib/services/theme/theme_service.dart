import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:pos/http_client.dart';
import 'package:pos/models/theme/theme_model.dart';

class ThemeService extends GetxService {
  static ThemeService get instance {
    if (!Get.isRegistered<ThemeService>()) {
      Get.put(ThemeService());
    }
    return Get.find<ThemeService>();
  }

  final HttpClient _httpClient = HttpClient.instance;
  final String _baseEndpoint = '/themes';

  /// Get list of themes with pagination
  Future<ThemeListResponse> getThemes({
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    try {
      final queryParameters = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await _httpClient.get(
        _baseEndpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ThemeListResponse.fromJson(json);
      } else {
        throw Exception('Failed to get themes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting themes: $e');
    }
  }

  /// Create new theme with multipart data
  Future<ThemeResponse> createTheme({
    required CreateThemeRequest request,
    File? logoFile,
    File? faviconFile,
  }) async {
    try {
      final fields = request.toMultipartFields();
      final files = <String, File>{};

      if (logoFile != null) {
        files['logo'] = logoFile;
      }

      if (faviconFile != null) {
        files['favicon'] = faviconFile;
      }

      final response = await _httpClient.postMultipart(
        _baseEndpoint,
        fields,
        files: files.isNotEmpty ? files : null,
      );

      final json = jsonDecode(response.body);
      return ThemeResponse.fromJson(json);
    } catch (e) {
      throw Exception('Error creating theme: $e');
    }
  }

  /// Update theme
  Future<ThemeResponse> updateTheme({
    required String themeId,
    String? name,
    String? primaryColor,
    String? pageTitle,
    bool? isDefault,
    File? logoFile,
    File? faviconFile,
  }) async {
    try {
      // If files are provided, use multipart request
      if (logoFile != null || faviconFile != null) {
        final fields = <String, String>{};
        final files = <String, File>{};

        if (name != null) fields['name'] = name;
        if (primaryColor != null) fields['primaryColor'] = primaryColor;
        if (pageTitle != null) fields['pageTitle'] = pageTitle;
        if (isDefault != null) fields['isDefault'] = isDefault.toString();

        if (logoFile != null) files['logo'] = logoFile;
        if (faviconFile != null) files['favicon'] = faviconFile;

        final response = await _httpClient.putMultipart(
          '$_baseEndpoint/$themeId',
          fields,
          files: files,
        );

        final json = jsonDecode(response.body);
        return ThemeResponse.fromJson(json);
      } else {
        // Use regular JSON request
        final data = <String, dynamic>{};

        if (name != null) data['name'] = name;
        if (primaryColor != null) data['primary_color'] = primaryColor;
        if (pageTitle != null) data['page_title'] = pageTitle;
        if (isDefault != null) data['is_default'] = isDefault;

        final response = await _httpClient.put(
          '$_baseEndpoint/$themeId',
          data,
        );

        final json = jsonDecode(response.body);
        return ThemeResponse.fromJson(json);
      }
    } catch (e) {
      throw Exception('Error updating theme: $e');
    }
  }

  /// Delete theme
  Future<ThemeResponse> deleteTheme(String themeId) async {
    try {
      final response = await _httpClient.delete('$_baseEndpoint/$themeId');
      final json = jsonDecode(response.body);
      return ThemeResponse.fromJson(json);
    } catch (e) {
      throw Exception('Error deleting theme: $e');
    }
  }

  /// Get single theme by ID
  Future<ThemeResponse> getTheme(String themeId) async {
    try {
      final response = await _httpClient.get('$_baseEndpoint/$themeId');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ThemeResponse.fromJson(json);
      } else {
        throw Exception('Failed to get theme: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting theme: $e');
    }
  }

  /// Set theme as default
  Future<ThemeResponse> setDefaultTheme(String themeId) async {
    try {
      return await updateTheme(
        themeId: themeId,
        isDefault: true,
      );
    } catch (e) {
      throw Exception('Error setting default theme: $e');
    }
  }
}
