import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  // Pagination and filter state
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int _totalItems = 0;
  int _totalPages = 0;
  String _searchQuery = '';
  String _roleFilter = '';

  UserBloc() : super(const UserInitial()) {
    on<UserLoadRequested>(_onLoadRequested);
    on<UserCreateRequested>(_onCreateRequested);
    on<UserUpdateRequested>(_onUpdateRequested);
    on<UserDeleteRequested>(_onDeleteRequested);
    on<UserByIdRequested>(_onByIdRequested);
    on<UserPageChanged>(_onPageChanged);
    on<UserSearchChanged>(_onSearchChanged);
    on<UserRoleFilterChanged>(_onRoleFilterChanged);
    on<UserRefreshRequested>(_onRefreshRequested);
  }

  // Getters
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _totalItems;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;
  String get roleFilter => _roleFilter;

  Future<void> _onLoadRequested(
    UserLoadRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      if (event.showLoading) {
        emit(const UserLoading());
      }

      _currentPage = event.page ?? _currentPage;
      _itemsPerPage = event.limit ?? _itemsPerPage;
      _searchQuery = event.search ?? _searchQuery;
      _roleFilter = event.role ?? _roleFilter;

      // TODO: Implement actual service call
      // For now, emit empty loaded state
      emit(UserLoaded(
        users: const [],
        currentPage: _currentPage,
        itemsPerPage: _itemsPerPage,
        totalItems: 0,
        totalPages: 0,
        searchQuery: _searchQuery,
        roleFilter: _roleFilter,
      ));
    } catch (e) {
      emit(UserError('Gagal memuat data user: ${e.toString()}'));
    }
  }

  Future<void> _onCreateRequested(
    UserCreateRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserOperationLoading('create'));

      // TODO: Implement actual service call

      emit(UserOperationSuccess(
        message: 'User "${event.name}" berhasil dibuat',
        operation: 'create',
      ));

      add(const UserLoadRequested(showLoading: false));
    } catch (e) {
      emit(UserError('Gagal membuat user: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateRequested(
    UserUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserOperationLoading('update'));

      // TODO: Implement actual service call

      emit(const UserOperationSuccess(
        message: 'User berhasil diperbarui',
        operation: 'update',
      ));

      add(const UserLoadRequested(showLoading: false));
    } catch (e) {
      emit(UserError('Gagal memperbarui user: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteRequested(
    UserDeleteRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserOperationLoading('delete'));

      // TODO: Implement actual service call

      emit(const UserOperationSuccess(
        message: 'User berhasil dihapus',
        operation: 'delete',
      ));

      add(const UserLoadRequested(showLoading: false));
    } catch (e) {
      emit(UserError('Gagal menghapus user: ${e.toString()}'));
    }
  }

  Future<void> _onByIdRequested(
    UserByIdRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      // TODO: Implement actual service call

      emit(const UserLoaded(
        users: [],
        currentPage: 1,
        itemsPerPage: 10,
        totalItems: 0,
        totalPages: 0,
        searchQuery: '',
        roleFilter: '',
      ));
    } catch (e) {
      emit(UserError('Gagal memuat detail user: ${e.toString()}'));
    }
  }

  void _onPageChanged(
    UserPageChanged event,
    Emitter<UserState> emit,
  ) {
    _currentPage = event.page;
    add(const UserLoadRequested());
  }

  void _onSearchChanged(
    UserSearchChanged event,
    Emitter<UserState> emit,
  ) {
    _searchQuery = event.query;
    _currentPage = 1;
    add(const UserLoadRequested());
  }

  void _onRoleFilterChanged(
    UserRoleFilterChanged event,
    Emitter<UserState> emit,
  ) {
    _roleFilter = event.role;
    _currentPage = 1;
    add(const UserLoadRequested());
  }

  void _onRefreshRequested(
    UserRefreshRequested event,
    Emitter<UserState> emit,
  ) {
    add(const UserLoadRequested(showLoading: false));
  }
}
