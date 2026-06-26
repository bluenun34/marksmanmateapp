import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import 'auth_session.dart';
import 'token_repository.dart';

final dioClientProvider = Provider<Dio>((ref) {
  return createApiClient(ref.read(tokenRepositoryProvider));
});

Dio createApiClient(TokenRepository tokenRepo) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(_AuthInterceptor(dio, tokenRepo));
  return dio;
}

class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor(this._dio, this._tokenRepo);
  final Dio _dio;
  final TokenRepository _tokenRepo;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenRepo.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _tokenRepo.getRefreshToken();
      if (refreshToken != null) {
        try {
          final resp = await _dio.post(
            '/auth/refresh',
            data: {'token': refreshToken},
            options: Options(headers: {'Authorization': null}),
          );
          final newToken =
              (resp.data['access_token'] ?? resp.data['token']) as String?;
          final newRefresh = resp.data['refresh_token'] as String? ?? newToken;
          if (newToken != null) {
            await _tokenRepo.saveTokens(
              accessToken: newToken,
              refreshToken: newRefresh,
            );
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retried = await _dio.fetch(err.requestOptions);
            return handler.resolve(retried);
          }
        } catch (_) {
          await _tokenRepo.clearTokens();
          notifyAuthSessionExpired();
        }
      }
    }
    handler.next(err);
  }
}
