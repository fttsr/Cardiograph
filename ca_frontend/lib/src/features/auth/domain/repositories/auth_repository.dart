abstract class AuthRepository {
  Future<Map<String, dynamic>> login(
    String login,
    String password,
  );

  Future<void> saveSession({
    required String userId,
    required String role,
  });

  Future<void> register(String login, String password);

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}
