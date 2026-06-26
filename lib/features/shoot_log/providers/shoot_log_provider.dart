import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/api_service.dart';
import '../../../core/sync/session_local_mapper.dart';
import '../../../core/sync/pending_photo_repository.dart';
import '../../../core/sync/session_sync_helper.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/sync/sync_status_provider.dart';
import '../../../core/widgets/home_widget_service.dart';
import '../../../shared/models/shoot_session_model.dart';
import '../../../shared/models/sync_payload.dart';

enum SessionDetailSource { local, remote }

enum SessionSaveResult {
  synced,
  syncedPhotosPending,
  savedOffline,
  savedOfflineAfterApiFailure,
  savedOfflinePhotosSkipped,
  failed,
}

class SessionCreateOutcome {
  const SessionCreateOutcome({required this.result, this.detail});

  final SessionSaveResult result;
  final String? detail;
}

class SessionItem {
  const SessionItem({required this.local});

  final ShootSession local;

  String get discipline => local.discipline;
  String get sessionType => local.sessionType;
  String get rangeName => local.rangeName ?? '';
  DateTime get date => local.date;
  int? get totalRounds => local.totalRounds;
  String get syncStatus => local.syncStatus;
  int get localId => local.id;
  int? get serverId => local.serverId;

  String get detailPath => serverId != null
      ? '/shoot-log/$serverId?source=remote'
      : '/shoot-log/$localId?source=local';
}

class ShootLogNotifier extends Notifier<AsyncValue<List<SessionItem>>> {
  int _loadGeneration = 0;
  int _apiPage = 1;
  bool _hasMoreRemote = true;
  bool _loadingMore = false;

  bool get hasMoreRemote => _hasMoreRemote;
  bool get isLoadingMore => _loadingMore;

  @override
  AsyncValue<List<SessionItem>> build() {
    ref.keepAlive();

    unawaited(_initialLoad());
    return const AsyncLoading();
  }

  Future<void> _initialLoad() async {
    await _loadLocal();
    if ((state.value ?? []).isNotEmpty) return;
    try {
      await pullFromApi();
    } catch (_) {}
  }

  AppDatabase get _db => ref.read(appDatabaseProvider);

  List<SessionItem> _itemsFromLogs(Iterable<Map<String, dynamic>> logs) {
    final items = <SessionItem>[];
    for (final json in logs) {
      try {
        final remote = ShootSessionModel.fromApiJson(json);
        items.add(SessionItem(local: shootSessionFromRemote(remote)));
      } catch (_) {}
    }
    return items;
  }

  List<SessionItem> _itemsFromModels(List<ShootSessionModel> models) {
    return models
        .map((remote) => SessionItem(local: shootSessionFromRemote(remote)))
        .toList();
  }

