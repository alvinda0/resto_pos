import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pos/controller/debt/debt_controller.dart';
import 'package:pos/models/debt/debt_model.dart';
import 'package:pos/widgets/pagination_widget.dart';

class DebtScreen extends StatelessWidget {
  final DebtController controller = Get.put(DebtController());

  DebtScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.debts.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.hasError.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Gagal memuat data hutang',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: controller.refreshData,
                            child: Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: controller.filteredDebts.isEmpty
                          ? _buildEmptyState()
                          : _buildDebtList(context),
                    ),
                    // Pagination Widget
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tidak ada data hutang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Belum ada hutang yang tercatat',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtList(BuildContext context) {
    // Check screen size for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      return _buildMobileDebtList();
    } else {
      return _buildDesktopDebtTable();
    }
  }

  Widget _buildMobileDebtList() {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: controller.displayedDebts.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final debt = controller.displayedDebts[index];
        return _buildMobileDebtCard(debt);
      },
    );
  }

  Widget _buildMobileDebtCard(Debt debt) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with inventory name and menu
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.inventoryName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pembelian: ${_formatDate(debt.purchaseDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionMenu(debt),
              ],
            ),

            SizedBox(height: 16),

            // Vendor
            Row(
              children: [
                Icon(Icons.store, size: 16, color: Colors.grey.shade600),
                SizedBox(width: 8),
                Text(
                  'Vendor: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Expanded(
                  child: Text(
                    debt.vendorName,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Amount
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey.shade600),
                SizedBox(width: 8),
                Text(
                  'Jumlah: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  debt.formattedAmount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Due date
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey.shade600),
                SizedBox(width: 8),
                Text(
                  'Jatuh Tempo: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  _formatDate(debt.dueDate),
                  style: TextStyle(fontSize: 14),
                ),
                if (debt.isOverdue) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Terlambat',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: 12),

            // Status
            Row(
              children: [
                Text(
                  'Status: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(debt).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.getStatusColor(debt).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    controller.getStatusText(debt),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: controller.getStatusColor(debt),
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

  Widget _buildDesktopDebtTable() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 2, child: Text('Inventaris', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Vendor', style: _headerStyle)),
                Expanded(flex: 1, child: Text('Jumlah', style: _headerStyle)),
                Expanded(
                    flex: 1, child: Text('Jatuh Tempo', style: _headerStyle)),
                Expanded(flex: 1, child: Text('Status', style: _headerStyle)),
                Expanded(flex: 1, child: Text('Aksi', style: _headerStyle)),
              ],
            ),
          ),

          // Table body
          Expanded(
            child: ListView.separated(
              itemCount: controller.displayedDebts.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final debt = controller.displayedDebts[index];
                return _buildDesktopDebtRow(debt);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopDebtRow(Debt debt) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Inventory name
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.inventoryName,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                Text(
                  'Pembelian: ${_formatDate(debt.purchaseDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Vendor name
          Expanded(
            flex: 2,
            child: Text(
              debt.vendorName,
              style: TextStyle(fontSize: 14),
            ),
          ),

          // Amount
          Expanded(
            flex: 1,
            child: Text(
              debt.formattedAmount,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ),

          // Due date
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(debt.dueDate),
                  style: TextStyle(fontSize: 14),
                ),
                if (debt.isOverdue)
                  Text(
                    'Terlambat',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: controller.getStatusColor(debt).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.getStatusColor(debt).withOpacity(0.3),
                ),
              ),
              child: Text(
                controller.getStatusText(debt),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: controller.getStatusColor(debt),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Actions
          Expanded(
            flex: 1,
            child: _buildActionMenu(debt),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(Debt debt) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey.shade600,
        size: 20,
      ),
      onSelected: (String action) {
        switch (action) {
          case 'edit':
            _showEditDialog(debt);
            break;
          case 'delete':
            controller.deleteDebt(debt.id);
            break;
          case 'toggle_payment':
            controller.togglePaymentStatus(debt);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'toggle_payment',
          child: Row(
            children: [
              Icon(
                debt.isPaid ? Icons.money_off : Icons.attach_money,
                size: 16,
                color: debt.isPaid ? Colors.orange : Colors.green,
              ),
              SizedBox(width: 8),
              Text(debt.isPaid ? 'Tandai Belum Lunas' : 'Tandai Lunas'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16, color: Colors.blue),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus'),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(Debt debt) {
    final formKey = GlobalKey<FormState>();
    final vendorController = TextEditingController(text: debt.vendorName);
    final amountController =
        TextEditingController(text: debt.amount.toString());
    DateTime selectedDueDate = debt.dueDate;

    Get.dialog(
      Dialog(
        child: Container(
          width: MediaQuery.of(Get.context!).size.width > 600 ? 500 : null,
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Hutang',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),

                  // Inventory name (read-only)
                  TextFormField(
                    initialValue: debt.inventoryName,
                    decoration: InputDecoration(
                      labelText: 'Nama Inventaris',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 16),

                  // Vendor name
                  TextFormField(
                    controller: vendorController,
                    decoration: InputDecoration(
                      labelText: 'Nama Vendor',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama vendor wajib diisi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Amount
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Jumlah',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Jumlah wajib diisi';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Masukkan jumlah yang valid';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Due date
                  StatefulBuilder(
                    builder: (context, setState) {
                      return InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDueDate,
                            firstDate:
                                DateTime.now().subtract(Duration(days: 365)),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              selectedDueDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Tanggal Jatuh Tempo',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(_formatDate(selectedDueDate)),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Batal'),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final updatedDebt = debt.copyWith(
                              vendorName: vendorController.text.trim(),
                              amount: int.parse(amountController.text.trim()),
                              dueDate: selectedDueDate,
                            );

                            controller.updateDebt(updatedDebt);
                            Get.back();
                          }
                        },
                        child: Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle get _headerStyle => TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
        fontSize: 14,
      );

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
