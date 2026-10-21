import 'package:dio/dio.dart';
import 'package:medconnect_frontend/core/constants/api_constants.dart';
import 'package:medconnect_frontend/core/network/dio_client.dart';
import 'package:medconnect_frontend/core/storage/token_storage.dart';
import 'package:medconnect_frontend/features/auth/data/models/auth_response_model.dart';
import 'package:medconnect_frontend/features/auth/domain/entities/auth_user.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client, this._tokenStorage);

  final DioClient _client;
  final TokenStorage _tokenStorage;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      ApiConstants.login,
      data: {'email': email.trim(), 'password': password},
    );
    return _parseAndSave(response.data);
  }

  Future<AuthResponseModel> signupPatient(Map<String, dynamic> data) async {
    final response = await _client.dio.post(
      ApiConstants.patientSignup,
      data: data,
    );
    return _parseAndSave(response.data);
  }

  Future<AuthResponseModel> signupDoctor(Map<String, dynamic> data) async {
    final response = await _client.dio.post(
      ApiConstants.doctorSignup,
      data: data,
    );
    return _parseAndSave(response.data);
  }

Future<AuthUser> getCurrentAuthUser() async {
    final token = await _tokenStorage.getToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception('You are not logged in');
    }

    final response = await _client.dio.get(
      ApiConstants.currentUser,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final json = Map<String, dynamic>.from(response.data as Map);

    if (json['success'] == false) {
      throw Exception(
        json['message']?.toString() ?? 'Failed to restore session',
      );
    }

    // Support APIs that return either { user: {...} }
    // or the user object directly.
    final userJson = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : json;

    return AuthUser(
      id: userJson['id']?.toString() ?? userJson['_id']?.toString() ?? '',
      email: userJson['email']?.toString() ?? '',
      role: userJson['role']?.toString() ?? '',
      profile: userJson['profile'] is Map
          ? Map<String, dynamic>.from(userJson['profile'] as Map)
          : null,
    );
  }

  Future<AuthResponseModel> _parseAndSave(dynamic responseData) async {
    final json = Map<String, dynamic>.from(responseData as Map);

    if (json['success'] == false) {
      throw Exception(json['message']?.toString() ?? 'Authentication failed');
    }

    final result = AuthResponseModel.fromJson(json);

    if (result.token.isEmpty) {
      throw Exception('The server did not return an authentication token');
    }

    final role = result.user.role.toLowerCase().trim();

    if (role != 'patient' && role != 'doctor') {
      throw Exception('The server returned an invalid user role');
    }

   await _tokenStorage.saveSession(
      token: result.token,
      role: result.user.role,
    );

    return result;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("You are not logged in");
    }
    final response = await _client.dio.get(
      ApiConstants.currentUser,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
