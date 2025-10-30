import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'kitchen_event.dart';
import 'kitchen_state.dart';

class KitchenBloc extends Bloc<KitchenEvent, KitchenState> {
  Timer? _autoRefreshTimer;

  String _selectedStatus = 'ALL';
  bool _isAutoRefreshEnabled = true;
  List<dynamic> _orders = [];

  final List<String> statusOptions = [
    'ALL',
    'PENDING',
    'COOKING',
    'READY',
    'SERVED',
  ];

  KitchenBloc() : super(const KitchenInitial()) {
    on<KitchenOrdersLoadRequested>(_onOrdersLoadRequested);
    on<KitchenOrderStatusUpdateRequested>(_onOrderStatusUpdateRequested);
    on<KitchenOrderItemCompleteRequested>(_onOrderItemCompleteRequested);
    on<KitchenRefreshRequested>(_onRefreshRequested);
    on<KitchenAutoRefreshToggled>(_onAutoRefreshToggled);
    on<KitchenAutoRefreshTick>(_onAutoRefreshTick);
    on<KitchenStatusFilterChanged>(_onStatusFilterChanged);

    _startAutoRefresh();
  }

  String get selectedStatus => _selectedStatus;
  bool get isAutoRefreshEnabled => _isAutoRefreshEnabled;

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        if (_isAutoRefreshEnabled && state is KitchenLoaded) {
          add(const KitchenAutoRefreshTick());
        }
      },
    );
  }

  Future<void> _onOrdersLoadRequested(
    KitchenOrdersLoadRequested event,
    Emitter<KitchenState> emit,
  ) async {
    try {
      if (event.showLoading) {
        emit(const KitchenLoading());
      }

      _selectedStatus = event.status ?? _selectedStatus;

      // TODO: Implement actual service call
      _orders = [];

      emit(KitchenLoaded(
        orders: _orders,
        selectedStatus: _selectedStatus,
        isAutoRefreshEnabled: _isAutoRefreshEnabled,
      ));
    } catch (e) {
      emit(KitchenError('Gagal memuat pesanan dapur: ${e.toString()}'));
    }
  }

  Future<void> _onOrderStatusUpdateRequested(
    KitchenOrderStatusUpdateRequested event,
    Emitter<KitchenState> emit,
  ) async {
    try {
      emit(const KitchenOperationLoading('update_status'));

      // TODO: Implement actual service call

      emit(const KitchenOperationSuccess(
        message: 'Status pesanan berhasil diperbarui',
        operation: 'update_status',
      ));

      add(const KitchenOrdersLoadRequested(showLoading: false));
    } catch (e) {
      emit(KitchenError('Gagal memperbarui status: ${e.toString()}'));
    }
  }

  Future<void> _onOrderItemCompleteRequested(
    KitchenOrderItemCompleteRequested event,
    Emitter<KitchenState> emit,
  ) async {
    try {
      emit(const KitchenOperationLoading('complete_item'));

      // TODO: Implement actual service call

      emit(const KitchenOperationSuccess(
        message: 'Item berhasil diselesaikan',
        operation: 'complete_item',
      ));

      add(const KitchenOrdersLoadRequested(showLoading: false));
    } catch (e) {
      emit(KitchenError('Gagal menyelesaikan item: ${e.toString()}'));
    }
  }

  void _onRefreshRequested(
    KitchenRefreshRequested event,
    Emitter<KitchenState> emit,
  ) {
    add(const KitchenOrdersLoadRequested(showLoading: false));
  }

  void _onAutoRefreshToggled(
    KitchenAutoRefreshToggled event,
    Emitter<KitchenState> emit,
  ) {
    _isAutoRefreshEnabled = !_isAutoRefreshEnabled;

    if (state is KitchenLoaded) {
      final currentState = state as KitchenLoaded;
      emit(currentState.copyWith(
        isAutoRefreshEnabled: _isAutoRefreshEnabled,
      ));
    }
  }

  Future<void> _onAutoRefreshTick(
    KitchenAutoRefreshTick event,
    Emitter<KitchenState> emit,
  ) async {
    try {
      // TODO: Implement actual service call
      // Silent refresh without showing loading

      if (state is KitchenLoaded) {
        final currentState = state as KitchenLoaded;
        emit(currentState.copyWith(orders: _orders));
      }
    } catch (e) {
      // Silent fail for auto refresh
    }
  }

  void _onStatusFilterChanged(
    KitchenStatusFilterChanged event,
    Emitter<KitchenState> emit,
  ) {
    _selectedStatus = event.status;
    add(const KitchenOrdersLoadRequested());
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }
}
