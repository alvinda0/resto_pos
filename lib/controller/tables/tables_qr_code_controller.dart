// controllers/qr_code_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/tables/model_tables.dart';
import 'package:pos/services/tables/tables_qr_code_service.dart';
import 'package:pos/storage_service.dart';

class QrCodeController extends GetxController {
  static QrCodeController get instance {
    if (!Get.isRegistered<QrCodeController>()) {
      Get.put(QrCodeController());
    }
    return Get.find<QrCodeController>();
  }

  final QrCodeService _qrCodeService = QrCodeService.instance;
  final StorageService _storage = StorageService.instance;

  // Observable variables
  final RxList<QrCodeModel> qrCodes = <QrCodeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rxn<QrCodeModel> selectedQrCode = Rxn<QrCodeModel>();

  // Form controllers
  final TextEditingController tableNumberController = TextEditingController();
  final TextEditingController menuUrlController = TextEditingController();
  final RxString selectedType = 'menu'.obs;
  final Rxn<DateTime> selectedExpiresAt = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchQrCodes();
  }

  @override
  void onClose() {
    tableNumberController.dispose();
    menuUrlController.dispose();
    super.onClose();
  }

  // Get current store ID
  String? get currentStoreId => _storage.getString('store_id');

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

  // Fetch QR codes by store
  Future<void> fetchQrCodesByStore(String storeId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final codes = await _qrCodeService.getQrCodesByStore(storeId);
      qrCodes.assignAll(codes);
    } catch (e) {
      String cleanError = _extractCleanErrorMessage(e.toString());
      error.value = cleanError;
      _showSnackBar('Error', cleanError, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Get QR code by ID
  Future<void> fetchQrCodeById(String id) async {
    try {
      isLoading.value = true;
      error.value = '';

      final qrCode = await _qrCodeService.getQrCodeById(id);
      selectedQrCode.value = qrCode;
    } catch (e) {
      String cleanError = _extractCleanErrorMessage(e.toString());
      error.value = cleanError;
      _showSnackBar('Error', cleanError, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Create new QR code
  Future<void> createQrCode({
    String? storeId,
  }) async {
    try {
      if (!_validateForm()) return;

      isLoading.value = true;
      error.value = '';

      // Use provided storeId or get current one
      final currentStoreId = storeId ?? this.currentStoreId;
      if (currentStoreId == null) {
        throw Exception('Store ID tidak ditemukan. Silakan login ulang.');
      }

      final qrCode = await _qrCodeService.createQrCode(
        storeId: currentStoreId,
        tableNumber: tableNumberController.text,
        type: selectedType.value,
        menuUrl: menuUrlController.text,
        expiresAt: selectedExpiresAt.value ??
            DateTime.now().add(const Duration(days: 365)),
      );

      qrCodes.add(qrCode);
      _clearForm();
      _showSnackBar('Sukses', 'QR code berhasil dibuat');

      Get.back(); // Close dialog/bottom sheet
    } catch (e) {
      String cleanError = _extractCleanErrorMessage(e.toString());
      error.value = cleanError;
      _showSnackBar('Error', cleanError, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Update QR code
  Future<void> updateQrCode(String id) async {
    try {
      if (!_validateForm()) return;

      isLoading.value = true;
      error.value = '';

      final updatedQrCode = await _qrCodeService.updateQrCode(
        id: id,
        tableNumber: tableNumberController.text,
        type: selectedType.value,
        menuUrl: menuUrlController.text,
        expiresAt: selectedExpiresAt.value,
      );

      final index = qrCodes.indexWhere((qr) => qr.id == id);
      if (index != -1) {
        qrCodes[index] = updatedQrCode;
      }

      _clearForm();
      _showSnackBar('Sukses', 'QR code berhasil diupdate');

      Get.back(); // Close dialog/bottom sheet
    } catch (e) {
      String cleanError = _extractCleanErrorMessage(e.toString());
      error.value = cleanError;
      _showSnackBar('Error', cleanError, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Delete QR code
  Future<void> deleteQrCode(String id) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin menghapus QR code ini?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isLoading.value = true;
      error.value = '';

      final success = await _qrCodeService.deleteQrCode(id);

      if (success) {
        qrCodes.removeWhere((qr) => qr.id == id);
        _showSnackBar('Sukses', 'QR code berhasil dihapus');
      }
    } catch (e) {
      String cleanError = _extractCleanErrorMessage(e.toString());
      error.value = cleanError;
      _showSnackBar('Error', cleanError, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Find QR code by table number
  Future<void> findQrCodeByTableNumber(String tableNumber) async {
    try {
      isLoading.value = true;
      error.value = '';

      final qrCode = await _qrCodeService.getQrCodeByTableNumber(tableNumber);
      selectedQrCode.value = qrCode;

      if (qrCode == null) {
        _showSnackBar(
            'Info', 'QR code untuk meja $tableNumber tidak ditemukan');
      }
    } catch (e) {
      String cleanError = _extractCleanErrorMessage(e.toString());
      error.value = cleanError;
      _showSnackBar('Error', cleanError, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Set form data for editing
  void setFormData(QrCodeModel qrCode) {
    tableNumberController.text = qrCode.tableNumber;
    menuUrlController.text = qrCode.menuUrl;
    selectedType.value = qrCode.type;
    selectedExpiresAt.value = qrCode.expiresAt;
    selectedQrCode.value = qrCode;
  }

  // Clear form
  void _clearForm() {
    tableNumberController.clear();
    menuUrlController.clear();
    selectedType.value = 'menu';
    selectedExpiresAt.value = null;
    selectedQrCode.value = null;
  }

  // Validate form
  bool _validateForm() {
    if (tableNumberController.text.isEmpty) {
      _showSnackBar('Error', 'Nomor meja harus diisi', isError: true);
      return false;
    }

    if (menuUrlController.text.isEmpty) {
      _showSnackBar('Error', 'URL menu harus diisi', isError: true);
      return false;
    }

    return true;
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

  // Check if QR code is expired
  bool isExpired(QrCodeModel qrCode) {
    return DateTime.now().isAfter(qrCode.expiresAt);
  }

  // Get QR codes count
  int get qrCodesCount => qrCodes.length;

  // Get active QR codes count
  int get activeQrCodesCount => qrCodes.where((qr) => !isExpired(qr)).length;

  // Get expired QR codes count
  int get expiredQrCodesCount => qrCodes.where((qr) => isExpired(qr)).length;
}
