import 'package:equatable/equatable.dart';

abstract class TableEvent extends Equatable {
  const TableEvent();

  @override
  List<Object> get props => [];
}

class TableLoadRequested extends TableEvent {
  final String token;

  const TableLoadRequested({required this.token});

  @override
  List<Object> get props => [token];
}

class TableCreateRequested extends TableEvent {
  final String token;
  final String tableNumber;

  const TableCreateRequested({
    required this.token,
    required this.tableNumber,
  });

  @override
  List<Object> get props => [token, tableNumber];
}

class TableDeleteRequested extends TableEvent {
  final String token;
  final String tableId;

  const TableDeleteRequested({
    required this.token,
    required this.tableId,
  });

  @override
  List<Object> get props => [token, tableId];
}

class TableUpdateRequested extends TableEvent {
  final String token;
  final String tableId;
  final Map<String, dynamic> data;

  const TableUpdateRequested({
    required this.token,
    required this.tableId,
    required this.data,
  });

  @override
  List<Object> get props => [token, tableId, data];
}

class TableRefreshRequested extends TableEvent {
  final String token;

  const TableRefreshRequested({required this.token});

  @override
  List<Object> get props => [token];
}
