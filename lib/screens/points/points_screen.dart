import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/points/points_controller.dart';
import 'package:pos/models/points/points_model.dart';
import 'package:pos/widgets/pagination_widget.dart';
import 'package:intl/intl.dart';

class PointConfigScreen extends StatelessWidget {
  final PointConfigController controller = Get.put(PointConfigController());

  PointConfigScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header section with add button and refresh
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Konfigurasi Poin',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: controller.showCreateDialog,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Point Config',
                ),
              ],
            ),
          ),

          // Table section
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
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
                        'Error loading data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.loadPointConfigs(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.pointConfigs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No point configurations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first point configuration to get started',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.showCreateDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Create Point Config'),
                      ),
                    ],
                  ),
                );
              }

              return _buildTable();
            }),
          ),

          // Pagination section
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
                onPageSizeChanged: controller.onPageSizeChanged,
                onPreviousPage: controller.onPreviousPage,
                onNextPage: controller.onNextPage,
                onPageSelected: controller.onPageSelected,
              )),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Mobile responsive table
          if (constraints.maxWidth < 600) {
            return _buildMobileTable();
          }
          return _buildDesktopTable();
        },
      ),
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
        columns: const [
          DataColumn(
            label: Text(
              'Amount (IDR)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Points',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Created At',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        rows: controller.pointConfigs.map((pointConfig) {
          return DataRow(
            cells: [
              DataCell(Text(_formatCurrency(pointConfig.amount))),
              DataCell(Text('${pointConfig.points} pts')),
              DataCell(_buildStatusBadge(pointConfig.isActive)),
              DataCell(Text(_formatDate(pointConfig.createdAt))),
              DataCell(_buildActionMenu(pointConfig)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileTable() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: controller.pointConfigs.length,
      itemBuilder: (context, index) {
        final pointConfig = controller.pointConfigs[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatCurrency(pointConfig.amount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildActionMenu(pointConfig),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text('${pointConfig.points} points'),
                    const SizedBox(width: 16),
                    _buildStatusBadge(pointConfig.isActive),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${_formatDate(pointConfig.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }

  Widget _buildActionMenu(PointConfig pointConfig) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            controller.showEditDialog(pointConfig);
            break;
          case 'toggle':
            controller.toggleActiveStatus(pointConfig);
            break;
          case 'delete':
            controller.deletePointConfig(pointConfig);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16),
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
                pointConfig.isActive ? Icons.toggle_off : Icons.toggle_on,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(pointConfig.isActive ? 'Deactivate' : 'Activate'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Obx(() => Container(
            padding: const EdgeInsets.all(8),
            child: controller.isLoadingAction.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Colors.grey,
                  ),
          )),
    );
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd MMM yyyy, HH:mm');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }
}
