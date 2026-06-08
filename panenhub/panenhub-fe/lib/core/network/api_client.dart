import 'package:dio/dio.dart';
import '../../../app/config/env.dart';
import 'token_storage.dart';
import 'api_exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late final Dio dio;

  ApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(_ErrorInterceptor());
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Coba refresh token
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final refreshDio = Dio(BaseOptions(baseUrl: Env.baseUrl));
          final response = await refreshDio.post('/auth/refresh', data: {
            'refresh_token': refreshToken,
          });

          final newAccess = response.data['data']['access_token'] as String;
          final newRefresh = response.data['data']['refresh_token'] as String;
          await TokenStorage.saveTokens(accessToken: newAccess, refreshToken: newRefresh);

          // Retry request dengan token baru
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
          final retryResponse = await refreshDio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          await TokenStorage.clear();
        }
      }
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (response != null) {
      final data = response.data;
      final message = data is Map ? (data['message'] ?? 'Terjadi kesalahan.') as String : 'Terjadi kesalahan.';
      final errors = data is Map ? data['errors'] as Map<String, dynamic>? : null;

      ApiException apiError;
      switch (response.statusCode) {
        case 400:
          apiError = ValidationException(message, errors: errors);
        case 401:
          apiError = UnauthorizedException(message);
        case 403:
          apiError = ForbiddenException(message);
        case 404:
          apiError = NotFoundException(message);
        case 409:
          apiError = ApiException(message, statusCode: 409);
        default:
          apiError = ApiException(message, statusCode: response.statusCode);
      }

      handler.reject(DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiError,
      ));
      return;
    }

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      type: err.type,
      error: ApiException(
        err.type == DioExceptionType.connectionTimeout
            ? 'Koneksi timeout. Periksa jaringan Anda.'
            : 'Tidak dapat terhubung ke server.',
      ),
    ));
  }
}
