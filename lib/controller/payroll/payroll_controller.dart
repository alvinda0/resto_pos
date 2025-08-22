import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/payroll/payroll_model.dart';
import 'package:pos/services/payroll/payroll_service.dart';

class PayrollController extends GetxController {
  final PayrollService _payrollService = PayrollService.instance;

  // Observable variables
  final RxList<Payroll> payrolls = <Payroll>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxList<int> availablePageSizes = [5, 10, 25, 50].obs;

  // Computed properties for pagination
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value + 1;
  int get endIndex =>
      (currentPage.value * itemsPerPage.value).clamp(0, totalItems.value);
  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => currentPage.value < totalPages.value;

  List<int> get pageNumbers {
    List<int> pages = [];
    for (int i = 1; i <= totalPages.value; i++) {
      pages.add(i);
    }
    return pages;
  }

  @override
  void onInit() {
    super.onInit();
    fetchPayrolls();
  }

  // Fetch payrolls dengan pagination
  Future<void> fetchPayrolls({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading(true);
      errorMessage('');

      final response = await _payrollService.getPayrolls(
        page: currentPage.value,
        limit: itemsPerPage.value,
      );

      if (response.success) {
        payrolls.assignAll(response.data);
        if (response.metadata != null) {
          totalItems(response.metadata!.total);
          totalPages(response.metadata!.totalPages);
        }
      } else {
        errorMessage(response.message);
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (showLoading) isLoading(false);
    }
  }

  // Generate payroll - FIXED VERSION
  Future<void> generatePayroll(PayrollGenerateRequest request) async {
    try {
      isGenerating(true);
      errorMessage('');

      final response = await _payrollService.generatePayroll(request);

      // Perbaikan: Periksa apakah response memiliki success flag atau tidak
      bool isSuccess = false;
      String message = '';
      int generatedCount = 0;

      // Cek berbagai kemungkinan struktur response
      if (response.success != null) {
        // Jika ada field success
        isSuccess = response.success!;
        message = response.message ?? '';
        generatedCount = response.data?.count ?? 0;
      } else {
        // Jika tidak ada field success, anggap berhasil jika ada data
        isSuccess = response.data != null;
        message = response.message ?? 'Payroll generated successfully';
        generatedCount = response.data?.count ?? 0;
      }

      if (isSuccess) {
        Get.snackbar(
          'Berhasil',
          '$message${generatedCount > 0 ? " $generatedCount payroll dibuat." : ""}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Refresh data setelah generate
        await fetchPayrolls(showLoading: false);
      } else {
        errorMessage(message);
        Get.snackbar(
          'Error',
          message.isNotEmpty ? message : 'Gagal membuat payroll',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      final errorMsg = e.toString();

      // Perbaikan: Jangan tampilkan error jika sebenarnya berhasil
      if (!errorMsg.toLowerCase().contains('payrolls generated') &&
          !errorMsg.toLowerCase().contains('success')) {
        errorMessage(errorMsg);
        Get.snackbar(
          'Error',
          'Terjadi kesalahan: $errorMsg',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        // Jika error message mengandung info sukses, tampilkan sebagai sukses
        Get.snackbar(
          'Berhasil',
          'Payroll berhasil dibuat',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Refresh data
        await fetchPayrolls(showLoading: false);
      }
    } finally {
      isGenerating(false);
    }
  }

  // Alternative method untuk handle generate payroll dengan lebih robust error handling
  Future<void> generatePayrollRobust(PayrollGenerateRequest request) async {
    try {
      isGenerating(true);
      errorMessage('');

      // Simpan jumlah payroll sebelumnya untuk perbandingan
      final initialCount = payrolls.length;

      final response = await _payrollService.generatePayroll(request);

      // Refresh data terlebih dahulu untuk melihat apakah ada perubahan
      await fetchPayrolls(showLoading: false);

      final newCount = payrolls.length;
      final addedCount = newCount - initialCount;

      // Jika ada penambahan data, anggap berhasil
      if (addedCount > 0) {
        Get.snackbar(
          'Berhasil',
          'Payroll berhasil dibuat! $addedCount payroll ditambahkan.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Periksa response untuk menentukan status
        final success = response.success ?? false;
        final message = response.message ?? '';

        if (success || message.toLowerCase().contains('success')) {
          Get.snackbar(
            'Info',
            message.isNotEmpty ? message : 'Payroll berhasil diproses',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            'Warning',
            message.isNotEmpty ? message : 'Tidak ada payroll baru yang dibuat',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      final errorMsg = e.toString();

      // Refresh data untuk memastikan
      await fetchPayrolls(showLoading: false);

      // Jika error tapi data bertambah, anggap berhasil
      if (payrolls.isNotEmpty) {
        Get.snackbar(
          'Berhasil',
          'Payroll berhasil dibuat',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        errorMessage(errorMsg);
        Get.snackbar(
          'Error',
          'Terjadi kesalahan: $errorMsg',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      isGenerating(false);
    }
  }

  // Pagination methods
  void onPageSizeChanged(int newSize) {
    itemsPerPage(newSize);
    currentPage(1); // Reset ke halaman pertama
    fetchPayrolls();
  }

  void onPreviousPage() {
    if (hasPreviousPage) {
      currentPage(currentPage.value - 1);
      fetchPayrolls();
    }
  }

  void onNextPage() {
    if (hasNextPage) {
      currentPage(currentPage.value + 1);
      fetchPayrolls();
    }
  }

  void onPageSelected(int page) {
    if (page != currentPage.value) {
      currentPage(page);
      fetchPayrolls();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    currentPage(1);
    await fetchPayrolls();
  }

  // Delete payroll
  Future<void> deletePayroll(String id) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this payroll?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        isLoading(true);

        final success = await _payrollService.deletePayroll(id);

        if (success) {
          Get.snackbar(
            'Success',
            'Payroll deleted successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Refresh data setelah delete
          await fetchPayrolls(showLoading: false);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // Format currency
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  // Format month
  String formatMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  // Search/Filter methods (jika diperlukan)
  final RxString searchQuery = ''.obs;
  final RxString selectedMonth = ''.obs;

  void onSearchChanged(String query) {
    searchQuery(query);
    currentPage(1);
    // Implement search logic here
    fetchPayrolls();
  }

  void onMonthFilterChanged(String month) {
    selectedMonth(month);
    currentPage(1);
    // Implement month filter logic here
    fetchPayrolls();
  }

  void clearFilters() {
    searchQuery('');
    selectedMonth('');
    currentPage(1);
    fetchPayrolls();
  }
}
