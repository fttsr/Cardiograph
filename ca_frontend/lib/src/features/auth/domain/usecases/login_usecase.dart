import 'package:ca_frontend/src/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repo;
  LoginUsecase(this.repo);

  Future<Map<String, dynamic>> call(
    String login,
    String password,
  ) {
    return repo.login(login, password);
  }
}
