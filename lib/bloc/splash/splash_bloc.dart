import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shao_kao/services/auth_service.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthService _authService;

  SplashBloc({required AuthService authService})
      : _authService = authService,
        super(const SplashInitial()) {
    on<SplashAuthenticationChecked>(_onAuthenticationChecked);
    on<SplashAnimationCompleted>(_onAnimationCompleted);
  }

  Future<void> _onAuthenticationChecked(
    SplashAuthenticationChecked event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    // Add a small delay to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    try {
      if (_authService.isAuthenticated()) {
        // Verify token is still valid
        final result = await _authService.getCurrentUser();
        if (result.success) {
          emit(const SplashNavigateToDashboard());
        } else {
          emit(const SplashNavigateToLogin());
        }
      } else {
        emit(const SplashNavigateToLogin());
      }
    } catch (e) {
      emit(const SplashNavigateToLogin());
    }
  }

  void _onAnimationCompleted(
    SplashAnimationCompleted event,
    Emitter<SplashState> emit,
  ) {
    add(const SplashAuthenticationChecked());
  }
}