import 'package:ca_frontend/src/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUsecase {
  final AuthRepository repo;
  ForgotPasswordUsecase(this.repo);

  Future<void> call(String email) {
    return repo.forgotPassword(email);
  }
}
