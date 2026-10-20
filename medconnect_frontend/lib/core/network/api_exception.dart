import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String? serverMessage;

    if (responseData is Map) {
      final message = responseData['message'];

      if (message is String && message.trim().isNotEmpty) {
        serverMessage = message.trim();
      }
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          message:
              serverMessage ?? 'Invalid request. Please check your details.',
          statusCode: statusCode,
        );

      case 401:
        return ApiException(
          message: serverMessage ?? 'Session expired. Please log in again.',
          statusCode: statusCode,
        );

      case 403:
        return ApiException(
          message:
              serverMessage ??
              'You do not have permission to perform this action.',
          statusCode: statusCode,
        );

      case 404:
        return ApiException(
          message: serverMessage ?? 'The requested resource was not found.',
          statusCode: statusCode,
        );

      case 409:
        return ApiException(
          message:
              serverMessage ?? 'This request conflicts with existing data.',
          statusCode: statusCode,
        );

      case 422:
        return ApiException(
          message: serverMessage ?? 'The submitted data is invalid.',
          statusCode: statusCode,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ApiException(
          message: serverMessage ?? 'Server error. Please try again later.',
          statusCode: statusCode,
        );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          message: 'The request timed out. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Unable to connect to the server. Check your internet connection.',
        );

      case DioExceptionType.cancel:
        return const ApiException(message: 'The request was cancelled.');

      case DioExceptionType.badCertificate:
        return const ApiException(
          message:
              'A secure connection to the server could not be established.',
        );

      case DioExceptionType.badResponse:
        return ApiException(
          message:
              serverMessage ?? 'The server returned an unexpected response.',
          statusCode: statusCode,
        );

      case DioExceptionType.unknown:
        return ApiException(
          message: serverMessage ?? 'An unexpected network error occurred.',
          statusCode: statusCode,
        );
    }
  }

  @override
  String toString() => message;
}
