import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shao_kao/models/order/order_model.dart';
import 'package:shao_kao/services/order/order_service.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderService _orderService;
  Timer? _autoRefreshTimer;

  // State variables
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int _totalPages = 1;
  String _searchQuery = '';
  String _selectedStatus = 'Semua Status';
  String _selectedMethod = 'Semua Metode';
  bool _isAutoRefreshEnabled = true;
  List<OrderModel> _orders = [];

  // Filter options
  final List<String> statusOptions = [
    'Semua Status',
    'PENDING',
    'PAID',
    'CANCELLED',
    'COMPLETED'
  ];

  final List<String> methodOptions = [
    'Semua Metode',
    'Tunai',
    'Qris',
  ];

  final List<int> itemsPerPageOptions = [10, 20, 50, 100];

  OrderBloc({required OrderService orderService})
      : _orderService = orderService,
        super(const OrderInitial()) {
    on<OrderLoadRequested>(_onLoadRequested);
    on<OrderSearchChanged>(_onSearchChanged);
    on<OrderStatusFilterChanged>(_onStatusFilterChanged);
    on<OrderMethodFilterChanged>(_onMethodFilterChanged);
    on<OrderPageChanged>(_onPageChanged);
    on<OrderPageSizeChanged>(_onPageSizeChanged);
    on<OrderRefreshRequested>(_onRefreshRequested);
    on<OrderAutoRefreshToggled>(_onAutoRefreshToggled);
    on<OrderAutoRefreshTick>(_onAutoRefreshTick);
    on<OrderFiltersCleared>(_onFiltersCleared);

    // Start auto refresh
    _startAutoRefresh();
  }

  // Getters
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String get selectedMethod => _selectedMethod;
  bool get isAutoRefreshEnabled => _isAutoRefreshEnabled;

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_isAutoRefreshEnabled && state is OrderLoaded) {
          add(const OrderAutoRefreshTick());
        }
      },
    );
  }

  Future<void> _onLoadRequested(
    OrderLoadRequested event,
    Emitter<OrderState> emit,
  ) async {
    try {
      if (event.showLoading) {
        emit(const OrderLoading());
      }

      // Update parameters
      _currentPage = event.page ?? _currentPage;
      _itemsPerPage = event.limit ?? _itemsPerPage;
      _selectedStatus = event.status ?? _selectedStatus;
      _selectedMethod = event.method ?? _selectedMethod;

      final response = await _orderService.getOrders(
        status: _selectedStatus != 'Semua Status' ? _selectedStatus : null,
        method: _selectedMethod != 'Semua Metode' ? _selectedMethod : null,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      _orders = response.data;
      final filteredOrders = _filterOrders(_orders);

      emit(OrderLoaded(
        orders: _orders,
        filteredOrders: filteredOrders,
        currentPage: _currentPage,
        itemsPerPage: _itemsPerPage,
        totalPages: _totalPages,
        searchQuery: _searchQuery,
        selectedStatus: _selectedStatus,
        selectedMethod: _selectedMethod,
        isAutoRefreshEnabled: _isAutoRefreshEnabled,
      ));
    } catch (e) {
      emit(OrderError('Gagal memuat data pesanan: ${e.toString()}'));
    }
  }

  void _onSearchChanged(
    OrderSearchChanged event,
    Emitter<OrderState> emit,
  ) {
    _searchQuery = event.query;
    
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      final filteredOrders = _filterOrders(_orders);
      
      emit(currentState.copyWith(
        searchQuery: _searchQuery,
        filteredOrders: filteredOrders,
      ));
    }
  }

  void _onStatusFilterChanged(
    OrderStatusFilterChanged event,
    Emitter<OrderState> emit,
  ) {
    _selectedStatus = event.status;
    _currentPage = 1;
    add(const OrderLoadRequested());
  }

  void _onMethodFilterChanged(
    OrderMethodFilterChanged event,
    Emitter<OrderState> emit,
  ) {
    _selectedMethod = event.method;
    _currentPage = 1;
    add(const OrderLoadRequested());
  }

  void _onPageChanged(
    OrderPageChanged event,
    Emitter<OrderState> emit,
  ) {
    _currentPage = event.page;
    add(const OrderLoadRequested());
  }

  void _onPageSizeChanged(
    OrderPageSizeChanged event,
    Emitter<OrderState> emit,
  ) {
    _itemsPerPage = event.size;
    _currentPage = 1;
    add(const OrderLoadRequested());
  }

  void _onRefreshRequested(
    OrderRefreshRequested event,
    Emitter<OrderState> emit,
  ) {
    add(const OrderLoadRequested(showLoading: false));
  }

  void _onAutoRefreshToggled(
    OrderAutoRefreshToggled event,
    Emitter<OrderState> emit,
  ) {
    _isAutoRefreshEnabled = !_isAutoRefreshEnabled;
    
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      emit(currentState.copyWith(
        isAutoRefreshEnabled: _isAutoRefreshEnabled,
      ));
    }
  }

  Future<void> _onAutoRefreshTick(
    OrderAutoRefreshTick event,
    Emitter<OrderState> emit,
  ) async {
    try {
      final response = await _orderService.getOrders(
        status: _selectedStatus != 'Semua Status' ? _selectedStatus : null,
        method: _selectedMethod != 'Semua Metode' ? _selectedMethod : null,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      // Only update if data changed
      if (!_isOrdersEqual(_orders, response.data)) {
        _orders = response.data;
        final filteredOrders = _filterOrders(_orders);

        if (state is OrderLoaded) {
          final currentState = state as OrderLoaded;
          emit(currentState.copyWith(
            orders: _orders,
            filteredOrders: filteredOrders,
          ));
        }
      }
    } catch (e) {
      // Silent fail for auto refresh
    }
  }

  void _onFiltersCleared(
    OrderFiltersCleared event,
    Emitter<OrderState> emit,
  ) {
    _searchQuery = '';
    _selectedStatus = 'Semua Status';
    _selectedMethod = 'Semua Metode';
    _currentPage = 1;
    add(const OrderLoadRequested());
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_searchQuery.isEmpty) {
      return orders;
    }

    final query = _searchQuery.toLowerCase();
    return orders.where((order) {
      return order.customerName.toLowerCase().contains(query) ||
          order.customerPhone.contains(query) ||
          order.id.toLowerCase().contains(query);
    }).toList();
  }

  bool _isOrdersEqual(List<OrderModel> oldOrders, List<OrderModel> newOrders) {
    if (oldOrders.length != newOrders.length) return false;

    for (int i = 0; i < oldOrders.length; i++) {
      if (oldOrders[i].id != newOrders[i].id ||
          oldOrders[i].status != newOrders[i].status ||
          oldOrders[i].totalAmount != newOrders[i].totalAmount) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }
}
