// controllers/referral_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/exceptions/exceptions.dart';
import 'package:pos/models/referral/referral_model.dart';
import 'package:pos/services/referral/referral_service.dart';

class ReferralController extends GetxController {
  final ReferralService _referralService = ReferralService.instance;

  // Observable variables
  final RxList<ReferralModel> referrals = <ReferralModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ReferralModel?> selectedReferral = Rx<ReferralModel?>(null);

  // Pagination properties
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;
  final List<int> availablePageSizes = [5, 10, 20, 50, 100];

  // Computed properties for pagination
  int get startIndex {
    if (totalItems.value == 0) return 0;
    return ((currentPage.value - 1) * itemsPerPage.value) + 1;
  }

  int get endIndex {
    final end = currentPage.value * itemsPerPage.value;
    return end > totalItems.value ? totalItems.value : end;
  }

  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => currentPage.value < totalPages.value;

  List<int> get pageNumbers {
    if (totalPages.value <= 7) {
      return List.generate(totalPages.value, (index) => index + 1);
    }

    final current = currentPage.value;
    final total = totalPages.value;

    if (current <= 4) {
      return [1, 2, 3, 4, 5, -1, total]; // -1 represents ellipsis
    } else if (current >= total - 3) {
      return [1, -1, total - 4, total - 3, total - 2, total - 1, total];
    } else {
      return [1, -1, current - 1, current, current + 1, -1, total];
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchReferrals();
  }

  // Improved error handling method
  void _handleError(dynamic error, String operation) {
    String errorMsg = error.toString();

    // Check for specific HTTP errors
    if (error is GetHttpException) {
      final message = error.message?.toLowerCase() ?? '';
      if (message.contains('400')) {
        errorMsg = 'Bad Request: Please check your input data';
      } else if (message.contains('401')) {
        errorMsg = 'Unauthorized: Please login again';
      } else if (message.contains('403')) {
        errorMsg = 'Forbidden: You don\'t have permission';
      } else if (message.contains('404')) {
        errorMsg = 'Not Found: Resource not found';
      } else if (message.contains('500')) {
        errorMsg = 'Server Error: Please try again later';
      } else {
        errorMsg = 'HTTP Error: $message';
      }
    }

    errorMessage.value = errorMsg;
    Get.snackbar(
      'Error',
      'Failed to $operation: $errorMsg',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  // Input validation method for referral
  bool _validateReferralInput({
    required String referralName,
    required String referralPhone,
    required String referralEmail,
    required double commissionRate,
  }) {
    if (referralName.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Referral name cannot be empty');
      return false;
    }

    if (referralPhone.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Referral phone cannot be empty');
      return false;
    }

    if (referralEmail.trim().isEmpty || !GetUtils.isEmail(referralEmail)) {
      Get.snackbar('Validation Error', 'Please enter a valid email address');
      return false;
    }

    if (commissionRate <= 0) {
      Get.snackbar(
          'Validation Error', 'Commission rate must be greater than 0');
      return false;
    }

    return true;
  }

  // Fetch referrals with pagination
  Future<void> fetchReferrals({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final response = await _referralService.getAllReferrals(
        page: currentPage.value,
        limit: itemsPerPage.value,
      );

      if (response.data != null) {
        referrals.value = response.data;
        totalItems.value = response.metadata?.total ?? response.data.length;
        totalPages.value = response.metadata?.totalPages ??
            (totalItems.value / itemsPerPage.value).ceil();

        // Only show success message if there's data and it's the first load
        if (response.data.isNotEmpty && showLoading) {
          Get.snackbar(
            'Success',
            'Referrals loaded successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
          );
        }
      } else {
        referrals.value = [];
        totalItems.value = 0;
        totalPages.value = 0;
      }
    } catch (e) {
      _handleError(e, 'load referrals');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch referral by ID
  Future<void> fetchReferralById(String id) async {
    if (id.trim().isEmpty) {
      Get.snackbar('Error', 'Invalid referral ID');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final referral = await _referralService.getReferralById(id);
      selectedReferral.value = referral;
    } catch (e) {
      _handleError(e, 'load referral');
    } finally {
      isLoading.value = false;
    }
  }

  // Create new referral with validation - Updated API parameters
  Future<void> createReferral({
    required String customerId,
    required String referralName,
    required String referralPhone,
    required String referralEmail,
    required String commissionType,
    required double commissionRate,
  }) async {
    // Validate input
    if (!_validateReferralInput(
      referralName: referralName,
      referralPhone: referralPhone,
      referralEmail: referralEmail,
      commissionRate: commissionRate,
    )) {
      return;
    }

    if (customerId.trim().isEmpty) {
      Get.snackbar('Error', 'Customer ID is required');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final newReferral = await _referralService.createReferral(
        customerId: customerId.trim(),
        referralName: referralName.trim(),
        referralPhone: referralPhone.trim(),
        referralEmail: referralEmail.trim(),
        commissionType: commissionType,
        commissionRate: commissionRate,
      );

      Get.snackbar(
        'Success',
        'Referral created successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        icon: Icon(Icons.check_circle_outline, color: Colors.green),
      );

      // Refresh data to get updated list
      await fetchReferrals(showLoading: false);

      // If we're not on page 1 and total pages increased, we might want to go to last page
      // But for better UX, let's stay on current page
    } catch (e) {
      _handleError(e, 'create referral');
    } finally {
      isLoading.value = false;
    }
  }

  // Update referral with validation - Updated API parameters
  Future<void> updateReferral(
    String id, {
    String? referralName,
    String? referralPhone,
    String? referralEmail,
    String? commissionType,
    double? commissionRate,
  }) async {
    if (id.trim().isEmpty) {
      Get.snackbar('Error', 'Invalid referral ID');
      return;
    }

    // Validate non-null inputs
    if (referralName != null && referralName.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Referral name cannot be empty');
      return;
    }

    if (referralPhone != null && referralPhone.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Referral phone cannot be empty');
      return;
    }

    if (referralEmail != null &&
        (referralEmail.trim().isEmpty || !GetUtils.isEmail(referralEmail))) {
      Get.snackbar('Validation Error', 'Please enter a valid email address');
      return;
    }

    if (commissionRate != null && commissionRate <= 0) {
      Get.snackbar(
          'Validation Error', 'Commission rate must be greater than 0');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _referralService.updateReferral(
        id,
        referralName: referralName?.trim(),
        referralPhone: referralPhone?.trim(),
        referralEmail: referralEmail?.trim(),
        commissionType: commissionType,
        commissionRate: commissionRate,
      );

      Get.snackbar(
        'Success',
        'Referral updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        icon: Icon(Icons.check_circle_outline, color: Colors.green),
      );

      // Refresh current page data
      await fetchReferrals(showLoading: false);
    } catch (e) {
      _handleError(e, 'update referral');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete referral with confirmation
  Future<void> deleteReferral(String id) async {
    if (id.trim().isEmpty) {
      Get.snackbar('Error', 'Invalid referral ID');
      return;
    }

    // Find referral for confirmation dialog
    final referral = referrals.firstWhereOrNull((r) => r.id == id);
    if (referral == null) {
      Get.snackbar('Error', 'Referral not found');
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showDeleteConfirmation(referral.customerName);
    if (!confirmed) return;

    try {
      isDeleting.value = true;
      errorMessage.value = '';

      final success = await _referralService.deleteReferral(id);

      if (success) {
        Get.snackbar(
          'Success',
          'Referral "${referral.customerName}" has been deleted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          icon: Icon(Icons.check_circle_outline, color: Colors.green),
        );

        // Refresh the list
        await fetchReferrals(showLoading: false);

        // If current page becomes empty and it's not page 1, go to previous page
        if (referrals.isEmpty && currentPage.value > 1) {
          currentPage.value--;
          await fetchReferrals(showLoading: false);
        }
      }
    } catch (e) {
      _handleError(e, 'delete referral');
    } finally {
      isDeleting.value = false;
    }
  }

  // Show delete confirmation dialog
  Future<bool> _showDeleteConfirmation(String referralName) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Confirm Delete'),
        content:
            Text('Are you sure you want to delete referral "$referralName"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }

  // Handle page size change
  void onPageSizeChanged(int newPageSize) {
    itemsPerPage.value = newPageSize;
    currentPage.value = 1; // Reset to first page
    fetchReferrals();
  }

  // Go to previous page
  void onPreviousPage() {
    if (hasPreviousPage) {
      currentPage.value--;
      fetchReferrals();
    }
  }

  // Go to next page
  void onNextPage() {
    if (hasNextPage) {
      currentPage.value++;
      fetchReferrals();
    }
  }

  // Go to specific page
  void onPageSelected(int page) {
    if (page != currentPage.value && page > 0 && page <= totalPages.value) {
      currentPage.value = page;
      fetchReferrals();
    }
  }

  // Fetch referrals by store ID
  Future<void> fetchReferralsByStoreId(String storeId) async {
    if (storeId.trim().isEmpty) {
      Get.snackbar('Error', 'Store ID cannot be empty');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _referralService.getReferralsByStoreId(storeId);
      referrals.value = response.data ?? [];
      totalItems.value = response.data?.length ?? 0;
      totalPages.value = 1; // Single page for filtered results
      currentPage.value = 1;
    } catch (e) {
      _handleError(e, 'load referrals by store');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch referrals by customer ID
  Future<void> fetchReferralsByCustomerId(String customerId) async {
    if (customerId.trim().isEmpty) {
      Get.snackbar('Error', 'Customer ID cannot be empty');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response =
          await _referralService.getReferralsByCustomerId(customerId);
      referrals.value = response.data ?? [];
      totalItems.value = response.data?.length ?? 0;
      totalPages.value = 1; // Single page for filtered results
      currentPage.value = 1;
    } catch (e) {
      _handleError(e, 'load referrals by customer');
    } finally {
      isLoading.value = false;
    }
  }

  // Search referral by code
  Future<void> searchReferralByCode(String code) async {
    if (code.trim().isEmpty) {
      Get.snackbar('Error', 'Referral code cannot be empty');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final referral = await _referralService.getReferralByCode(code.trim());
      selectedReferral.value = referral;

      Get.snackbar(
        'Success',
        'Referral found: ${referral.customerName}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      selectedReferral.value = null;
      _handleError(e, 'search referral');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data
  Future<void> refreshReferrals() async {
    await fetchReferrals();
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Clear selected referral
  void clearSelected() {
    selectedReferral.value = null;
  }

  // Filter referrals by customer name
  List<ReferralModel> filterByCustomerName(String query) {
    if (query.isEmpty) return referrals;

    return referrals
        .where((referral) =>
            referral.customerName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Filter referrals by code
  List<ReferralModel> filterByCode(String query) {
    if (query.isEmpty) return referrals;

    return referrals
        .where((referral) =>
            referral.code.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get referral count
  int get referralCount => referrals.length;

  // Check if referrals list is empty
  bool get isEmpty => referrals.isEmpty;

  // Check if has error
  bool get hasError => errorMessage.isNotEmpty;
}
