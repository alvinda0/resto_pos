// lib/controllers/qr_code_controller.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/tables/model_tables.dart';
import 'package:pos/services/tables/tables_qr_code_service.dart';

class QRCodeController extends GetxController {
  final QRCodeService _qrCodeService = QRCodeService();

  // Observable variables
  final RxList<QRCode> qrCodes = <QRCode>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreatingQR = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxBool hasMoreData = true.obs;

  // Form controllers for creating QR codes
  final TextEditingController tableNumberController = TextEditingController();
  final TextEditingController menuUrlController = TextEditingController();
  final TextEditingController bulkTableCountController =
      TextEditingController();
  final TextEditingController bulkStartNumberController =
      TextEditingController();

  // Form variables
  final RxString selectedType = 'menu'.obs;
  final Rx<DateTime?> selectedExpiryDate = Rx<DateTime?>(null);
  final RxBool hasExpiryDate = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadQRCodes();

    // Set default values
    menuUrlController.text = 'https://www.sibayar.co.id';
    bulkStartNumberController.text = '1';
    bulkTableCountController.text = '5';
  }

  @override
  void onClose() {
    tableNumberController.dispose();
    menuUrlController.dispose();
    bulkTableCountController.dispose();
    bulkStartNumberController.dispose();
    super.onClose();
  }

  // Load QR codes with pagination
  Future<void> loadQRCodes({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      qrCodes.clear();
    }

    isLoading.value = true;

    try {
      final response = await _qrCodeService.getQRCodes(
        page: currentPage.value,
        limit: 100,
        search: searchQuery.value,
      );

      if (refresh) {
        qrCodes.assignAll(response.qrcodes);
      } else {
        qrCodes.addAll(response.qrcodes);
      }

      totalPages.value = response.metadata.totalPages;
      totalItems.value = response.metadata.total;
      hasMoreData.value = currentPage.value < totalPages.value;

      if (response.qrcodes.isNotEmpty) {
        currentPage.value++;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Search QR codes
  Future<void> searchQRCodes(String query) async {
    searchQuery.value = query;
    await loadQRCodes(refresh: true);
  }

  // Create single QR code using bulk API with table_count = 1
  Future<void> createSingleQRCode() async {
    if (!_validateSingleQRForm()) return;

    isCreatingQR.value = true;

    try {
      // Parse table number to get start_number
      final startNumber = int.tryParse(tableNumberController.text.trim()) ?? 1;

      final request = BulkCreateQRCodeRequest(
        tableCount: 1, // Single QR code
        startNumber: startNumber,
        type: selectedType.value,
        menuUrl: menuUrlController.text.trim(),
        expiresAt: hasExpiryDate.value
            ? (selectedExpiryDate.value ??
                DateTime.now().add(const Duration(days: 365)))
            : DateTime.now().add(const Duration(days: 365)),
      );

      final response = await _qrCodeService.createQRCodes(request: request);

      // Add new QR code to the beginning of the list
      qrCodes.insertAll(0, response.data);
      totalItems.value += response.data.length;

      // Clear form
      _clearSingleQRForm();

      Get.back(); // Close dialog/bottom sheet
      Get.snackbar(
        'Success',
        'QR Code created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreatingQR.value = false;
    }
  }

  // Create bulk QR codes
  Future<void> createBulkQRCodes() async {
    if (!_validateBulkQRForm()) return;

    isCreatingQR.value = true;

    try {
      final request = BulkCreateQRCodeRequest(
        tableCount: int.parse(bulkTableCountController.text.trim()),
        startNumber: int.parse(bulkStartNumberController.text.trim()),
        type: selectedType.value,
        menuUrl: menuUrlController.text.trim(),
        expiresAt: hasExpiryDate.value
            ? (selectedExpiryDate.value ??
                DateTime.now().add(const Duration(days: 365)))
            : DateTime.now().add(const Duration(days: 365)),
      );

      final response = await _qrCodeService.createQRCodes(request: request);

      // Add new QR codes to the beginning of the list
      qrCodes.insertAll(0, response.data);
      totalItems.value += response.data.length;

      // Clear form
      _clearBulkQRForm();

      Get.back(); // Close dialog/bottom sheet
      Get.snackbar(
        'Success',
        '${response.data.length} QR Codes created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreatingQR.value = false;
    }
  }

  // Delete QR code
  Future<void> deleteQRCode(String qrCodeId) async {
    try {
      final success = await _qrCodeService.deleteQRCode(qrCodeId: qrCodeId);

      if (success) {
        qrCodes.removeWhere((qr) => qr.id == qrCodeId);
        totalItems.value--;

        Get.snackbar(
          'Success',
          'QR Code deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get QR code image as Uint8List
  Uint8List? getQRCodeImage(QRCode qrCode) {
    if (qrCode.image != null && qrCode.image!.isNotEmpty) {
      try {
        return base64Decode(qrCode.image!);
      } catch (e) {
        print('Error decoding QR code image: $e');
        return null;
      }
    }
    return null;
  }

  // Validate single QR form
  bool _validateSingleQRForm() {
    if (tableNumberController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Table number is required');
      return false;
    }

    // Validate table number is numeric
    if (int.tryParse(tableNumberController.text.trim()) == null) {
      Get.snackbar('Error', 'Table number must be a valid number');
      return false;
    }

    if (menuUrlController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Menu URL is required');
      return false;
    }

    if (!_qrCodeService.isValidMenuUrl(menuUrlController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid URL');
      return false;
    }

    return true;
  }

  // Validate bulk QR form
  bool _validateBulkQRForm() {
    if (bulkTableCountController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Table count is required');
      return false;
    }

    if (bulkStartNumberController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Start number is required');
      return false;
    }

    final tableCount = int.tryParse(bulkTableCountController.text.trim());
    if (tableCount == null || tableCount <= 0) {
      Get.snackbar('Error', 'Table count must be a positive number');
      return false;
    }

    final startNumber = int.tryParse(bulkStartNumberController.text.trim());
    if (startNumber == null || startNumber < 0) {
      Get.snackbar('Error', 'Start number must be a valid number');
      return false;
    }

    if (menuUrlController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Menu URL is required');
      return false;
    }

    if (!_qrCodeService.isValidMenuUrl(menuUrlController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid URL');
      return false;
    }

    return true;
  }

  // Clear single QR form
  void _clearSingleQRForm() {
    tableNumberController.clear();
    // Keep menu URL and other defaults
  }

  // Clear bulk QR form
  void _clearBulkQRForm() {
    bulkTableCountController.text = '5';
    bulkStartNumberController.text = '1';
    // Keep menu URL and other defaults
  }

  // Set expiry date
  void setExpiryDate(DateTime? date) {
    selectedExpiryDate.value = date;
    hasExpiryDate.value = date != null;
  }

  // Set QR type
  void setQRType(String type) {
    selectedType.value = type;
  }

  // Check if QR code is expired
  bool isExpired(QRCode qrCode) {
    return _qrCodeService.isQRCodeExpired(qrCode);
  }

  // Format expiry date for display
  String formatExpiryDate(DateTime? date) {
    if (date == null) return 'No expiry';
    return '${date.day}/${date.month}/${date.year}';
  }

  // Get next available table number
  int getNextAvailableTableNumber() {
    if (qrCodes.isEmpty) return 1;

    final usedNumbers = qrCodes
        .map((qr) => int.tryParse(qr.tableNumber) ?? 0)
        .where((num) => num > 0)
        .toList();

    if (usedNumbers.isEmpty) return 1;

    usedNumbers.sort();
    for (int i = 1; i <= usedNumbers.last + 1; i++) {
      if (!usedNumbers.contains(i)) {
        return i;
      }
    }

    return usedNumbers.last + 1;
  }

  // Auto fill next table number
  void autoFillNextTableNumber() {
    final nextNumber = getNextAvailableTableNumber();
    tableNumberController.text = nextNumber.toString();
  }

  // Toggle expiry date
  void toggleExpiryDate(bool value) {
    hasExpiryDate.value = value;
    if (!value) {
      selectedExpiryDate.value = null;
    } else {
      selectedExpiryDate.value = DateTime.now().add(const Duration(days: 365));
    }
  }
}
