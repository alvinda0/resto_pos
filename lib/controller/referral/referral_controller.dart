// controllers/referral_controller.dart
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/exceptions/exceptions.dart';
import 'package:pos/models/referral/referral_model.dart';
import 'package:pos/services/referral/referral_service.dart';

class ReferralController extends GetxController {
  final ReferralService _referralService = ReferralService.instance;

  // Observable variables
  final RxList<ReferralModel> referrals = <ReferralModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ReferralModel?> selectedReferral = Rx<ReferralModel?>(null);

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = true.obs;

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
      // GetHttpException does not expose statusCode directly; use message or statusText
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

  // Input validation method
  bool _validateReferralInput({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String code,
  }) {
    if (customerName.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Customer name cannot be empty');
      return false;
    }

    if (customerPhone.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Customer phone cannot be empty');
      return false;
    }

    if (customerEmail.trim().isEmpty || !GetUtils.isEmail(customerEmail)) {
      Get.snackbar('Validation Error', 'Please enter a valid email address');
      return false;
    }

    if (code.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Referral code cannot be empty');
      return false;
    }

    return true;
  }

  // Fetch all referrals
  Future<void> fetchReferrals() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _referralService.getAllReferrals();

      if (response.data != null) {
        referrals.value = response.data;

        // Only show success message if there's data
        if (response.data.isNotEmpty) {
          Get.snackbar(
            'Success',
            'Referrals loaded successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
          );
        }
      } else {
        referrals.value = [];
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

  // Create new referral with validation
  Future<void> createReferral({
    required String storeId,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String code,
  }) async {
    // Validate input
    if (!_validateReferralInput(
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      code: code,
    )) {
      return;
    }

    if (storeId.trim().isEmpty || customerId.trim().isEmpty) {
      Get.snackbar('Error', 'Store ID and Customer ID are required');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final newReferral = await _referralService.createReferral(
        storeId: storeId.trim(),
        customerId: customerId.trim(),
        customerName: customerName.trim(),
        customerPhone: customerPhone.trim(),
        customerEmail: customerEmail.trim(),
        code: code.trim(),
      );

      // Add to local list
      referrals.add(newReferral);

      Get.snackbar(
        'Success',
        'Referral created successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      // Go back or refresh
      Get.back();
    } catch (e) {
      _handleError(e, 'create referral');
    } finally {
      isLoading.value = false;
    }
  }

  // Update referral with validation
  Future<void> updateReferral(
    String id, {
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? code,
  }) async {
    if (id.trim().isEmpty) {
      Get.snackbar('Error', 'Invalid referral ID');
      return;
    }

    // Validate non-null inputs
    if (customerName != null && customerName.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Customer name cannot be empty');
      return;
    }

    if (customerPhone != null && customerPhone.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Customer phone cannot be empty');
      return;
    }

    if (customerEmail != null &&
        (customerEmail.trim().isEmpty || !GetUtils.isEmail(customerEmail))) {
      Get.snackbar('Validation Error', 'Please enter a valid email address');
      return;
    }

    if (code != null && code.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Referral code cannot be empty');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final updatedReferral = await _referralService.updateReferral(
        id,
        customerName: customerName?.trim(),
        customerPhone: customerPhone?.trim(),
        customerEmail: customerEmail?.trim(),
        code: code?.trim(),
      );

      // Update local list
      final index = referrals.indexWhere((referral) => referral.id == id);
      if (index != -1) {
        referrals[index] = updatedReferral;
      }

      // Update selected referral if it matches
      if (selectedReferral.value?.id == id) {
        selectedReferral.value = updatedReferral;
      }

      Get.snackbar(
        'Success',
        'Referral updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      Get.back();
    } catch (e) {
      _handleError(e, 'update referral');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete referral
  Future<void> deleteReferral(String id) async {
    if (id.trim().isEmpty) {
      Get.snackbar('Error', 'Invalid referral ID');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final success = await _referralService.deleteReferral(id);

      if (success) {
        // Remove from local list
        referrals.removeWhere((referral) => referral.id == id);

        // Clear selected referral if it matches
        if (selectedReferral.value?.id == id) {
          selectedReferral.value = null;
        }

        Get.snackbar(
          'Success',
          'Referral deleted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }
    } catch (e) {
      _handleError(e, 'delete referral');
    } finally {
      isLoading.value = false;
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
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
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
