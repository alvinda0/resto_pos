// controllers/referral_controller.dart
import 'package:get/get.dart';
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

  // Fetch all referrals
  Future<void> fetchReferrals() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _referralService.getAllReferrals();

      referrals.value = response.data;

      // Show success message
      if (response.data.isNotEmpty) {
        Get.snackbar(
          'Success',
          'Referrals loaded successfully',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load referrals: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch referral by ID
  Future<void> fetchReferralById(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final referral = await _referralService.getReferralById(id);
      selectedReferral.value = referral;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load referral: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create new referral
  Future<void> createReferral({
    required String storeId,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String code,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final newReferral = await _referralService.createReferral(
        storeId: storeId,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        code: code,
      );

      // Add to local list
      referrals.add(newReferral);

      Get.snackbar(
        'Success',
        'Referral created successfully',
        snackPosition: SnackPosition.TOP,
      );

      // Go back or refresh
      Get.back();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to create referral: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update referral
  Future<void> updateReferral(
    String id, {
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? code,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final updatedReferral = await _referralService.updateReferral(
        id,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        code: code,
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
      );

      Get.back();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update referral: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete referral
  Future<void> deleteReferral(String id) async {
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
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete referral: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch referrals by store ID
  Future<void> fetchReferralsByStoreId(String storeId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _referralService.getReferralsByStoreId(storeId);
      referrals.value = response.data;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load referrals by store: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch referrals by customer ID
  Future<void> fetchReferralsByCustomerId(String customerId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response =
          await _referralService.getReferralsByCustomerId(customerId);
      referrals.value = response.data;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load referrals by customer: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Search referral by code
  Future<void> searchReferralByCode(String code) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final referral = await _referralService.getReferralByCode(code);
      selectedReferral.value = referral;

      Get.snackbar(
        'Success',
        'Referral found: ${referral.customerName}',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      selectedReferral.value = null;
      Get.snackbar(
        'Error',
        'Referral not found: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
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
