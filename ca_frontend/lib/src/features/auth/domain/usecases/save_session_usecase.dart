import 'package:ca_frontend/src/features/auth/domain/repositories/auth_repository.dart';

class SaveSessionUsecase {
  final AuthRepository repo;
  SaveSessionUsecase(this.repo);

  Future<void> call({
    required String userId,
    required String role,
  }) {
    return repo.saveSession(userId: userId, role: role);
  }
}
