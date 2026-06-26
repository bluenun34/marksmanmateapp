import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/local_notifications_service.dart';
import 'last_sync_repository.dart';
import 'sync_service.dart';
import '../../features/locker/providers/locker_provider.dart';
import '../../features/shoot_log/providers/shoot_log_provider.dart';

class SyncStatus {
  const SyncStatus({
    this.lastSyncedAt,
    this.isSyncing = false,
    this.lastError,
  });

  final DateTime? lastSyncedAt;
  final bool isSyncing;
  final String? lastError;

  SyncStatus copyWith({
    DateTime? lastSyncedAt,
    bool? isSyncing,
    String? lastError,
    bool clearLastSyncedAt = false,
    bool clearError = false,
  }) {
    return SyncStatus(
      lastSyncedAt:
          clearLastSyncedAt ? null : (lastSyncedAt ?? this.lastSyncedAt),
      isSyncing: isSyncing ?? this.isSyncing,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

class SyncResult {
  const SyncResult._({
    required this.ok,
    this.sessionCount = 0,
    this.error,
  });

  final bool ok;
  final int sessionCount;
  final String? error;

  factory SyncResult.success({required int sessionCount}) =>
      SyncResult._(ok: true, sessionCount: sessionCount);

  factory SyncResult.failure(String error) =>
      SyncResult._(ok: false, error: error);
}

String formatLastSync(DateTime value) {
  final local = value.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final syncDay = DateTime(local.year, local.month, local.day);
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

  if (syncDay == today) return 'Today at $time';

  final yesterday = today.subtract(const Duration(days: 1));
  if (syncDay == yesterday) return 'Yesterday at $time';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${local.day} ${months[local.month - 1]} ${local.year} at $time';
}

String describeSyncError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    final message = error.response?.data;
    if (status == 401) {
      return 'Session expired — sign out and log in again';
    }
    if (status != null) {
      return 'Server error ($status)';
    }
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Cannot reach the API — check your connection or API URL';
      default:
        break;
    }
  }
  return error.toString();
}

class SyncStatusNotifier extends Notifier<SyncStatus> {
  Future<SyncResult>? _activeSync;

  @override
  SyncStatus build() {
    unawaited(_loadLastSync());
    return const SyncStatus();
  }

  void reset() {
    state = const SyncStatus();
  }

  Future<void> _loadLastSync() async {
    try {
      final last = await ref
          .read(lastSyncRepositoryProvider)
          .read()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (last != null) {
        state = state.copyWith(lastSyncedAt: last);
      }
    } catch (_) {}
  }

  Future<void> recordSuccess([DateTime? when]) async {
    final now = when ?? DateTime.now();
    state = state.copyWith(lastSyncedAt: now, clearError: true);
    try {
      await ref
          .read(lastSyncRepositoryProvider)
          .write(now)
          .timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<bool> syncAll({Duration timeout = const Duration(seconds: 25)}) async {
    final result = await syncAllDetailed(timeout: timeout);
    return result.ok;
  }

  Future<SyncResult> syncAllDetailed({
    Duration timeout = const Duration(seconds: 25),
  }) {
    final active = _activeSync;
    if (active != null) return active;
    final run = _runSync(timeout);
    _activeSync = run;
    return run.whenComplete(() {
      if (identical(_activeSync, run)) {
        _activeSync = null;
      }
    });
  }

  Future<SyncResult> _runSync(Duration timeout) async {
    state = state.copyWith(isSyncing: true, clearError: true);
    try {
      final payload = await ref
          .read(syncServiceProvider)
          .syncAll()
          .timeout(timeout);

      try {
        ref.read(lockerProvider.notifier).applyRemotePayload(payload);
      } catch (_) {}

      await ref.read(shootLogProvider.notifier).applyRemotePayload(payload);

      var sessionCount = ref.read(shootLogProvider).value?.length ?? 0;
      if (sessionCount == 0) {
        sessionCount =
            await ref.read(shootLogProvider.notifier).pullFromApi();
      }

      await recordSuccess();
      unawaited(
        LocalNotificationsService.instance.showSyncComplete(
          sessionCount: sessionCount,
        ),
      );
      return SyncResult.success(sessionCount: sessionCount);
    } catch (error) {
      try {
        final sessionCount =
            await ref.read(shootLogProvider.notifier).pullFromApi();
        if (sessionCount > 0) {
          await recordSuccess();
          return SyncResult.success(sessionCount: sessionCount);
        }
      } catch (_) {}

      final message = describeSyncError(error);
      state = state.copyWith(lastError: message);
      unawaited(LocalNotificationsService.instance.showSyncFailed(message));
      return SyncResult.failure(message);
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }
}

final syncStatusProvider =
    NotifierProvider<SyncStatusNotifier, SyncStatus>(SyncStatusNotifier.new);
