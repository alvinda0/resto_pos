// dialogs/user_form_dialog.dart - INTEGRATED WITH ROLE CONTROLLER
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/account/account_controller.dart';
import 'package:pos/controller/role/role_controller.dart';
import 'package:pos/models/account/account_model.dart';

class UserFormDialog {
  static void show({
    User? user, // If null, it's create mode. If not null, it's edit mode
  }) {
    final UserController userController = Get.find<UserController>();
    final RoleController roleController = Get.find<RoleController>();
    final formKey = GlobalKey<FormState>();
    final isEditMode = user != null;

    // Local reactive variables for password visibility
    final RxBool isPasswordVisible = false.obs;
    final RxBool isConfirmPasswordVisible = false.obs;

    // Fill form if editing
    if (isEditMode) {
      userController.fillForm(user);
    } else {
      userController.resetForm();
    }

    // Load roles when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      roleController.loadRoles();
    });

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 700),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    isEditMode ? Icons.edit : Icons.person_add,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditMode ? 'Edit User' : 'Tambah User Baru',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        TextFormField(
                          controller: userController.nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap *',
                            hintText: 'Masukkan nama lengkap',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: userController.validateName,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 16),

                        // Email field
                        TextFormField(
                          controller: userController.emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            hintText: 'Masukkan alamat email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: userController.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 16),

                        // Password field
                        Obx(() => TextFormField(
                              controller: userController.passwordController,
                              decoration: InputDecoration(
                                labelText: isEditMode
                                    ? 'Password Baru (Opsional)'
                                    : 'Password *',
                                hintText: isEditMode
                                    ? 'Kosongkan jika tidak ingin mengubah'
                                    : 'Masukkan password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    isPasswordVisible.value =
                                        !isPasswordVisible.value;
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  userController.validatePassword(value,
                                      isRequired: !isEditMode),
                              obscureText: !isPasswordVisible.value,
                              textInputAction: TextInputAction.next,
                            )),

                        const SizedBox(height: 16),

                        // Confirm Password field
                        Obx(() => TextFormField(
                              controller:
                                  userController.confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Konfirmasi Password',
                                hintText: 'Konfirmasi password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isConfirmPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    isConfirmPasswordVisible.value =
                                        !isConfirmPasswordVisible.value;
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: userController.validateConfirmPassword,
                              obscureText: !isConfirmPasswordVisible.value,
                              textInputAction: TextInputAction.next,
                            )),

                        const SizedBox(height: 16),

                        // Role dropdown - INTEGRATED WITH ROLE CONTROLLER (WITHOUT DESCRIPTION)
                        Obx(() {
                          final isLoadingRoles = roleController.isLoading.value;
                          final roles = roleController.roles;
                          final hasError = roleController.error.isNotEmpty;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                value:
                                    userController.selectedRoleId.value.isEmpty
                                        ? null
                                        : userController.selectedRoleId.value,
                                decoration: InputDecoration(
                                  labelText: 'Role *',
                                  prefixIcon: isLoadingRoles
                                      ? Container(
                                          width: 20,
                                          height: 20,
                                          padding: const EdgeInsets.all(12),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.grey.shade600),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.admin_panel_settings_outlined),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: hasError
                                      ? IconButton(
                                          icon: const Icon(Icons.refresh,
                                              color: Colors.red),
                                          onPressed: () =>
                                              roleController.loadRoles(),
                                          tooltip: 'Muat ulang data role',
                                        )
                                      : null,
                                ),
                                hint: Text(
                                  isLoadingRoles
                                      ? 'Memuat roles...'
                                      : hasError
                                          ? 'Error memuat roles'
                                          : roles.isEmpty
                                              ? 'Tidak ada role tersedia'
                                              : 'Pilih role',
                                ),
                                validator: userController.validateRole,
                                items: isLoadingRoles || hasError
                                    ? []
                                    : roles
                                        .map<DropdownMenuItem<String>>((role) {
                                        return DropdownMenuItem<String>(
                                          value: role.id,
                                          child: Text(
                                            role.name.isNotEmpty
                                                ? role.name
                                                : 'Nama role tidak tersedia',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                        );
                                      }).toList(),
                                onChanged: (isLoadingRoles ||
                                        hasError ||
                                        roles.isEmpty)
                                    ? null
                                    : (value) {
                                        userController.selectedRoleId.value =
                                            value ?? '';
                                      },
                              ),

                              // Show appropriate message based on state
                              const SizedBox(height: 8),
                              if (isLoadingRoles)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.blue.shade600),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Sedang memuat data role...',
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (hasError)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.red.shade600, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Gagal memuat data role',
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              roleController.error.value,
                                              style: TextStyle(
                                                color: Colors.red.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            roleController.loadRoles(),
                                        child: const Text('Coba Lagi'),
                                      ),
                                    ],
                                  ),
                                )
                              else if (roles.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.amber.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning_amber_outlined,
                                          color: Colors.amber.shade600,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Tidak ada role tersedia. Silakan buat role terlebih dahulu.',
                                          style: TextStyle(
                                            color: Colors.amber.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            roleController.loadRoles(),
                                        child: const Text('Muat Ulang'),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }),

                        const SizedBox(height: 16),

                        // Staff toggle
                        Obx(() => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_user_outlined),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Status Staff',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Apakah user ini adalah staff?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: userController.isStaff.value,
                                    onChanged: (value) {
                                      userController.isStaff.value = value;
                                    },
                                    activeColor: Colors.blue,
                                  ),
                                ],
                              ),
                            )),

                        const SizedBox(height: 20),

                        // Error message from UserController
                        Obx(() => userController.errorMessage.isNotEmpty
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        userController.errorMessage.value,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox()),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final isSubmittingUser =
                          userController.isSubmitting.value;
                      final isLoadingRoles = roleController.isLoading.value;
                      final hasRoles = roleController.roles.isNotEmpty;
                      final hasRoleError = roleController.error.isNotEmpty;

                      final canSubmit = !isSubmittingUser &&
                          !isLoadingRoles &&
                          hasRoles &&
                          !hasRoleError;

                      return ElevatedButton(
                        onPressed: canSubmit
                            ? () => _handleSubmit(
                                  formKey,
                                  userController,
                                  isEditMode,
                                  user?.id,
                                )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: isSubmittingUser
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                isEditMode ? 'Update' : 'Tambah',
                                style: const TextStyle(color: Colors.white),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void _handleSubmit(
    GlobalKey<FormState> formKey,
    UserController userController,
    bool isEditMode,
    String? userId,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Additional validation
    if (userController.selectedRoleId.value.isEmpty) {
      userController.showErrorMessage('Role harus dipilih');
      return;
    }

    bool success = false;

    if (isEditMode && userId != null) {
      // Update user
      success = await userController.updateUser(
        userId: userId,
        name: userController.nameController.text.trim(),
        email: userController.emailController.text.trim(),
        password: userController.passwordController.text.isEmpty
            ? null
            : userController.passwordController.text,
        isStaff: userController.isStaff.value,
        roleId: userController.selectedRoleId.value,
      );
    } else {
      // Create user
      success = await userController.createUser(
        name: userController.nameController.text.trim(),
        email: userController.emailController.text.trim(),
        password: userController.passwordController.text,
        isStaff: userController.isStaff.value,
        roleId: userController.selectedRoleId.value,
      );
    }

    if (success) {
      Get.back(); // Close dialog
    }
  }
}
