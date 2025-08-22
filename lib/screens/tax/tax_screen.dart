// screens/tax_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/tax/tax_controller.dart';
import 'package:pos/models/tax/tax_model.dart';
import 'package:pos/widgets/pagination_widget.dart';

class TaxScreen extends StatelessWidget {
  TaxScreen({Key? key}) : super(key: key);

  // Buat controller langsung tanpa injection
  final TaxController controller = TaxController();

  @override
  Widget build(BuildContext context) {
    // Bind controller ke GetX
    Get.put(controller, permanent: false);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          final isTablet =
              constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
          final isDesktop = constraints.maxWidth >= 1024;

          return Column(
            children: [
              _buildActionSection(isMobile),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(isMobile ? 8 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (!isMobile) _buildTableHeader(isTablet),
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value &&
                              controller.taxes.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Memuat pajak...'),
                                ],
                              ),
                            );
                          }

                          if (controller.error.value.isNotEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 16 : 32,
                                    ),
                                    child: Text(
                                      controller.error.value,
                                      style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: controller.refreshTaxes,
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (controller.taxes.isEmpty) {
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
                                    'Tidak ada pajak ditemukan',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Buat pajak baru untuk memulai',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return Stack(
                            children: [
                              isMobile
                                  ? _buildMobileList()
                                  : _buildDataTable(isTablet),
                              if (controller.isLoading.value)
                                Container(
                                  color: Colors.white.withOpacity(0.7),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                      // Pagination Widget
                      Obx(() => controller.taxes.isNotEmpty
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 8 : 16,
                                vertical: 8,
                              ),
                              child: PaginationWidget(
                                currentPage: controller.currentPage.value,
                                totalItems: controller.totalItems.value,
                                itemsPerPage: controller.itemsPerPage.value,
                                availablePageSizes:
                                    controller.availablePageSizes,
                                startIndex: controller.startIndex,
                                endIndex: controller.endIndex,
                                hasPreviousPage: controller.hasPreviousPage,
                                hasNextPage: controller.hasNextPage,
                                pageNumbers: controller.pageNumbers,
                                onPageSizeChanged: controller.onPageSizeChanged,
                                onPreviousPage: controller.previousPage,
                                onNextPage: controller.nextPage,
                                onPageSelected: controller.onPageChanged,
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      color: Colors.white,
      child: Row(
        children: [
          if (isMobile) ...[
            Text(
              'Pajak',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
          const Spacer(),
          TextButton.icon(
            onPressed: controller.refreshTaxes,
            icon: Icon(Icons.refresh, size: isMobile ? 18 : 20),
            label: Text(
              'Perbarui',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _showCreateTaxDialog,
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              isMobile ? 'Add' : 'Add Tax',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: isTablet ? 4 : 3,
            child: const Text(
              'Nama',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          if (!isTablet) ...[
            const Expanded(
              flex: 2,
              child: Text(
                'Jenis',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
          const Expanded(
            flex: 2,
            child: Text(
              'Persentase',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (!isTablet) ...[
            const Expanded(
              flex: 2,
              child: Text(
                'Prioritas',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(
            width: 50,
            child: Text(
              'Aksi',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(bool isTablet) {
    return ListView.builder(
      itemCount: controller.taxes.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final tax = controller.taxes[index];
        return _buildTableRow(tax, index, isTablet);
      },
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: controller.taxes.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final tax = controller.taxes[index];
        return _buildMobileCard(tax, index);
      },
    );
  }

  Widget _buildMobileCard(TaxModel tax, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tax.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      if (tax.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          tax.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) => _handleMenuAction(value, tax),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, size: 20),
                        title: Text('Ubah'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading:
                            Icon(Icons.delete, size: 20, color: Colors.red),
                        title:
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMobileInfoItem('Jenis', tax.typeDisplayName),
                ),
                Expanded(
                  child: _buildMobileInfoItem(
                    'Persentase',
                    '${tax.percentage.toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Status: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tax.isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tax.statusText,
                          style: TextStyle(
                            color: tax.isActive
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildMobileInfoItem(
                      'Prioritas', tax.priority.toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow(TaxModel tax, int index, bool isTablet) {
    final isEven = index % 2 == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: isTablet ? 4 : 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tax.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (tax.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tax.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (isTablet) ...[
                  const SizedBox(height: 4),
                  Text(
                    tax.typeDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isTablet) ...[
            Expanded(
              flex: 2,
              child: Text(
                tax.typeDisplayName,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
          Expanded(
            flex: 2,
            child: Text(
              '${tax.percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tax.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tax.statusText,
                  style: TextStyle(
                    color: tax.isActive
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          if (!isTablet) ...[
            Expanded(
              flex: 2,
              child: Text(
                tax.priority.toString(),
                style: const TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          SizedBox(
            width: 50,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) => _handleMenuAction(value, tax),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, size: 20),
                    title: Text('Ubah'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, size: 20, color: Colors.red),
                    title: Text('Hapus', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, TaxModel tax) {
    switch (action) {
      case 'edit':
        _showEditTaxDialog(tax);
        break;
      case 'delete':
        controller.deleteTax(tax.id, tax.name);
        break;
    }
  }

  void _showCreateTaxDialog() {
    _showTaxDialog(null);
  }

  void _showEditTaxDialog(TaxModel tax) {
    _showTaxDialog(tax);
  }

  void _showTaxDialog(TaxModel? tax) {
    final nameController = TextEditingController(text: tax?.name ?? '');
    final descriptionController =
        TextEditingController(text: tax?.description ?? '');
    final percentageController =
        TextEditingController(text: tax?.percentage.toString() ?? '');
    final priorityController =
        TextEditingController(text: tax?.priority.toString() ?? '0');

    TaxType selectedType =
        tax != null ? TaxType.fromString(tax.type) : TaxType.VAT;
    bool isActive = tax?.isActive ?? true;

    Get.dialog(
      LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return AlertDialog(
            title: Text(tax == null ? 'Buat Pajak' : 'Ubah Pajak'),
            content: SizedBox(
              width: isMobile ? constraints.maxWidth * 0.9 : 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pajak*',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaxType>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Jenis*',
                        border: OutlineInputBorder(),
                      ),
                      items: TaxType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName),
                              ))
                          .toList(),
                      onChanged: (value) => selectedType = value ?? TaxType.VAT,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: percentageController,
                            decoration: const InputDecoration(
                              labelText: 'Persentase*',
                              border: OutlineInputBorder(),
                              suffixText: '%',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        if (!isMobile) const SizedBox(width: 16),
                        if (!isMobile)
                          Expanded(
                            child: TextField(
                              controller: priorityController,
                              decoration: const InputDecoration(
                                labelText: 'Prioritas',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                      ],
                    ),
                    if (isMobile) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: priorityController,
                        decoration: const InputDecoration(
                          labelText: 'Prioritas',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    StatefulBuilder(
                      builder: (context, setState) => SwitchListTile(
                        title: const Text('Aktif'),
                        value: isActive,
                        onChanged: (value) => setState(() => isActive = value),
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
                onPressed: () => _saveTax(
                  tax,
                  nameController.text,
                  selectedType,
                  double.tryParse(percentageController.text) ?? 0,
                  int.tryParse(priorityController.text) ?? 0,
                  descriptionController.text,
                  isActive,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(tax == null ? 'Buat' : 'Perbarui'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveTax(
    TaxModel? existingTax,
    String name,
    TaxType type,
    double percentage,
    int priority,
    String description,
    bool isActive,
  ) {
    if (name.isEmpty || percentage <= 0) {
      Get.snackbar(
        'Kesalahan',
        'Mohon isi semua field yang diperlukan dengan nilai yang valid',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
      );
      return;
    }

    final taxModel = TaxModel(
      id: existingTax?.id ?? '',
      name: name,
      type: type.value,
      percentage: percentage,
      description: description,
      isActive: isActive,
      priority: priority,
      createdAt: existingTax?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Get.back();

    if (existingTax == null) {
      controller.createTax(taxModel);
    } else {
      controller.updateTax(existingTax.id, taxModel);
    }
  }
}
