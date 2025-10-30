import 'package:equatable/equatable.dart';

abstract class TableState extends Equatable {
  const TableState();

  @override
  List<Object?> get props => [];
}

class TableInitial extends TableState {
  const TableInitial();
}

class TableLoading extends TableState {
  const TableLoading();
}

class TableLoaded extends TableState {
  final List<dynamic> tables;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int totalPages;
  final String searchQuery;

  const TableLoaded({
    required this.tables,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
    required this.totalPages,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [
        tables,
        currentPage,
        itemsPerPage,
        totalItems,
        totalPages,
        searchQuery,
      ];
}

class TableOperationLoading extends TableState {
  final String operation;

  const TableOperationLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}

class TableOperationSuccess extends TableState {
  final String message;
  final String operation;

  const TableOperationSuccess({
    required this.message,
    required this.operation,
  });

  @override
  List<Object?> get props => [message, operation];
}

class TableQRCodeGenerated extends TableState {
  final String tableId;
  final String qrCode;

  const TableQRCodeGenerated({
    required this.tableId,
    required this.qrCode,
  });

  @override
  List<Object?> get props => [tableId, qrCode];
}

class TableError extends TableState {
  final String message;

  const TableError(this.message);

  @override
  List<Object?> get props => [message];
}
