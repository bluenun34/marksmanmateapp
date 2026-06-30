import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_errors.dart';
import '../../../shared/models/user_access.dart';

String? inboxUnavailableMessage({
  required bool canUseApp,
  required bool isOnline,
}) {
  if (!canUseApp) return mobileSyncInactiveMessage;
  if (!isOnline) {
    return 'Connect to the internet to load notifications and messages.';
  }
  return null;
}

String inboxErrorMessage(Object error) {
  if (error is TimeoutException) {
    return 'Request timed out. Check your connection and try again.';
  }
  if (error is InboxApiUnavailableException) {
    return error.detail;
  }
  if (error is DioException && error.response?.statusCode == 404) {
    return InboxApiUnavailableException.defaultMessage;
  }
  return messageFromApiError(error);
}

class InboxUnavailableView extends StatelessWidget {
  const InboxUnavailableView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
