// screens/redemption/redemption_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/redemption/redemption_controller.dart';
import 'package:pos/models/redemption/redemption_model.dart';

class RedemptionScreen extends StatelessWidget {
  const RedemptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RedemptionController controller = Get.put(RedemptionController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Penukaran'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Table Section
            Expanded(
              child: _buildDataTable(controller),
            ),

            // Pagination Section
            _buildPaginationSection(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(RedemptionController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.error.value.isNotEmpty) {
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

      if (controller.redemptions.isEmpty) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate column widths based on available space
            final double availableWidth = constraints.maxWidth - 32; // padding
            final double idWidth = availableWidth * 0.12;
            final double customerWidth = availableWidth * 0.15;
            final double rewardWidth = availableWidth * 0.15;
            final double pointsWidth = availableWidth * 0.12;
            final double statusWidth = availableWidth * 0.15;
            final double dateWidth = availableWidth * 0.18;
            final double actionsWidth = availableWidth * 0.13;

            return DataTable(
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
                    child: const Text('Tanggal Dibuat',
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
                          redemption.id.length > 6
                              ? '${redemption.id.substring(0, 6)}...'
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: redemption.status.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: redemption.status.color),
                          ),
                          child: Text(
                            redemption.status.displayName,
                            style: TextStyle(
                              color: redemption.status.color,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18),
                          tooltip: 'Menu Aksi',
                          onSelected: (value) {
                            if (value == 'edit') {
                              controller.showStatusUpdateDialog(
                                  redemption.id, redemption.status);
                            } else if (value == 'view') {
                              _showRedemptionDetails(redemption);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit,
                                      color: Colors.blue, size: 18),
                                  SizedBox(width: 8),
                                  Text('Ubah Status'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility,
                                      color: Colors.green, size: 18),
                                  SizedBox(width: 8),
                                  Text('Lihat Detail'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          },
        ),
      );
    });
  }

  Widget _buildPaginationSection(RedemptionController controller) {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              // Items per page
              Text(
                'Item per halaman:',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: controller.itemsPerPage.value,
                items: controller.availablePageSizes
                    .map((size) => DropdownMenuItem<int>(
                          value: size,
                          child: Text(size.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.changePageSize(value);
                  }
                },
                underline: const SizedBox(),
              ),
              const SizedBox(width: 32),

              // Page info
              Text(
                '${controller.startIndex}-${controller.endIndex} of ${controller.totalItems.value}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Spacer(),

              // Pagination controls
              IconButton(
                onPressed:
                    controller.hasPreviousPage ? controller.previousPage : null,
                icon: const Icon(Icons.chevron_left),
              ),
              ...controller.pageNumbers.take(5).map((page) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: page == controller.currentPage.value
                          ? null
                          : () => controller.goToPage(page),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: page == controller.currentPage.value
                            ? Colors.blue[600]
                            : Colors.grey[200],
                        foregroundColor: page == controller.currentPage.value
                            ? Colors.white
                            : Colors.grey[700],
                        minimumSize: const Size(40, 36),
                        padding: const EdgeInsets.all(8),
                      ),
                      child: Text(page.toString()),
                    ),
                  )),
              IconButton(
                onPressed: controller.hasNextPage ? controller.nextPage : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showRedemptionDetails(Redemption redemption) {
    Get.dialog(
      AlertDialog(
        title: const Text('Detail Penukaran'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', redemption.id),
              _buildDetailRow('ID Pelanggan', redemption.customerId),
              _buildDetailRow('ID Hadiah', redemption.rewardId),
              _buildDetailRow(
                  'Poin Digunakan', '${redemption.pointsUsed} poin'),
              _buildDetailRow('Status', redemption.status.displayName),
              _buildDetailRow(
                  'Tanggal Dibuat', _formatDate(redemption.createdAt)),
              _buildDetailRow(
                  'Tanggal Diupdate', _formatDate(redemption.updatedAt)),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
