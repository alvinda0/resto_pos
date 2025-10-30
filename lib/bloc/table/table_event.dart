import 'package:equatable/equatable.dart';

abstract class TableEvent extends Equatable {
  const TableEvent();

  @override
  List<Object?> get props => [];
}

class TableLoadRequested extends TableEvent {
  final bool showLoading;
  final int? page;
  final int? limit;
  final String? search;

  const TableLoadRequested({
    this.showLoading = true,
    this.page,
    this.limit,
    this.search,
  });

  @override
  List<Object?> get props => [showLoading, page, limit, search];
}

class TableCreateRequested extends TableEvent {
  final int tableNumber;
  final int capacity;
  final String? location;

  const TableCreateRequested({
    required this.tableNumber,
    required this.capacity,
    this.location,
  });

  @override
  List<Object?> get props => [tableNumber, capacity, location];
}

class TableUpdateRequested extends TableEvent {
  final String id;
  final int? tableNumber;
  final int? capacity;
  final String? location;
  final bool? isActive;

  const TableUpdateRequested({
    required this.id,
    this.tableNumber,
    this.capacity,
    this.location,
    this.isActive,
  });

  @override
  List<Object?> get props => [id, tableNumber, capacity, location, isActive];
}

class TableDeleteRequested extends TableEvent {
  final String id;

  const TableDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class TableQRCodeGenerateRequested extends TableEvent {
  final String tableId;

  const TableQRCodeGenerateRequested(this.tableId);

  @override
  List<Object?> get props => [tableId];
}

class TablePageChanged extends TableEvent {
  final int page;

  const TablePageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class TableSearchChanged extends TableEvent {
  final String query;

  const TableSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class TableRefreshRequested extends TableEvent {
  const TableRefreshRequested();
}
