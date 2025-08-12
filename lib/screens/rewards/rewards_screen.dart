// screens/reward_management_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/rewards/rewards_controller.dart';
import 'package:pos/models/rewards/rewards_model.dart';

import 'package:pos/widgets/pagination_widget.dart';

class RewardManagementScreen extends StatelessWidget {
  const RewardManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RewardController controller = Get.put(RewardController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Kelola Hadiah',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.rewards.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.error.value.isNotEmpty && controller.rewards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.error.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
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

        return Column(
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kelola Hadiah',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement add reward functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 8),
                        Text('Tambah Hadiah'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Table section
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Table header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                              width: 60,
                              child: Text('No.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          SizedBox(
                              width: 120,
                              child: Text('Gambar',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          SizedBox(
                              width: 200,
                              child: Text('Nama',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          SizedBox(
                              width: 200,
                              child: Text('Deskripsi',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          SizedBox(
                              width: 120,
                              child: Text('Biaya Poin',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          SizedBox(
                              width: 100,
                              child: Text('Status',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          SizedBox(
                              width: 80,
                              child: Text('Aksi',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ),

                    const Divider(height: 0),

                    // Table body
                    Expanded(
                      child: controller.rewards.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada data hadiah',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(0),
                              itemCount: controller.rewards.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 0),
                              itemBuilder: (context, index) {
                                final reward = controller.rewards[index];
                                final displayIndex =
                                    controller.startIndex + index;

                                return _buildTableRow(
                                    reward, displayIndex, controller);
                              },
                            ),
                    ),

                    // Pagination
                    PaginationWidget(
                      currentPage: controller.currentPage.value,
                      totalItems: controller.totalItems.value,
                      itemsPerPage: controller.itemsPerPage.value,
                      availablePageSizes: controller.availablePageSizes,
                      startIndex: controller.startIndex,
                      endIndex: controller.endIndex,
                      hasPreviousPage: controller.hasPreviousPage,
                      hasNextPage: controller.hasNextPage,
                      pageNumbers: controller.pageNumbers,
                      onPageSizeChanged: controller.changePageSize,
                      onPreviousPage: controller.previousPage,
                      onNextPage: controller.nextPage,
                      onPageSelected: controller.goToPage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTableRow(
      RewardModel reward, int displayIndex, RewardController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // No.
          SizedBox(
            width: 60,
            child: Text(
              displayIndex.toString(),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Gambar
          SizedBox(
            width: 120,
            child: reward.imageUrl != null && reward.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      reward.imageUrl!,
                      width: 60,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.image_not_supported,
                            size: 20,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                  ),
          ),

          // Nama
          SizedBox(
            width: 200,
            child: Text(
              reward.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Deskripsi
          SizedBox(
            width: 200,
            child: Text(
              reward.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),

          // Biaya Poin
          SizedBox(
            width: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                controller.formatPoints(reward.pointsCost),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Status
          SizedBox(
            width: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: reward.isActive ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                controller.formatStatus(reward.isActive),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: reward.isActive ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Aksi
          SizedBox(
            width: 80,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                // TODO: Implement edit and delete functionality
                switch (value) {
                  case 'edit':
                    // Handle edit
                    break;
                  case 'delete':
                    // Handle delete
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
