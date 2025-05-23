import 'package:equatable/equatable.dart';
import 'package:pos/models/auth/auth_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;

  const AuthAuthenticated(this.token);

  @override
  List<Object> get props => [token];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final ApiError error;

  const AuthError(this.error);

  @override
  List<Object> get props => [error];
}
