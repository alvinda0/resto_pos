import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/blocs/auth/auth_bloc.dart';
import 'package:pos/blocs/auth/auth_state.dart';
import 'package:pos/blocs/dashboard/dashboard_bloc.dart';
import 'package:pos/blocs/dashboard/dashboard_event.dart';
import 'package:pos/blocs/dashboard/dashboard_state.dart';
import 'package:pos/models/dashboard/dashboard_model.dart';
import 'package:pos/repositories/dashboard/dashboard_repository.dart';
import 'package:pos/widgets/dashboard/statistics_chart_widget.dart';
import 'package:pos/widgets/dashboard/trending_menu_widget.dart';
import 'package:pos/widgets/dashboard/weekly_chart_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return BlocProvider(
            create: (context) => DashboardBloc(
              dashboardRepository: DashboardRepository(),
              token: authState.token,
            )..add(
                const DashboardLoadRequested()), // Move the event trigger here
            child: const _DashboardPageContent(),
          );
        }

        // Handle unauthenticated state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class _DashboardPageContent extends StatelessWidget {
  const _DashboardPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardBloc>().add(const DashboardRefreshRequested());
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is DashboardError) {
              return _buildErrorWidget(context, state);
            } else if (state is DashboardLoaded) {
              return _buildDashboardContent(context, state.stats);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, DashboardError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${state.error.message}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DashboardBloc>().add(const DashboardLoadRequested());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardStats stats) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          StatisticsCardsWidget(stats: stats),
          SizedBox(height: _getSpacing(context)),

          // Charts and Menu Section
          _buildChartsAndMenuSection(context, stats),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Beranda'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: _isTabletOrDesktop(context) ? 16 : 8),
          child: Row(
            children: [
              if (_isTabletOrDesktop(context)) ...[
                Text(
                  'Pages / ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'Beranda',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartsAndMenuSection(
      BuildContext context, DashboardStats stats) {
    if (_isMobile(context)) {
      // Mobile: Stack vertically
      return Column(
        children: [
          WeeklyChartWidget(weeklyStats: stats.weeklyStats),
          SizedBox(height: _getSpacing(context)),
          TrendingMenuWidget(trendingItems: stats.trendingItems),
        ],
      );
    } else {
      // Tablet/Desktop: Side by side
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: _isDesktop(context) ? 2 : 1,
            child: WeeklyChartWidget(weeklyStats: stats.weeklyStats),
          ),
          SizedBox(width: _getSpacing(context)),
          Expanded(
            flex: 1,
            child: TrendingMenuWidget(trendingItems: stats.trendingItems),
          ),
        ],
      );
    }
  }

  // Helper methods for responsive design
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  bool _isTabletOrDesktop(BuildContext context) {
    return !_isMobile(context);
  }

  double _getPadding(BuildContext context) {
    if (_isMobile(context)) {
      return 16.0;
    } else if (_isTablet(context)) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  double _getSpacing(BuildContext context) {
    if (_isMobile(context)) {
      return 16.0;
    } else if (_isTablet(context)) {
      return 20.0;
    } else {
      return 24.0;
    }
  }
}
