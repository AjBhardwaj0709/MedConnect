import 'package:medconnect_frontend/core/storage/token_storage.dart';
import 'package:medconnect_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:medconnect_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:medconnect_frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStorage);
  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final result = await _remote.login(email: email, password: password);
    return result.user;
  }

  @override
  Future<AuthUser> signupPatient(Map<String, dynamic> data) async {
    final result = await _remote.signupPatient(data);
    return result.user;
  }

  @override
  Future<AuthUser> signupDoctor(Map<String, dynamic> data) async {
    final result = await _remote.signupDoctor(data);
    return result.user;
  }

  @override
  Future<void> logout() => _tokenStorage.clearToken();
}
