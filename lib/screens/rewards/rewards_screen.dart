// screens/reward_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pos/controller/rewards/rewards_controller.dart';
import 'package:pos/models/rewards/rewards_model.dart';
import 'package:pos/widgets/pagination_widget.dart';
import 'dart:io';

class RewardManagementScreen extends StatelessWidget {
  const RewardManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RewardController controller = Get.put(RewardController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    controller.error.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1024;
            final isTablet =
                constraints.maxWidth > 768 && constraints.maxWidth <= 1024;
            final isMobile = constraints.maxWidth <= 768;

            return Column(
              children: [
                // Header section
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Kelola Hadiah',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _showRewardDialog(context, controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 18),
                            if (!isMobile) ...[
                              const SizedBox(width: 8),
                              const Text('Tambah Hadiah'),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Table section
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(isMobile ? 16 : 24),
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
                        // Responsive table
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
                              : isMobile
                                  ? _buildMobileView(controller)
                                  : _buildDesktopTableView(
                                      controller, isTablet),
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
          },
        );
      }),
    );
  }

  Widget _buildDesktopTableView(RewardController controller, bool isTablet) {
    return Column(
      children: [
        // Table header
        Container(
          padding: EdgeInsets.all(isTablet ? 16 : 24),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: isTablet ? 40 : 60,
                child: const Text('No.',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                width: isTablet ? 80 : 120,
                child: const Text('Gambar',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                width: isTablet ? 120 : 200,
                child: const Text('Nama',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                width: isTablet ? 150 : 200,
                child: const Text('Deskripsi',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                width: isTablet ? 80 : 120,
                child: const Text('Biaya Poin',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                width: isTablet ? 80 : 100,
                child: const Text('Status',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                width: 80,
                child: const Text('Aksi',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),

        const Divider(height: 0),

        // Table body
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(0),
            itemCount: controller.rewards.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final reward = controller.rewards[index];
              final displayIndex = controller.startIndex + index;
              return _buildDesktopTableRow(
                  reward, displayIndex, controller, isTablet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTableRow(RewardModel reward, int displayIndex,
      RewardController controller, bool isTablet) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: isTablet ? 16 : 24, vertical: 16),
      child: Row(
        children: [
          // No.
          SizedBox(
            width: isTablet ? 40 : 60,
            child: Text(
              displayIndex.toString(),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Gambar
          SizedBox(
            width: isTablet ? 80 : 120,
            child: reward.imageUrl != null && reward.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      reward.imageUrl!,
                      width: isTablet ? 40 : 60,
                      height: isTablet ? 30 : 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: isTablet ? 40 : 60,
                          height: isTablet ? 30 : 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.image_not_supported,
                            size: isTablet ? 16 : 20,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    width: isTablet ? 40 : 60,
                    height: isTablet ? 30 : 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image,
                      size: isTablet ? 16 : 20,
                      color: Colors.grey[400],
                    ),
                  ),
          ),

          // Nama
          SizedBox(
            width: isTablet ? 120 : 200,
            child: Text(
              reward.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Deskripsi
          SizedBox(
            width: isTablet ? 150 : 200,
            child: Text(
              reward.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Biaya Poin
          SizedBox(
            width: isTablet ? 80 : 120,
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
            width: isTablet ? 80 : 100,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _showRewardDialog(Get.context!, controller,
                      reward: reward),
                  icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () =>
                      controller.showDeleteConfirmation(reward.id, reward.name),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView(RewardController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.rewards.length,
      itemBuilder: (context, index) {
        final reward = controller.rewards[index];
        final displayIndex = controller.startIndex + index;
        return _buildMobileCard(reward, displayIndex, controller);
      },
    );
  }

  Widget _buildMobileCard(
      RewardModel reward, int displayIndex, RewardController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: reward.imageUrl != null && reward.imageUrl!.isNotEmpty
                      ? Image.network(
                          reward.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.image_not_supported,
                                size: 24,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.image,
                            size: 24,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#$displayIndex - ${reward.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reward.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
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
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: reward.isActive
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              controller.formatStatus(reward.isActive),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    reward.isActive ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
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
                    switch (value) {
                      case 'edit':
                        _showRewardDialog(Get.context!, controller,
                            reward: reward);
                        break;
                      case 'delete':
                        controller.showDeleteConfirmation(
                            reward.id, reward.name);
                        break;
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardDialog(BuildContext context, RewardController controller,
      {RewardModel? reward}) {
    final isEdit = reward != null;
    final nameController = TextEditingController(text: reward?.name ?? '');
    final descriptionController =
        TextEditingController(text: reward?.description ?? '');
    final pointsController =
        TextEditingController(text: reward?.pointsCost.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width > 600 ? 500 : null,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    isEdit ? 'Edit Hadiah' : 'Tambah Hadiah Baru',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form fields
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Hadiah',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama hadiah tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: pointsController,
                    decoration: const InputDecoration(
                      labelText: 'Biaya Poin',
                      border: OutlineInputBorder(),
                      suffixText: 'PTS',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Biaya poin tidak boleh kosong';
                      }
                      final points = int.tryParse(value);
                      if (points == null || points <= 0) {
                        return 'Biaya poin harus berupa angka positif';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Note about image upload
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Upload gambar belum tersedia. Fitur ini akan ditambahkan setelah HttpClient mendukung multipart.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        final isLoading = isEdit
                            ? controller.isUpdating.value
                            : controller.isCreating.value;
                        return ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    final name = nameController.text.trim();
                                    final description =
                                        descriptionController.text.trim();
                                    final points =
                                        int.parse(pointsController.text.trim());

                                    if (isEdit) {
                                      await controller.updateReward(
                                        rewardId: reward.id,
                                        name: name,
                                        description: description,
                                        pointsCost: points,
                                      );
                                    } else {
                                      await controller.createReward(
                                        name: name,
                                        description: description,
                                        pointsCost: points,
                                      );
                                    }

                                    if (controller.error.value.isEmpty) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(isEdit ? 'Perbarui' : 'Simpan'),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
