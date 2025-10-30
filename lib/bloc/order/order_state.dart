import 'package:equatable/equatable.dart';
import 'package:shao_kao/models/order/order_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  final List<OrderModel> orders;
  final List<OrderModel> filteredOrders;
  final int currentPage;
  final int itemsPerPage;
  final int totalPages;
  final String searchQuery;
  final String selectedStatus;
  final String selectedMethod;
  final bool isAutoRefreshEnabled;

  const OrderLoaded({
    required this.orders,
    required this.filteredOrders,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalPages,
    required this.searchQuery,
    required this.selectedStatus,
    required this.selectedMethod,
    required this.isAutoRefreshEnabled,
  });

  @override
  List<Object?> get props => [
        orders,
        filteredOrders,
        currentPage,
        itemsPerPage,
        totalPages,
        searchQuery,
        selectedStatus,
        selectedMethod,
        isAutoRefreshEnabled,
      ];

  OrderLoaded copyWith({
    List<OrderModel>? orders,
    List<OrderModel>? filteredOrders,
    int? currentPage,
    int? itemsPerPage,
    int? totalPages,
    String? searchQuery,
    String? selectedStatus,
    String? selectedMethod,
    bool? isAutoRefreshEnabled,
  }) {
    return OrderLoaded(
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalPages: totalPages ?? this.totalPages,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      isAutoRefreshEnabled: isAutoRefreshEnabled ?? this.isAutoRefreshEnabled,
    );
  }
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}
