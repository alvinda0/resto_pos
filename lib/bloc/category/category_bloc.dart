import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shao_kao/services/category/category_service.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryService _categoryService;

  // Form state
  String _nameValue = '';
  String _positionValue = '';
  bool _isActiveValue = true;
  bool _isEditMode = false;
  String? _editingId;

  // Pagination and filter state
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int _totalItems = 0;
  int _totalPages = 0;
  String _searchQuery = '';
  String _statusFilter = '';

  CategoryBloc({required CategoryService categoryService})
      : _categoryService = categoryService,
        super(const CategoryInitial()) {
    on<CategoryLoadRequested>(_onLoadRequested);
    on<CategoryCreateRequested>(_onCreateRequested);
    on<CategoryUpdateRequested>(_onUpdateRequested);
    on<CategoryDeleteRequested>(_onDeleteRequested);
    on<CategoryPageChanged>(_onPageChanged);
    on<CategoryPageSizeChanged>(_onPageSizeChanged);
    on<CategorySearchChanged>(_onSearchChanged);
    on<CategoryStatusFilterChanged>(_onStatusFilterChanged);
    on<CategorySearchCleared>(_onSearchCleared);
    on<CategoryRefreshRequested>(_onRefreshRequested);
    on<CategoryFormActiveToggled>(_onFormActiveToggled);
    on<CategoryFormPreparedForCreate>(_onFormPreparedForCreate);
    on<CategoryFormPreparedForEdit>(_onFormPreparedForEdit);
  }

  // Getters for current state
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _totalItems;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get nameValue => _nameValue;
  String get positionValue => _positionValue;
  bool get isActiveValue => _isActiveValue;
  bool get isEditMode => _isEditMode;
  String? get editingId => _editingId;

  // Pagination helpers
  bool get hasPreviousPage => _currentPage > 1;
  bool get hasNextPage => _currentPage < _totalPages;

  int get startIndex {
    if (_totalItems == 0) return 0;
    return ((_currentPage - 1) * _itemsPerPage) + 1;
  }

  int get endIndex {
    final end = _currentPage * _itemsPerPage;
    return end > _totalItems ? _totalItems : end;
  }

  List<int> get pageNumbers {
    if (_totalPages <= 0) return [];

    const maxVisiblePages = 5;
    final pages = <int>[];

    if (_totalPages <= maxVisiblePages) {
      for (int i = 1; i <= _totalPages; i++) {
        pages.add(i);
      }
    } else {
      int start = (_currentPage - (maxVisiblePages ~/ 2)).clamp(1, _totalPages);
      int end = (start + maxVisiblePages - 1).clamp(1, _totalPages);

      if (end == _totalPages) {
        start = (end - maxVisiblePages + 1).clamp(1, _totalPages);
      }

      for (int i = start; i <= end; i++) {
        pages.add(i);
      }
    }

    return pages;
  }

  Future<void> _onLoadRequested(
    CategoryLoadRequested event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      if (event.showLoading) {
        emit(const CategoryLoading());
      }

      // Update pagination and filter parameters
      _currentPage = event.page ?? _currentPage;
      _itemsPerPage = event.limit ?? _itemsPerPage;
      _searchQuery = event.search ?? _searchQuery;
      _statusFilter = event.status ?? _statusFilter;

      final response = await _categoryService.getCategories(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        status: _statusFilter.isEmpty ? null : _statusFilter,
      );

      _totalItems = response.metadata.total;
      _totalPages = response.metadata.totalPages;
      _currentPage = response.metadata.page;
      _itemsPerPage = response.metadata.limit;

      emit(CategoryLoaded(
        categories: response.data,
        currentPage: _currentPage,
        itemsPerPage: _itemsPerPage,
        totalItems: _totalItems,
        totalPages: _totalPages,
        searchQuery: _searchQuery,
        statusFilter: _statusFilter,
      ));
    } catch (e) {
      emit(CategoryError('Gagal memuat data kategori: ${e.toString()}'));
    }
  }

  Future<void> _onCreateRequested(
    CategoryCreateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryOperationLoading('create'));

      await _categoryService.createCategory(
        name: event.name,
        isActive: event.isActive,
        position: event.position,
        storeId: event.storeId,
      );

      emit(CategoryOperationSuccess(
        message: 'Kategori "${event.name}" berhasil dibuat',
        operation: 'create',
      ));

      // Reload categories
      add(const CategoryLoadRequested(showLoading: false));
    } catch (e) {
      emit(CategoryError('Gagal membuat kategori: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateRequested(
    CategoryUpdateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryOperationLoading('update'));

      await _categoryService.updateCategory(
        event.id,
        name: event.name,
        isActive: event.isActive,
        position: event.position,
        storeId: event.storeId,
      );

      emit(const CategoryOperationSuccess(
        message: 'Kategori berhasil diperbarui',
        operation: 'update',
      ));

      // Reload categories
      add(const CategoryLoadRequested(showLoading: false));
    } catch (e) {
      emit(CategoryError('Gagal memperbarui kategori: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteRequested(
    CategoryDeleteRequested event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryOperationLoading('delete'));

      final success = await _categoryService.deleteCategory(
        event.id,
        storeId: event.storeId,
      );

      if (success) {
        emit(const CategoryOperationSuccess(
          message: 'Kategori berhasil dihapus',
          operation: 'delete',
        ));

        // Adjust pagination if needed
        _totalItems = _totalItems - 1;
        if (_totalItems > 0) {
          _totalPages = (_totalItems / _itemsPerPage).ceil();
          if (_currentPage > _totalPages) {
            _currentPage = _totalPages;
          }
        }

        // Reload categories
        add(const CategoryLoadRequested(showLoading: false));
      } else {
        emit(const CategoryError('Gagal menghapus kategori'));
      }
    } catch (e) {
      emit(CategoryError('Gagal menghapus kategori: ${e.toString()}'));
    }
  }

  void _onPageChanged(
    CategoryPageChanged event,
    Emitter<CategoryState> emit,
  ) {
    _currentPage = event.page;
    add(const CategoryLoadRequested());
  }

  void _onPageSizeChanged(
    CategoryPageSizeChanged event,
    Emitter<CategoryState> emit,
  ) {
    _itemsPerPage = event.size;
    _currentPage = 1;
    add(const CategoryLoadRequested());
  }

  void _onSearchChanged(
    CategorySearchChanged event,
    Emitter<CategoryState> emit,
  ) {
    _searchQuery = event.query;
    _currentPage = 1;
    add(const CategoryLoadRequested());
  }

  void _onStatusFilterChanged(
    CategoryStatusFilterChanged event,
    Emitter<CategoryState> emit,
  ) {
    _statusFilter = event.status;
    _currentPage = 1;
    add(const CategoryLoadRequested());
  }

  void _onSearchCleared(
    CategorySearchCleared event,
    Emitter<CategoryState> emit,
  ) {
    _searchQuery = '';
    _currentPage = 1;
    add(const CategoryLoadRequested());
  }

  void _onRefreshRequested(
    CategoryRefreshRequested event,
    Emitter<CategoryState> emit,
  ) {
    add(const CategoryLoadRequested(showLoading: false));
  }

  void _onFormActiveToggled(
    CategoryFormActiveToggled event,
    Emitter<CategoryState> emit,
  ) {
    _isActiveValue = !_isActiveValue;
    emit(CategoryFormState(
      nameValue: _nameValue,
      positionValue: _positionValue,
      isActiveValue: _isActiveValue,
      isEditMode: _isEditMode,
      editingId: _editingId,
    ));
  }

  void _onFormPreparedForCreate(
    CategoryFormPreparedForCreate event,
    Emitter<CategoryState> emit,
  ) {
    _nameValue = '';
    _positionValue = '';
    _isActiveValue = true;
    _isEditMode = false;
    _editingId = null;

    emit(CategoryFormState(
      nameValue: _nameValue,
      positionValue: _positionValue,
      isActiveValue: _isActiveValue,
      isEditMode: _isEditMode,
      editingId: _editingId,
    ));
  }

  void _onFormPreparedForEdit(
    CategoryFormPreparedForEdit event,
    Emitter<CategoryState> emit,
  ) {
    _nameValue = event.name;
    _positionValue = event.position?.toString() ?? '';
    _isActiveValue = event.isActive;
    _isEditMode = true;
    _editingId = event.id;

    emit(CategoryFormState(
      nameValue: _nameValue,
      positionValue: _positionValue,
      isActiveValue: _isActiveValue,
      isEditMode: _isEditMode,
      editingId: _editingId,
    ));
  }

  // Helper methods for form validation
  bool validateForm() {
    return _nameValue.trim().isNotEmpty;
  }

  int? parsePosition() {
    if (_positionValue.trim().isEmpty) return null;
    return int.tryParse(_positionValue.trim());
  }

  // Update form values
  void updateNameValue(String value) {
    _nameValue = value;
  }

  void updatePositionValue(String value) {
    _positionValue = value;
  }
}