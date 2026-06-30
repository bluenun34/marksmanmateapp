import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/core/network/api_errors.dart';

void main() {
  group('isTransientApiError', () {
    test('returns true for timeouts', () {
      expect(isTransientApiError(TimeoutException('timed out')), isTrue);
      expect(
        isTransientApiError(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
        isTrue,
      );
    });

    test('returns true for connection errors', () {
      expect(
        isTransientApiError(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        ),
        isTrue,
      );
    });

    test('returns false for auth failures', () {
      expect(
        isTransientApiError(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
        isFalse,
      );
    });
  });

  group('isAuthApiError', () {
    test('returns true for 401 responses', () {
      expect(
        isAuthApiError(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
        isTrue,
      );
    });

    test('returns false for network failures', () {
      expect(
        isAuthApiError(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        ),
        isFalse,
      );
    });
  });

  group('isRefreshRejected', () {
    test('returns true for rejected refresh responses', () {
      expect(
        isRefreshRejected(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
        isTrue,
      );
    });

    test('returns false for offline refresh failures', () {
      expect(
        isRefreshRejected(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        ),
        isFalse,
      );
    });
  });
}
