import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/models/theme/theme_model.dart' as ThemeModel;
import 'package:pos/services/theme/theme_service.dart';

class ThemeController extends GetxController {
  final ThemeService _themeService = ThemeService.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Observable variables
  final RxList<ThemeModel.Theme> themes = <ThemeModel.Theme>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = false.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController primaryColorController = TextEditingController();
  final TextEditingController pageTitleController = TextEditingController();
  final RxBool isDefaultController = false.obs;
  final Rx<File?> selectedLogo = Rx<File?>(null);
  final Rx<File?> selectedFavicon = Rx<File?>(null);

  // Current theme being edited
  final Rx<ThemeModel.Theme?> currentTheme = Rx<ThemeModel.Theme?>(null);

  @override
  void onInit() {
    super.onInit();
    loadThemes();
  }

  @override
  void onClose() {
    nameController.dispose();
    primaryColorController.dispose();
    pageTitleController.dispose();
    super.onClose();
  }

  /// Load themes list
  Future<void> loadThemes({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        themes.clear();
      }

      isLoading.value = true;

      final response = await _themeService.getThemes(
        page: currentPage.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (response.success) {
        if (refresh) {
          themes.assignAll(response.data);
        } else {
          themes.addAll(response.data);
        }

        totalPages.value = response.metadata.totalPages;
        hasMore.value = currentPage.value < totalPages.value;
      } else {
        _showErrorSnackbar('Error', response.message);
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to load themes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search themes
  Future<void> searchThemes(String query) async {
    searchQuery.value = query;
    currentPage.value = 1;
    await loadThemes(refresh: true);
  }

  /// Load more themes (pagination)
  Future<void> loadMore() async {
    if (hasMore.value && !isLoading.value) {
      currentPage.value++;
      await loadThemes();
    }
  }

  /// Create new theme
  Future<void> createTheme() async {
    if (!_validateForm()) return;

    try {
      isCreating.value = true;

      final request = ThemeModel.CreateThemeRequest(
        name: nameController.text.trim(),
        primaryColor: primaryColorController.text.trim(),
        pageTitle: pageTitleController.text.trim(),
        isDefault: isDefaultController.value,
      );

      final response = await _themeService.createTheme(
        request: request,
        logoFile: selectedLogo.value,
        faviconFile: selectedFavicon.value,
      );

      if (response.success && response.data != null) {
        themes.insert(0, response.data!);
        _clearForm();
        Get.back(); // Close dialog/form
        _showSuccessSnackbar('Success', 'Theme created successfully');
      } else {
        _showErrorSnackbar('Error', response.message);
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to create theme: $e');
    } finally {
      isCreating.value = false;
    }
  }

  /// Update theme
  Future<void> updateTheme(String themeId) async {
    if (!_validateForm()) return;

    try {
      isUpdating.value = true;

      final response = await _themeService.updateTheme(
        themeId: themeId,
        name: nameController.text.trim(),
        primaryColor: primaryColorController.text.trim(),
        pageTitle: pageTitleController.text.trim(),
        isDefault: isDefaultController.value,
        logoFile: selectedLogo.value,
        faviconFile: selectedFavicon.value,
      );

      if (response.success && response.data != null) {
        final index = themes.indexWhere((t) => t.id == themeId);
        if (index != -1) {
          themes[index] = response.data!;
        }
        _clearForm();
        Get.back(); // Close dialog/form
        _showSuccessSnackbar('Success', 'Theme updated successfully');
      } else {
        _showErrorSnackbar('Error', response.message);
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to update theme: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  /// Delete theme with confirmation
  Future<void> deleteTheme(String themeId, String themeName) async {
    final confirm = await _showDeleteConfirmation(themeName);
    if (confirm == true) {
      await _performDelete(themeId);
    }
  }

  /// Show delete confirmation dialog
  Future<bool?> _showDeleteConfirmation(String themeName) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete theme "$themeName"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Perform actual delete operation
  Future<void> _performDelete(String themeId) async {
    try {
      isDeleting.value = true;

      final response = await _themeService.deleteTheme(themeId);

      if (response.success) {
        themes.removeWhere((t) => t.id == themeId);
        _showSuccessSnackbar('Success', 'Theme deleted successfully');
      } else {
        _showErrorSnackbar('Error', response.message);
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to delete theme: $e');
    } finally {
      isDeleting.value = false;
    }
  }

  /// Set theme as default
  Future<void> setDefaultTheme(String themeId, String themeName) async {
    try {
      final response = await _themeService.setDefaultTheme(themeId);

      if (response.success && response.data != null) {
        // Update all themes to not be default
        for (int i = 0; i < themes.length; i++) {
          if (themes[i].id == themeId) {
            themes[i] = response.data!;
          } else {
            themes[i] = themes[i].copyWith(isDefault: false);
          }
        }

        _showSuccessSnackbar('Success', 'Theme "$themeName" set as default');
      } else {
        _showErrorSnackbar('Error', response.message);
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to set default theme: $e');
    }
  }

  /// Pick logo image
  Future<void> pickLogo() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 600,
      );

      if (image != null) {
        selectedLogo.value = File(image.path);
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to pick logo: $e');
    }
  }

  /// Pick favicon image
  Future<void> pickFavicon() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 32,
        maxHeight: 32,
      );

      if (image != null) {
        selectedFavicon.value = File(image.path);
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to pick favicon: $e');
    }
  }

  /// Prepare form for editing - FIXED VERSION
  void prepareEdit(ThemeModel.Theme theme) {
    try {
      // Clear form first
      _clearForm();

      // Set current theme
      currentTheme.value = theme;

      // Use post frame callback to ensure UI is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Set form values
        nameController.text = theme.name;
        primaryColorController.text = theme.primaryColor;
        pageTitleController.text = theme.pageTitle;
        isDefaultController.value = theme.isDefault;
      });
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to prepare edit form: $e');
    }
  }

  /// Clear form - OPTIMIZED VERSION
  void _clearForm() {
    try {
      currentTheme.value = null;
      nameController.clear();
      primaryColorController.clear();
      pageTitleController.clear();
      isDefaultController.value = false;
      selectedLogo.value = null;
      selectedFavicon.value = null;
    } catch (e) {
      debugPrint('Error clearing form: $e');
    }
  }

  /// Validate form
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _showWarningSnackbar('Validation Error', 'Theme name is required');
      return false;
    }

    if (primaryColorController.text.trim().isEmpty) {
      _showWarningSnackbar('Validation Error', 'Primary color is required');
      return false;
    }

    if (pageTitleController.text.trim().isEmpty) {
      _showWarningSnackbar('Validation Error', 'Page title is required');
      return false;
    }

    // Validate color format
    final colorString = primaryColorController.text.trim();
    if (!_isValidColor(colorString)) {
      _showWarningSnackbar(
          'Validation Error', 'Invalid color format. Use #RRGGBB format');
      return false;
    }

    return true;
  }

  /// Validate color format
  bool _isValidColor(String colorString) {
    try {
      if (colorString.isEmpty) return false;

      // Remove # if present
      String color = colorString.replaceFirst('#', '');

      // Check if it's a valid hex color (6 characters)
      if (color.length != 6) return false;

      // Try to parse as hex
      int.parse(color, radix: 16);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Show success snackbar
  void _showSuccessSnackbar(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  /// Show warning snackbar
  void _showWarningSnackbar(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Refresh themes
  Future<void> refreshThemes() async {
    await loadThemes(refresh: true);
  }
}
