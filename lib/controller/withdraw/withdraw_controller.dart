// controllers/withdrawal_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/withdraw/withdraw_model.dart';
import 'package:pos/services/withdraw/withdraw_service.dart';

class WithdrawalController extends GetxController {
  final WithdrawalService _withdrawalService = WithdrawalService();

  // Observable variables
  final RxList<WithdrawalModel> withdrawals = <WithdrawalModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMoreData = true.obs;

  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Filter options
  final List<String> statusOptions = ['', 'PENDING', 'APPROVED', 'REJECTED'];
  final List<String> statusLabels = [
    'Semua',
    'Menunggu',
    'Diterima',
    'Ditolak'
  ];

  @override
  void onInit() {
    super.onInit();
    fetchWithdrawals();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Fetch withdrawals
  Future<void> fetchWithdrawals({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      isLoading.value = true;

      final response = await _withdrawalService.getWithdrawals(
        page: currentPage.value,
        limit: 10,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: selectedStatus.value.isNotEmpty ? selectedStatus.value : null,
        sortBy: 'created_at',
        sortOrder: 'desc',
      );

      if (isRefresh) {
        withdrawals.clear();
      }

      withdrawals.addAll(response.data);

      // Calculate pagination
      final totalItems = response.data.length;
      hasMoreData.value = totalItems == 10; // Assuming 10 items per page
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data penarikan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load more data
  Future<void> loadMoreData() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response = await _withdrawalService.getWithdrawals(
        page: currentPage.value,
        limit: 10,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: selectedStatus.value.isNotEmpty ? selectedStatus.value : null,
        sortBy: 'created_at',
        sortOrder: 'desc',
      );

      if (response.data.isEmpty) {
        hasMoreData.value = false;
      } else {
        withdrawals.addAll(response.data);
        hasMoreData.value = response.data.length == 10;
      }
    } catch (e) {
      currentPage.value--; // Rollback page increment
      Get.snackbar(
        'Error',
        'Gagal memuat data tambahan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Search withdrawals
  void searchWithdrawals(String query) {
    searchQuery.value = query;
    fetchWithdrawals(isRefresh: true);
  }

  // Filter by status
  void filterByStatus(String status) {
    selectedStatus.value = status;
    fetchWithdrawals(isRefresh: true);
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchWithdrawals(isRefresh: true);
  }

  // Update withdrawal status
  Future<void> updateWithdrawalStatus(
    String withdrawalId,
    String status,
    String note,
  ) async {
    try {
      isLoading.value = true;

      await _withdrawalService.updateWithdrawalStatus(
        withdrawalId,
        status,
        note,
      );

      // Update local data
      final index = withdrawals.indexWhere((w) => w.id == withdrawalId);
      if (index != -1) {
        final updatedWithdrawal = WithdrawalModel(
          id: withdrawals[index].id,
          walletId: withdrawals[index].walletId,
          storeId: withdrawals[index].storeId,
          referralId: withdrawals[index].referralId,
          referralName: withdrawals[index].referralName,
          amount: withdrawals[index].amount,
          status: status,
          type: withdrawals[index].type,
          bankName: withdrawals[index].bankName,
          bankAccountNumber: withdrawals[index].bankAccountNumber,
          bankAccountName: withdrawals[index].bankAccountName,
          createdAt: withdrawals[index].createdAt,
          updatedAt: DateTime.now(),
        );
        withdrawals[index] = updatedWithdrawal;
      }

      Get.snackbar(
        'Berhasil',
        'Status penarikan berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui status: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Approve withdrawal
  Future<void> approveWithdrawal(String withdrawalId, {String? note}) async {
    await updateWithdrawalStatus(
      withdrawalId,
      'APPROVED',
      note ?? 'Disetujui oleh admin',
    );
  }

  // Reject withdrawal
  Future<void> rejectWithdrawal(String withdrawalId, {String? note}) async {
    await updateWithdrawalStatus(
      withdrawalId,
      'REJECTED',
      note ?? 'Ditolak oleh admin',
    );
  }

  // Show action dialog
  void showActionDialog(WithdrawalModel withdrawal) {
    if (!withdrawal.isPending) {
      Get.snackbar(
        'Peringatan',
        'Hanya penarikan dengan status menunggu yang dapat diubah',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('Konfirmasi Tindakan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${withdrawal.referralName}'),
            Text('Jumlah: ${withdrawal.formattedAmount}'),
            Text('Bank: ${withdrawal.bankName}'),
            Text('Rekening: ${withdrawal.bankAccountNumber}'),
            SizedBox(height: 16),
            Text('Pilih tindakan:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              rejectWithdrawal(withdrawal.id);
            },
            child: Text('Tolak', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              approveWithdrawal(withdrawal.id);
            },
            child: Text('Setujui'),
          ),
        ],
      ),
    );
  }

  // Get filtered withdrawals
  List<WithdrawalModel> get filteredWithdrawals {
    return withdrawals.where((withdrawal) {
      final matchesSearch = searchQuery.value.isEmpty ||
          withdrawal.referralName
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          withdrawal.bankName
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          withdrawal.bankAccountNumber.contains(searchQuery.value);

      final matchesStatus = selectedStatus.value.isEmpty ||
          withdrawal.status == selectedStatus.value;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Get status color
  Color getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get status text
  String getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Menunggu';
      case 'APPROVED':
        return 'Diterima';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status;
    }
  }

  // Get total amount
  double get totalAmount {
    return withdrawals.fold(0.0, (sum, withdrawal) => sum + withdrawal.amount);
  }

  // Get pending count
  int get pendingCount {
    return withdrawals.where((w) => w.isPending).length;
  }

  // Get approved count
  int get approvedCount {
    return withdrawals.where((w) => w.isApproved).length;
  }

  // Get rejected count
  int get rejectedCount {
    return withdrawals.where((w) => w.isRejected).length;
  }
}
