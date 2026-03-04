import 'package:ca_frontend/src/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUsecase {
  final ProfileRepository repo;
  GetProfileUsecase(this.repo);

  Future<Map<String, dynamic>> call(String userId) =>
      repo.getProfile(userId);
}
