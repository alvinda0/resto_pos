import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shao_kao/services/dashboard/dashboard_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final StatisticsService _statisticsService;

  DashboardBloc({required StatisticsService statisticsService})
      : _statisticsService = statisticsService,
        super(const DashboardInitial()) {
    on<DashboardStatisticsLoadRequested>(_onStatisticsLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
    on<DashboardRetryRequested>(_onRetryRequested);
  }

  Future<void> _onStatisticsLoadRequested(
    DashboardStatisticsLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      if (event.showLoading) {
        emit(const DashboardLoading());
      }

      final result = await _statisticsService.getStatisticsWithRetry(
        storeId: event.storeId,
      );

      final chartData = _statisticsService.getWeeklyChartData(
        result.data.weeklyStats.dailyBreakdown,
      );

      emit(DashboardLoaded(
        statistics: result,
        chartData: chartData,
      ));
    } catch (e) {
      emit(DashboardError('Gagal memuat statistik: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    add(DashboardStatisticsLoadRequested(
      storeId: event.storeId,
      showLoading: false,
    ));
  }

  Future<void> _onRetryRequested(
    DashboardRetryRequested event,
    Emitter<DashboardState> emit,
  ) async {
    add(DashboardStatisticsLoadRequested(
      storeId: event.storeId,
      showLoading: true,
    ));
  }

  // Helper methods for UI
  String formatCurrency(int amount) {
    return _statisticsService.formatCurrency(amount);
  }
}
