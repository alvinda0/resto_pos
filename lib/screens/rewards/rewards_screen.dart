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
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty && controller.rewards.isEmpty) {
          return _buildErrorState(controller);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth <= 768;
            return Column(
              children: [
                _buildHeader(context, controller, isMobile),
                _buildContent(controller, isMobile),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildErrorState(RewardController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Terjadi kesalahan',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600])),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(controller.error.value,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: controller.refreshData,
              child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, RewardController controller, bool isMobile) {
    return Container(
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
                  color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => _showRewardDialog(context, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 18),
                if (!isMobile) ...[
                  const SizedBox(width: 8),
                  const Text('Tambah Hadiah')
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(RewardController controller, bool isMobile) {
    return Expanded(
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
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: controller.rewards.isEmpty
                  ? const Center(
                      child: Text('Tidak ada data hadiah',
                          style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : isMobile
                      ? _buildMobileView(controller)
                      : _buildTableView(controller),
            ),
            _buildPagination(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildTableView(RewardController controller) {
    return Column(
      children: [
        _buildTableHeader(),
        const Divider(height: 0),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(0),
            itemCount: controller.rewards.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final reward = controller.rewards[index];
              final displayIndex = controller.startIndex + index;
              return _buildTableRow(reward, displayIndex, controller);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildHeaderCell('No.', flex: 1),
          _buildHeaderCell('Gambar', flex: 2),
          _buildHeaderCell('Nama', flex: 3),
          _buildHeaderCell('Deskripsi', flex: 3),
          _buildHeaderCell('Poin', flex: 2),
          _buildHeaderCell('Status', flex: 2),
          _buildHeaderCell('Aksi', flex: 2),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );
  }

  Widget _buildTableRow(
      RewardModel reward, int displayIndex, RewardController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(displayIndex.toString(),
                  style: const TextStyle(fontSize: 13)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildImageWidget(reward, size: 32),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(reward.name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(reward.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child:
                  _buildPointsBadge(controller.formatPoints(reward.pointsCost)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildStatusBadge(
                  reward.isActive, controller.formatStatus(reward.isActive)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildActionButtons(reward, controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(RewardModel reward, {double size = 60}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: reward.imageUrl != null && reward.imageUrl!.isNotEmpty
          ? Image.network(
              reward.imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(size),
            )
          : _buildImagePlaceholder(size),
    );
  }

  Widget _buildImagePlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      child: Icon(Icons.image, size: size * 0.4, color: Colors.grey[400]),
    );
  }

  Widget _buildPointsBadge(String points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
      child: Text(points,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue),
          textAlign: TextAlign.center),
    );
  }

  Widget _buildStatusBadge(bool isActive, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
          color: isActive ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(4)),
      child: Text(status,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green : Colors.red),
          textAlign: TextAlign.center),
    );
  }

  Widget _buildActionButtons(RewardModel reward, RewardController controller) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 16),
      iconSize: 16,
      padding: EdgeInsets.zero,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16, color: Colors.blue),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                reward.isActive ? Icons.toggle_off : Icons.toggle_on,
                size: 16,
                color: reward.isActive ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                reward.isActive ? 'Nonaktifkan' : 'Aktifkan',
                style: TextStyle(
                  color: reward.isActive ? Colors.orange : Colors.green,
                ),
              ),
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
            _showRewardDialog(Get.context!, controller, reward: reward);
            break;
          case 'toggle':
            controller.showToggleStatusConfirmation(
                reward.id, reward.name, reward.isActive);
            break;
          case 'delete':
            controller.showDeleteConfirmation(reward.id, reward.name);
            break;
        }
      },
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
        child: Row(
          children: [
            _buildImageWidget(reward),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#$displayIndex - ${reward.name}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(reward.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPointsBadge(
                          controller.formatPoints(reward.pointsCost)),
                      const SizedBox(width: 8),
                      _buildStatusBadge(reward.isActive,
                          controller.formatStatus(reward.isActive)),
                    ],
                  ),
                ],
              ),
            ),
            _buildMobilePopupMenu(reward, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePopupMenu(
      RewardModel reward, RewardController controller) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: 'edit',
            child: Row(children: [
              Icon(Icons.edit, size: 16),
              SizedBox(width: 8),
              Text('Edit')
            ])),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(reward.isActive ? Icons.toggle_off : Icons.toggle_on,
                  size: 16,
                  color: reward.isActive ? Colors.orange : Colors.green),
              const SizedBox(width: 8),
              Text(reward.isActive ? 'Nonaktifkan' : 'Aktifkan',
                  style: TextStyle(
                      color: reward.isActive ? Colors.orange : Colors.green)),
            ],
          ),
        ),
        const PopupMenuItem(
            value: 'delete',
            child: Row(children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus', style: TextStyle(color: Colors.red))
            ])),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showRewardDialog(Get.context!, controller, reward: reward);
            break;
          case 'toggle':
            controller.showToggleStatusConfirmation(
                reward.id, reward.name, reward.isActive);
            break;
          case 'delete':
            controller.showDeleteConfirmation(reward.id, reward.name);
            break;
        }
      },
    );
  }

  Widget _buildPagination(RewardController controller) {
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
      onPageSizeChanged: controller.changePageSize,
      onPreviousPage: controller.previousPage,
      onNextPage: controller.nextPage,
      onPageSelected: controller.goToPage,
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

    controller.clearSelectedImage();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width > 600 ? 500 : null,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEdit ? 'Edit Hadiah' : 'Tambah Hadiah Baru',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    _buildImageSection(controller, reward),
                    const SizedBox(height: 16),
                    _buildFormFields(nameController, descriptionController,
                        pointsController),
                    const SizedBox(height: 24),
                    _buildDialogActions(
                        context,
                        controller,
                        formKey,
                        nameController,
                        descriptionController,
                        pointsController,
                        reward,
                        isEdit),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(RewardController controller, RewardModel? reward) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gambar Hadiah',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700])),
        const SizedBox(height: 8),
        Obx(() => Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8)),
              child: controller.selectedImage.value != null
                  ? _buildSelectedImage(controller)
                  : reward?.imageUrl != null && reward!.imageUrl!.isNotEmpty
                      ? _buildExistingImage(reward, controller)
                      : _buildImagePickerPlaceholder(controller),
            )),
      ],
    );
  }

  Widget _buildSelectedImage(RewardController controller) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(controller.selectedImage.value!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.red,
            child: IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                onPressed: controller.clearSelectedImage),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingImage(RewardModel reward, RewardController controller) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            reward.imageUrl!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildImagePickerPlaceholder(controller),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: FloatingActionButton.small(
              onPressed: controller.showImagePickerOptions,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.edit, size: 16)),
        ),
      ],
    );
  }

  Widget _buildImagePickerPlaceholder(RewardController controller) {
    return InkWell(
      onTap: controller.showImagePickerOptions,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('Tambah Gambar',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            Text('Tap untuk memilih gambar',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(
      TextEditingController nameController,
      TextEditingController descriptionController,
      TextEditingController pointsController) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
              labelText: 'Nama Hadiah', border: OutlineInputBorder()),
          validator: (value) => value?.trim().isEmpty ?? true
              ? 'Nama hadiah tidak boleh kosong'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
              labelText: 'Deskripsi', border: OutlineInputBorder()),
          maxLines: 3,
          validator: (value) => value?.trim().isEmpty ?? true
              ? 'Deskripsi tidak boleh kosong'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: pointsController,
          decoration: const InputDecoration(
              labelText: 'Biaya Poin',
              border: OutlineInputBorder(),
              suffixText: 'PTS'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value?.trim().isEmpty ?? true)
              return 'Biaya poin tidak boleh kosong';
            final points = int.tryParse(value!);
            return points == null || points <= 0
                ? 'Biaya poin harus berupa angka positif'
                : null;
          },
        ),
      ],
    );
  }

  Widget _buildDialogActions(
      BuildContext context,
      RewardController controller,
      GlobalKey<FormState> formKey,
      TextEditingController nameController,
      TextEditingController descriptionController,
      TextEditingController pointsController,
      RewardModel? reward,
      bool isEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            controller.clearSelectedImage();
            Navigator.of(context).pop();
          },
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
                : () => _handleSubmit(
                    context,
                    controller,
                    formKey,
                    nameController,
                    descriptionController,
                    pointsController,
                    reward,
                    isEdit),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(isEdit ? 'Perbarui' : 'Simpan'),
          );
        }),
      ],
    );
  }

  void _handleSubmit(
      BuildContext context,
      RewardController controller,
      GlobalKey<FormState> formKey,
      TextEditingController nameController,
      TextEditingController descriptionController,
      TextEditingController pointsController,
      RewardModel? reward,
      bool isEdit) async {
    if (formKey.currentState?.validate() ?? false) {
      final name = nameController.text.trim();
      final description = descriptionController.text.trim();
      final points = int.parse(pointsController.text.trim());

      if (isEdit) {
        await controller.updateReward(
          rewardId: reward!.id,
          name: name,
          description: description,
          pointsCost: points,
          image: controller.selectedImage.value,
        );
      } else {
        await controller.createReward(
          name: name,
          description: description,
          pointsCost: points,
          image: controller.selectedImage.value,
        );
      }

      if (controller.error.value.isEmpty) {
        Navigator.of(context).pop();
      }
    }
  }
}
