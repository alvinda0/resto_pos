import 'package:equatable/equatable.dart';
import 'package:shao_kao/models/dashboard/dashboard_model.dart';
import 'package:shao_kao/services/dashboard/dashboard_service.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final StatisticsModel statistics;
  final List<ChartData> chartData;

  const DashboardLoaded({
    required this.statistics,
    required this.chartData,
  });

  @override
  List<Object?> get props => [statistics, chartData];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
