import 'package:ca_frontend/src/core/network/api_service.dart';

abstract class EcgRemoteDataSource {
  Future<String> getPatientIdByUser(String userId);
  Future<String> createMeasurement(String patientId);

  Future<void> saveHeartRate({
    required String measurementId,
    required int second,
    required int bpm,
  });

  Future<void> createReport({
    required String measurementId,
    required String filePath,
  });
}

class EcgRemoteDataSourceImpl implements EcgRemoteDataSource {
  @override
  Future<String> getPatientIdByUser(String userId) {
    return ApiService.getPatientIdByUser(userId);
  }

  @override
  Future<String> createMeasurement(String patientId) {
    return ApiService.createMeasurement(patientId);
  }

  @override
  Future<void> saveHeartRate({
    required String measurementId,
    required int second,
    required int bpm,
  }) {
    return ApiService.saveHeartRate(
      measurementId: measurementId,
      second: second,
      bpm: bpm,
    );
  }

  @override
  Future<void> createReport({
    required String measurementId,
    required String filePath,
  }) {
    return ApiService.createReport(
      measurementId: measurementId,
      filePath: filePath,
    );
  }
}
