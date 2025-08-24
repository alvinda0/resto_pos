import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/auth/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.store,
                  size: 72,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Shao Kao',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masuk ke sistem Point of Sale',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Form Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: authController.loginFormKey,
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: authController.emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: authController.validateEmail,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                            hintText: 'Masukkan email Anda',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Obx(() => TextFormField(
                              controller: authController.passwordController,
                              obscureText: !authController.passwordVisible,
                              validator: authController.validatePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: const OutlineInputBorder(),
                                hintText: 'Masukkan password Anda',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    authController.passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: authController.passwordVisible
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                  ),
                                  onPressed:
                                      authController.togglePasswordVisibility,
                                ),
                              ),
                            )),
                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() => ElevatedButton(
                                onPressed: authController.isLoading
                                    ? null
                                    : authController.login,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.deepPurple,
                                  disabledBackgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: authController.isLoading ? 0 : 2,
                                ),
                                child: authController.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Forgot Password
              TextButton(
                onPressed: () {
                  Get.snackbar(
                    'Info',
                    'Fitur lupa password belum tersedia',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange[100],
                    colorText: Colors.orange[800],
                    duration: const Duration(seconds: 2),
                  );
                },
                child: Text(
                  'Lupa password?',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Development Info (hapus di production)
              if (authController.emailController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Development Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Email dan password sudah diisi otomatis',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
