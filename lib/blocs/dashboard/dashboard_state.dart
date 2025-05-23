import 'package:equatable/equatable.dart';
import 'package:pos/models/dashboard/dashboard_model.dart';
import 'package:pos/models/auth/auth_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;

  const DashboardLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class DashboardError extends DashboardState {
  final ApiError error;

  const DashboardError(this.error);

  @override
  List<Object> get props => [error];
}
