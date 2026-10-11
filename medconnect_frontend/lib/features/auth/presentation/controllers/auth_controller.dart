import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medconnect_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:medconnect_frontend/features/auth/presentation/providers/auth_providers.dart';

class AuthController extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async => null;
  Future<AuthUser?> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(loginUseCaseProvider)(
        email: email,
        password: password,
      );
      state = AsyncData(user);
      return user;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<AuthUser?> signupDoctor(Map<String, dynamic> data) async {
    return _signup(() => ref.read(signupUseCaseProvider).doctor(data));
  }

  Future<AuthUser?> signupPatient(Map<String, dynamic> data) async {
    return _signup(() => ref.read(signupUseCaseProvider).patient(data));
  }

  Future<AuthUser?> _signup(Future<AuthUser> Function() operation) async {
    state = const AsyncLoading();
    try {
      final user = await operation();
      state = AsyncData(user);
      return user;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
