import 'package:ca_frontend/src/core/storage/app_box.dart';
import 'package:ca_frontend/src/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ca_frontend/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AppBox box;

  AuthRepositoryImpl({required this.remote, required this.box});

  @override
  Future<Map<String, dynamic>> login(
    String login,
    String password,
  ) {
    return remote.login(login, password);
  }

  @override
  Future<void> saveSession({
    required String userId,
    required String role,
  }) {
    return box.saveSession(userId: userId, role: role);
  }

  @override
  Future<void> forgotPassword(String email) {
    return remote.forgotPassword(email);
  }

  @override
  Future<void> register(String login, String password) {
    return remote.register(login, password);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return remote.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }
}
