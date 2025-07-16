import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/promotion/promotion_controller.dart';
import 'package:pos/models/promotion/promotion_model.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            const SizedBox(height: 24),

            // Search and Filter Section
            _buildSearchAndFilter(),
            const SizedBox(height: 24),

            // Data Table Section
            Expanded(
              child: _buildDataTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Manajemen Promo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => controller.navigateToAddPromotion(),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Tambah Promo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[400],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        // Search Field
        Expanded(
          flex: 2,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Cari promo',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Filter Dropdown
        Expanded(
          flex: 1,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedFilter.value,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.changeFilter(newValue);
                      }
                    },
                    items: controller.filterOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(value),
                        ),
                      );
                    }).toList(),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    isExpanded: true,
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
            child: CircularProgressIndicator(),
          );
        }

        if (controller.filteredPromotions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada promo ditemukan',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Table Header
            _buildTableHeader(),

            // Table Body
            Expanded(
              child: ListView.builder(
                itemCount: controller.filteredPromotions.length,
                itemBuilder: (context, index) {
                  final promotion = controller.filteredPromotions[index];
                  return _buildTableRow(promotion, index + 1);
                },
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
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('No', flex: 1),
          _buildHeaderCell('Nama Promo', flex: 3),
          _buildHeaderCell('Kode', flex: 2),
          _buildHeaderCell('Diskon', flex: 2),
          _buildHeaderCell('Periode', flex: 3),
          _buildHeaderCell('Hari', flex: 2),
          _buildHeaderCell('Status', flex: 2),
          _buildHeaderCell('Aksi', flex: 1),
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
      height: 64,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          _buildDataCell(index.toString(), flex: 1),
          _buildDataCell(promotion.name, flex: 3),
          _buildDataCell(promotion.promoCode, flex: 2),
          _buildDataCell(promotion.formattedDiscount, flex: 2),
          _buildDataCell(promotion.formattedPeriod, flex: 3),
          _buildDataCell(promotion.formattedDays, flex: 2),
          _buildStatusCell(promotion.status, flex: 2),
          _buildActionCell(promotion, flex: 1),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
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

    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'AKTIF';
        break;
      case 'inactive':
        statusColor = Colors.orange;
        statusText = 'TIDAK AKTIF';
        break;
      case 'expired':
        statusColor = Colors.red;
        statusText = 'KEDALUWARSA';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status.toUpperCase();
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
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
            textAlign: TextAlign.center,
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
        child: PopupMenuButton<String>(
          onSelected: (value) => _handleAction(value, promotion),
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
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
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    promotion.status.toLowerCase() == 'active'
                        ? Icons.toggle_off
                        : Icons.toggle_on,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(promotion.status.toLowerCase() == 'active'
                      ? 'Nonaktifkan'
                      : 'Aktifkan'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
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
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.more_vert,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  void _handleAction(String action, Promotion promotion) {
    switch (action) {
      case 'edit':
        controller.navigateToEditPromotion(promotion.id);
        break;
      case 'toggle':
        controller.togglePromotionStatus(promotion.id, promotion.status);
        break;
      case 'delete':
        controller.deletePromotion(promotion.id);
        break;
    }
  }
}
