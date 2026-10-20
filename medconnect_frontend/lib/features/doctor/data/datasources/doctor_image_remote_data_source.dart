import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class DoctorImageRemoteDataSource {
  DoctorImageRemoteDataSource(this._dio);

  final Dio _dio;

  /// Upload or replace the logged-in doctor's profile image.
  Future<Map<String, dynamic>> uploadProfileImage(XFile image) async {
    final bytes = await image.readAsBytes();

    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: image.name),
    });

    final response = await _dio.post(
      '/api/doctors/profile/image',
      data: formData,
    );

    return Map<String, dynamic>.from(response.data);
  }

  /// Delete the logged-in doctor's profile image.
  Future<Map<String, dynamic>> deleteProfileImage() async {
    final response = await _dio.delete('/api/doctors/profile/image');

    return Map<String, dynamic>.from(response.data);
  }
}
