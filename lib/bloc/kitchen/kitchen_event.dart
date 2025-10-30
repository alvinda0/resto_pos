import 'package:equatable/equatable.dart';

abstract class KitchenEvent extends Equatable {
  const KitchenEvent();

  @override
  List<Object?> get props => [];
}

class KitchenOrdersLoadRequested extends KitchenEvent {
  final bool showLoading;
  final String? status;

  const KitchenOrdersLoadRequested({
    this.showLoading = true,
    this.status,
  });

  @override
  List<Object?> get props => [showLoading, status];
}

class KitchenOrderStatusUpdateRequested extends KitchenEvent {
  final String orderId;
  final String newStatus;

  const KitchenOrderStatusUpdateRequested({
    required this.orderId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [orderId, newStatus];
}

class KitchenOrderItemCompleteRequested extends KitchenEvent {
  final String orderId;
  final String itemId;

  const KitchenOrderItemCompleteRequested({
    required this.orderId,
    required this.itemId,
  });

  @override
  List<Object?> get props => [orderId, itemId];
}

class KitchenRefreshRequested extends KitchenEvent {
  const KitchenRefreshRequested();
}

class KitchenAutoRefreshToggled extends KitchenEvent {
  const KitchenAutoRefreshToggled();
}

class KitchenAutoRefreshTick extends KitchenEvent {
  const KitchenAutoRefreshTick();
}

class KitchenStatusFilterChanged extends KitchenEvent {
  final String status;

  const KitchenStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}
