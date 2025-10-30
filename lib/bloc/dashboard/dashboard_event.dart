import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardStatisticsLoadRequested extends DashboardEvent {
  final String? storeId;
  final bool showLoading;

  const DashboardStatisticsLoadRequested({
    this.storeId,
    this.showLoading = true,
  });

  @override
  List<Object?> get props => [storeId, showLoading];
}

class DashboardRefreshRequested extends DashboardEvent {
  final String? storeId;

  const DashboardRefreshRequested({this.storeId});

  @override
  List<Object?> get props => [storeId];
}

class DashboardRetryRequested extends DashboardEvent {
  final String? storeId;

  const DashboardRetryRequested({this.storeId});

  @override
  List<Object?> get props => [storeId];
}
