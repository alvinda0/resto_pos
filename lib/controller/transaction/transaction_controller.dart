// controllers/transaction_controller.dart
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shao_kao/models/transaction/transaction_model.dart';
import 'package:shao_kao/screens/report/export_tax_report_dialog.dart';
import 'package:shao_kao/services/transaction/transaction_service.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class TransactionController extends GetxController {
  final TransactionService _transactionService = TransactionService.instance;

  // Observable variables
  final RxList<Transaction> _transactions = <Transaction>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _isLoadingRekap = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _itemsPerPage = 10.obs;
  final RxInt _totalItems = 0.obs;
  final RxInt _totalPages = 0.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedTab = 'rinci'.obs;
  final RxBool _isExporting = false.obs;

  // Rekap data
  final RxList<Map<String, dynamic>> _rekapData = <Map<String, dynamic>>[].obs;

  // Available page sizes
  final List<int> availablePageSizes = [5, 10, 20, 50, 100];

  // Date filter
  final Rxn<DateTime> _startDate = Rxn<DateTime>();
  final Rxn<DateTime> _endDate = Rxn<DateTime>();

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get isLoadingRekap => _isLoadingRekap.value;
  String get errorMessage => _errorMessage.value;
  int get currentPage => _currentPage.value;
  int get itemsPerPage => _itemsPerPage.value;
  int get totalItems => _totalItems.value;
  int get totalPages => _totalPages.value;
  String get searchQuery => _searchQuery.value;
  DateTime? get startDate => _startDate.value;
  DateTime? get endDate => _endDate.value;
  String get selectedTab => _selectedTab.value;
  List<Map<String, dynamic>> get rekapData => _rekapData;
  bool get isExporting => _isExporting.value;

  // Rekap summary getters
  double get totalRevenue {
    return _rekapData.fold(
        0.0, (sum, data) => sum + (data['total'] as double? ?? 0.0));
  }

  double get averageTransaction {
    if (_rekapData.isEmpty) return 0.0;
    int totalTransactions =
        _rekapData.fold(0, (sum, data) => sum + (data['count'] as int? ?? 0));
    return totalTransactions > 0 ? totalRevenue / totalTransactions : 0.0;
  }

  // Pagination helpers
  bool get hasPreviousPage => _currentPage.value > 1;
  bool get hasNextPage => _currentPage.value < _totalPages.value;
  int get startIndex => totalItems == 0
      ? 0
      : ((_currentPage.value - 1) * _itemsPerPage.value) + 1;
  int get endIndex => totalItems == 0
      ? 0
      : (_currentPage.value * _itemsPerPage.value > totalItems)
          ? totalItems
          : _currentPage.value * _itemsPerPage.value;

  // Generate page numbers for pagination widget
  List<int> get pageNumbers {
    if (_totalPages.value <= 7) {
      return List.generate(_totalPages.value, (index) => index + 1);
    }

    List<int> pages = [];
    int current = _currentPage.value;
    int total = _totalPages.value;

    // Always include first page
    pages.add(1);

    if (current > 4) {
      pages.add(-1); // Ellipsis placeholder
    }

    // Add pages around current page
    int start = (current - 2).clamp(2, total - 1);
    int end = (current + 2).clamp(2, total - 1);

    for (int i = start; i <= end; i++) {
      if (!pages.contains(i)) {
        pages.add(i);
      }
    }

    if (current < total - 3) {
      pages.add(-1); // Ellipsis placeholder
    }

    // Always include last page
    if (total > 1 && !pages.contains(total)) {
      pages.add(total);
    }

    return pages.where((page) => page != -1).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
    // Load rekap data on initialization so it's ready when tab is clicked
    loadRekapData();
  }

  /// Switch between tabs
  Future<void> switchTab(String tab) async {
    if (_selectedTab.value != tab) {
      _selectedTab.value = tab;
      if (tab == 'rekap' && _rekapData.isEmpty) {
        // Only load rekap data if it's empty
        await loadRekapData();
      }
    }
  }

  Future<void> showExportModal() async {
    // Show modal dialog for export options
    await Get.dialog(
      ExportTaxReportDialog(
        onExport: exportTaxReport,
        initialStartDate: _startDate.value,
        initialEndDate: _endDate.value,
      ),
      barrierDismissible: true,
    );
  }

  Future<void> exportTaxReport({
    DateTime? startDate,
    DateTime? endDate,
    double? newTaxRate,
    bool realTax = false,
  }) async {
    try {
      _isExporting.value = true;

      // Use provided dates or current filter dates
      final exportStartDate = startDate ??
          _startDate.value ??
          DateTime.now().subtract(const Duration(days: 30));
      final exportEndDate = endDate ?? _endDate.value ?? DateTime.now();

      showSuccess('Mempersiapkan export Excel...');

      final result = await _transactionService.exportTaxReport(
        startDate: exportStartDate,
        endDate: exportEndDate,
        newTaxRate: newTaxRate,
        realTax: realTax,
      );

      if (result != null && result['success'] == true) {
        final downloadUrl = result['download_url'] as String?;

        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          showSuccess('Mendownload file Excel...');
          await _downloadAndOpenExcel(downloadUrl);
        } else {
          showError('URL download tidak ditemukan');
        }
      } else {
        final errorMessage = result?['message'] ?? 'Gagal export laporan pajak';
        showError(errorMessage);
      }
    } catch (e) {
      showError('Error saat export: $e');
      print('Export exception: $e');
    } finally {
      _isExporting.value = false;
    }
  }

  /// Request storage permission for Android
  Future<bool> _requestStoragePermission() async {
    if (!GetPlatform.isAndroid) return true;

    // For Android 13+ (API 33+), we don't need MANAGE_EXTERNAL_STORAGE for Downloads
    // We can write to the Downloads folder using the standard storage permission

    var status = await Permission.storage.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      status = await Permission.storage.request();
    }

    if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      Get.dialog(
        AlertDialog(
          title: const Text('Izin Penyimpanan Diperlukan'),
          content: const Text(
              'Aplikasi memerlukan izin penyimpanan untuk mendownload file Excel. '
              'Silakan aktifkan izin di pengaturan aplikasi.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                await openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
          ],
        ),
      );
      return false;
    }

    return status.isGranted;
  }

  /// Download and open Excel file
  Future<void> _downloadAndOpenExcel(String url) async {
    try {
      // For web platform, open URL directly
      if (GetPlatform.isWeb) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          showExcelSuccess('File Excel berhasil dibuka di browser');
        } else {
          throw 'Could not launch $url';
        }
        return;
      }

      // Request permission for Android
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        showError('Izin penyimpanan diperlukan untuk mendownload file');
        return;
      }

      final dio = Dio();

      // Configure Dio to handle SSL certificate issues
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          // Allow Cloudflare R2 certificates
          if (host.contains('.r2.dev') || host.contains('cloudflare')) {
            return true;
          }
          return false;
        };
        return client;
      };

      // Get appropriate directory - prioritize Downloads folder for Android
      Directory? targetDirectory;

      if (GetPlatform.isAndroid) {
        // Try multiple paths for Android Downloads folder
        final possiblePaths = [
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Downloads',
          '/sdcard/Download',
          '/sdcard/Downloads',
        ];

        for (String path in possiblePaths) {
          try {
            final dir = Directory(path);
            if (await dir.exists()) {
              targetDirectory = dir;
              break;
            }
          } catch (e) {
            // Continue to next path
            continue;
          }
        }

        // Fallback to external storage directory if Downloads not found
        if (targetDirectory == null) {
          try {
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              // Create Downloads subfolder in external storage
              final downloadsDir = Directory('${externalDir.path}/Downloads');
              await downloadsDir.create(recursive: true);
              targetDirectory = downloadsDir;
            }
          } catch (e) {
            // Final fallback to app documents directory
            targetDirectory = await getApplicationDocumentsDirectory();
          }
        }
      } else if (GetPlatform.isIOS) {
        targetDirectory = await getApplicationDocumentsDirectory();
      } else {
        targetDirectory = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      if (targetDirectory == null) {
        throw 'Could not determine download directory';
      }

      // Generate proper Excel filename
      final fileName = _generateExcelFileName();
      final filePath = '${targetDirectory.path}/$fileName';

      // Show download progress
      showSuccess('Mendownload file...');

      // Download file with proper headers
      await dio.download(
        url,
        filePath,
        options: Options(
          headers: {
            'Accept':
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'User-Agent': 'Mozilla/5.0 (Android; Mobile)',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total * 100);
            if (progress % 20 == 0) {
              // Show progress every 20%
              print('Download progress: ${progress.toStringAsFixed(0)}%');
            }
          }
        },
      );

      // Verify file was downloaded successfully
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        if (fileSize > 0) {
          final downloadLocation = GetPlatform.isAndroid &&
                  targetDirectory.path.contains('/storage/emulated/0/Download')
              ? 'Downloads folder'
              : 'Documents folder';

          showExcelSuccess(
              'File Excel berhasil didownload ke $downloadLocation',
              fileName: fileName);

          // Try to open the file
          await _openExcelFile(filePath, fileName);
        } else {
          throw 'File yang didownload kosong';
        }
      } else {
        throw 'File gagal didownload';
      }
    } catch (e) {
      print('Download error: $e');

      // More specific error handling
      if (e.toString().contains('CERTIFICATE_VERIFY_FAILED') ||
          e.toString().contains('HandshakeException') ||
          e.toString().contains('Hostname mismatch')) {
        showError(
            'Gagal mendownload file: Masalah sertifikat SSL server. Coba lagi dalam beberapa saat.');
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection failed')) {
        showError(
            'Gagal mendownload file: Masalah koneksi internet atau server tidak dapat diakses');
      } else if (e.toString().contains('Permission denied')) {
        showError('Gagal mendownload file: Izin penyimpanan ditolak');
      } else {
        showError('Gagal mendownload file Excel: $e');
      }
    }
  }

  /// Open Excel file with appropriate app
  Future<void> _openExcelFile(String filePath, String fileName) async {
    try {
      if (GetPlatform.isAndroid || GetPlatform.isIOS) {
        // Use open_file package for mobile platforms
        final result = await OpenFile.open(filePath);

        if (result.type == ResultType.done) {
          showSuccess('File Excel dibuka dengan aplikasi Excel');
        } else if (result.type == ResultType.noAppToOpen) {
          // Show instructions to install Excel app
          _showInstallExcelAppDialog(filePath, fileName);
        } else {
          // Try alternative methods
          await _openWithAlternativeMethod(filePath);
        }
      } else {
        // Desktop platforms
        final fileUri = Uri.file(filePath);
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri);
          showExcelSuccess('File Excel dibuka');
        }
      }
    } catch (e) {
      print('Could not open Excel file: $e');
      // Show file location instead
      _showFileLocationDialog(filePath, fileName);
    }
  }

  /// Try alternative methods to open file
  Future<void> _openWithAlternativeMethod(String filePath) async {
    try {
      // Try with file:// URI
      final fileUri = Uri.parse('file://$filePath');
      if (await canLaunchUrl(fileUri)) {
        await launchUrl(fileUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Try with content:// URI for Android
      if (GetPlatform.isAndroid) {
        final fileName = filePath.split('/').last;
        final contentUri = Uri.parse(
            'content://com.android.externalstorage.documents/document/primary:Download/$fileName');

        if (await canLaunchUrl(contentUri)) {
          await launchUrl(contentUri);
          return;
        }
      }

      throw 'No alternative method worked';
    } catch (e) {
      final fileName = filePath.split('/').last;
      _showFileLocationDialog(filePath, fileName);
    }
  }

  /// Show dialog to install Excel app
  void _showInstallExcelAppDialog(String filePath, String fileName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Install Aplikasi Excel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Untuk membuka file Excel, Anda perlu menginstall salah satu aplikasi berikut:',
            ),
            const SizedBox(height: 12),
            const Text('• Microsoft Excel'),
            const Text('• Google Sheets'),
            const Text('• WPS Office'),
            const Text('• LibreOffice'),
            const SizedBox(height: 12),
            Text('File tersimpan di: $fileName'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              // Open Play Store to Excel app
              final uri = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.microsoft.office.excel');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Install Excel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showFileLocationDialog(filePath, fileName);
            },
            child: const Text('Lihat File'),
          ),
        ],
      ),
    );
  }

  /// Show dialog with file location
  void _showFileLocationDialog(String filePath, String fileName) {
    final isInDownloads = filePath.contains('/storage/emulated/0/Download');
    final folderName = isInDownloads ? 'Downloads' : 'Documents';

    Get.dialog(
      AlertDialog(
        title: const Text('File Berhasil Didownload'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File Excel telah berhasil didownload ke folder $folderName:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                fileName,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isInDownloads
                  ? 'Anda dapat menemukan file ini di folder Downloads perangkat Anda.'
                  : 'Anda dapat membuka file ini dengan aplikasi Excel di perangkat Anda.',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
          if (GetPlatform.isAndroid && isInDownloads)
            TextButton(
              onPressed: () async {
                Get.back();
                // Open Downloads folder using system file manager
                try {
                  // Try to open Downloads folder directly
                  final intent = AndroidIntent(
                      action: 'android.intent.action.VIEW',
                      data:
                          'content://com.android.externalstorage.documents/document/primary:Download',
                      type: 'vnd.android.document/directory');
                  await intent.launch();
                } catch (e) {
                  // Fallback to generic file manager
                  try {
                    final intent = AndroidIntent(
                      action: 'android.intent.action.VIEW',
                      type: 'resource/folder',
                    );
                    await intent.launch();
                  } catch (e2) {
                    showError('Tidak dapat membuka file manager');
                  }
                }
              },
              child: const Text('Buka Downloads'),
            ),
        ],
      ),
    );
  }

  /// Generate Excel filename with timestamp
  String _generateExcelFileName() {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';

    return 'Laporan-Pajak-${dateStr}_$timeStr.xlsx';
  }

  void showExcelSuccess(String message, {String? fileName}) {
    Get.snackbar(
      'Export Berhasil',
      fileName != null ? '$message\nFile: $fileName' : message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 4),
      icon: const Icon(
        Icons.table_chart,
        color: Colors.green,
      ),
    );
  }

  /// Generate rekap data from currently loaded transactions (for initial load)
  void _generateRekapDataFromCurrentTransactions() {
    if (_transactions.isNotEmpty) {
      _generateRekapData(_transactions);
    }
  }

  /// Load rekap/summary data
  Future<void> loadRekapData() async {
    try {
      _isLoadingRekap.value = true;

      // If we already have transactions loaded and no filters applied,
      // use existing data to avoid unnecessary API calls
      if (_transactions.isNotEmpty &&
          _searchQuery.value.isEmpty &&
          _startDate.value == null &&
          _endDate.value == null &&
          _currentPage.value == 1) {
        _generateRekapData(_transactions);
        _isLoadingRekap.value = false;
        return;
      }

      // Get all transactions for summary (without pagination)
      TransactionResponse response;

      if (_searchQuery.value.isNotEmpty) {
        response = await _transactionService.searchTransactions(
          query: _searchQuery.value,
          page: 1,
          limit: 1000, // Get more records for summary
        );
      } else if (_startDate.value != null || _endDate.value != null) {
        response = await _transactionService.getTransactionsByDateRange(
          startDate: _startDate.value,
          endDate: _endDate.value,
          page: 1,
          limit: 1000,
        );
      } else {
        response = await _transactionService.getTransactions(
          page: 1,
          limit: 1000,
        );
      }

      if (response.success) {
        _generateRekapData(response.data);
      } else {
        _errorMessage.value = response.message;
      }
    } catch (e) {
      _errorMessage.value = 'Error loading rekap data: $e';
    } finally {
      _isLoadingRekap.value = false;
    }
  }

  /// Generate rekap data from transactions
  void _generateRekapData(List<Transaction> transactions) {
    Map<String, Map<String, dynamic>> dailyData = {};

    // Group transactions by date
    for (Transaction transaction in transactions) {
      String dateKey = transaction.formattedDate;

      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = {
          'date': dateKey,
          'count': 0,
          'total': 0.0,
          'subtotal': 0.0,
          'tax': 0.0,
        };
      }

      dailyData[dateKey]!['count'] = (dailyData[dateKey]!['count'] as int) + 1;
      dailyData[dateKey]!['total'] =
          (dailyData[dateKey]!['total'] as double) + transaction.totalAmount;
      dailyData[dateKey]!['subtotal'] =
          (dailyData[dateKey]!['subtotal'] as double) + transaction.baseAmount;
      dailyData[dateKey]!['tax'] =
          (dailyData[dateKey]!['tax'] as double) + transaction.taxAmount;
    }

    // Convert to list and calculate averages
    List<Map<String, dynamic>> rekapList = dailyData.values.map((data) {
      final count = data['count'] as int;
      final total = data['total'] as double;
      data['average'] = count > 0 ? total / count : 0.0;
      return data;
    }).toList();

    // Sort by date (newest first)
    rekapList.sort((a, b) {
      // Parse date format dd/mm/yyyy for sorting
      List<String> partsA = (a['date'] as String).split('/');
      List<String> partsB = (b['date'] as String).split('/');

      DateTime dateA = DateTime(
        int.parse(partsA[2]), // year
        int.parse(partsA[1]), // month
        int.parse(partsA[0]), // day
      );

      DateTime dateB = DateTime(
        int.parse(partsB[2]),
        int.parse(partsB[1]),
        int.parse(partsB[0]),
      );

      return dateB.compareTo(dateA); // Newest first
    });

    _rekapData.value = rekapList;
  }

  // [Rest of the methods remain the same as in your original code]
  /// Load transactions with current filters
  Future<void> loadTransactions({bool refresh = false}) async {
    try {
      if (refresh || _currentPage.value == 1) {
        _isLoading.value = true;
        _transactions.clear();
      } else {
        _isLoadingMore.value = true;
      }

      _errorMessage.value = '';

      TransactionResponse response;

      if (_searchQuery.value.isNotEmpty) {
        response = await _transactionService.searchTransactions(
          query: _searchQuery.value,
          page: _currentPage.value,
          limit: _itemsPerPage.value,
        );
      } else if (_startDate.value != null || _endDate.value != null) {
        response = await _transactionService.getTransactionsByDateRange(
          startDate: _startDate.value,
          endDate: _endDate.value,
          page: _currentPage.value,
          limit: _itemsPerPage.value,
        );
      } else {
        response = await _transactionService.getTransactions(
          page: _currentPage.value,
          limit: _itemsPerPage.value,
        );
      }

      if (response.success) {
        if (refresh || _currentPage.value == 1) {
          _transactions.value = response.data;
        } else {
          _transactions.addAll(response.data);
        }

        _totalItems.value = response.metadata.total;
        _totalPages.value = response.metadata.totalPages;

        // Always update rekap data when transactions are loaded
        // Use the same response data to avoid duplicate API calls
        _generateRekapDataFromCurrentTransactions();
      } else {
        _errorMessage.value = response.message;
      }
    } catch (e) {
      _errorMessage.value = 'Error loading transactions: $e';
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
    }
  }

  /// Refresh transactions
  Future<void> refreshTransactions() async {
    _currentPage.value = 1;
    await loadTransactions(refresh: true);
  }

  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= _totalPages.value && page != _currentPage.value) {
      _currentPage.value = page;
      await loadTransactions();
    }
  }

  /// Go to next page
  Future<void> nextPage() async {
    if (hasNextPage) {
      await goToPage(_currentPage.value + 1);
    }
  }

  /// Go to previous page
  Future<void> previousPage() async {
    if (hasPreviousPage) {
      await goToPage(_currentPage.value - 1);
    }
  }

  /// Change items per page
  Future<void> changeItemsPerPage(int newItemsPerPage) async {
    if (newItemsPerPage != _itemsPerPage.value) {
      _itemsPerPage.value = newItemsPerPage;
      _currentPage.value = 1;
      await loadTransactions(refresh: true);
    }
  }

  /// Search transactions
  Future<void> searchTransactions(String query) async {
    _searchQuery.value = query;
    _currentPage.value = 1;
    await loadTransactions(refresh: true);
    // Refresh rekap data with new search
    if (_selectedTab.value == 'rekap') {
      await loadRekapData();
    }
  }

  /// Clear search
  Future<void> clearSearch() async {
    _searchQuery.value = '';
    _currentPage.value = 1;
    await loadTransactions(refresh: true);
    // Refresh rekap data
    if (_selectedTab.value == 'rekap') {
      await loadRekapData();
    }
  }

  /// Filter by date range
  Future<void> filterByDateRange(DateTime? start, DateTime? end) async {
    _startDate.value = start;
    _endDate.value = end;
    _currentPage.value = 1;
    await loadTransactions(refresh: true);
    // Refresh rekap data with new date filter
    if (_selectedTab.value == 'rekap') {
      await loadRekapData();
    }
  }

  /// Clear date filter
  Future<void> clearDateFilter() async {
    _startDate.value = null;
    _endDate.value = null;
    _currentPage.value = 1;
    await loadTransactions(refresh: true);
    // Refresh rekap data
    if (_selectedTab.value == 'rekap') {
      await loadRekapData();
    }
  }

  /// Clear all filters
  Future<void> clearAllFilters() async {
    _searchQuery.value = '';
    _startDate.value = null;
    _endDate.value = null;
    _currentPage.value = 1;
    await loadTransactions(refresh: true);
    // Refresh rekap data
    if (_selectedTab.value == 'rekap') {
      await loadRekapData();
    }
  }

  /// Get transaction by ID
  Future<Transaction?> getTransactionById(String id) async {
    try {
      return await _transactionService.getTransactionById(id);
    } catch (e) {
      _errorMessage.value = 'Error getting transaction: $e';
      return null;
    }
  }

  /// Export transactions
  Future<bool> exportTransactions({String format = 'excel'}) async {
    try {
      return await _transactionService.exportTransactions(
        startDate: _startDate.value,
        endDate: _endDate.value,
        format: format,
      );
    } catch (e) {
      _errorMessage.value = 'Error exporting transactions: $e';
      return false;
    }
  }

  /// Format currency helper
  String formatCurrency(double amount) {
    return _transactionService.formatCurrency(amount);
  }

  /// Get transaction status
  String getTransactionStatus(Transaction transaction) {
    return _transactionService.getTransactionStatus(transaction);
  }

  /// Calculate total amount for selected transactions
  double calculateSelectedTotal(List<Transaction> selectedTransactions) {
    return selectedTransactions.fold(
        0.0, (sum, transaction) => sum + transaction.totalAmount);
  }

  /// Calculate subtotal for selected transactions
  double calculateSelectedSubtotal(List<Transaction> selectedTransactions) {
    return selectedTransactions.fold(
        0.0, (sum, transaction) => sum + transaction.subtotal);
  }

  /// Calculate tax for selected transactions
  double calculateSelectedTax(List<Transaction> selectedTransactions) {
    return selectedTransactions.fold(
        0.0, (sum, transaction) => sum + transaction.taxAmount);
  }

  /// Get monthly summary
  Map<String, dynamic> getMonthlySummary() {
    if (_rekapData.isEmpty) {
      return {
        'totalTransactions': 0,
        'totalRevenue': 0.0,
        'averagePerDay': 0.0,
        'averagePerTransaction': 0.0,
      };
    }

    int totalTransactions =
        _rekapData.fold(0, (sum, data) => sum + (data['count'] as int? ?? 0));
    double totalRevenue = _rekapData.fold(
        0.0, (sum, data) => sum + (data['total'] as double? ?? 0.0));
    double averagePerDay = totalRevenue / _rekapData.length;
    double averagePerTransaction =
        totalTransactions > 0 ? totalRevenue / totalTransactions : 0.0;

    return {
      'totalTransactions': totalTransactions,
      'totalRevenue': totalRevenue,
      'averagePerDay': averagePerDay,
      'averagePerTransaction': averagePerTransaction,
    };
  }

  /// Get best performing day
  Map<String, dynamic>? getBestPerformingDay() {
    if (_rekapData.isEmpty) return null;

    Map<String, dynamic> bestDay = _rekapData.first;
    for (Map<String, dynamic> data in _rekapData) {
      final currentTotal = data['total'] as double? ?? 0.0;
      final bestTotal = bestDay['total'] as double? ?? 0.0;
      if (currentTotal > bestTotal) {
        bestDay = data;
      }
    }
    return bestDay;
  }

  /// Get transaction trend (comparing with previous period)
  String getTransactionTrend() {
    if (_rekapData.length < 2) return 'neutral';

    // Compare last 3 days average with previous 3 days average
    int halfLength = (_rekapData.length / 2).floor();

    double recentTotal = _rekapData
        .take(halfLength)
        .fold(0.0, (sum, data) => sum + (data['total'] as double? ?? 0.0));
    double recentAverage = recentTotal / halfLength;

    double previousTotal = _rekapData
        .skip(halfLength)
        .fold(0.0, (sum, data) => sum + (data['total'] as double? ?? 0.0));
    double previousAverage = previousTotal / (_rekapData.length - halfLength);

    if (recentAverage > previousAverage * 1.05) {
      return 'up';
    } else if (recentAverage < previousAverage * 0.95) {
      return 'down';
    } else {
      return 'stable';
    }
  }

  /// Show error message
  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show success message
  void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 3),
    );
  }
}
