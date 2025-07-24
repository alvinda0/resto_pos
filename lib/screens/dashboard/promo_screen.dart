import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/promotion/promotion_controller.dart';
import 'package:pos/models/promotion/promotion_model.dart';
import 'package:pos/services/promotion/promotion_service.dart';
import 'package:pos/storage_service.dart';

class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  late PromotionController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PromotionController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: controller.refreshPromotions,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchAndFilter(),
              const SizedBox(height: 24),
              Expanded(child: _buildDataTable()),
              _buildPagination(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manajemen Promo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Obx(() => Text(
                  'Total ${controller.totalPromotions.value} promo',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                )),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showAddPromotionDialog,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Tambah Promo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[400],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama promo atau kode promo...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: controller.clearSearch,
                      )
                    : const SizedBox.shrink()),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedFilter.value,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.changeFilter(newValue);
                      }
                    },
                    items:
                        controller.filterOptions.map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(value,
                                style: const TextStyle(fontSize: 14)),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(64.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data promo...'),
                ],
              ),
            ),
          );
        }

        if (controller.filteredPromotions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(64.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    controller.searchQuery.value.isNotEmpty
                        ? 'Tidak ada promo ditemukan'
                        : 'Tidak ada data promo',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            _buildTableHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: controller.scrollController,
                child: Column(
                  children: [
                    ...controller.filteredPromotions.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final promotion = entry.value;
                        final globalIndex = (controller.currentPage.value - 1) *
                                controller.limit.value +
                            index +
                            1;
                        return _buildTableRow(promotion, globalIndex);
                      },
                    ),
                    if (controller.isLoadingMore.value)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Memuat lebih banyak...'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          _buildHeaderCell('No', flex: 1),
          _buildHeaderCell('Nama Promo', flex: 3),
          _buildHeaderCell('Kode', flex: 2),
          _buildHeaderCell('Diskon', flex: 2),
          _buildHeaderCell('Status', flex: 2),
          _buildHeaderCell('Aksi', flex: 2),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(Promotion promotion, int index) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[25],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _buildDataCell(index.toString(), flex: 1),
          _buildDataCell(promotion.name, flex: 3, isBold: true),
          _buildDataCell(promotion.promoCode, flex: 2, isCode: true),
          _buildDataCell(promotion.formattedDiscount, flex: 2),
          _buildStatusCell(promotion.status, flex: 2),
          _buildActionCell(promotion, flex: 2),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text,
      {required int flex, bool isBold = false, bool isCode = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            fontFamily: isCode ? 'monospace' : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildStatusCell(String status, {required int flex}) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'AKTIF';
        statusIcon = Icons.check_circle;
        break;
      case 'inactive':
        statusColor = Colors.orange;
        statusText = 'TIDAK AKTIF';
        statusIcon = Icons.pause_circle;
        break;
      case 'expired':
        statusColor = Colors.red;
        statusText = 'KEDALUWARSA';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = status.toUpperCase();
        statusIcon = Icons.help;
    }

    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell(Promotion promotion, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Tooltip(
              message: 'Edit',
              child: InkWell(
                onTap: () => _showEditPromotionDialog(promotion),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                ),
              ),
            ),
            Tooltip(
              message: promotion.status.toLowerCase() == 'active'
                  ? 'Nonaktifkan'
                  : 'Aktifkan',
              child: InkWell(
                onTap: () => controller.togglePromotionStatus(
                    promotion.id, promotion.status),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    promotion.status.toLowerCase() == 'active'
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    size: 16,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
            Tooltip(
              message: 'Hapus',
              child: InkWell(
                onTap: () => controller.deletePromotion(promotion.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.delete_outline,
                      size: 16, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Obx(() {
      if (controller.searchQuery.value.isNotEmpty ||
          controller.totalPromotions.value == 0) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              controller.paginationInfo,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: controller.isFirstPage
                      ? null
                      : () => controller
                          .jumpToPage(controller.currentPage.value - 1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  'Halaman ${controller.currentPage.value} dari ${controller.totalPages.value}',
                  style: const TextStyle(fontSize: 14),
                ),
                IconButton(
                  onPressed: controller.isLastPage
                      ? null
                      : () => controller
                          .jumpToPage(controller.currentPage.value + 1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showAddPromotionDialog() {
    _showPromotionFormDialog();
  }

  void _showEditPromotionDialog(Promotion promotion) {
    _showPromotionFormDialog(promotion: promotion);
  }

  void _showPromotionFormDialog({Promotion? promotion}) {
    final isEdit = promotion != null;
    final formKey = GlobalKey<FormState>();

    // Form controllers
    final nameController = TextEditingController(text: promotion?.name ?? '');
    final descController =
        TextEditingController(text: promotion?.description ?? '');
    final codeController =
        TextEditingController(text: promotion?.promoCode ?? '');
    final discountController =
        TextEditingController(text: promotion?.discountValue.toString() ?? '');
    final maxDiscountController =
        TextEditingController(text: promotion?.maxDiscount?.toString() ?? '');
    final usageLimitController =
        TextEditingController(text: promotion?.usageLimit.toString() ?? '100');

    // Form state
    String discountType = promotion?.discountType ?? 'percent';
    String timeType = promotion?.timeType ?? 'daily';
    String status = promotion?.status ?? 'active';

    DateTime? startDate = promotion?.startDate;
    DateTime? endDate = promotion?.endDate;
    TimeOfDay? startTime = promotion?.startTime != null
        ? TimeOfDay.fromDateTime(promotion!.startTime!)
        : null;
    TimeOfDay? endTime = promotion?.endTime != null
        ? TimeOfDay.fromDateTime(promotion!.endTime!)
        : null;

    List<String> selectedDays = promotion?.days?.split(',') ?? [];

    final ValueNotifier<String> discountTypeNotifier =
        ValueNotifier(discountType);
    final ValueNotifier<String> timeTypeNotifier = ValueNotifier(timeType);
    final ValueNotifier<DateTime?> startDateNotifier = ValueNotifier(startDate);
    final ValueNotifier<DateTime?> endDateNotifier = ValueNotifier(endDate);
    final ValueNotifier<TimeOfDay?> startTimeNotifier =
        ValueNotifier(startTime);
    final ValueNotifier<TimeOfDay?> endTimeNotifier = ValueNotifier(endTime);
    final ValueNotifier<List<String>> selectedDaysNotifier =
        ValueNotifier(selectedDays);

    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          height: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Promo' : 'Tambah Promo',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information
                        const Text('Informasi Dasar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Promo *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty == true
                              ? 'Nama promo harus diisi'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi *',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) => value?.isEmpty == true
                              ? 'Deskripsi harus diisi'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: codeController,
                          decoration: const InputDecoration(
                            labelText: 'Kode Promo *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty == true
                              ? 'Kode promo harus diisi'
                              : null,
                        ),
                        const SizedBox(height: 24),

                        // Discount Information
                        const Text('Informasi Diskon',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: discountController,
                                decoration: const InputDecoration(
                                  labelText: 'Nilai Diskon *',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty == true)
                                    return 'Nilai diskon harus diisi';
                                  final discount = double.tryParse(value!);
                                  if (discount == null || discount <= 0) {
                                    return 'Nilai diskon harus lebih dari 0';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ValueListenableBuilder<String>(
                                  valueListenable: discountTypeNotifier,
                                  builder: (context, value, child) {
                                    return DropdownButtonFormField<String>(
                                      value: value,
                                      decoration: const InputDecoration(
                                        labelText: 'Tipe Diskon',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'percent',
                                            child: Text('Persentase (%)')),
                                        DropdownMenuItem(
                                            value: 'fixed',
                                            child: Text('Nominal (Rp)')),
                                      ],
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          discountType = newValue;
                                          discountTypeNotifier.value = newValue;
                                        }
                                      },
                                    );
                                  }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        ValueListenableBuilder<String>(
                            valueListenable: discountTypeNotifier,
                            builder: (context, value, child) {
                              if (value == 'percent') {
                                return TextFormField(
                                  controller: maxDiscountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Maksimal Diskon (Rp)',
                                    border: OutlineInputBorder(),
                                    helperText:
                                        'Opsional - batas maksimal diskon dalam rupiah',
                                  ),
                                  keyboardType: TextInputType.number,
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: usageLimitController,
                          decoration: const InputDecoration(
                            labelText: 'Batas Penggunaan *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty == true)
                              return 'Batas penggunaan harus diisi';
                            final limit = int.tryParse(value!);
                            if (limit == null || limit <= 0) {
                              return 'Batas penggunaan harus lebih dari 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Time Configuration
                        const Text('Konfigurasi Waktu',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),

                        ValueListenableBuilder<String>(
                            valueListenable: timeTypeNotifier,
                            builder: (context, value, child) {
                              return DropdownButtonFormField<String>(
                                value: value,
                                decoration: const InputDecoration(
                                  labelText: 'Tipe Waktu',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'daily',
                                      child: Text(
                                          'Harian (Berulang setiap hari)')),
                                  DropdownMenuItem(
                                      value: 'period',
                                      child:
                                          Text('Periode (Tanggal tertentu)')),
                                ],
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    timeType = newValue;
                                    timeTypeNotifier.value = newValue;
                                  }
                                },
                              );
                            }),
                        const SizedBox(height: 16),

                        // Date Selection
                        Row(
                          children: [
                            Expanded(
                              child: ValueListenableBuilder<DateTime?>(
                                  valueListenable: startDateNotifier,
                                  builder: (context, value, child) {
                                    return InkWell(
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: value ?? DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2030),
                                        );
                                        if (date != null) {
                                          startDate = date;
                                          startDateNotifier.value = date;
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calendar_today),
                                            const SizedBox(width: 8),
                                            Text(value != null
                                                ? '${value.day}/${value.month}/${value.year}'
                                                : 'Tanggal Mulai *'),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                            const SizedBox(width: 16),
                            ValueListenableBuilder<String>(
                                valueListenable: timeTypeNotifier,
                                builder: (context, timeTypeValue, child) {
                                  if (timeTypeValue == 'period') {
                                    return Expanded(
                                      child: ValueListenableBuilder<DateTime?>(
                                          valueListenable: endDateNotifier,
                                          builder: (context, value, child) {
                                            return InkWell(
                                              onTap: () async {
                                                final date =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: value ??
                                                      startDate ??
                                                      DateTime.now(),
                                                  firstDate: startDate ??
                                                      DateTime.now(),
                                                  lastDate: DateTime(2030),
                                                );
                                                if (date != null) {
                                                  endDate = date;
                                                  endDateNotifier.value = date;
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.calendar_today),
                                                    const SizedBox(width: 8),
                                                    Text(value != null
                                                        ? '${value.day}/${value.month}/${value.year}'
                                                        : 'Tanggal Berakhir *'),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                    );
                                  }
                                  return const Expanded(
                                      child: SizedBox.shrink());
                                }),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Days Selection for Daily Type
                        ValueListenableBuilder<String>(
                            valueListenable: timeTypeNotifier,
                            builder: (context, timeTypeValue, child) {
                              if (timeTypeValue == 'daily') {
                                return ValueListenableBuilder<List<String>>(
                                    valueListenable: selectedDaysNotifier,
                                    builder: (context, selectedDays, child) {
                                      final days = [
                                        {'key': 'monday', 'label': 'Senin'},
                                        {'key': 'tuesday', 'label': 'Selasa'},
                                        {'key': 'wednesday', 'label': 'Rabu'},
                                        {'key': 'thursday', 'label': 'Kamis'},
                                        {'key': 'friday', 'label': 'Jumat'},
                                        {'key': 'saturday', 'label': 'Sabtu'},
                                        {'key': 'sunday', 'label': 'Minggu'},
                                      ];

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Pilih Hari *',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: days.map((day) {
                                              final isSelected = selectedDays
                                                  .contains(day['key']);
                                              return FilterChip(
                                                label: Text(day['label']!),
                                                selected: isSelected,
                                                onSelected: (bool selected) {
                                                  List<String> newSelectedDays =
                                                      List.from(selectedDays);
                                                  if (selected) {
                                                    newSelectedDays
                                                        .add(day['key']!);
                                                  } else {
                                                    newSelectedDays
                                                        .remove(day['key']);
                                                  }
                                                  selectedDaysNotifier.value =
                                                      newSelectedDays;
                                                },
                                                backgroundColor:
                                                    Colors.grey[100],
                                                selectedColor: Colors.red[400]
                                                    ?.withOpacity(0.2),
                                                checkmarkColor: Colors.red[400],
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      );
                                    });
                              }
                              return const SizedBox.shrink();
                            }),
                        const SizedBox(height: 16),

                        // Time Selection
                        Row(
                          children: [
                            Expanded(
                              child: ValueListenableBuilder<TimeOfDay?>(
                                  valueListenable: startTimeNotifier,
                                  builder: (context, value, child) {
                                    return InkWell(
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: value ?? TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          startTime = time;
                                          startTimeNotifier.value = time;
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time),
                                            const SizedBox(width: 8),
                                            Text(value != null
                                                ? value.format(context)
                                                : 'Jam Mulai'),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ValueListenableBuilder<TimeOfDay?>(
                                  valueListenable: endTimeNotifier,
                                  builder: (context, value, child) {
                                    return InkWell(
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: value ?? TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          endTime = time;
                                          endTimeNotifier.value = time;
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time),
                                            const SizedBox(width: 8),
                                            Text(value != null
                                                ? value.format(context)
                                                : 'Jam Berakhir'),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Status Selection
                        const Text('Status',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: const InputDecoration(
                            labelText: 'Status Promo',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'active', child: Text('Aktif')),
                            DropdownMenuItem(
                                value: 'inactive', child: Text('Tidak Aktif')),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              status = newValue;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.back(); // Tutup dialog saja, dispose otomatis karena widget dihancurkan
                    },
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _submitPromotionForm(
                        formKey: formKey,
                        isEdit: isEdit,
                        promotion: promotion,
                        nameController: nameController,
                        descController: descController,
                        codeController: codeController,
                        discountController: discountController,
                        maxDiscountController: maxDiscountController,
                        usageLimitController: usageLimitController,
                        discountType: discountType,
                        timeType: timeType,
                        status: status,
                        startDate: startDate,
                        endDate: endDate,
                        startTime: startTime,
                        endTime: endTime,
                        selectedDays: selectedDaysNotifier.value,
                        controllers: {}, // Kosongkan karena tidak digunakan lagi
                        notifiers: {}, // Kosongkan karena tidak digunakan lagi
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(isEdit ? 'Update' : 'Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPromotionForm({
    required GlobalKey<FormState> formKey,
    required bool isEdit,
    required Promotion? promotion,
    required TextEditingController nameController,
    required TextEditingController descController,
    required TextEditingController codeController,
    required TextEditingController discountController,
    required TextEditingController maxDiscountController,
    required TextEditingController usageLimitController,
    required String discountType,
    required String timeType,
    required String status,
    required DateTime? startDate,
    required DateTime? endDate,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required List<String> selectedDays,
    required Map<String, TextEditingController> controllers,
    required Map<String, ValueNotifier> notifiers,
  }) async {
    try {
      // Validate form
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Additional validations
      if (startDate == null) {
        Get.snackbar('Error', 'Tanggal mulai harus dipilih');
        return;
      }

      if (timeType == 'period' && endDate == null) {
        Get.snackbar(
            'Error', 'Tanggal berakhir harus dipilih untuk tipe periode');
        return;
      }

      if (timeType == 'daily' && selectedDays.isEmpty) {
        Get.snackbar(
            'Error', 'Minimal satu hari harus dipilih untuk tipe harian');
        return;
      }

      if (startTime == null || endTime == null) {
        Get.snackbar('Error', 'Waktu mulai dan berakhir harus dipilih');
        return;
      }

      // Ambil nilai dari controllers
      final nameValue = nameController.text.trim();
      final descValue = descController.text.trim();
      final codeValue = codeController.text.trim().toUpperCase();
      final discountValueStr = discountController.text.trim();
      final maxDiscountStr = maxDiscountController.text.trim();
      final usageLimitStr = usageLimitController.text.trim();

      // Parse dan validasi values
      final discountValue = double.tryParse(discountValueStr);
      if (discountValue == null || discountValue <= 0) {
        Get.snackbar('Error', 'Nilai diskon tidak valid');
        return;
      }

      // Validasi discount percentage
      if (discountType == 'percent' && discountValue > 100) {
        Get.snackbar('Error', 'Diskon persentase tidak boleh lebih dari 100%');
        return;
      }

      final maxDiscount =
          maxDiscountStr.isNotEmpty ? double.tryParse(maxDiscountStr) : null;
      if (maxDiscount != null && maxDiscount <= 0) {
        Get.snackbar('Error', 'Maksimal diskon harus lebih dari 0');
        return;
      }

      final usageLimit = int.tryParse(usageLimitStr);
      if (usageLimit == null || usageLimit <= 0) {
        Get.snackbar('Error', 'Batas penggunaan tidak valid');
        return;
      }

      // Validasi format kode promo (hanya huruf dan angka, uppercase)
      if (!RegExp(r'^[A-Z0-9]+$').hasMatch(codeValue)) {
        Get.snackbar(
            'Error', 'Kode promo hanya boleh berisi huruf besar dan angka');
        return;
      }

      // Validasi panjang kode promo
      if (codeValue.length < 3 || codeValue.length > 20) {
        Get.snackbar('Error', 'Kode promo harus antara 3-20 karakter');
        return;
      }

      // Validasi waktu untuk memastikan end_time setelah start_time
      final startMinutes = startTime!.hour * 60 + startTime!.minute;
      final endMinutes = endTime!.hour * 60 + endTime!.minute;

      // Untuk periode, validasi tanggal dan waktu
      if (timeType == 'period' && endDate != null) {
        if (endDate!.isBefore(startDate!)) {
          Get.snackbar('Error', 'Tanggal berakhir harus setelah tanggal mulai');
          return;
        }
        // Jika tanggal sama, pastikan waktu berakhir setelah waktu mulai
        if (endDate!.isAtSameMomentAs(startDate!) &&
            endMinutes <= startMinutes) {
          Get.snackbar('Error', 'Waktu berakhir harus setelah waktu mulai');
          return;
        }
      } else if (timeType == 'daily' && endMinutes <= startMinutes) {
        Get.snackbar('Error', 'Waktu berakhir harus setelah waktu mulai');
        return;
      }

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Helper function untuk format datetime dengan timezone +07:00
      String formatDateTimeWithTimezone(DateTime date,
          {TimeOfDay? time, bool isEndOfDay = false}) {
        final targetTime = time ??
            (isEndOfDay
                ? const TimeOfDay(hour: 23, minute: 59)
                : const TimeOfDay(hour: 0, minute: 0));

        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          targetTime.hour,
          targetTime.minute,
          isEndOfDay ? 59 : 0,
        );

        // Format: 2025-05-17T09:00:00+07:00
        return '${dateTime.toIso8601String().split('.')[0]}+07:00';
      }

      // Prepare promotion data sesuai dengan format API
      final promotionData = <String, dynamic>{
        'name': nameValue,
        'description': descValue,
        'discount_type': discountType,
        'discount_value': discountValue,
        'time_type': timeType,
        'start_date': formatDateTimeWithTimezone(startDate!),
        'start_time': formatDateTimeWithTimezone(startDate!, time: startTime),
        'promo_code': codeValue,
        'usage_limit': usageLimit,
        'status': status,
      };

      // Tambahkan max_discount hanya jika discount_type adalah percent dan ada nilainya
      if (discountType == 'percent' && maxDiscount != null) {
        promotionData['max_discount'] = maxDiscount;
      }

      // Untuk tipe period
      if (timeType == 'period' && endDate != null) {
        promotionData['end_date'] =
            formatDateTimeWithTimezone(endDate!, isEndOfDay: true);
        promotionData['end_time'] =
            formatDateTimeWithTimezone(endDate!, time: endTime);
      } else if (timeType == 'daily') {
        // Untuk tipe daily, end_time menggunakan hari berikutnya jika diperlukan
        // Sesuai contoh: start_time di hari pertama, end_time di hari kedua
        DateTime endDateTime = startDate!;
        if (endMinutes < startMinutes) {
          // Jika waktu berakhir lebih kecil, berarti di hari berikutnya
          endDateTime = startDate!.add(const Duration(days: 1));
        }
        promotionData['end_time'] =
            formatDateTimeWithTimezone(endDateTime, time: endTime);

        // Tambahkan days untuk tipe daily
        if (selectedDays.isNotEmpty) {
          promotionData['days'] = selectedDays.join(',');
        }
      }

      // Debug print untuk melihat data yang dikirim
      print('Promotion data to send: $promotionData');

      final storeId = StorageService.instance.getStoreIdWithFallback();
      final promotionService = PromotionService();

      // Perform operation
      if (isEdit && promotion != null) {
        await promotionService.updatePromotion(promotion.id, promotionData,
            storeId: storeId);
      } else {
        await promotionService.createPromotion(promotionData, storeId: storeId);
      }

      // Close loading
      Get.back();

      // Close form dialog
      Get.back();

      // Show success message
      Get.snackbar(
        'Berhasil',
        isEdit ? 'Promo berhasil diupdate' : 'Promo berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh data
      await controller.loadPromotions();
    } catch (e) {
      print('Error in _submitPromotionForm: $e');

      // Close loading if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      String errorMessage = 'Gagal menyimpan promo';

      // Parse error message jika ada
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      } else if (e.toString().contains('Invalid request body')) {
        errorMessage = 'Format data tidak valid. Periksa kembali input Anda.';
      } else if (e.toString().contains('already exists')) {
        errorMessage = 'Kode promo sudah digunakan. Gunakan kode yang berbeda.';
      } else if (e.toString().contains('validation')) {
        errorMessage = 'Data tidak valid. Periksa kembali semua field.';
      } else {
        errorMessage = '$errorMessage: ${e.toString()}';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }
}
