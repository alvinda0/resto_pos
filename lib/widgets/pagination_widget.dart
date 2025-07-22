import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int itemsPerPage;
  final List<int> availablePageSizes;
  final int startIndex;
  final int endIndex;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final List<int> pageNumbers;
  final Function(int) onPageSizeChanged;
  final Function() onPreviousPage;
  final Function() onNextPage;
  final Function(int) onPageSelected;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    required this.availablePageSizes,
    required this.startIndex,
    required this.endIndex,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.pageNumbers,
    required this.onPageSizeChanged,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onPageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Rows per page selector
          _buildRowsPerPageSelector(),

          // Center - Items count info
          _buildItemsCountInfo(),

          // Right side - Pagination controls
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildRowsPerPageSelector() {
    return Row(
      children: [
        Text(
          'Rows per page:',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: itemsPerPage,
              isDense: true,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
              items: availablePageSizes.map((int size) {
                return DropdownMenuItem<int>(
                  value: size,
                  child: Text('$size'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onPageSizeChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCountInfo() {
    return Text(
      '$startIndex-$endIndex of $totalItems',
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 14,
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous page button
        IconButton(
          onPressed: !hasPreviousPage ? null : onPreviousPage,
          icon: const Icon(Icons.chevron_left),
          iconSize: 20,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          tooltip: 'Previous page',
        ),

        const SizedBox(width: 8),

        // Page numbers
        ...pageNumbers.map((pageNumber) {
          final isCurrentPage = pageNumber == currentPage;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: isCurrentPage ? null : () => onPageSelected(pageNumber),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCurrentPage ? Colors.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: isCurrentPage
                      ? null
                      : Border.all(color: Colors.transparent),
                ),
                child: Center(
                  child: Text(
                    '$pageNumber',
                    style: TextStyle(
                      color:
                          isCurrentPage ? Colors.white : Colors.grey.shade700,
                      fontWeight:
                          isCurrentPage ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(width: 8),

        // Next page button
        IconButton(
          onPressed: !hasNextPage ? null : onNextPage,
          icon: const Icon(Icons.chevron_right),
          iconSize: 20,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          tooltip: 'Next page',
        ),
      ],
    );
  }
}
