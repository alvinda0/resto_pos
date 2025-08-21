import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/employee/employe_model.dart';
import 'package:pos/services/employee/employee_service.dart';

class EmployeeController extends GetxController {
  final EmployeeService _employeeService = EmployeeService.instance;

  // Observable variables
  final RxList<Employee> employees = <Employee>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingAction = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxList<int> availablePageSizes = [5, 10, 15, 20, 25].obs;

  // Search variables
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  // Form validation
  final RxBool isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadEmployees();

    // Listen to search query changes
    debounce(searchQuery, (_) => searchEmployees(),
        time: const Duration(milliseconds: 500));

    // Add listeners to form controllers for validation
    nameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
    positionController.addListener(_validateForm);
    salaryController.addListener(_validateForm);
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    positionController.dispose();
    salaryController.dispose();
    super.onClose();
  }

  // Load employees with pagination
  Future<void> loadEmployees({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      errorMessage.value = '';

      final response = await _employeeService.getEmployees(
        page: currentPage.value,
        limit: itemsPerPage.value,
      );

      if (response.success) {
        employees.value = response.data;
        if (response.metadata != null) {
          totalItems.value = response.metadata!.total;
          totalPages.value = response.metadata!.totalPages;
        }
      } else {
        errorMessage.value = response.message;
        Get.snackbar('Error', response.message,
            backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  // Search employees
  Future<void> searchEmployees() async {
    currentPage.value = 1; // Reset to first page when searching
    await loadEmployees();
  }

  // Create new employee
  Future<bool> createEmployee(Employee employee) async {
    try {
      isLoadingAction.value = true;

      // Validate employee data
      final validationError = _employeeService.validateEmployee(employee);
      if (validationError != null) {
        Get.snackbar('Validation Error', validationError,
            backgroundColor: Colors.orange.shade100);
        return false;
      }

      final response = await _employeeService.createEmployee(employee);

      if (response.success) {
        Get.snackbar('Success', 'Employee created successfully',
            backgroundColor: Colors.green.shade100);
        await loadEmployees(showLoading: false);
        clearForm();
        return true;
      } else {
        Get.snackbar('Error', response.message,
            backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
      return false;
    } finally {
      isLoadingAction.value = false;
    }
  }

  // Update employee
  Future<bool> updateEmployee(String id, Employee employee) async {
    try {
      isLoadingAction.value = true;

      // Validate employee data
      final validationError = _employeeService.validateEmployee(employee);
      if (validationError != null) {
        Get.snackbar('Validation Error', validationError,
            backgroundColor: Colors.orange.shade100);
        return false;
      }

      final response = await _employeeService.updateEmployee(id, employee);

      if (response.success) {
        Get.snackbar('Success', 'Employee updated successfully',
            backgroundColor: Colors.green.shade100);
        await loadEmployees(showLoading: false);
        clearForm();
        return true;
      } else {
        Get.snackbar('Error', response.message,
            backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
      return false;
    } finally {
      isLoadingAction.value = false;
    }
  }

  // Delete employee
  Future<bool> deleteEmployee(String id) async {
    try {
      isLoadingAction.value = true;

      final response = await _employeeService.deleteEmployee(id);

      if (response.success) {
        Get.snackbar('Success', 'Employee deleted successfully',
            backgroundColor: Colors.green.shade100);
        await loadEmployees(showLoading: false);
        return true;
      } else {
        Get.snackbar('Error', response.message,
            backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
      return false;
    } finally {
      isLoadingAction.value = false;
    }
  }

  // Show delete confirmation dialog
  void showDeleteConfirmation(Employee employee) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteEmployee(employee.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Pagination methods
  void goToNextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadEmployees();
    }
  }

  void goToPreviousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadEmployees();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      currentPage.value = page;
      loadEmployees();
    }
  }

  void changePageSize(int newSize) {
    itemsPerPage.value = newSize;
    currentPage.value = 1; // Reset to first page
    loadEmployees();
  }

  // Pagination helper methods
  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => currentPage.value < totalPages.value;

  int get startIndex {
    if (totalItems.value == 0) return 0;
    return (currentPage.value - 1) * itemsPerPage.value + 1;
  }

  int get endIndex {
    final end = currentPage.value * itemsPerPage.value;
    return end > totalItems.value ? totalItems.value : end;
  }

  List<int> get pageNumbers {
    List<int> pages = [];

    // Simple pagination: show current page ± 2
    int start = (currentPage.value - 2).clamp(1, totalPages.value);
    int end = (currentPage.value + 2).clamp(1, totalPages.value);

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    return pages;
  }

  // Form methods
  void clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    positionController.clear();
    salaryController.clear();
    isFormValid.value = false;
  }

  void fillForm(Employee employee) {
    nameController.text = employee.name;
    emailController.text = employee.email;
    phoneController.text = employee.phone;
    positionController.text = employee.position;
    salaryController.text = employee.baseSalary.toStringAsFixed(0);
    _validateForm();
  }

  Employee getEmployeeFromForm() {
    return Employee(
      id: '',
      storeId: '',
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      position: positionController.text.trim(),
      baseSalary: double.tryParse(salaryController.text.trim()) ?? 0,
    );
  }

  void _validateForm() {
    final employee = getEmployeeFromForm();
    final validationError = _employeeService.validateEmployee(employee);
    isFormValid.value = validationError == null;
  }

  // Search methods
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  // Refresh data
  Future<void> refreshData() async {
    currentPage.value = 1;
    await loadEmployees();
  }

  // Format salary for display
  String formatSalary(double salary) {
    return _employeeService.formatSalary(salary);
  }
}
