import 'package:medconnect_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:medconnect_frontend/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  const LoginUsecase(this._repository);
  final AuthRepository _repository;

  Future<AuthUser> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}
