import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import 'api_errors.dart';
import 'auth_session.dart';
import 'token_repository.dart';

final dioClientProvider = Provider<Dio>((ref) {
  return createApiClient(ref.read(tokenRepositoryProvider));
});

Dio _createBaseDio() {
  return Dio(
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
}

Dio createApiClient(TokenRepository tokenRepo) {
  final refreshDio = _createBaseDio();
  final dio = _createBaseDio();
  dio.interceptors.add(_AuthInterceptor(dio, refreshDio, tokenRepo));
  return dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio, this._refreshDio, this._tokenRepo);

  final Dio _dio;
  final Dio _refreshDio;
  final TokenRepository _tokenRepo;

  Completer<void>? _refreshCompleter;

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
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = await _tokenRepo.getRefreshToken();
    if (refreshToken == null) {
      await _tokenRepo.clearTokens();
      notifyAuthSessionExpired();
      return handler.next(err);
    }

    try {
      await _refreshAccessToken(refreshToken);
      final accessToken = await _tokenRepo.getAccessToken();
      if (accessToken == null) {
        return handler.next(err);
      }
      err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
      final retried = await _dio.fetch(err.requestOptions);
      return handler.resolve(retried);
    } catch (e) {
      if (isRefreshRejected(e)) {
        await _tokenRepo.clearTokens();
        notifyAuthSessionExpired();
      }
      return handler.next(err);
    }
  }

  Future<void> _refreshAccessToken(String refreshToken) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<void>();
    _refreshCompleter = completer;

    try {
      final resp = await _refreshDio.post(
        '/auth/refresh',
        data: {'token': refreshToken},
      );
      final data = resp.data;
      final payload = data is Map ? Map<String, dynamic>.from(data) : const {};
      final newToken =
          (payload['access_token'] ?? payload['token']) as String?;
      final newRefresh = payload['refresh_token'] as String? ?? newToken;
      if (newToken == null) {
        throw StateError('Refresh response did not include a token');
      }
      await _tokenRepo.saveTokens(
        accessToken: newToken,
        refreshToken: newRefresh,
      );
      completer.complete();
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }
}
