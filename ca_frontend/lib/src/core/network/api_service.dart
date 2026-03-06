import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.0.163:3000',
  );

  static Future<Map<String, dynamic>> login(
    String login,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login': login, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> register(
    String login,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login': login, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> savePatientProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? email,
    String? dateOfBirth,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/patient/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName,
        'phone': phone,
        'email': email,
        'date_of_birth': dateOfBirth,
      }),
    );
  }

  static Future<Map<String, dynamic>> getPatientProfile(
    String userId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient/profile?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {};
    }
  }

  static Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<String> getPatientIdByUser(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient/by-user/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Пациент не найден');
    }

    return jsonDecode(response.body)['id'];
  }

  static Future<String> createMeasurement(
    String patientId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/measurements'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'patient_id': patientId}),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Ошибка создания measurement, ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body);
    final measurement = body['measurement'];
    if (measurement == null || measurement['id'] == null) {
      throw Exception(
        "Некорректный ответ сервера: ${response.body}",
      );
    }

    return measurement['id'] as String;
  }

  static Future<void> saveHeartRate({
    required String measurementId,
    required int second,
    required int bpm,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/measurements/$measurementId/heart-rate',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': [
          {'second': second, 'bpm': bpm},
        ],
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        "Ошибка сохранения heart_rate (${response.statusCode}): $response.body",
      );
    }
  }

  static Future<void> createReport({
    required String measurementId,
    required String filePath,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/reports'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'measurement_id': measurementId,
        'file_path': filePath,
      }),
    );
  }
}
