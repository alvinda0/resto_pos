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
            horizontal: isMobile ? 12 : 24,
            vertical: isMobile ? 8 : 16,
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

  // Layout untuk mobile - SINGLE ROW
  Widget _buildMobileLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Kiri: Items count info (compact)
        Flexible(
          flex: 2,
          child: _buildCompactItemsInfo(),
        ),

        // Tengah: Pagination controls (sangat compact)
        Flexible(
          flex: 3,
          child: _buildPaginationControls(compact: true),
        ),

        // Kanan: Rows per page (compact)
        Flexible(
          flex: 2,
          child: _buildCompactRowsPerPageSelector(),
        ),
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

  // Compact version untuk mobile
  Widget _buildCompactRowsPerPageSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: itemsPerPage,
              isDense: true,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
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

  // Compact version untuk mobile
  Widget _buildCompactItemsInfo() {
    return Text(
      '$startIndex-$endIndex/$totalItems',
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 12,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPaginationControls({required bool compact}) {
    // Untuk mobile, batasi jumlah page numbers yang ditampilkan
    List<int> displayPageNumbers = pageNumbers;

    if (compact && pageNumbers.length > 3) {
      // Logic untuk menampilkan page numbers yang sangat sedikit di mobile
      displayPageNumbers = _getUltraCompactPageNumbers();
    }

    final buttonSize = compact ? 24.0 : 32.0;
    final iconSize = compact ? 16.0 : 20.0;
    final fontSize = compact ? 12.0 : 14.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous page button
        InkWell(
          onTap: !hasPreviousPage ? null : onPreviousPage,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color:
                  !hasPreviousPage ? Colors.grey.shade100 : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.chevron_left,
              size: iconSize,
              color: !hasPreviousPage
                  ? Colors.grey.shade400
                  : Colors.grey.shade700,
            ),
          ),
        ),

        const SizedBox(width: 2),

        // Page numbers (sangat terbatas untuk mobile)
        ...displayPageNumbers.map((pageNumber) {
          if (pageNumber == -1) {
            // Ellipsis
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: buttonSize,
              height: buttonSize,
              child: Center(
                child: Text(
                  '...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: fontSize,
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
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: isCurrentPage ? Colors.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '$pageNumber',
                    style: TextStyle(
                      color:
                          isCurrentPage ? Colors.white : Colors.grey.shade700,
                      fontWeight:
                          isCurrentPage ? FontWeight.w600 : FontWeight.normal,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(width: 2),

        // Next page button
        InkWell(
          onTap: !hasNextPage ? null : onNextPage,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: !hasNextPage ? Colors.grey.shade100 : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.chevron_right,
              size: iconSize,
              color: !hasNextPage ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // Generate ultra compact page numbers untuk mobile (maksimal 3 angka)
  List<int> _getUltraCompactPageNumbers() {
    List<int> result = [];
    int totalPages = pageNumbers.last;

    if (totalPages <= 3) {
      return pageNumbers;
    }

    if (currentPage <= 2) {
      // Tampilkan: 1, 2, ..., last
      result.addAll([1, 2, -1, totalPages]);
    } else if (currentPage >= totalPages - 1) {
      // Tampilkan: 1, ..., last-1, last
      result.addAll([1, -1, totalPages - 1, totalPages]);
    } else {
      // Tampilkan: 1, ..., current, ..., last
      result.addAll([1, -1, currentPage, -1, totalPages]);
    }

    return result;
  }

  // Alternatif: hanya tampilkan current page untuk mobile yang sangat kecil
  List<int> _getMinimalPageNumbers() {
    return [currentPage];
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
      appBar: AppBar(title: Text('Compact Mobile Pagination')),
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
                currentPage = 1;
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
