import 'package:ca_frontend/src/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ca_frontend/src/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;

  ProfileRepositoryImpl({required this.remote});

  @override
  Future<Map<String, dynamic>> getProfile(String userId) {
    return remote.getPatientProfile(userId);
  }

  @override
  Future<void> saveProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? email,
    String? dateOfBirth,
  }) {
    return remote.savePatientProfile(
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
