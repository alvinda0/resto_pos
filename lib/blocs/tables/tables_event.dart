import 'package:equatable/equatable.dart';

abstract class TableEvent extends Equatable {
  const TableEvent();

  @override
  List<Object?> get props => [];
}

class TableLoadRequested extends TableEvent {
  final String token;
  final String? storeId;

  const TableLoadRequested({
    required this.token,
    this.storeId,
  });

  @override
  List<Object?> get props => [token, storeId];
}

class TableCreateRequested extends TableEvent {
  final String token;
  final String tableNumber;
  final String? storeId;

  const TableCreateRequested({
    required this.token,
    required this.tableNumber,
    this.storeId,
  });

  @override
  List<Object?> get props => [token, tableNumber, storeId];
}

class TableDeleteRequested extends TableEvent {
  final String token;
  final String tableId;
  final String? storeId;

  const TableDeleteRequested({
    required this.token,
    required this.tableId,
    this.storeId,
  });

  @override
  List<Object?> get props => [token, tableId, storeId];
}

class TableUpdateRequested extends TableEvent {
  final String token;
  final String tableId;
  final Map<String, dynamic> data;
  final String? storeId;

  const TableUpdateRequested({
    required this.token,
    required this.tableId,
    required this.data,
    this.storeId,
  });

  @override
  List<Object?> get props => [token, tableId, data, storeId];
}

class TableRefreshRequested extends TableEvent {
  final String token;
  final String? storeId;

  const TableRefreshRequested({
    required this.token,
    this.storeId,
  });

  @override
  List<Object?> get props => [token, storeId];
}
