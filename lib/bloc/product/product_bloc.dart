import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shao_kao/models/product/product_model.dart';
import 'package:shao_kao/services/product/product_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService _productService;

  // Pagination and filter state
  int _currentPage = 1;
  int _itemsPerPage = 12;
  int _totalItems = 0;
  int _totalPages = 0;
  String _searchQuery = '';
  String _categoryFilter = '';

  // Categories cache
  List<ProductCategory> _categories = [];

  ProductBloc({required ProductService productService})
      : _productService = productService,
        super(const ProductInitial()) {
    on<ProductLoadRequested>(_onLoadRequested);
    on<ProductCreateRequested>(_onCreateRequested);
    on<ProductUpdateRequested>(_onUpdateRequested);
    on<ProductDeleteRequested>(_onDeleteRequested);
    on<ProductByIdRequested>(_onByIdRequested);
    on<ProductPageChanged>(_onPageChanged);
    on<ProductPageSizeChanged>(_onPageSizeChanged);
    on<ProductSearchChanged>(_onSearchChanged);
    on<ProductCategoryFilterChanged>(_onCategoryFilterChanged);
    on<ProductFiltersCleared>(_onFiltersCleared);
    on<ProductRefreshRequested>(_onRefreshRequested);
    on<ProductCategoriesLoadRequested>(_onCategoriesLoadRequested);
  }

  // Getters
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _totalItems;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;
  String get categoryFilter => _categoryFilter;
  List<ProductCategory> get categories => _categories;

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

    if (_totalPages <= 7) {
      return List.generate(_totalPages, (index) => index + 1);
    }

    List<int> pages = [];
    int current = _currentPage;
    int total = _totalPages;

    if (current <= 4) {
      pages = [1, 2, 3, 4, 5];
      if (total > 5) pages.addAll([0, total]);
    } else if (current >= total - 3) {
      pages = [1, 0];
      pages.addAll(List.generate(5, (index) => total - 4 + index));
    } else {
      pages = [1, 0, current - 1, current, current + 1, 0, total];
    }

    return pages;
  }

  Future<void> _onLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      if (event.showLoading) {
        emit(const ProductLoading());
      }

      // Update pagination and filter parameters
      _currentPage = event.page ?? _currentPage;
      _itemsPerPage = event.limit ?? _itemsPerPage;
      _searchQuery = event.search ?? _searchQuery;
      _categoryFilter = event.category ?? _categoryFilter;

      final response = await _productService.getProducts(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        category: _categoryFilter.isEmpty ? null : _categoryFilter,
      );

      _totalItems = response.metadata.total;
      _totalPages = response.metadata.totalPages;
      _currentPage = response.metadata.page;
      _itemsPerPage = response.metadata.limit;

      emit(ProductLoaded(
        products: response.data,
        currentPage: _currentPage,
        itemsPerPage: _itemsPerPage,
        totalItems: _totalItems,
        totalPages: _totalPages,
        searchQuery: _searchQuery,
        categoryFilter: _categoryFilter,
      ));
    } catch (e) {
      emit(ProductError('Gagal memuat data produk: ${e.toString()}'));
    }
  }

  Future<void> _onCreateRequested(
    ProductCreateRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductOperationLoading('create'));

      await _productService.createProduct(
        name: event.name,
        description: event.description,
        basePrice: event.basePrice,
        categoryId: event.categoryId,
        isAvailable: event.isAvailable,
        position: event.position,
        recipeId: event.recipeId,
        imageFile: event.imageFile,
      );

      emit(ProductOperationSuccess(
        message: 'Produk "${event.name}" berhasil dibuat',
        operation: 'create',
      ));

      // Reload products
      add(const ProductLoadRequested(showLoading: false));
    } catch (e) {
      emit(ProductError('Gagal membuat produk: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateRequested(
    ProductUpdateRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductOperationLoading('update'));

      await _productService.updateProduct(
        id: event.id,
        name: event.name,
        description: event.description,
        basePrice: event.basePrice,
        categoryId: event.categoryId,
        isAvailable: event.isAvailable,
        position: event.position,
        recipeId: event.recipeId,
        imageFile: event.imageFile,
      );

      emit(const ProductOperationSuccess(
        message: 'Produk berhasil diperbarui',
        operation: 'update',
      ));

      // Reload products
      add(const ProductLoadRequested(showLoading: false));
    } catch (e) {
      emit(ProductError('Gagal memperbarui produk: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteRequested(
    ProductDeleteRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductOperationLoading('delete'));

      final success = await _productService.deleteProduct(event.id);

      if (success) {
        emit(const ProductOperationSuccess(
          message: 'Produk berhasil dihapus',
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

        // Reload products
        add(const ProductLoadRequested(showLoading: false));
      } else {
        emit(const ProductError('Gagal menghapus produk'));
      }
    } catch (e) {
      emit(ProductError('Gagal menghapus produk: ${e.toString()}'));
    }
  }

  Future<void> _onByIdRequested(
    ProductByIdRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductLoading());

      final product = await _productService.getProductById(event.id);

      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductError('Gagal memuat detail produk: ${e.toString()}'));
    }
  }

  void _onPageChanged(
    ProductPageChanged event,
    Emitter<ProductState> emit,
  ) {
    _currentPage = event.page;
    add(const ProductLoadRequested());
  }

  void _onPageSizeChanged(
    ProductPageSizeChanged event,
    Emitter<ProductState> emit,
  ) {
    _itemsPerPage = event.size;
    _currentPage = 1;
    add(const ProductLoadRequested());
  }

  void _onSearchChanged(
    ProductSearchChanged event,
    Emitter<ProductState> emit,
  ) {
    _searchQuery = event.query;
    _currentPage = 1;
    add(const ProductLoadRequested());
  }

  void _onCategoryFilterChanged(
    ProductCategoryFilterChanged event,
    Emitter<ProductState> emit,
  ) {
    _categoryFilter = event.category;
    _currentPage = 1;
    add(const ProductLoadRequested());
  }

  void _onFiltersCleared(
    ProductFiltersCleared event,
    Emitter<ProductState> emit,
  ) {
    _searchQuery = '';
    _categoryFilter = '';
    _currentPage = 1;
    add(const ProductLoadRequested());
  }

  void _onRefreshRequested(
    ProductRefreshRequested event,
    Emitter<ProductState> emit,
  ) {
    add(const ProductLoadRequested(showLoading: false));
  }

  Future<void> _onCategoriesLoadRequested(
    ProductCategoriesLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      _categories = await _productService.getCategories();
      emit(ProductCategoriesLoaded(_categories));
    } catch (e) {
      emit(ProductError('Gagal memuat kategori: ${e.toString()}'));
    }
  }

  // Helper method for currency formatting
  String formatCurrency(int amount) {
    return 'Rp${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }
}
