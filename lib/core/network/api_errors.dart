import 'package:dio/dio.dart';

String messageFromDioException(DioException error) {
  final data = error.response?.data;
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        return first.first.toString();
      }
    }
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Connection timed out. Check your internet and try again.';
    case DioExceptionType.connectionError:
      return 'Could not reach the server. Check your internet connection.';
    default:
      break;
  }

  final status = error.response?.statusCode;
  if (status == 401) {
    return 'Invalid email or password.';
  }
  if (status == 429) {
    return 'Too many login attempts. Please wait a few minutes.';
  }
  if (status != null && status >= 500) {
    return 'Server error ($status). Try again shortly.';
  }

  return 'Login failed. Please try again.';
}

String messageFromAuthError(Object error, {String? apiBaseUrl}) {
  if (error is DioException) {
    final message = messageFromDioException(error);
    if (error.response?.statusCode == 401 && apiBaseUrl != null) {
      return '$message (${Uri.parse(apiBaseUrl).host})';
    }
    return message;
  }
  if (error is FormatException) {
    return 'Unexpected response from the server. The API may need updating.';
  }
  return 'Login failed. Please try again.';
}
