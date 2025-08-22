import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/points/points_model.dart';
import 'package:pos/services/points/points_service.dart';

class PointConfigController extends GetxController {
  final PointConfigService _pointConfigService = PointConfigService.instance;

  // Observable variables
  final RxList<PointConfig> pointConfigs = <PointConfig>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingAction = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final List<int> availablePageSizes = [5, 10, 25, 50];

  // Form controllers
  final amountController = TextEditingController();
  final pointsController = TextEditingController();
  final RxBool isActiveForm = true.obs;
  final RxBool isEditMode = false.obs;
  final RxString editingId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPointConfigs();
  }

  @override
  void onClose() {
    amountController.dispose();
    pointsController.dispose();
    super.onClose();
  }

  // Pagination getters
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

  // Load point configs
  Future<void> loadPointConfigs({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      errorMessage.value = '';

      final response = await _pointConfigService.getPointConfigs(
        page: currentPage.value,
        limit: itemsPerPage.value,
      );

      pointConfigs.assignAll(response.data);

      if (response.metadata != null) {
        totalItems.value = response.metadata!.total;
        totalPages.value = response.metadata!.totalPages;
        currentPage.value = response.metadata!.page;
        itemsPerPage.value = response.metadata!.limit;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load point configs: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Pagination handlers
  void onPageSizeChanged(int newSize) {
    itemsPerPage.value = newSize;
    currentPage.value = 1;
    loadPointConfigs();
  }

  void onPreviousPage() {
    if (hasPreviousPage) {
      currentPage.value--;
      loadPointConfigs();
    }
  }

  void onNextPage() {
    if (hasNextPage) {
      currentPage.value++;
      loadPointConfigs();
    }
  }

  void onPageSelected(int page) {
    currentPage.value = page;
    loadPointConfigs();
  }

  // Form methods
  void clearForm() {
    amountController.clear();
    pointsController.clear();
    isActiveForm.value = true;
    isEditMode.value = false;
    editingId.value = '';
  }

  void fillFormForEdit(PointConfig pointConfig) {
    amountController.text = pointConfig.amount.toString();
    pointsController.text = pointConfig.points.toString();
    isActiveForm.value = pointConfig.isActive;
    isEditMode.value = true;
    editingId.value = pointConfig.id;
  }

  // Validate form
  bool validateForm() {
    if (amountController.text.isEmpty) {
      Get.snackbar('Error', 'Amount is required');
      return false;
    }

    if (pointsController.text.isEmpty) {
      Get.snackbar('Error', 'Points is required');
      return false;
    }

    final amount = int.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Amount must be a valid positive number');
      return false;
    }

    final points = int.tryParse(pointsController.text);
    if (points == null || points <= 0) {
      Get.snackbar('Error', 'Points must be a valid positive number');
      return false;
    }

    return true;
  }

  // Save point config (create or update)
  Future<void> savePointConfig() async {
    if (!validateForm()) return;

    try {
      isLoadingAction.value = true;

      final request = PointConfigRequest(
        amount: int.parse(amountController.text),
        points: int.parse(pointsController.text),
        isActive: isActiveForm.value,
      );

      if (isEditMode.value) {
        await _pointConfigService.updatePointConfig(
          id: editingId.value,
          request: request,
        );
        Get.snackbar(
          'Success',
          'Point config updated successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        await _pointConfigService.createPointConfig(request: request);
        Get.snackbar(
          'Success',
          'Point config created successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      clearForm();
      await loadPointConfigs(showLoading: false);
      Get.back(); // Close dialog
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save point config: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingAction.value = false;
    }
  }

  // Toggle active status
  Future<void> toggleActiveStatus(PointConfig pointConfig) async {
    try {
      isLoadingAction.value = true;

      await _pointConfigService.togglePointConfigStatus(
        id: pointConfig.id,
        isActive: !pointConfig.isActive,
      );

      Get.snackbar(
        'Success',
        pointConfig.isActive
            ? 'Point config deactivated successfully'
            : 'Point config activated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await loadPointConfigs(showLoading: false);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to toggle status: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingAction.value = false;
    }
  }

  // Delete point config
  Future<void> deletePointConfig(PointConfig pointConfig) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete this point config?\n\nAmount: ${pointConfig.amount}\nPoints: ${pointConfig.points}'),
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

      if (confirmed != true) return;

      isLoadingAction.value = true;

      await _pointConfigService.deletePointConfig(id: pointConfig.id);

      Get.snackbar(
        'Success',
        'Point config deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await loadPointConfigs(showLoading: false);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete point config: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingAction.value = false;
    }
  }

  // Show create dialog
  void showCreateDialog() {
    clearForm();
    _showFormDialog();
  }

  // Show edit dialog
  void showEditDialog(PointConfig pointConfig) {
    fillFormForEdit(pointConfig);
    _showFormDialog();
  }

  // Show form dialog
  void _showFormDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
            isEditMode.value ? 'Edit Point Config' : 'Create Point Config'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (IDR)',
                  hintText: 'Enter amount in IDR',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Points',
                  hintText: 'Enter points to earn',
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => SwitchListTile(
                    title: const Text('Active'),
                    value: isActiveForm.value,
                    onChanged: (value) => isActiveForm.value = value,
                    contentPadding: EdgeInsets.zero,
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
                onPressed: isLoadingAction.value ? null : savePointConfig,
                child: isLoadingAction.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditMode.value ? 'Update' : 'Create'),
              )),
        ],
      ),
    );
  }
}
