import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String login;
  final String password;

  const AuthLoginRequested({
    required this.login,
    required this.password,
  });

  @override
  List<Object?> get props => [login, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String login;
  final String password;

  const AuthRegisterRequested({
    required this.login,
    required this.password,
  });

  @override
  List<Object?> get props => [login, password];
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;

  const AuthResetPasswordRequested({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}

class AuthClearStatus extends AuthEvent {
  const AuthClearStatus();
}
