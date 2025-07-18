import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/withdraw/withdraw_controller.dart';
import 'package:pos/models/withdraw/withdraw_model.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final WithdrawalController controller = Get.put(WithdrawalController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      controller.loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penarikan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.searchWithdrawals,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      controller.statusOptions.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(controller.statusLabels[index]),
                          selected: controller.selectedStatus.value ==
                              controller.statusOptions[index],
                          onSelected: (selected) {
                            controller.filterByStatus(selected
                                ? controller.statusOptions[index]
                                : '');
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                )),
          ),

          // Data Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.withdrawals.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.withdrawals.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada data penarikan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshData,
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                                width: 40,
                                child: Text('No.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Nama',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Tanggal',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Saldo Tersedia',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Nama Bank',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Nomor Rekening',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Jumlah',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Aksi',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),

                      // Table Body
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: controller.withdrawals.length +
                              (controller.isLoadingMore.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == controller.withdrawals.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final withdrawal = controller.withdrawals[index];
                            return _buildTableRow(withdrawal, index + 1);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Pagination
          Obx(() {
            if (controller.withdrawals.isEmpty) return const SizedBox();

            return Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: controller.currentPage.value > 1
                        ? () {
                            controller.currentPage.value--;
                            controller.fetchWithdrawals();
                          }
                        : null,
                    child: const Text('< Previous'),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${controller.currentPage.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: controller.hasMoreData.value
                        ? () {
                            controller.currentPage.value++;
                            controller.fetchWithdrawals();
                          }
                        : null,
                    child: const Text('Next >'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableRow(WithdrawalModel withdrawal, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              index.toString(),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              withdrawal.referralName,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(withdrawal.createdAt),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              withdrawal.formattedAmount,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              withdrawal.bankName,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              withdrawal.bankAccountNumber,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              withdrawal.formattedAmount,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildActionButtons(withdrawal),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(WithdrawalModel withdrawal) {
    if (withdrawal.isPending) {
      return Row(
        children: [
          ElevatedButton(
            onPressed: () => _showAcceptDialog(withdrawal),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(60, 32),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Terima', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () => _showRejectDialog(withdrawal),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(60, 32),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Tolak', style: TextStyle(fontSize: 12)),
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: controller.getStatusColor(withdrawal.status),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          controller.getStatusText(withdrawal.status),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }

  void _showAcceptDialog(WithdrawalModel withdrawal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terima Pencairan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID Referal', withdrawal.referralId ?? ''),
            _buildDetailRow('Nama', withdrawal.referralName),
            _buildDetailRow('Saldo Tersedia', withdrawal.formattedAmount),
            _buildDetailRow('Nama Bank', withdrawal.bankName),
            _buildDetailRow('Nomor Rekening', withdrawal.bankAccountNumber),
            _buildDetailRow(
                'Nama Pemilik Rekening', withdrawal.bankAccountName),
            _buildDetailRow('Jumlah', withdrawal.formattedAmount),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.approveWithdrawal(withdrawal.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Terima'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(WithdrawalModel withdrawal) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pencairan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID Referal', withdrawal.referralId ?? ''),
            _buildDetailRow('Nama', withdrawal.referralName),
            _buildDetailRow('Saldo Tersedia', withdrawal.formattedAmount),
            _buildDetailRow('Nama Bank', withdrawal.bankName),
            _buildDetailRow('Nomor Rekening', withdrawal.bankAccountNumber),
            _buildDetailRow(
                'Nama Pemilik Rekening', withdrawal.bankAccountName),
            _buildDetailRow('Jumlah', withdrawal.formattedAmount),
            const SizedBox(height: 16),
            const Text('Alasan'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alasan penolakan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.rejectWithdrawal(
                withdrawal.id,
                note: reasonController.text.isNotEmpty
                    ? reasonController.text
                    : 'Ditolak oleh admin',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
