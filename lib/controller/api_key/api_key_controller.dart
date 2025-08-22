// controllers/api_key_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/api_key/api_key_model.dart';
import 'package:pos/services/api_key/api_key_service.dart';

class ApiKeyController extends GetxController {
  // Direct instantiation instead of dependency injection
  final ApiKeyService _apiKeyService = ApiKeyService.instance;

  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final callbackUrlController = TextEditingController();
  final keyController = TextEditingController();
  final secretController = TextEditingController();

  // Observable variables
  final RxList<ApiKeyModel> apiKeys = <ApiKeyModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final Rx<ApiKeyModel?> currentApiKey = Rx<ApiKeyModel?>(null);
  final RxBool isEditMode = false.obs;

  // Form validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool showApiKey = false.obs;
  final RxBool showSecretKey = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadApiKeys();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    callbackUrlController.dispose();
    keyController.dispose();
    secretController.dispose();
    super.onClose();
  }

  /// Load all API keys
  Future<void> loadApiKeys() async {
    try {
      isLoading.value = true;
      final keys = await _apiKeyService.getApiKeys();
      apiKeys.value = keys;

      // Check if we have any API key and set it as current
      if (keys.isNotEmpty) {
        setCurrentApiKey(keys.first);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat API keys: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Set current API key and populate form
  void setCurrentApiKey(ApiKeyModel apiKey) {
    currentApiKey.value = apiKey;
    isEditMode.value = true;

    // Populate form fields
    nameController.text = apiKey.name;
    descriptionController.text = apiKey.description ?? '';
    callbackUrlController.text = apiKey.callbackUrl ?? '';
    keyController.text = apiKey.key ?? '';
    secretController.text = apiKey.secret ?? '';
  }

  /// Clear form and reset to create mode
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    callbackUrlController.clear();
    keyController.clear();
    secretController.clear();

    currentApiKey.value = null;
    isEditMode.value = false;
    showApiKey.value = false;
    showSecretKey.value = false;
  }

  /// Validate form
  bool validateForm() {
    if (formKey.currentState == null) return false;
    return formKey.currentState!.validate();
  }

  /// Create or update API key
  Future<void> saveApiKey() async {
    if (!validateForm()) return;

    try {
      isSubmitting.value = true;

      final apiKey = ApiKeyModel(
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        callbackUrl: callbackUrlController.text.trim().isNotEmpty
            ? callbackUrlController.text.trim()
            : null,
        key: keyController.text.trim().isNotEmpty
            ? keyController.text.trim()
            : null,
        secret: secretController.text.trim().isNotEmpty
            ? secretController.text.trim()
            : null,
      );

      if (isEditMode.value && currentApiKey.value != null) {
        // Update existing API key
        final updatedKey = await _apiKeyService.updateApiKey(
          currentApiKey.value!.id!,
          apiKey,
        );

        // Update in the list
        final index = apiKeys.indexWhere((k) => k.id == updatedKey.id);
        if (index != -1) {
          apiKeys[index] = updatedKey;
        }

        Get.snackbar(
          'Sukses',
          'API Key berhasil diperbarui',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Create new API key
        final newKey = await _apiKeyService.createApiKey(apiKey);
        apiKeys.add(newKey);
        setCurrentApiKey(newKey);

        Get.snackbar(
          'Sukses',
          'API Key berhasil dibuat',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan API Key: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete current API key
  Future<void> deleteApiKey() async {
    if (currentApiKey.value?.id == null) return;

    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Konfirmasi Hapus'),
              content: Text(
                  'Apakah Anda yakin ingin menghapus API Key "${currentApiKey.value!.name}"?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirmed) return;

      isSubmitting.value = true;

      final success =
          await _apiKeyService.deleteApiKey(currentApiKey.value!.id!);

      if (success) {
        // Remove from list
        apiKeys.removeWhere((k) => k.id == currentApiKey.value!.id);

        // Clear form
        clearForm();

        Get.snackbar(
          'Sukses',
          'API Key berhasil dihapus',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus API Key: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Toggle API key visibility
  void toggleApiKeyVisibility() {
    showApiKey.value = !showApiKey.value;
  }

  /// Toggle secret key visibility
  void toggleSecretKeyVisibility() {
    showSecretKey.value = !showSecretKey.value;
  }

  /// Check if we have existing data
  bool get hasExistingData => currentApiKey.value != null && isEditMode.value;

  /// Get button text based on mode
  String get buttonText => hasExistingData ? 'Hapus' : 'Simpan';

  /// Get button color based on mode
  Color get buttonColor => hasExistingData ? Colors.red : Colors.blue;

  /// Handle button press (save or delete)
  Future<void> handleButtonPress() async {
    if (hasExistingData) {
      await deleteApiKey();
    } else {
      await saveApiKey();
    }
  }
}
