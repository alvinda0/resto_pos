// screens/redemption/redemption_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/redemption/redemption_controller.dart';
import 'package:pos/models/redemption/redemption_model.dart';
import 'package:pos/widgets/pagination_widget.dart';

class RedemptionScreen extends StatelessWidget {
  const RedemptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RedemptionController controller = Get.put(RedemptionController());

    return Scaffold(
      body: Column(
        children: [
          // Content Section
          Expanded(
            child: _buildContent(controller),
          ),

          // Pagination Section
          _buildPaginationSection(controller),
        ],
      ),
    );
  }

  Widget _buildContent(RedemptionController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorState(controller);
        }

        if (controller.redemptions.isEmpty) {
          return _buildEmptyState();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Responsive breakpoint
            final isTabletOrDesktop = constraints.maxWidth >= 768;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isTabletOrDesktop
                  ? _buildDesktopTable(controller, constraints)
                  : _buildMobileList(controller),
            );
          },
        );
      }),
    );
  }

  Widget _buildErrorState(RedemptionController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error Memuat Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.error.value,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Penukaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada penukaran yang sesuai dengan kriteria.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(
      RedemptionController controller, BoxConstraints constraints) {
    final double availableWidth = constraints.maxWidth - 32;
    final double idWidth = availableWidth * 0.12;
    final double customerWidth = availableWidth * 0.15;
    final double rewardWidth = availableWidth * 0.15;
    final double pointsWidth = availableWidth * 0.12;
    final double statusWidth = availableWidth * 0.15;
    final double dateWidth = availableWidth * 0.18;
    final double actionsWidth = availableWidth * 0.13;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 8,
        horizontalMargin: 16,
        columns: [
          DataColumn(
            label: SizedBox(
              width: idWidth,
              child: const Text('ID',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: customerWidth,
              child: const Text('Pelanggan',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: rewardWidth,
              child: const Text('Hadiah',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: pointsWidth,
              child: const Text('Poin',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: statusWidth,
              child: const Text('Status',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: dateWidth,
              child: const Text('Tanggal',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: actionsWidth,
              child: const Text('Aksi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
        rows: controller.redemptions.map((redemption) {
          return DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: idWidth,
                  child: Text(
                    redemption.id.length > 8
                        ? '${redemption.id.substring(0, 8)}...'
                        : redemption.id,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: customerWidth,
                  child: Text(
                    redemption.customerId.length > 12
                        ? '${redemption.customerId.substring(0, 12)}...'
                        : redemption.customerId,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: rewardWidth,
                  child: Text(
                    redemption.rewardId.length > 12
                        ? '${redemption.rewardId.substring(0, 12)}...'
                        : redemption.rewardId,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: pointsWidth,
                  child: Text(
                    '${redemption.pointsUsed}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: statusWidth,
                  child: _buildStatusChip(redemption.status),
                ),
              ),
              DataCell(
                SizedBox(
                  width: dateWidth,
                  child: Text(
                    _formatDate(redemption.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: actionsWidth,
                  child: _buildActionMenu(controller, redemption),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileList(RedemptionController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.redemptions.length,
      itemBuilder: (context, index) {
        final redemption = controller.redemptions[index];
        return _buildMobileRedemptionCard(controller, redemption);
      },
    );
  }

  Widget _buildMobileRedemptionCard(
      RedemptionController controller, Redemption redemption) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'ID: ${redemption.id.length > 12 ? "${redemption.id.substring(0, 12)}..." : redemption.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                _buildActionMenu(controller, redemption),
              ],
            ),
            const SizedBox(height: 8),

            // Customer info
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Pelanggan: ${redemption.customerId}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Reward info
            Row(
              children: [
                Icon(Icons.card_giftcard, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Hadiah: ${redemption.rewardId}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Points and Status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    '${redemption.pointsUsed} poin',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _buildStatusChip(redemption.status),
              ],
            ),
            const SizedBox(height: 8),

            // Date
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(redemption.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(dynamic status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: status.color,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildActionMenu(
      RedemptionController controller, Redemption redemption) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      tooltip: 'Menu Aksi',
      onSelected: (value) {
        if (value == 'edit') {
          controller.showStatusUpdateDialog(redemption.id, redemption.status);
        } else if (value == 'view') {
          _showRedemptionDetails(controller, redemption);
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Text('Lihat Detail'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.orange, size: 18),
              SizedBox(width: 8),
              Text('Ubah Status'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationSection(RedemptionController controller) {
    return Obx(() {
      return PaginationWidget(
        currentPage: controller.currentPage.value,
        totalItems: controller.totalItems.value,
        itemsPerPage: controller.itemsPerPage.value,
        availablePageSizes: controller.availablePageSizes,
        startIndex: controller.startIndex,
        endIndex: controller.endIndex,
        hasPreviousPage: controller.hasPreviousPage,
        hasNextPage: controller.hasNextPage,
        pageNumbers: controller.pageNumbers,
        onPageSizeChanged: (newSize) {
          controller.changePageSize(newSize);
        },
        onPreviousPage: () {
          controller.previousPage();
        },
        onNextPage: () {
          controller.nextPage();
        },
        onPageSelected: (page) {
          controller.goToPage(page);
        },
      );
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showRedemptionDetails(
      RedemptionController controller, Redemption redemption) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.card_giftcard, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Detail Penukaran'),
          ],
        ),
        content: Container(
          width: Get.width * 0.8,
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID', redemption.id),
                const Divider(height: 16),
                _buildDetailRow('ID Pelanggan', redemption.customerId),
                _buildDetailRow('ID Hadiah', redemption.rewardId),
                const Divider(height: 16),
                _buildDetailRow(
                    'Poin Digunakan', '${redemption.pointsUsed} poin'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text(
                        'Status:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: _buildStatusChip(redemption.status)),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 16),
                _buildDetailRow(
                    'Tanggal Dibuat', _formatDate(redemption.createdAt)),
                _buildDetailRow(
                    'Tanggal Diupdate', _formatDate(redemption.updatedAt)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
