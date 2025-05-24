import 'package:equatable/equatable.dart';
import 'package:pos/models/auth/auth_model.dart';
import 'package:pos/models/tables/model_tables.dart';

abstract class TableState extends Equatable {
  const TableState();

  @override
  List<Object> get props => [];
}

class TableInitial extends TableState {}

class TableLoading extends TableState {}

class TableLoaded extends TableState {
  final List<QrCodeModel> tables;

  const TableLoaded({required this.tables});

  @override
  List<Object> get props => [tables];
}

class TableError extends TableState {
  final ApiError error;

  const TableError({required this.error});

  @override
  List<Object> get props => [error];
}

class TableActionLoading extends TableState {
  final List<QrCodeModel> tables;
  final String actionType; // 'create', 'delete', 'update'

  const TableActionLoading({
    required this.tables,
    required this.actionType,
  });

  @override
  List<Object> get props => [tables, actionType];
}

class TableActionSuccess extends TableState {
  final List<QrCodeModel> tables;
  final String message;

  const TableActionSuccess({
    required this.tables,
    required this.message,
  });

  @override
  List<Object> get props => [tables, message];
}
