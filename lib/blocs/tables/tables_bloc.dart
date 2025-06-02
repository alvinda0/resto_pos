import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/blocs/tables/tables_event.dart';
import 'package:pos/blocs/tables/tables_state.dart';
import 'package:pos/models/auth/auth_model.dart';
import 'package:pos/models/tables/model_tables.dart';
import 'package:pos/repositories/tables/tables_repository.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  final TableRepository _tableRepository;

  TableBloc({required TableRepository tableRepository})
      : _tableRepository = tableRepository,
        super(TableInitial()) {
    on<TableLoadRequested>(_onLoadRequested);
    on<TableCreateRequested>(_onCreateRequested);
    on<TableDeleteRequested>(_onDeleteRequested);
    on<TableUpdateRequested>(_onUpdateRequested);
    on<TableRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    TableLoadRequested event,
    Emitter<TableState> emit,
  ) async {
    emit(TableLoading());

    try {
      final response = await _tableRepository.getTables(
        event.token,
        storeId: event.storeId,
      );
      emit(TableLoaded(tables: response.data.qrCodes));
    } catch (error) {
      if (error is ApiError) {
        emit(TableError(error: error));
      } else {
        emit(TableError(error: ApiError(message: error.toString())));
      }
    }
  }

  Future<void> _onCreateRequested(
    TableCreateRequested event,
    Emitter<TableState> emit,
  ) async {
    final currentState = state;
    final currentTables =
        currentState is TableLoaded ? currentState.tables : <QrCodeModel>[];

    emit(TableActionLoading(tables: currentTables, actionType: 'create'));

    try {
      await _tableRepository.createTable(
        event.token,
        event.tableNumber,
        storeId: event.storeId,
      );

      // Refresh the tables list after successful creation
      final response = await _tableRepository.getTables(
        event.token,
        storeId: event.storeId,
      );
      emit(TableActionSuccess(
        tables: response.data.qrCodes,
        message: 'Meja berhasil ditambahkan',
      ));
    } catch (error) {
      if (error is ApiError) {
        emit(TableError(error: error));
      } else {
        emit(TableError(error: ApiError(message: error.toString())));
      }
    }
  }

  Future<void> _onDeleteRequested(
    TableDeleteRequested event,
    Emitter<TableState> emit,
  ) async {
    final currentState = state;
    final currentTables =
        currentState is TableLoaded ? currentState.tables : <QrCodeModel>[];

    emit(TableActionLoading(tables: currentTables, actionType: 'delete'));

    try {
      await _tableRepository.deleteTable(
        event.token,
        event.tableId,
        storeId: event.storeId,
      );

      // Refresh the tables list after successful deletion
      final response = await _tableRepository.getTables(
        event.token,
        storeId: event.storeId,
      );
      emit(TableActionSuccess(
        tables: response.data.qrCodes,
        message: 'Meja berhasil dihapus',
      ));
    } catch (error) {
      if (error is ApiError) {
        emit(TableError(error: error));
      } else {
        emit(TableError(error: ApiError(message: error.toString())));
      }
    }
  }

  Future<void> _onUpdateRequested(
    TableUpdateRequested event,
    Emitter<TableState> emit,
  ) async {
    final currentState = state;
    final currentTables =
        currentState is TableLoaded ? currentState.tables : <QrCodeModel>[];

    emit(TableActionLoading(tables: currentTables, actionType: 'update'));

    try {
      await _tableRepository.updateTable(
        event.token,
        event.tableId,
        event.data,
        storeId: event.storeId,
      );

      // Refresh the tables list after successful update
      final response = await _tableRepository.getTables(
        event.token,
        storeId: event.storeId,
      );
      emit(TableActionSuccess(
        tables: response.data.qrCodes,
        message: 'Meja berhasil diperbarui',
      ));
    } catch (error) {
      if (error is ApiError) {
        emit(TableError(error: error));
      } else {
        emit(TableError(error: ApiError(message: error.toString())));
      }
    }
  }

  Future<void> _onRefreshRequested(
    TableRefreshRequested event,
    Emitter<TableState> emit,
  ) async {
    try {
      final response = await _tableRepository.getTables(
        event.token,
        storeId: event.storeId,
      );
      emit(TableLoaded(tables: response.data.qrCodes));
    } catch (error) {
      if (error is ApiError) {
        emit(TableError(error: error));
      } else {
        emit(TableError(error: ApiError(message: error.toString())));
      }
    }
  }
}
