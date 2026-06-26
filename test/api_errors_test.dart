import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/core/network/api_errors.dart';

void main() {
  group('messageFromDioException', () {
    test('returns API message when present', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: {'message': 'Invalid credentials.'},
        ),
      );

      expect(messageFromDioException(error), 'Invalid credentials.');
    });

    test('returns timeout message for connection timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        messageFromDioException(error),
        contains('timed out'),
      );
    });
  });
}
