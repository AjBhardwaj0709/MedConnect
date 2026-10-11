import 'package:medconnect_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:medconnect_frontend/features/auth/domain/repositories/auth_repository.dart';

class SignupUsecase {
  const SignupUsecase(this._repository);
  final AuthRepository _repository;
  Future<AuthUser> patient(Map<String, dynamic> data) {
    return _repository.signupPatient(data);
  }

  Future<AuthUser> doctor(Map<String, dynamic> data) {
    return _repository.signupDoctor(data);
  }
}
