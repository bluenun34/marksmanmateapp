import 'dart:async';

import 'package:dio/dio.dart';

/// True when the request failed because of connectivity or timeouts.
bool isTransientApiError(Object error) {
  if (error is TimeoutException) return true;
  if (error is! DioException) return false;

  final status = error.response?.statusCode;
  if (status == 401 || status == 403 || status == 422) return false;

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return true;
    default:
      return error.response == null;
  }
}

/// True when the server rejected credentials.
bool isAuthApiError(Object error) {
  if (error is DioException && error.response?.statusCode == 401) {
    return true;
  }
  return false;
}

/// True when a token refresh response means the session is no longer valid.
bool isRefreshRejected(Object error) {
  if (error is StateError) return true;
  if (error is! DioException) return false;

  final status = error.response?.statusCode;
  return status == 401 || status == 403 || status == 422;
}

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
  if (status == 403) {
    final message = _messageFromData(data);
    if (message.toLowerCase().contains('pro')) {
      return message;
    }
    return message.isNotEmpty ? message : 'You do not have permission for this action.';
  }
  if (status == 429) {
    return 'Too many requests. Please wait a moment and try again.';
  }
  if (status != null && status >= 500) {
    return 'Server error ($status). Try again shortly.';
  }

  return 'Login failed. Please try again.';
}

String _messageFromData(Object? data) {
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
  }
  return '';
}

String messageFromApiError(Object error) {
  if (error is DioException) {
    return messageFromDioException(error);
  }
  return error.toString();
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

class InboxApiUnavailableException implements Exception {
  const InboxApiUnavailableException([this.detail = defaultMessage]);

  static const defaultMessage =
      'Notifications and messages are not available on this server yet. '
      'Update marksmanmate.com to the latest version, or use the website inbox for now.';

  final String detail;

  @override
  String toString() => detail;
}
