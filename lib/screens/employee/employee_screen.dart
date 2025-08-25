import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/employee/employee_controller.dart';
import 'package:pos/models/employee/employe_model.dart';
import 'package:pos/widgets/pagination_widget.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EmployeeController controller = Get.put(EmployeeController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Bilah Pencarian dengan Tombol Aksi
          _buildSearchBarWithActions(controller),

          // Area Konten
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header Tabel dengan Judul
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Daftar Karyawan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Obx(() => Text(
                              '${controller.totalItems.value} karyawan',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            )),
                      ],
                    ),
                  ),

                  // Konten Tabel
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.red),
                        );
                      }

                      if (controller.employees.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildEmployeeTable(controller);
                    }),
                  ),

                  // Paginasi
                  Obx(() => PaginationWidget(
                        currentPage: controller.currentPage.value,
                        totalItems: controller.totalItems.value,
                        itemsPerPage: controller.itemsPerPage.value,
                        availablePageSizes: controller.availablePageSizes,
                        startIndex: controller.startIndex,
                        endIndex: controller.endIndex,
                        hasPreviousPage: controller.hasPreviousPage,
                        hasNextPage: controller.hasNextPage,
                        pageNumbers: controller.pageNumbers,
                        onPageSizeChanged: controller.changePageSize,
                        onPreviousPage: controller.goToPreviousPage,
                        onNextPage: controller.goToNextPage,
                        onPageSelected: controller.goToPage,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarWithActions(EmployeeController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Field Pencarian
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari karyawan...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                  suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          onPressed: controller.clearSearch,
                          icon: Icon(Icons.clear,
                              color: Colors.grey.shade500, size: 20),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        )
                      : const SizedBox.shrink()),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Tombol Tambah Karyawan
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => _showEmployeeDialog(Get.context!, controller),
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              tooltip: 'Tambah Karyawan',
            ),
          ),

          const SizedBox(width: 8),

          // Tombol Refresh
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              onPressed: () => controller.refreshData(),
              icon: Icon(Icons.refresh, color: Colors.grey.shade600, size: 20),
              tooltip: 'Segarkan',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeTable(EmployeeController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth:
                MediaQuery.of(Get.context!).size.width - 32, // Minus margin
          ),
          child: Table(
            columnWidths: const {
              0: FixedColumnWidth(50), // No - width fixed
              1: FixedColumnWidth(150), // Nama - width fixed
              2: FixedColumnWidth(180), // Email - width fixed
              3: FixedColumnWidth(120), // Telepon - width fixed
              4: FixedColumnWidth(120), // Jabatan - width fixed
              5: FixedColumnWidth(100), // Gaji - width fixed
              6: FixedColumnWidth(80), // Aksi - width fixed
            },
            children: [
              // Header Tabel
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                children: [
                  _buildTableHeaderCell('No'),
                  _buildTableHeaderCell('Nama'),
                  _buildTableHeaderCell('Email'),
                  _buildTableHeaderCell('Telepon'),
                  _buildTableHeaderCell('Jabatan'),
                  _buildTableHeaderCell('Gaji'),
                  _buildTableHeaderCell('Aksi'),
                ],
              ),

              // Baris Tabel
              ...controller.employees.asMap().entries.map((entry) {
                final index = entry.key;
                final employee = entry.value;
                final globalIndex = controller.startIndex + index;

                return TableRow(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.white : Colors.grey.shade100,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  children: [
                    _buildTableCell('$globalIndex'),
                    _buildTableCell(employee.name),
                    _buildTableCell(employee.email),
                    _buildTableCell(employee.phone),
                    _buildTableCell(employee.position),
                    _buildTableCell(
                        controller.formatSalary(employee.baseSalary)),
                    _buildActionCell(employee, controller),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildActionCell(Employee employee, EmployeeController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          size: 18,
          color: Colors.grey.shade600,
        ),
        iconSize: 18,
        padding: EdgeInsets.zero,
        offset: const Offset(-10, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ubah',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  size: 16,
                  color: Colors.red.shade600,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Hapus',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
        onSelected: (String value) {
          switch (value) {
            case 'edit':
              _showEmployeeDialog(Get.context!, controller, employee: employee);
              break;
            case 'delete':
              controller.showDeleteConfirmation(employee);
              break;
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada karyawan ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai dengan menambahkan karyawan pertama Anda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showEmployeeDialog(
                Get.context!, Get.find<EmployeeController>()),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Karyawan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmployeeDialog(BuildContext context, EmployeeController controller,
      {Employee? employee}) {
    final isEdit = employee != null;

    if (isEdit) {
      controller.fillForm(employee);
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Dialog
              Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit : Icons.add,
                    color: Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'Ubah Karyawan' : 'Tambah Karyawan Baru',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Field Formulir
              _buildFormField(
                label: 'Nama',
                controller: controller.nameController,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              _buildFormField(
                label: 'Email',
                controller: controller.emailController,
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildFormField(
                label: 'Telepon',
                controller: controller.phoneController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildFormField(
                label: 'Jabatan',
                controller: controller.positionController,
                icon: Icons.work,
              ),
              const SizedBox(height: 16),

              _buildFormField(
                label: 'Gaji Pokok',
                controller: controller.salaryController,
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                prefix: 'Rp ',
              ),
              const SizedBox(height: 32),

              // Tombol Aksi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isFormValid.value &&
                                  !controller.isLoadingAction.value
                              ? () async {
                                  final employeeData =
                                      controller.getEmployeeFromForm();
                                  bool success = false;

                                  try {
                                    if (isEdit) {
                                      success = await controller.updateEmployee(
                                          employee.id, employeeData);
                                    } else {
                                      success = await controller
                                          .createEmployee(employeeData);
                                    }

                                    // Tutup modal jika berhasil
                                    if (success) {
                                      Navigator.of(context)
                                          .pop(); // Atau bisa pakai Get.back()
                                    }
                                  } catch (e) {
                                    // Error handling sudah ada di controller
                                    print('Error di dialog: $e');
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: controller.isLoadingAction.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(isEdit ? 'Perbarui' : 'Buat'),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
              prefixText: prefix,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
