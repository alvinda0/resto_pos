import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/customer/customer_controller.dart';
import 'package:pos/models/customer/customer_model.dart';
import 'package:pos/widgets/pagination_widget.dart';

class CustomerScreen extends StatelessWidget {
  CustomerScreen({Key? key}) : super(key: key);

  final CustomerController controller = Get.put(CustomerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Main content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.customers.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.hasError.value && controller.customers.isEmpty) {
                return _buildErrorState();
              }

              if (controller.customers.isEmpty) {
                return _buildEmptyState();
              }

              return _buildCustomerList();
            }),
          ),

          // Pagination
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

  Widget _buildCustomerList() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Table content
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive breakpoints
                if (constraints.maxWidth < 600) {
                  // Mobile layout - Card view
                  return _buildMobileList();
                } else if (constraints.maxWidth < 900) {
                  // Tablet layout - Compact table
                  return _buildTabletTable();
                } else {
                  // Desktop layout - Full table
                  return _buildDesktopTable();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Mobile layout with cards
  Widget _buildMobileList() {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.customers.length,
          itemBuilder: (context, index) {
            final customer = controller.customers[index];
            return _buildMobileCustomerCard(customer, index);
          },
        ));
  }

  Widget _buildMobileCustomerCard(Customer customer, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Obx(() => IconButton(
                      onPressed: controller.isDeleting.value
                          ? null
                          : () => controller.deleteCustomer(
                              customer.id, customer.name),
                      icon: controller.isDeleting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline),
                      iconSize: 20,
                      color: Colors.red,
                      tooltip: 'Delete customer',
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  customer.phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(customer.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tablet layout with compact table
  Widget _buildTabletTable() {
    return Column(
      children: [
        _buildTabletTableHeader(),
        Expanded(
          child: Obx(() => ListView.builder(
                itemCount: controller.customers.length,
                itemBuilder: (context, index) {
                  final customer = controller.customers[index];
                  return _buildTabletCustomerItem(customer, index);
                },
              )),
        ),
      ],
    );
  }

  Widget _buildTabletTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Phone',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              'Actions',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletCustomerItem(Customer customer, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Name with created date as subtitle
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(customer.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Phone
          Expanded(
            flex: 2,
            child: Text(
              customer.phone,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => IconButton(
                      onPressed: controller.isDeleting.value
                          ? null
                          : () => controller.deleteCustomer(
                              customer.id, customer.name),
                      icon: controller.isDeleting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline),
                      iconSize: 18,
                      color: Colors.red,
                      tooltip: 'Delete customer',
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Desktop layout with full table
  Widget _buildDesktopTable() {
    return Column(
      children: [
        _buildDesktopTableHeader(),
        Expanded(
          child: Obx(() => ListView.builder(
                itemCount: controller.customers.length,
                itemBuilder: (context, index) {
                  final customer = controller.customers[index];
                  return _buildDesktopCustomerItem(customer, index);
                },
              )),
        ),
      ],
    );
  }

  Widget _buildDesktopTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Customer Name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Phone Number',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Date Created',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              'Actions',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCustomerItem(Customer customer, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Name
          Expanded(
            flex: 3,
            child: Text(
              customer.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Phone
          Expanded(
            flex: 2,
            child: Text(
              customer.phone,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          // Created date
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(customer.createdAt),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => IconButton(
                      onPressed: controller.isDeleting.value
                          ? null
                          : () => controller.deleteCustomer(
                              customer.id, customer.name),
                      icon: controller.isDeleting.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline),
                      iconSize: 20,
                      color: Colors.red,
                      tooltip: 'Delete customer',
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double iconSize = constraints.maxWidth < 600 ? 60 : 80;
        double titleSize = constraints.maxWidth < 600 ? 16 : 18;
        double subtitleSize = constraints.maxWidth < 600 ? 13 : 14;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: iconSize,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No customers found',
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'There are no customers to display.',
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double iconSize = constraints.maxWidth < 600 ? 60 : 80;
        double titleSize = constraints.maxWidth < 600 ? 16 : 18;
        double subtitleSize = constraints.maxWidth < 600 ? 13 : 14;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: iconSize,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading customers',
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          fontSize: subtitleSize,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}
