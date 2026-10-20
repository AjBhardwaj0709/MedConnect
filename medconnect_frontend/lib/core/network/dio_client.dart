import 'package:dio/dio.dart';
import 'package:medconnect_frontend/core/constants/api_constants.dart';
import 'package:medconnect_frontend/core/network/api_exception.dart';
import 'package:medconnect_frontend/core/storage/token_storage.dart';

class DioClient {
  DioClient({required TokenStorage tokenStorage})
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await tokenStorage.getToken();

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            handler.next(options);
          } catch (error) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: error,
                message: 'Failed to retrieve authentication token.',
              ),
            );
          }
        },

        onError: (error, handler) {
          final apiException = ApiException.fromDioException(error);

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: apiException,
              message: apiException.message,
            ),
          );
        },
      ),
    );
  }

  final Dio dio;
}
