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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tentukan apakah ini mobile (layar kecil)
        final isMobile = constraints.maxWidth < 600;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        );
      },
    );
  }

  // Layout untuk desktop/tablet
  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRowsPerPageSelector(),
        _buildItemsCountInfo(),
        _buildPaginationControls(compact: false),
      ],
    );
  }

  // Layout untuk mobile
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Baris pertama: Items count dan rows per page
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildItemsCountInfo(),
            _buildRowsPerPageSelector(),
          ],
        ),
        const SizedBox(height: 12),
        // Baris kedua: Pagination controls
        _buildPaginationControls(compact: true),
      ],
    );
  }

  Widget _buildRowsPerPageSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Rows:',
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

  Widget _buildPaginationControls({required bool compact}) {
    // Untuk mobile, batasi jumlah page numbers yang ditampilkan
    List<int> displayPageNumbers = pageNumbers;

    if (compact && pageNumbers.length > 5) {
      // Logic untuk menampilkan page numbers yang lebih sedikit di mobile
      displayPageNumbers = _getCompactPageNumbers();
    }

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

        const SizedBox(width: 4),

        // Page numbers
        ...displayPageNumbers.map((pageNumber) {
          if (pageNumber == -1) {
            // Ellipsis
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 32,
              height: 32,
              child: const Center(
                child: Text(
                  '...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }

          final isCurrentPage = pageNumber == currentPage;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
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

        const SizedBox(width: 4),

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

  // Generate compact page numbers untuk mobile
  List<int> _getCompactPageNumbers() {
    if (pageNumbers.length <= 5) return pageNumbers;

    List<int> result = [];
    int totalPages = pageNumbers.last;

    if (currentPage <= 3) {
      // Tampilkan: 1, 2, 3, 4, ..., last
      result.addAll([1, 2, 3, 4]);
      if (totalPages > 5) {
        result.addAll([-1, totalPages]); // -1 untuk ellipsis
      } else if (totalPages == 5) {
        result.add(5);
      }
    } else if (currentPage >= totalPages - 2) {
      // Tampilkan: 1, ..., last-3, last-2, last-1, last
      result.addAll([1, -1]);
      for (int i = totalPages - 3; i <= totalPages; i++) {
        result.add(i);
      }
    } else {
      // Tampilkan: 1, ..., current-1, current, current+1, ..., last
      result.addAll([
        1,
        -1,
        currentPage - 1,
        currentPage,
        currentPage + 1,
        -1,
        totalPages
      ]);
    }

    return result;
  }
}

// Contoh penggunaan:
class PaginationExample extends StatefulWidget {
  @override
  _PaginationExampleState createState() => _PaginationExampleState();
}

class _PaginationExampleState extends State<PaginationExample> {
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalItems = 250;
  List<int> availablePageSizes = [5, 10, 25, 50];

  int get totalPages => (totalItems / itemsPerPage).ceil();
  int get startIndex => (currentPage - 1) * itemsPerPage + 1;
  int get endIndex => (currentPage * itemsPerPage).clamp(0, totalItems);
  bool get hasPreviousPage => currentPage > 1;
  bool get hasNextPage => currentPage < totalPages;

  List<int> get pageNumbers {
    List<int> pages = [];
    for (int i = 1; i <= totalPages; i++) {
      pages.add(i);
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Responsive Pagination')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: itemsPerPage,
              itemBuilder: (context, index) {
                int itemIndex = startIndex + index;
                if (itemIndex > totalItems) return SizedBox.shrink();

                return ListTile(
                  title: Text('Item $itemIndex'),
                  subtitle: Text('This is item number $itemIndex'),
                );
              },
            ),
          ),
          PaginationWidget(
            currentPage: currentPage,
            totalItems: totalItems,
            itemsPerPage: itemsPerPage,
            availablePageSizes: availablePageSizes,
            startIndex: startIndex,
            endIndex: endIndex,
            hasPreviousPage: hasPreviousPage,
            hasNextPage: hasNextPage,
            pageNumbers: pageNumbers,
            onPageSizeChanged: (newSize) {
              setState(() {
                itemsPerPage = newSize;
                currentPage = 1; // Reset ke halaman pertama
              });
            },
            onPreviousPage: () {
              setState(() {
                currentPage--;
              });
            },
            onNextPage: () {
              setState(() {
                currentPage++;
              });
            },
            onPageSelected: (page) {
              setState(() {
                currentPage = page;
              });
            },
          ),
        ],
      ),
    );
  }
}
