import 'package:equatable/equatable.dart';

abstract class KitchenState extends Equatable {
  const KitchenState();

  @override
  List<Object?> get props => [];
}

class KitchenInitial extends KitchenState {
  const KitchenInitial();
}

class KitchenLoading extends KitchenState {
  const KitchenLoading();
}

class KitchenLoaded extends KitchenState {
  final List<dynamic> orders;
  final String selectedStatus;
  final bool isAutoRefreshEnabled;

  const KitchenLoaded({
    required this.orders,
    required this.selectedStatus,
    required this.isAutoRefreshEnabled,
  });

  @override
  List<Object?> get props => [orders, selectedStatus, isAutoRefreshEnabled];

  KitchenLoaded copyWith({
    List<dynamic>? orders,
    String? selectedStatus,
    bool? isAutoRefreshEnabled,
  }) {
    return KitchenLoaded(
      orders: orders ?? this.orders,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isAutoRefreshEnabled: isAutoRefreshEnabled ?? this.isAutoRefreshEnabled,
    );
  }
}

class KitchenOperationLoading extends KitchenState {
  final String operation;

  const KitchenOperationLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}

class KitchenOperationSuccess extends KitchenState {
  final String message;
  final String operation;

  const KitchenOperationSuccess({
    required this.message,
    required this.operation,
  });

  @override
  List<Object?> get props => [message, operation];
}

class KitchenError extends KitchenState {
  final String message;

  const KitchenError(this.message);

  @override
  List<Object?> get props => [message];
}
