import 'package:flutter_bloc/flutter_bloc.dart';
import 'table_event.dart';
import 'table_state.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int _totalItems = 0;
  int _totalPages = 0;
  String _searchQuery = '';

  TableBloc() : super(const TableInitial()) {
    on<TableLoadRequested>(_onLoadRequested);
    on<TableCreateRequested>(_onCreateRequested);
    on<TableUpdateRequested>(_onUpdateRequested);
    on<TableDeleteRequested>(_onDeleteRequested);
    on<TableQRCodeGenerateRequested>(_onQRCodeGenerateRequested);
    on<TablePageChanged>(_onPageChanged);
    on<TableSearchChanged>(_onSearchChanged);
    on<TableRefreshRequested>(_onRefreshRequested);
  }

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _totalItems;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;

  Future<void> _onLoadRequested(
    TableLoadRequested event,
    Emitter<TableState> emit,
  ) async {
    try {
      if (event.showLoading) {
        emit(const TableLoading());
      }

      _currentPage = event.page ?? _currentPage;
      _itemsPerPage = event.limit ?? _itemsPerPage;
      _searchQuery = event.search ?? _searchQuery;

      // TODO: Implement actual service call

      emit(TableLoaded(
        tables: const [],
        currentPage: _currentPage,
        itemsPerPage: _itemsPerPage,
        totalItems: 0,
        totalPages: 0,
        searchQuery: _searchQuery,
      ));
    } catch (e) {
      emit(TableError('Gagal memuat data meja: ${e.toString()}'));
    }
  }

  Future<void> _onCreateRequested(
    TableCreateRequested event,
    Emitter<TableState> emit,
  ) async {
    try {
      emit(const TableOperationLoading('create'));

      // TODO: Implement actual service call

      emit(TableOperationSuccess(
        message: 'Meja ${event.tableNumber} berhasil dibuat',
        operation: 'create',
      ));

      add(const TableLoadRequested(showLoading: false));
    } catch (e) {
      emit(TableError('Gagal membuat meja: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateRequested(
    TableUpdateRequested event,
    Emitter<TableState> emit,
  ) async {
    try {
      emit(const TableOperationLoading('update'));

      // TODO: Implement actual service call

      emit(const TableOperationSuccess(
        message: 'Meja berhasil diperbarui',
        operation: 'update',
      ));

      add(const TableLoadRequested(showLoading: false));
    } catch (e) {
      emit(TableError('Gagal memperbarui meja: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteRequested(
    TableDeleteRequested event,
    Emitter<TableState> emit,
  ) async {
    try {
      emit(const TableOperationLoading('delete'));

      // TODO: Implement actual service call

      emit(const TableOperationSuccess(
        message: 'Meja berhasil dihapus',
        operation: 'delete',
      ));

      add(const TableLoadRequested(showLoading: false));
    } catch (e) {
      emit(TableError('Gagal menghapus meja: ${e.toString()}'));
    }
  }

  Future<void> _onQRCodeGenerateRequested(
    TableQRCodeGenerateRequested event,
    Emitter<TableState> emit,
  ) async {
    try {
      emit(const TableLoading());

      // TODO: Implement actual QR code generation

      emit(TableQRCodeGenerated(
        tableId: event.tableId,
        qrCode: 'QR_CODE_${event.tableId}',
      ));
    } catch (e) {
      emit(TableError('Gagal generate QR code: ${e.toString()}'));
    }
  }

  void _onPageChanged(
    TablePageChanged event,
    Emitter<TableState> emit,
  ) {
    _currentPage = event.page;
    add(const TableLoadRequested());
  }

  void _onSearchChanged(
    TableSearchChanged event,
    Emitter<TableState> emit,
  ) {
    _searchQuery = event.query;
    _currentPage = 1;
    add(const TableLoadRequested());
  }

  void _onRefreshRequested(
    TableRefreshRequested event,
    Emitter<TableState> emit,
  ) {
    add(const TableLoadRequested(showLoading: false));
  }
}
