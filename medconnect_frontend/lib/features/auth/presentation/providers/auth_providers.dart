import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medconnect_frontend/features/auth/domain/entities/auth_user.dart';
import '../controllers/auth_controller.dart';
import 'package:medconnect_frontend/core/network/dio_client.dart';
import 'package:medconnect_frontend/core/storage/token_storage.dart';
import 'package:medconnect_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:medconnect_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:medconnect_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:medconnect_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:medconnect_frontend/features/auth/domain/usecases/signup_usecase.dart';


final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final authRemoteDataSource = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.watch(dioClientProvider),
    ref.watch(tokenStorageProvider),
  );
});
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSource),
    ref.watch(tokenStorageProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.watch(authRepositoryProvider));
});

final signupUseCaseProvider = Provider<SignupUsecase>((ref) {
  return SignupUsecase(ref.watch(authRepositoryProvider));
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);
