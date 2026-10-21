import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'medconnect_jwt';
  static const String _roleKey = 'medconnect_role';

  Future<void> saveSession({
    required String token,
    required String role,
  }) async {
    await _storage.write(key: _tokenKey, value: token);

    await _storage.write(key: _roleKey, value: role.toLowerCase().trim());
  }

  Future<String?> getToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<String?> getRole() {
    return _storage.read(key: _roleKey);
  }

  Future<bool> hasSession() async {
    final token = await getToken();
    final role = await getRole();

    return token != null &&
        token.trim().isNotEmpty &&
        (role == 'patient' || role == 'doctor');
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }

  Future<void> clearSession() => clearToken();
}
