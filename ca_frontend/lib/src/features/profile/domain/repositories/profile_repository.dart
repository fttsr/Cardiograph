abstract class ProfileRepository {
  Future<Map<String, dynamic>> getProfile(String userId);

  Future<void> saveProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? email,
    String? dateOfBirth,
  });
}
