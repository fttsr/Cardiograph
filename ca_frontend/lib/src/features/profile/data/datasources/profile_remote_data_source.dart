import 'package:ca_frontend/src/core/network/api_service.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getPatientProfile(String userId);

  Future<void> savePatientProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? email,
    String? dateOfBirth,
  });
}

class ProfileRemoteDataSourceImpl
    implements ProfileRemoteDataSource {
  @override
  Future<Map<String, dynamic>> getPatientProfile(String userId) {
    return ApiService.getPatientProfile(userId);
  }

  @override
  Future<void> savePatientProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? email,
    String? dateOfBirth,
  }) {
    return ApiService.savePatientProfile(
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
