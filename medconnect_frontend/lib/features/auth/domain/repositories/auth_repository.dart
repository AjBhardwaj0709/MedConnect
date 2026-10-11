import 'package:medconnect_frontend/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login({required String email, required String password});
  Future<AuthUser> signupPatient(Map<String, dynamic> data);
  Future<AuthUser> signupDoctor(Map<String, dynamic> data);
  Future<void> logout();
}
