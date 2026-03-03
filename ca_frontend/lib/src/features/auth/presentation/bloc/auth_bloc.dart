import 'package:ca_frontend/src/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:ca_frontend/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:ca_frontend/src/features/auth/domain/usecases/register_usecase.dart';
import 'package:ca_frontend/src/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:ca_frontend/src/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:ca_frontend/src/features/auth/presentation/bloc/auth_event.dart';
import 'package:ca_frontend/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase login;
  final SaveSessionUsecase saveSession;
  final RegisterUsecase register;
  final ForgotPasswordUsecase forgotPassword;
  final ResetPasswordUsecase resetPassword;

  AuthBloc({
    required this.login,
    required this.saveSession,
    required this.register,
    required this.forgotPassword,
    required this.resetPassword,
  }) : super(AuthState.initial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthForgotPasswordRequested>(_onForgot);
    on<AuthResetPasswordRequested>(_onReset);
    on<AuthClearStatus>(_onClear);
  }

  Future<void> _onLogin(
    AuthLoginRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        error: null,
        success: false,
        flow: AuthFlow.login,
      ),
    );
    try {
      final result = await login(
        e.login.trim(),
        e.password.trim(),
      );

      final userId = (result['id'] ?? '').toString();
      final role = (result['role'] ?? '').toString();

      await saveSession(userId: userId, role: role);

      emit(
        state.copyWith(
          loading: false,
          success: true,
          flow: AuthFlow.login,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          loading: false,
          error: err.toString(),
          success: false,
          flow: AuthFlow.login,
        ),
      );
    }
  }

  void _onClear(AuthClearStatus e, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        loading: false,
        error: null,
        success: false,
        flow: AuthFlow.idle,
      ),
    );
  }

  Future<void> _onRegister(
    AuthRegisterRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        error: null,
        success: false,
        flow: AuthFlow.register,
      ),
    );
    try {
      await register(e.login.trim(), e.password.trim());
      emit(
        state.copyWith(
          loading: false,
          success: true,
          flow: AuthFlow.register,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          loading: false,
          error: err.toString(),
          success: false,
          flow: AuthFlow.register,
        ),
      );
    }
  }

  Future<void> _onForgot(
    AuthForgotPasswordRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        error: null,
        success: false,
        flow: AuthFlow.forgot,
      ),
    );
    try {
      await forgotPassword(e.email.trim());
      emit(
        state.copyWith(
          loading: false,
          success: true,
          flow: AuthFlow.forgot,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          loading: false,
          error: err.toString(),
          success: false,
          flow: AuthFlow.forgot,
        ),
      );
    }
  }

  Future<void> _onReset(
    AuthResetPasswordRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        error: null,
        success: false,
        flow: AuthFlow.reset,
      ),
    );
    try {
      await resetPassword(
        email: e.email.trim(),
        code: e.code.trim(),
        newPassword: e.newPassword.trim(),
      );
      emit(
        state.copyWith(
          loading: false,
          success: true,
          flow: AuthFlow.reset,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          loading: false,
          error: err.toString(),
          success: false,
          flow: AuthFlow.reset,
        ),
      );
    }
  }
}
