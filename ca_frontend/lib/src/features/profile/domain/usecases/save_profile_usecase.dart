import 'package:ca_frontend/src/features/profile/domain/repositories/profile_repository.dart';

class SaveProfileUsecase {
  final ProfileRepository repo;
  SaveProfileUsecase(this.repo);

  Future<void> call({
    required String userId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? email,
    String? dateOfBirth,
  }) {
    return repo.saveProfile(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      middleName: middleName,
      phone: phone,
      email: email,
      dateOfBirth: dateOfBirth,
    );
  }
}
