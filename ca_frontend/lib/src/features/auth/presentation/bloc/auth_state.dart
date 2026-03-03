import 'package:equatable/equatable.dart';

enum AuthFlow { idle, login, register, forgot, reset }

class AuthState extends Equatable {
  final bool loading;
  final String? error;
  final AuthFlow flow;
  final bool success;

  const AuthState({
    required this.loading,
    required this.flow,
    required this.success,
    this.error,
  });

  factory AuthState.initial() => const AuthState(
    loading: false,
    flow: AuthFlow.idle,
    success: false,
  );

  AuthState copyWith({
    bool? loading,
    bool? success,
    AuthFlow? flow,
    String? error,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      flow: flow ?? this.flow,
      success: success ?? this.success,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, error, flow, success];
}
