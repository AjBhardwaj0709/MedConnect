import 'package:dio/dio.dart';
import 'package:medconnect_frontend/core/constants/api_constants.dart';
import 'package:medconnect_frontend/core/network/dio_client.dart';
import 'package:medconnect_frontend/core/storage/token_storage.dart';
import 'package:medconnect_frontend/features/auth/data/models/auth_response_model.dart';

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

  Future<AuthResponseModel> _parseAndSave(dynamic responseData) async {
    final json = Map<String, dynamic>.from(responseData as Map);

    if (json['success'] == false) {
      throw Exception(json['message']?.toString() ?? 'Authentication failed');
    }
    final result = AuthResponseModel.fromJson(json);
    if (result.token.isEmpty) {
      throw Exception("The server did not return Authenticate Token");
    }
    await _tokenStorage.saveToken(result.token);

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
