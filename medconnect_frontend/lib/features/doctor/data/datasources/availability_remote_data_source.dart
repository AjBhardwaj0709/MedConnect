import 'package:dio/dio.dart';

import '../models/availability_model.dart';

class AvailabilityRemoteDataSource {
  AvailabilityRemoteDataSource(this._dio);

  final Dio _dio;

  static const String _path = '/api/doctors/availability';

  List<dynamic> _recordsFromResponse(dynamic response) {
    final body = response.data;

    if (body is List) return body;

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) return data;

      // Also support APIs that return {data: {availability: [...]}}.
      if (data is Map && data['availability'] is List) {
        return data['availability'] as List;
      }
    }

    throw const FormatException('Unexpected availability response format.');
  }

  Map<String, dynamic> _recordFromResponse(dynamic response) {
    final body = response.data;

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
      if (body.containsKey('_id')) return body;
    }

    throw const FormatException(
      'Unexpected availability record response format.',
    );
  }

  Future<List<AvailabilityModel>> getAvailability() async {
    final response = await _dio.get(_path);

    return _recordsFromResponse(response)
        .map(
          (item) => AvailabilityModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<AvailabilityModel> createAvailability({
    required String date,
    required String startTime,
    required String endTime,
    required int slotDuration,
  }) async {
    final response = await _dio.post(
      _path,
      data: {
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'slotDuration': slotDuration,
      },
    );

    return AvailabilityModel.fromJson(_recordFromResponse(response));
  }

  Future<AvailabilityModel> updateAvailability({
    required String id,
    required String date,
    required String startTime,
    required String endTime,
    required int slotDuration,
    required bool isAvailable,
  }) async {
    final response = await _dio.put(
      '$_path/$id',
      data: {
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'slotDuration': slotDuration,
        'isAvailable': isAvailable,
      },
    );

    return AvailabilityModel.fromJson(_recordFromResponse(response));
  }

  Future<void> deleteAvailability(String id) async {
    await _dio.delete('$_path/$id');
  }
}
