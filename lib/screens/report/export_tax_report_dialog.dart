// widgets/export_tax_report_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ExportTaxReportDialog extends StatefulWidget {
  final Function({
    DateTime? startDate,
    DateTime? endDate,
    double? newTaxRate,
    bool realTax,
  }) onExport;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const ExportTaxReportDialog({
    Key? key,
    required this.onExport,
    this.initialStartDate,
    this.initialEndDate,
  }) : super(key: key);

  @override
  State<ExportTaxReportDialog> createState() => _ExportTaxReportDialogState();
}

class _ExportTaxReportDialogState extends State<ExportTaxReportDialog> {
  late DateTime startDate;
  late DateTime endDate;
  bool isRealTax = false;
  double newTaxRate = 0.05; // Default 5%
  final TextEditingController taxRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate ??
        DateTime.now().subtract(const Duration(days: 30));
    endDate = widget.initialEndDate ?? DateTime.now();
    taxRateController.text = '5'; // Default 5%
  }

  @override
  void dispose() {
    taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.download,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Export Tax Report',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Date Range Section
            const Text(
              'Date Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Start Date',
                    date: startDate,
                    onTap: () => _selectStartDate(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    label: 'End Date',
                    date: endDate,
                    onTap: () => _selectEndDate(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tax Configuration Section
            const Text(
              'Tax Configuration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Real Tax Option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isRealTax ? Colors.blue : Colors.grey.shade300,
                  width: isRealTax ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isRealTax ? Colors.blue.shade50 : Colors.transparent,
              ),
              child: InkWell(
                onTap: () => setState(() => isRealTax = true),
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isRealTax,
                      onChanged: (value) => setState(() => isRealTax = value!),
                      activeColor: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Real Tax',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Export with actual tax rates from transactions',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Manipulated Tax Option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: !isRealTax ? Colors.blue : Colors.grey.shade300,
                  width: !isRealTax ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: !isRealTax ? Colors.blue.shade50 : Colors.transparent,
              ),
              child: InkWell(
                onTap: () => setState(() => isRealTax = false),
                child: Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: isRealTax,
                      onChanged: (value) => setState(() => isRealTax = value!),
                      activeColor: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Custom Tax Rate',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const Text(
                            'Export with custom tax rate',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          if (!isRealTax) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    controller: taxRateController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*')),
                                    ],
                                    onChanged: (value) {
                                      final rate = double.tryParse(value) ?? 0;
                                      newTaxRate = rate /
                                          100; // Convert percentage to decimal
                                    },
                                    decoration: const InputDecoration(
                                      hintText: '5',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onExportPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Export Excel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: endDate,
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  void _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  void _onExportPressed() {
    Get.back(); // Close dialog first

    widget.onExport(
      startDate: startDate,
      endDate: endDate,
      newTaxRate: isRealTax ? null : newTaxRate,
      realTax: isRealTax,
    );
  }
}
