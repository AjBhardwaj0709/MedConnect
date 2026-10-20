import 'package:flutter/material.dart';
import 'package:medconnect_frontend/core/constants/api_constants.dart';
import 'package:medconnect_frontend/core/network/dio_client.dart';
import 'package:medconnect_frontend/features/doctor/data/models/doctor_model.dart';

class DoctorProfileRemoteDataSource {
  DoctorProfileRemoteDataSource(this._client);

  final DioClient _client;

  // Future<DoctorProfileModel> getMyProfile() async {
  //   final response = await _client.dio.get(ApiConstants.doctorProfile);

  //   final body = Map<String, dynamic>.from(response.data as Map);
  //   final doctor = body['doctor'];

  //   if (body['success'] != true || doctor is! Map) {
  //     throw Exception(
  //       body['message']?.toString() ?? 'Could not load doctor profile.',
  //     );
  //   }

  //   return DoctorProfileModel.fromJson(Map<String, dynamic>.from(doctor));
  // }


Future<DoctorProfileModel> getMyProfile() async {
    try {
      final response = await _client.dio.get(ApiConstants.doctorProfile);

      debugPrint('========== DOCTOR PROFILE API ==========');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      debugPrint('=========================================');

      final body = Map<String, dynamic>.from(response.data as Map);

      if (body['success'] != true || body['doctor'] == null) {
        throw Exception('Doctor profile data was not returned by backend.');
      }

      final doctorJson = Map<String, dynamic>.from(body['doctor'] as Map);

      debugPrint('Doctor JSON: $doctorJson');

      final profile = DoctorProfileModel.fromJson(doctorJson);

      debugPrint('Parsed doctor name: ${profile.name}');
      debugPrint('Parsed specialization: ${profile.specialization}');
      debugPrint('Parsed qualification: ${profile.qualification}');

      return profile;
    } catch (e, stackTrace) {
      debugPrint('Doctor profile API error: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }
  Future<DoctorProfileModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.dio.put(
      ApiConstants.doctorProfile,
      data: data,
    );

    final body = Map<String, dynamic>.from(response.data as Map);
    final doctor = body['doctor'];

    if (body['success'] != true || doctor is! Map) {
      throw Exception(
        body['message']?.toString() ?? 'Could not update doctor profile.',
      );
    }

    return DoctorProfileModel.fromJson(Map<String, dynamic>.from(doctor));
  }
}
