import 'package:ca_frontend/src/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUsecase {
  final AuthRepository repo;
  ResetPasswordUsecase(this.repo);

  Future<void> call({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return repo.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }
}
