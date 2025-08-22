// screens/credential_access_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/api_key/api_key_controller.dart';

class CredentialAccessScreen extends StatelessWidget {
  const CredentialAccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApiKeyController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Credential Access'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                const Text(
                  'Credential Access',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Status Message
            Obx(() => controller.currentApiKey.value != null
                ? const Text(
                    'Credential ditemukan.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  )
                : const Text(
                    'Credential tidak ditemukan.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  )),
            const SizedBox(height: 32),

            // Loading indicator
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return const SizedBox.shrink();
            }),

            // Form Section
            Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Field
                  _buildTextField(
                    controller: controller.nameController,
                    label: 'Name',
                    hint: 'Masukkan Nama',
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Description Field
                  _buildTextField(
                    controller: controller.descriptionController,
                    label: 'Deskripsi',
                    hint: 'Masukkan Deskripsi',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Callback URL Field
                  _buildTextField(
                    controller: controller.callbackUrlController,
                    label: 'CallBack URL',
                    hint: 'Masukkan CallBack URL',
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'CallBack URL wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // X-API-KEY Field
                  Obx(() => _buildTextField(
                        controller: controller.keyController,
                        label: 'X-API-KEY',
                        hint: 'Masukkan API Key',
                        isRequired: true,
                        obscureText: !controller.showApiKey.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.showApiKey.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: controller.toggleApiKeyVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'X-API-KEY wajib diisi';
                          }
                          return null;
                        },
                      )),
                  const SizedBox(height: 24),

                  // X-SECRET-KEY Field
                  Obx(() => _buildTextField(
                        controller: controller.secretController,
                        label: 'X-SECRET-KEY',
                        hint: 'Masukkan Secret Key',
                        isRequired: true,
                        obscureText: !controller.showSecretKey.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.showSecretKey.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: controller.toggleSecretKeyVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'X-SECRET-KEY wajib diisi';
                          }
                          return null;
                        },
                      )),
                  const SizedBox(height: 48),

                  // Submit Button
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.handleButtonPress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.buttonColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  controller.buttonText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      )),
                ],
              ),
            ),

            // Clear Form Button (only show when in edit mode)
            Obx(() {
              if (controller.hasExistingData) {
                return Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: controller.clearForm,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Buat Baru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