  List<SessionItem> _mergeWithPending(List<SessionItem> remoteItems) {
    final remoteServerIds =
        remoteItems.map((item) => item.serverId).whereType<int>().toSet();

    final pendingLocal = (state.value ?? []).where((item) {
      if (item.syncStatus != 'pending' && item.syncStatus != 'error') {
        return false;
      }
      final serverId = item.serverId;
      return serverId == null || !remoteServerIds.contains(serverId);
    });

    return [...pendingLocal, ...remoteItems]
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _setItems(List<SessionItem> items) {
    state = AsyncData(items);
    unawaited(HomeWidgetService.updateFromSessions(items));
  }

  Future<void> _loadLocal({List<SessionItem>? fallback}) async {
    final generation = ++_loadGeneration;
    try {
      final local = await _db.shootSessionDao
          .getAllSessions()
          .timeout(const Duration(seconds: 8), onTimeout: () => []);
      if (generation != _loadGeneration) return;

      if (local.isEmpty) {
        if (fallback != null && fallback.isNotEmpty) {
          _setItems(fallback);
          return;
        }
        if (state.value?.isNotEmpty ?? false) return;
        _setItems(const []);
        return;
      }

      _setItems(local.map((s) => SessionItem(local: s)).toList());
    } catch (e, st) {
      if (generation != _loadGeneration) return;
      if (fallback != null && fallback.isNotEmpty) {
        _setItems(fallback);
        return;
      }
      if (state.value?.isNotEmpty ?? false) return;
      state = AsyncError(e, st);
    }
  }

  Future<void> reloadLocal() => _loadLocal();

  Future<int> pullFromApi({bool append = false}) async {
    final page = append ? _apiPage + 1 : 1;
    final remote = await ref
        .read(apiServiceProvider)
        .getShootSessions(page: page, perPage: 50)
        .timeout(const Duration(seconds: 20));
    if (remote.isEmpty) {
      _hasMoreRemote = false;
      return state.value?.length ?? 0;
    }

    _apiPage = page;
    _hasMoreRemote = remote.length >= 50;

    final newItems = _itemsFromModels(remote);
    final items = append
        ? _mergeAppended(newItems)
        : _mergeWithPending(newItems);
    _setItems(items);
    await _cacheFromModels(remote);
    return items.length;
  }

  List<SessionItem> _mergeAppended(List<SessionItem> newItems) {
    final current = state.value ?? [];
    final existingIds = current.map((i) => i.serverId).whereType<int>().toSet();
    final merged = [
      ...current,
      ...newItems.where((i) => i.serverId == null || !existingIds.contains(i.serverId)),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return merged;
  }

  Future<void> loadMoreFromApi() async {
    if (_loadingMore || !_hasMoreRemote) return;
    _loadingMore = true;
    try {
      await pullFromApi(append: true);
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> applyRemotePayload(SyncPayload payload) async {
    final remoteItems = _itemsFromLogs(payload.shootLogs);
    final merged = _mergeWithPending(remoteItems);
    _setItems(merged);

    if (payload.shootLogs.isNotEmpty) {
      await _cacheRemoteLogs(payload.shootLogs);
      await _loadLocal(fallback: merged);
    }

    if ((state.value ?? []).isEmpty) {
      try {
        await pullFromApi();
      } catch (_) {}
    }
  }

  Future<void> ensureSessionsVisible() => _ensureSessionsVisible();

  Future<void> _ensureSessionsVisible() async {
    if ((state.value ?? []).isNotEmpty) return;
    await _loadLocal();
    if ((state.value ?? []).isNotEmpty) return;
    try {
      await pullFromApi();
    } catch (_) {}
  }

  Future<void> _cacheFromModels(List<ShootSessionModel> models) async {
    for (final remote in models) {
      if (remote.id == null) continue;
      try {
        await _upsertRemoteLog(remote, null);
      } catch (_) {}
    }
  }

  Future<void> _cacheRemoteLogs(List<Map<String, dynamic>> logs) async {
    for (final logJson in logs) {
      try {
        final remote = ShootSessionModel.fromApiJson(logJson);
        if (remote.id == null) continue;
        await _upsertRemoteLog(remote, logJson);
      } catch (_) {}
    }
  }

  Future<void> _upsertRemoteLog(
    ShootSessionModel remote,
    Map<String, dynamic>? rawJson,
  ) async {
    final existing = await _db.shootSessionDao.getByServerId(remote.id!);
    if (existing != null) {
      if (existing.syncStatus == 'pending' || existing.syncStatus == 'error') {
        return;
      }
      if (existing.locallyModified &&
          remote.updatedAt != null &&
          (existing.serverUpdatedAt == null ||
              remote.updatedAt!.isAfter(existing.serverUpdatedAt!))) {
        await _db.shootSessionDao.markConflict(
          existing.id,
          jsonEncode(rawJson ?? {'id': remote.id}),
        );
        return;
      }
    }

    await _db.shootSessionDao
        .upsertRemoteSession(
          insertCompanion: remoteSessionToCompanion(remote),
          updateCompanion: remoteSessionToUpdateCompanion(remote),
        )
        .timeout(const Duration(seconds: 5));
  }

  void _prependItem(SessionItem item) {
    final current = state.value ?? [];
    final filtered = current
        .where(
          (existing) =>
              existing.serverId != item.serverId &&
              existing.localId != item.localId,
        )
        .toList();
    _setItems([item, ...filtered]);
  }

  Future<SyncResult> refresh() async {
    try {
      final count = await pullFromApi();
      if (count > 0) {
        await ref.read(syncStatusProvider.notifier).recordSuccess();
        return SyncResult.success(sessionCount: count);
      }
    } catch (_) {}

    return ref
        .read(syncStatusProvider.notifier)
        .syncAllDetailed(timeout: const Duration(seconds: 25));
  }

  Future<SessionCreateOutcome> createSession(
    ShootSessionsCompanion companion,
    Map<String, dynamic> payload, {
    List<XFile> targetPhotos = const [],
    List<XFile> sessionPhotos = const [],
  }) async {
    final hasPhotos = targetPhotos.isNotEmpty || sessionPhotos.isNotEmpty;
    final gear = (
      firearmId: companion.firearmId.present ? companion.firearmId.value : null,
      ammoLoadId:
          companion.ammoLoadId.present ? companion.ammoLoadId.value : null,
      equipmentIds: companion.equipmentIds.present
          ? companion.equipmentIds.value
          : null,
    );

    var attemptedOnline = false;

    if (ref.read(isOnlineProvider)) {
      attemptedOnline = true;
      try {
        final created = await ref
            .read(apiServiceProvider)
            .createShootSession(payload)
            .timeout(const Duration(seconds: 20));
        final serverId = created.session.id;
        if (serverId == null) {
          return const SessionCreateOutcome(result: SessionSaveResult.failed);
        }

        String? photoDetail;
        if (hasPhotos) {
          try {
            if (sessionPhotos.isNotEmpty) {
              await ref.read(apiServiceProvider).uploadSessionPhotos(
                    shootLogId: serverId,
                    files: sessionPhotos,
                  );
            }
            if (targetPhotos.isNotEmpty) {
              final entryId = created.firstEntryId;
              if (entryId == null) {
                photoDetail =
                    'Session saved but target photos need a shooting entry on the server';
              } else {
                await ref.read(apiServiceProvider).uploadTargetPhotos(
                      shootLogId: serverId,
                      entryId: entryId,
                      files: targetPhotos,
                    );
              }
            }
          } catch (_) {
            photoDetail =
                'Session saved but some photos could not be uploaded';
          }
        }

        final localId = await _insertCompanion(
          companion,
          serverId: serverId,
          syncStatus: 'synced',
        );
        if (localId == null) {
          return const SessionCreateOutcome(result: SessionSaveResult.failed);
        }

        _prependItem(
          SessionItem(
            local: shootSessionFromRemote(
              created.session,
              syncStatus: 'synced',
              firearmId: gear.firearmId,
              ammoLoadId: gear.ammoLoadId,
              equipmentIds: gear.equipmentIds,
            ),
          ),
        );
        return SessionCreateOutcome(
          result: photoDetail == null
              ? SessionSaveResult.synced
              : SessionSaveResult.syncedPhotosPending,
          detail: photoDetail,
        );
      } catch (_) {}
    }

    if (hasPhotos) {
      final localId = await _insertCompanion(companion, syncStatus: 'pending');
      if (localId == null) {
        return const SessionCreateOutcome(result: SessionSaveResult.failed);
      }
      await ref.read(pendingPhotoRepositoryProvider).queuePhotos(
            localSessionId: localId,
            targetPhotos: targetPhotos,
            sessionPhotos: sessionPhotos,
          );
      _prependItem(
        SessionItem(
          local: shootSessionFromCompanion(
            companion,
            id: localId,
            syncStatus: 'pending',
          ),
        ),
      );
      return SessionCreateOutcome(
        result: attemptedOnline
            ? SessionSaveResult.savedOfflineAfterApiFailure
            : SessionSaveResult.savedOffline,
        detail: 'Session and photos saved locally — will sync when online',
      );
    }

    final localId = await _insertCompanion(companion, syncStatus: 'pending');
    if (localId == null) {
      return const SessionCreateOutcome(result: SessionSaveResult.failed);
    }

    _prependItem(
      SessionItem(
        local: shootSessionFromCompanion(
          companion,
          id: localId,
          syncStatus: 'pending',
        ),
      ),
    );

    return SessionCreateOutcome(
      result: attemptedOnline
          ? SessionSaveResult.savedOfflineAfterApiFailure
          : SessionSaveResult.savedOffline,
    );
  }

  Future<String?> retrySessionSync(int localId) async {
    if (!ref.read(isOnlineProvider)) {
      return 'Connect to the internet to sync this session';
    }

    final session = await _db.shootSessionDao.getByLocalId(localId);
    if (session == null) return 'Session not found';
    if (session.syncStatus == 'synced') return null;

    try {
      final payload = payloadFromLocalSession(session);
      final created = await ref
          .read(apiServiceProvider)
          .createShootSession(payload)
          .timeout(const Duration(seconds: 20));
      final serverId = created.session.id;
      if (serverId == null) return 'Server did not return a session id';

      await _db.shootSessionDao.markSynced(localId, serverId);

      final photoMessage = await uploadQueuedPhotos(
        api: ref.read(apiServiceProvider),
        photoRepo: ref.read(pendingPhotoRepositoryProvider),
        localSessionId: localId,
        serverId: serverId,
        entryId: created.firstEntryId,
      );

      await reloadLocal();
      await ref.read(syncStatusProvider.notifier).recordSuccess();
      return photoMessage;
    } catch (_) {
      await _db.shootSessionDao.markSyncError(localId);
      await reloadLocal();
      return 'Could not sync — check your connection and try again';
    }
  }

  Future<int?> _insertCompanion(
    ShootSessionsCompanion companion, {
    int? serverId,
    required String syncStatus,
  }) async {
    try {
      return await _db.shootSessionDao
          .insertSession(
            companion.copyWith(
              serverId: serverId == null ? const Value.absent() : Value(serverId),
              syncStatus: Value(syncStatus),
            ),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      return null;
    }
  }

  Future<String?> deleteSession({
    required int localId,
    int? serverId,
  }) async {
    if (serverId != null && ref.read(isOnlineProvider)) {
      try {
        await ref.read(apiServiceProvider).deleteShootSession(serverId);
      } catch (_) {
        return 'Could not delete on server — check your connection';
      }
    }

    try {
      await ref.read(pendingPhotoRepositoryProvider).clearSession(localId);
      await _db.shootSessionDao.deleteSession(localId);
      final current = state.value ?? [];
      _setItems(current.where((s) => s.localId != localId).toList());
      return null;
    } catch (_) {
      return 'Could not delete session locally';
    }
  }

  Future<String?> updateSession({
    required int localId,
    int? serverId,
    required ShootSessionsCompanion companion,
    required Map<String, dynamic> payload,
  }) async {
    var syncStatus = serverId != null ? 'synced' : 'pending';

    if (serverId != null && ref.read(isOnlineProvider)) {
      try {
        final updated = await ref
            .read(apiServiceProvider)
            .updateShootSession(serverId, payload);
        syncStatus = 'synced';
        await _db.shootSessionDao
            .updateSession(
              companion.copyWith(
                id: Value(localId),
                serverId: Value(updated.id ?? serverId),
                syncStatus: Value(syncStatus),
                locallyModified: const Value(false),
                serverUpdatedAt: Value(updated.updatedAt),
              ),
            )
            .timeout(const Duration(seconds: 5));
        await reloadLocal();
        return null;
      } catch (_) {
        syncStatus = 'error';
      }
    } else if (serverId != null) {
      syncStatus = 'pending';
    }

    try {
        await _db.shootSessionDao.updateSession(
        companion.copyWith(
          id: Value(localId),
          serverId: serverId == null ? const Value.absent() : Value(serverId),
          syncStatus: Value(syncStatus),
          locallyModified: const Value(true),
        ),
      );
      await reloadLocal();
      if (syncStatus == 'error') {
        return 'Saved locally — could not update on server';
      }
      if (syncStatus == 'pending' && serverId != null) {
        return 'Saved offline — will sync when online';
      }
      return null;
    } catch (_) {
      return 'Could not save changes';
    }
  }

  Future<int?> duplicateSession(int localId) async {
    final session = await _db.shootSessionDao.getByLocalId(localId);
    if (session == null) return null;

    final companion = ShootSessionsCompanion.insert(
      date: DateTime.now(),
      discipline: session.discipline,
      sessionType: session.sessionType,
      eventId: Value(session.eventId),
      rangeName: Value(session.rangeName),
      venueType: Value(session.venueType),
      location: Value(session.location),
      latitude: Value(session.latitude),
      longitude: Value(session.longitude),
      firearmId: Value(session.firearmId),
      ammoLoadId: Value(session.ammoLoadId),
      equipmentIds: Value(session.equipmentIds),
      totalRounds: Value(session.totalRounds),
      totalHits: Value(session.totalHits),
      totalMisses: Value(session.totalMisses),
      totalScore: Value(session.totalScore),
      rating: Value(session.rating),
      notes: Value(
        session.notes != null ? 'Copy of session\n${session.notes}' : 'Copy of session',
      ),
      weatherCondition: Value(session.weatherCondition),
      temperature: Value(session.temperature),
      windSpeed: Value(session.windSpeed),
      windDirection: Value(session.windDirection),
      humidity: Value(session.humidity),
      pressure: Value(session.pressure),
      syncStatus: const Value('pending'),
    );

    final newLocalId = await _insertCompanion(companion, syncStatus: 'pending');
    if (newLocalId == null) return null;
    await reloadLocal();
    return newLocalId;
  }

  Future<int?> ensureLocalCache(int serverId) async {
    final existing = await _db.shootSessionDao.getByServerId(serverId);
    if (existing != null) return existing.id;

    try {
      final remote = await ref
          .read(apiServiceProvider)
          .getShootSession(serverId)
          .timeout(const Duration(seconds: 15));
      await _upsertRemoteLog(remote, null);
      return (await _db.shootSessionDao.getByServerId(serverId))?.id;
    } catch (_) {
      return null;
    }
  }

  Future<String?> resolveConflictKeepLocal(int localId) async {
    final session = await _db.shootSessionDao.getByLocalId(localId);
    if (session == null) return 'Session not found';
    if (session.serverId == null) return 'Session is not linked to the server';

    final payload = payloadFromLocalSession(session);
    return updateSession(
      localId: localId,
      serverId: session.serverId,
      companion: ShootSessionsCompanion(
        id: Value(localId),
        syncStatus: const Value('synced'),
        locallyModified: const Value(false),
        conflictRemoteJson: const Value(null),
      ),
      payload: payload,
    );
  }

  Future<String?> resolveConflictUseServer(int localId) async {
    final session = await _db.shootSessionDao.getByLocalId(localId);
    if (session == null) return 'Session not found';
    final raw = session.conflictRemoteJson;
    if (raw == null || raw.isEmpty) return 'No server version saved for this conflict';

    try {
      final remote = ShootSessionModel.fromApiJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      await _db.shootSessionDao.updateSession(
        remoteSessionToUpdateCompanion(remote).copyWith(
          id: Value(localId),
          serverId: Value(remote.id ?? session.serverId),
          syncStatus: const Value('synced'),
          locallyModified: const Value(false),
          serverUpdatedAt: Value(remote.updatedAt),
          conflictRemoteJson: const Value(null),
          voiceNotePath: Value(session.voiceNotePath),
        ),
      );
      await reloadLocal();
      return null;
    } catch (_) {
      return 'Could not apply the website version';
    }
  }
}

final shootLogProvider = NotifierProvider<ShootLogNotifier,
    AsyncValue<List<SessionItem>>>(ShootLogNotifier.new);
