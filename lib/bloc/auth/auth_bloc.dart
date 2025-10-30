import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shao_kao/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  bool _passwordVisible = false;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onStatusChecked);
    on<AuthUserDataRefreshed>(_onUserDataRefreshed);
    on<AuthForceLogout>(_onForceLogout);
    on<AuthPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
  }

  bool get passwordVisible => _passwordVisible;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await _authService.login(event.email, event.password);

      if (result.success) {
        emit(const AuthAuthenticated());
      } else {
        emit(AuthError(message: result.message));
      }
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authService.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Error during logout: ${e.toString()}'));
    }
  }

  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    if (_authService.isAuthenticated()) {
      try {
        final result = await _authService.getCurrentUser();
        if (result.success) {
          emit(const AuthAuthenticated());
        } else {
          emit(const AuthUnauthenticated());
        }
      } catch (e) {
        emit(const AuthUnauthenticated());
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onUserDataRefreshed(
    AuthUserDataRefreshed event,
    Emitter<AuthState> emit,
  ) async {
    if (!_authService.isAuthenticated()) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final result = await _authService.getCurrentUser();
      if (result.success) {
        emit(const AuthAuthenticated());
      } else {
        if (result.status == 401) {
          emit(const AuthUnauthenticated());
        } else {
          emit(AuthError(message: result.message));
        }
      }
    } catch (e) {
      emit(AuthError(message: 'Failed to refresh user data: ${e.toString()}'));
    }
  }

  Future<void> _onForceLogout(
    AuthForceLogout event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  void _onPasswordVisibilityToggled(
    AuthPasswordVisibilityToggled event,
    Emitter<AuthState> emit,
  ) {
    _passwordVisible = !_passwordVisible;
    emit(AuthPasswordVisibilityChanged(isVisible: _passwordVisible));
  }
}