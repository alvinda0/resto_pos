import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/promotion/promotion_controller.dart';
import 'package:pos/models/promotion/promotion_model.dart';
import 'package:pos/widgets/pagination_widget.dart';

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
  void dispose() {
    // Don't dispose the controller here if it's used elsewhere
    // Get.delete<PromotionController>();
    super.dispose();
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
              // Header Section
              _buildHeader(),
              const SizedBox(height: 24),

              // Search and Filter Section
              _buildSearchAndFilter(),
              const SizedBox(height: 24),

              // Summary Stats Section

              // Data Table Section
              Expanded(
                child: _buildDataTable(),
              ),

              // Pagination Section
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
          ],
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
            elevation: 2,
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

        // Page Size Selector
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
                  Icon(
                    Icons.local_offer_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.searchQuery.value.isNotEmpty
                        ? 'Tidak ada promo ditemukan dengan pencarian "${controller.searchQuery.value}"'
                        : 'Tidak ada data promo',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (controller.searchQuery.value.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: controller.clearSearch,
                      child: const Text('Hapus Pencarian'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Table Header
            _buildTableHeader(),

            // Table Body
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
                    // Loading more indicator
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
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
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
        color: index % 2 == 0 ? Colors.white : Colors.grey[50],
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
              Icon(
                statusIcon,
                size: 14,
                color: statusColor,
              ),
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
        child: PopupMenuButton<String>(
          onSelected: (value) => _handleAction(value, promotion),
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Lihat Detail'),
                ],
              ),
            ),
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
            if (promotion.status.toLowerCase() != 'expired')
              PopupMenuItem<String>(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      promotion.status.toLowerCase() == 'active'
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
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
                  Icon(Icons.delete_outline, size: 16, color: Colors.red),
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

  Widget _buildPagination() {
    return Obx(() {
      if (controller.searchQuery.value.isNotEmpty ||
          controller.totalPromotions.value == 0) {
        return const SizedBox.shrink();
      }

      final startIndex =
          (controller.currentPage.value - 1) * controller.limit.value + 1;
      final endIndex = (controller.currentPage.value * controller.limit.value)
          .clamp(0, controller.totalPromotions.value);

      final totalPages = controller.totalPages.value;
      final currentPage = controller.currentPage.value;

      int startPage = (currentPage - 2).clamp(1, totalPages);
      int endPage = (startPage + 4).clamp(1, totalPages);

      if (endPage - startPage < 4) {
        startPage = (endPage - 4).clamp(1, totalPages);
      }

      final pageNumbers = List.generate(
        endPage - startPage + 1,
        (index) => startPage + index,
      );

      return PaginationWidget(
        currentPage: controller.currentPage.value,
        totalItems: controller.totalPromotions.value,
        itemsPerPage: controller.limit.value,
        availablePageSizes: [5, 10, 25, 50],
        startIndex: startIndex,
        endIndex: endIndex,
        hasPreviousPage: !controller.isFirstPage,
        hasNextPage: !controller.isLastPage,
        pageNumbers: pageNumbers,
        onPageSizeChanged: (newSize) {
          controller.updateLimit(newSize);
        },
        onPreviousPage: () {
          controller.jumpToPage(currentPage - 1);
        },
        onNextPage: () {
          controller.jumpToPage(currentPage + 1);
        },
        onPageSelected: (page) {
          controller.jumpToPage(page);
        },
      );
    });
  }

  void _handleAction(String action, Promotion promotion) {
    switch (action) {
      case 'view':
        _showPromotionDetail(promotion);
        break;
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

  void _showPromotionDetail(Promotion promotion) {
    Get.dialog(
      AlertDialog(
        title: Text(promotion.name),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Deskripsi', promotion.description),
              _buildDetailRow('Kode Promo', promotion.promoCode),
              _buildDetailRow('Jenis Diskon', promotion.discountType),
              _buildDetailRow('Nilai Diskon', promotion.formattedDiscount),
              _buildDetailRow('Maksimal Diskon', 'Rp ${promotion.maxDiscount}'),
              _buildDetailRow('Periode', promotion.formattedPeriod),
              _buildDetailRow('Hari', promotion.formattedDays),
              _buildDetailRow('Batas Penggunaan', '${promotion.usageLimit}x'),
              _buildDetailRow('Status', promotion.statusDisplayName),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Semua':
        return Icons.all_inclusive;
      case 'Aktif':
        return Icons.check_circle;
      case 'Tidak Aktif':
        return Icons.pause_circle;
      case 'Kedaluwarsa':
        return Icons.cancel;
      default:
        return Icons.filter_list;
    }
  }
}
