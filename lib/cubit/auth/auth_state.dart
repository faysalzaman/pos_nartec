// Auth States
import 'package:pos/model/auth/login_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final LoginResponse response;

  AuthSuccess({required this.response});
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}
