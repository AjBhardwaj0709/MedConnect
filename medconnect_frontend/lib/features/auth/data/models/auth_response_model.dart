import 'package:medconnect_frontend/features/auth/domain/entities/auth_user.dart';

class AuthResponseModel {
  AuthResponseModel({required this.token, required this.user, this.message});

  final String token;
  final AuthUser user;
  final String? message;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson = Map<String, dynamic>.from(json['user'] as Map? ?? {});
    return AuthResponseModel(
      token: (json['token'] as String? ?? ''
    ),
      message: json['message'] as String? ?? '',
      user: AuthUser(
        id: (userJson['id'] as String? ?? '').toString(),
        email: (userJson['email'] as String? ?? '').toString(),
        role: (userJson['role'] as String? ?? '').toString(),
        profile: json['profile'] is Map ? Map<String,dynamic>.from(json['profile']as Map ):null
      ),
    );
  }
}
