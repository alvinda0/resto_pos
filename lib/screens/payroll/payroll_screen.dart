import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/payroll/payroll_controller.dart';
import 'package:pos/models/payroll/payroll_model.dart';
import 'package:pos/widgets/pagination_widget.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({Key? key}) : super(key: key);

  @override
  _PayrollScreenState createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final PayrollController controller = Get.put(PayrollController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Payroll'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildPayrollTable()),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Daftar Payroll',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              // Tombol Refresh
              IconButton(
                onPressed: () => controller.refreshData(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Muat Ulang',
              ),
              const SizedBox(width: 8),
              // Tombol Generate
              Obx(() => ElevatedButton.icon(
                    onPressed: controller.isGenerating.value
                        ? null
                        : () => _showGenerateDialog(),
                    icon: controller.isGenerating.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.add),
                    label: Text(controller.isGenerating.value
                        ? 'Sedang Memproses...'
                        : 'Buat Payroll'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollTable() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: ${controller.errorMessage.value}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.refreshData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );
      }

      if (controller.payrolls.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada data payroll',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showGenerateDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Buat Payroll Pertama'),
              ),
            ],
          ),
        );
      }

      return _buildDataTable();
    });
  }

  Widget _buildDataTable() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => DataTable(
              headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.grey.shade50,
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'ID Karyawan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Bulan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Gaji Pokok',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Bonus',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Potongan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Pajak',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Gaji Bersih',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Aksi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: controller.payrolls.map((payroll) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(payroll.employeeId.substring(0, 8) + '...'),
                    ),
                    DataCell(
                      Text(controller.formatMonth(payroll.payrollMonth)),
                    ),
                    DataCell(
                      Text(controller.formatCurrency(payroll.baseSalary)),
                    ),
                    DataCell(
                      Text(controller.formatCurrency(payroll.bonus)),
                    ),
                    DataCell(
                      Text(controller.formatCurrency(payroll.deductions)),
                    ),
                    DataCell(
                      Text(controller.formatCurrency(payroll.taxAmount)),
                    ),
                    DataCell(
                      Text(
                        controller.formatCurrency(payroll.netSalary),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        onPressed: () => _showPayrollDetail(payroll),
                        icon: const Icon(Icons.visibility),
                        tooltip: 'Lihat Detail',
                        iconSize: 18,
                      ),
                    ),
                  ],
                );
              }).toList(),
            )),
      ),
    );
  }

  Widget _buildPagination() {
    return Obx(() => PaginationWidget(
          currentPage: controller.currentPage.value,
          totalItems: controller.totalItems.value,
          itemsPerPage: controller.itemsPerPage.value,
          availablePageSizes: controller.availablePageSizes,
          startIndex: controller.startIndex,
          endIndex: controller.endIndex,
          hasPreviousPage: controller.hasPreviousPage,
          hasNextPage: controller.hasNextPage,
          pageNumbers: controller.pageNumbers,
          onPageSizeChanged: controller.onPageSizeChanged,
          onPreviousPage: controller.onPreviousPage,
          onNextPage: controller.onNextPage,
          onPageSelected: controller.onPageSelected,
        ));
  }

  void _showGenerateDialog() {
    final monthController = TextEditingController();
    final bonusController = TextEditingController();
    final deductionsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Set bulan default ke bulan sekarang
    final now = DateTime.now();
    monthController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    Get.dialog(
      AlertDialog(
        title: const Text('Buat Payroll'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: monthController,
                  decoration: const InputDecoration(
                    labelText: 'Bulan Payroll (YYYY-MM)',
                    hintText: '2025-08',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan bulan payroll';
                    }
                    // Validasi format YYYY-MM
                    final regex = RegExp(r'^\d{4}-\d{2}$');
                    if (!regex.hasMatch(value)) {
                      return 'Format tidak valid. Gunakan YYYY-MM';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: bonusController,
                  decoration: const InputDecoration(
                    labelText: 'Bonus (Opsional)',
                    hintText: '500000',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final bonus = double.tryParse(value);
                      if (bonus == null || bonus < 0) {
                        return 'Jumlah bonus tidak valid';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: deductionsController,
                  decoration: const InputDecoration(
                    labelText: 'Potongan (Opsional)',
                    hintText: '200000',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final deductions = double.tryParse(value);
                      if (deductions == null || deductions < 0) {
                        return 'Jumlah potongan tidak valid';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue.shade600, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Kosongkan bonus dan potongan untuk gaji pokok saja\n'
                        '• Bonus dan potongan akan diterapkan ke semua karyawan\n'
                        '• Untuk penyesuaian individual, gunakan fitur edit',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final request = PayrollGenerateRequest(
                  payrollMonth: monthController.text,
                  bonus: bonusController.text.isNotEmpty
                      ? double.parse(bonusController.text)
                      : null,
                  deductions: deductionsController.text.isNotEmpty
                      ? double.parse(deductionsController.text)
                      : null,
                );

                Get.back();
                controller.generatePayroll(request);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  void _showPayrollDetail(Payroll payroll) {
    Get.dialog(
      AlertDialog(
        title: const Text('Detail Payroll'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID Karyawan', payroll.employeeId),
              _buildDetailRow('ID Toko', payroll.storeId),
              _buildDetailRow(
                  'Bulan', controller.formatMonth(payroll.payrollMonth)),
              const Divider(),
              _buildDetailRow(
                  'Gaji Pokok', controller.formatCurrency(payroll.baseSalary)),
              _buildDetailRow(
                  'Bonus', controller.formatCurrency(payroll.bonus)),
              _buildDetailRow(
                  'Potongan', controller.formatCurrency(payroll.deductions)),
              _buildDetailRow(
                  'Jumlah Pajak', controller.formatCurrency(payroll.taxAmount)),
              const Divider(),
              _buildDetailRow(
                'Gaji Bersih',
                controller.formatCurrency(payroll.netSalary),
                isHighlighted: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showEditPayrollDialog(payroll);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? Colors.green : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPayrollDialog(Payroll payroll) {
    final bonusController =
        TextEditingController(text: payroll.bonus.toString());
    final deductionsController =
        TextEditingController(text: payroll.deductions.toString());
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Payroll'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('ID Karyawan',
                          payroll.employeeId.substring(0, 8) + '...'),
                      _buildDetailRow('Bulan',
                          controller.formatMonth(payroll.payrollMonth)),
                      _buildDetailRow('Gaji Pokok',
                          controller.formatCurrency(payroll.baseSalary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: bonusController,
                  decoration: const InputDecoration(
                    labelText: 'Bonus',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan jumlah bonus';
                    }
                    final bonus = double.tryParse(value);
                    if (bonus == null || bonus < 0) {
                      return 'Jumlah bonus tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: deductionsController,
                  decoration: const InputDecoration(
                    labelText: 'Potongan',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan jumlah potongan';
                    }
                    final deductions = double.tryParse(value);
                    if (deductions == null || deductions < 0) {
                      return 'Jumlah potongan tidak valid';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Implementasi logika update payroll di sini
                final updateData = {
                  'bonus': double.parse(bonusController.text),
                  'deductions': double.parse(deductionsController.text),
                };

                Get.back();
                // controller.updatePayroll(payroll.id, updateData);
                Get.snackbar(
                  'Info',
                  'Fitur edit payroll akan segera diimplementasikan',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Perbarui'),
          ),
        ],
      ),
    );
  }
}
