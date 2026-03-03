import 'package:ca_frontend/src/core/network/api_service.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(
    String login,
    String password,
  );
  Future<void> register(String login, String password);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> forgotPassword(String email) {
    return ApiService.forgotPassword(email);
  }

  @override
  Future<Map<String, dynamic>> login(
    String login,
    String password,
  ) {
    return ApiService.login(login, password);
  }

  @override
  Future<void> register(String login, String password) {
    return ApiService.register(login, password);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return ApiService.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }
}
