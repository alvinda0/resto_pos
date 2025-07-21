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
  final RxBool isCreatingBulk = false.obs;
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

  // Create bulk QR codes
  Future<bool> createBulkQrCodes({
    required int tableCount,
    required int startNumber,
    required String type,
    required String menuUrl,
    DateTime? expiresAt,
  }) async {
    try {
      isCreatingBulk.value = true;
      error.value = '';

      // Validate input
      if (tableCount <= 0) {
        throw Exception('Jumlah meja harus lebih dari 0');
      }

      if (startNumber <= 0) {
        throw Exception('Nomor awal meja harus lebih dari 0');
      }

      if (menuUrl.isEmpty) {
        throw Exception('URL menu tidak boleh kosong');
      }

      // Call service to create bulk QR codes
      final newQrCodes = await _qrCodeService.createBulkQrCodes(
        tableCount: tableCount,
        startNumber: startNumber,
        type: type,
        menuUrl: menuUrl,
        expiresAt: expiresAt,
      );

      // Add new QR codes to existing list
      qrCodes.addAll(newQrCodes);

      // Sort by table number for better display
      qrCodes.sort((a, b) {
        final aNum = int.tryParse(a.tableNumber) ?? 0;
        final bNum = int.tryParse(b.tableNumber) ?? 0;
        return aNum.compareTo(bNum);
      });

      _showSnackBar(
        'Berhasil',
        '$tableCount meja berhasil ditambahkan (Meja ${startNumber} - ${startNumber + tableCount - 1})',
        isError: false,
      );

      return true;
    } catch (e) {
      String cleanError = _extractCleanErrorMessage(e.toString());
      error.value = cleanError;
      _showSnackBar('Error', 'Gagal menambahkan meja: $cleanError',
          isError: true);
      return false;
    } finally {
      isCreatingBulk.value = false;
    }
  }

  // Check if table number already exists
  bool isTableNumberExists(int tableNumber) {
    return qrCodes.any((qr) => qr.tableNumber == tableNumber.toString());
  }

  // Check if any table in range already exists
  bool isTableRangeExists(int startNumber, int count) {
    for (int i = 0; i < count; i++) {
      if (isTableNumberExists(startNumber + i)) {
        return true;
      }
    }
    return false;
  }

  // Get existing table numbers in range
  List<int> getExistingTablesInRange(int startNumber, int count) {
    List<int> existing = [];
    for (int i = 0; i < count; i++) {
      int tableNum = startNumber + i;
      if (isTableNumberExists(tableNum)) {
        existing.add(tableNum);
      }
    }
    return existing;
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

    // Handle "Failed to create bulk QR codes:" prefix
    if (errorMessage.startsWith('Failed to create bulk QR codes: ')) {
      errorMessage = errorMessage.substring(33);
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
      duration: Duration(seconds: isError ? 4 : 3),
      margin: const EdgeInsets.all(16),
    );
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchQrCodes();
  }

  // Get QR codes count
  int get qrCodesCount => qrCodes.length;

  // Get next available table number
  int getNextAvailableTableNumber() {
    if (qrCodes.isEmpty) return 1;

    final tableNumbers = qrCodes
        .map((qr) => int.tryParse(qr.tableNumber) ?? 0)
        .where((num) => num > 0)
        .toList();

    if (tableNumbers.isEmpty) return 1;

    tableNumbers.sort();
    return tableNumbers.last + 1;
  }
}
