import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrderLoadRequested extends OrderEvent {
  final bool showLoading;
  final int? page;
  final int? limit;
  final String? status;
  final String? method;

  const OrderLoadRequested({
    this.showLoading = true,
    this.page,
    this.limit,
    this.status,
    this.method,
  });

  @override
  List<Object?> get props => [showLoading, page, limit, status, method];
}

class OrderSearchChanged extends OrderEvent {
  final String query;

  const OrderSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class OrderStatusFilterChanged extends OrderEvent {
  final String status;

  const OrderStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class OrderMethodFilterChanged extends OrderEvent {
  final String method;

  const OrderMethodFilterChanged(this.method);

  @override
  List<Object?> get props => [method];
}

class OrderPageChanged extends OrderEvent {
  final int page;

  const OrderPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class OrderPageSizeChanged extends OrderEvent {
  final int size;

  const OrderPageSizeChanged(this.size);

  @override
  List<Object?> get props => [size];
}

class OrderRefreshRequested extends OrderEvent {
  const OrderRefreshRequested();
}

class OrderAutoRefreshToggled extends OrderEvent {
  const OrderAutoRefreshToggled();
}

class OrderAutoRefreshTick extends OrderEvent {
  const OrderAutoRefreshTick();
}

class OrderFiltersCleared extends OrderEvent {
  const OrderFiltersCleared();
}
