// controllers/qr_code_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/tables/model_tables.dart';
import 'package:pos/services/tables/tables_qr_code_service.dart';

class QrCodeController extends GetxController {
  static QrCodeController get instance {
    if (!Get.isRegistered<QrCodeController>()) {
      Get.put(QrCodeController());
    }
    return Get.find<QrCodeController>();
  }

  final QrCodeService _qrCodeService = QrCodeService.instance;

  // Observable variables
  final RxList<QrCodeModel> qrCodes = <QrCodeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchQrCodes();
  }

  // Fetch all QR codes
  Future<void> fetchQrCodes() async {
    try {
      isLoading.value = true;
      error.value = '';

      final codes = await _qrCodeService.getQrCodes();
      qrCodes.assignAll(codes);
    } catch (e) {
      // Extract clean error message
      String cleanError = _extractCleanErrorMessage(e.toString());
      error.value = cleanError;
      _showSnackBar('Error', cleanError, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Extract clean error message
  String _extractCleanErrorMessage(String errorMessage) {
    // Remove "Exception: " prefix if present
    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring(11);
    }

    // Handle nested exception messages
    if (errorMessage.contains('Exception: ')) {
      final parts = errorMessage.split('Exception: ');
      if (parts.length > 1) {
        // Get the last (most specific) error message
        errorMessage = parts.last.trim();
      }
    }

    // Remove any "Error saat" prefixes for cleaner message
    if (errorMessage.startsWith('Error saat ')) {
      errorMessage = errorMessage.substring(11);
    }

    return errorMessage;
  }

  // Show snackbar
  void _showSnackBar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchQrCodes();
  }

  // Get QR codes count
  int get qrCodesCount => qrCodes.length;
}
