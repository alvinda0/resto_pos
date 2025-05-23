import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/repositories/dashboard/dashboard_repository.dart';
import 'package:pos/models/auth/auth_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;
  final String _token;

  DashboardBloc({
    required DashboardRepository dashboardRepository,
    required String token,
  })  : _dashboardRepository = dashboardRepository,
        _token = token,
        super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadDashboardData(emit);
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Don't emit loading state for refresh to avoid UI flicker
    await _loadDashboardData(emit);
  }

  Future<void> _loadDashboardData(Emitter<DashboardState> emit) async {
    try {
      final response = await _dashboardRepository.getDashboardStats(_token);
      emit(DashboardLoaded(response.data));
    } catch (error) {
      if (error is ApiError) {
        emit(DashboardError(error));
      } else {
        emit(DashboardError(ApiError(message: error.toString())));
      }
    }
  }
}
