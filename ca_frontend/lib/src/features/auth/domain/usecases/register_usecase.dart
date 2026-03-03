import 'package:ca_frontend/src/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repo;
  RegisterUsecase(this.repo);

  Future<void> call(String login, String password) {
    return repo.register(login, password);
  }
}
