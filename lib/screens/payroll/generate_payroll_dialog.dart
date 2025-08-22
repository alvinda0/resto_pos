import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/payroll/payroll_model.dart';

class GeneratePayrollDialog {
  static void show(Function(PayrollGenerateRequest) onGenerate) {
    final monthController = TextEditingController();
    final bonusController = TextEditingController();
    final deductionsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Set default month to current month
    final now = DateTime.now();
    monthController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.play_circle_outline, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Generate Payroll'),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Input
                  TextFormField(
                    controller: monthController,
                    decoration: const InputDecoration(
                      labelText: 'Payroll Month *',
                      hintText: '2025-08',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month),
                      helperText: 'Format: YYYY-MM',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter payroll month';
                      }
                      final regex = RegExp(r'^\d{4}-\d{2}$');
                      if (!regex.hasMatch(value)) {
                        return 'Invalid format. Use YYYY-MM (e.g., 2025-08)';
                      }

                      // Validate month range
                      final parts = value.split('-');
                      final month = int.tryParse(parts[1]);
                      if (month == null || month < 1 || month > 12) {
                        return 'Invalid month. Use 01-12';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Global Adjustments Section
                  Text(
                    'Global Adjustments (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These amounts will be applied to all employees',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bonus Input
                  TextFormField(
                    controller: bonusController,
                    decoration: const InputDecoration(
                      labelText: 'Bonus Amount',
                      hintText: '500000',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final bonus =
                            double.tryParse(value.replaceAll(',', ''));
                        if (bonus == null || bonus < 0) {
                          return 'Invalid bonus amount';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Deductions Input
                  TextFormField(
                    controller: deductionsController,
                    decoration: const InputDecoration(
                      labelText: 'Deductions Amount',
                      hintText: '200000',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.remove_circle_outline),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final deductions =
                            double.tryParse(value.replaceAll(',', ''));
                        if (deductions == null || deductions < 0) {
                          return 'Invalid deductions amount';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Information Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Payroll Generation Rules',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoPoint(
                            'Base salary will be taken from employee records'),
                        _buildInfoPoint(
                            'Global bonus/deductions apply to all employees'),
                        _buildInfoPoint(
                            'Leave fields empty for base salary only'),
                        _buildInfoPoint('Tax calculations are automatic'),
                        _buildInfoPoint(
                            'Existing payrolls for the same month will be skipped'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final request = PayrollGenerateRequest(
                  payrollMonth: monthController.text.trim(),
                  bonus: bonusController.text.trim().isNotEmpty
                      ? double.parse(
                          bonusController.text.trim().replaceAll(',', ''))
                      : null,
                  deductions: deductionsController.text.trim().isNotEmpty
                      ? double.parse(
                          deductionsController.text.trim().replaceAll(',', ''))
                      : null,
                );

                Get.back();
                onGenerate(request);
              }
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Generate Payroll'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Advanced Generate Dialog with Employee Override
class AdvancedGeneratePayrollDialog {
  static void show(Function(PayrollGenerateRequest) onGenerate) {
    final monthController = TextEditingController();
    final bonusController = TextEditingController();
    final deductionsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final RxList<PayrollOverride> overrides = <PayrollOverride>[].obs;
    final RxBool showAdvanced = false.obs;

    // Set default month to current month
    final now = DateTime.now();
    monthController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings_outlined, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Advanced Payroll Generation'),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 600,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Settings
                  _buildSectionTitle('Basic Settings'),
                  TextFormField(
                    controller: monthController,
                    decoration: const InputDecoration(
                      labelText: 'Payroll Month *',
                      hintText: '2025-08',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter payroll month';
                      }
                      final regex = RegExp(r'^\d{4}-\d{2}$');
                      if (!regex.hasMatch(value)) {
                        return 'Invalid format. Use YYYY-MM';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Global Adjustments
                  _buildSectionTitle('Global Adjustments'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: bonusController,
                          decoration: const InputDecoration(
                            labelText: 'Global Bonus',
                            border: OutlineInputBorder(),
                            prefixText: 'Rp ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: deductionsController,
                          decoration: const InputDecoration(
                            labelText: 'Global Deductions',
                            border: OutlineInputBorder(),
                            prefixText: 'Rp ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Employee Overrides Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Employee Overrides'),
                      Obx(() => Switch(
                            value: showAdvanced.value,
                            onChanged: (value) => showAdvanced.value = value,
                            activeColor: Colors.red,
                          )),
                    ],
                  ),

                  Obx(() => showAdvanced.value
                      ? _buildOverrideSection(overrides)
                      : Container()),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final request = PayrollGenerateRequest(
                  payrollMonth: monthController.text.trim(),
                  bonus: bonusController.text.trim().isNotEmpty
                      ? double.parse(bonusController.text.trim())
                      : null,
                  deductions: deductionsController.text.trim().isNotEmpty
                      ? double.parse(deductionsController.text.trim())
                      : null,
                  overrides: overrides.isNotEmpty ? overrides : null,
                );

                Get.back();
                onGenerate(request);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  static Widget _buildOverrideSection(RxList<PayrollOverride> overrides) {
    return Column(
      children: [
        // Add Override Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _addOverride(overrides),
            icon: const Icon(Icons.add),
            label: const Text('Add Employee Override'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.shade300),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Override List
        Obx(() => Column(
              children: overrides
                  .map((override) => _buildOverrideItem(override, overrides))
                  .toList(),
            )),
      ],
    );
  }

  static Widget _buildOverrideItem(
      PayrollOverride override, RxList<PayrollOverride> overrides) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Employee: ${override.employeeId.substring(0, 8)}...',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Text('Bonus: Rp ${override.bonus ?? 0}'),
            ),
            Expanded(
              child: Text('Deductions: Rp ${override.deductions ?? 0}'),
            ),
            IconButton(
              onPressed: () => overrides.remove(override),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  static void _addOverride(RxList<PayrollOverride> overrides) {
    final employeeIdController = TextEditingController();
    final bonusController = TextEditingController();
    final deductionsController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Employee Override'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: employeeIdController,
              decoration: const InputDecoration(
                labelText: 'Employee ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bonusController,
              decoration: const InputDecoration(
                labelText: 'Bonus Override',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: deductionsController,
              decoration: const InputDecoration(
                labelText: 'Deductions Override',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (employeeIdController.text.isNotEmpty) {
                final override = PayrollOverride(
                  employeeId: employeeIdController.text.trim(),
                  bonus: bonusController.text.isNotEmpty
                      ? double.parse(bonusController.text)
                      : null,
                  deductions: deductionsController.text.isNotEmpty
                      ? double.parse(deductionsController.text)
                      : null,
                );

                overrides.add(override);
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
