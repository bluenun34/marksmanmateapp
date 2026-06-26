import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../network/api_service.dart';
import '../../features/tools/data/paper_target_library_service.dart';
import '../../shared/models/ammo_load_model.dart';
import '../../shared/models/equipment_model.dart';
import '../../shared/models/firearm_model.dart';
import '../../shared/models/shoot_session_model.dart';
import '../../shared/models/sync_payload.dart';
import 'pending_photo_repository.dart';
import 'session_local_mapper.dart';
import 'session_sync_helper.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final controller = StreamController<List<ConnectivityResult>>.broadcast();

  Connectivity()
      .checkConnectivity()
      .then(controller.add)
      .catchError((_) => controller.add([ConnectivityResult.none]));

  final subscription =
      Connectivity().onConnectivityChanged.listen(controller.add);

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

final isOnlineProvider = Provider<bool>((ref) {
  final result = ref.watch(connectivityProvider).value;
  if (result == null) return true;
  if (result.isEmpty || result.contains(ConnectivityResult.none)) {
    return false;
  }
  return true;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.read(appDatabaseProvider),
    ref.read(apiServiceProvider),
    ref.read(pendingPhotoRepositoryProvider),
    ref.read(paperTargetLibraryProvider),
  );
});

class SyncService {
  const SyncService(
    this._db,
    this._api,
    this._photos,
    this._paperTargets,
  );
  final AppDatabase _db;
  final ApiService _api;
  final PendingPhotoRepository _photos;
  final PaperTargetLibraryService _paperTargets;

  /// Push local pending sessions up, then pull locker + shoot logs down.
  /// Returns the sync payload so callers can update UI without waiting on DB writes.
  Future<SyncPayload> syncAll() async {
    await _bestEffort(syncPendingSessions(), const Duration(seconds: 8));

    final payload = await _api.getSync().timeout(const Duration(seconds: 15));

    // Wait for DB cache before callers refresh UI from local storage.
    await _bestEffort(_applyPullPayload(payload), const Duration(seconds: 10));
    await _bestEffort(_paperTargets.pushUnsyncedLocal(), const Duration(seconds: 5));

    return payload;
  }

  Future<void> _bestEffort(Future<void> work, Duration timeout) async {
    try {
      await work.timeout(timeout);
    } catch (_) {}
  }

  Future<void> syncPendingSessions() async {
    List<ShootSession> pending;
    try {
      pending = await _db.shootSessionDao
          .getPendingSessions()
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      return;
    }

    for (final session in pending) {
      try {
        final payload = payloadFromLocalSession(session);
        final created = await _api
            .createShootSession(payload)
            .timeout(const Duration(seconds: 15));
        if (created.session.id != null) {
          await _db.shootSessionDao
              .markSynced(session.id, created.session.id!)
              .timeout(const Duration(seconds: 3));
          await uploadQueuedPhotos(
            api: _api,
            photoRepo: _photos,
            localSessionId: session.id,
            serverId: created.session.id!,
            entryId: created.firstEntryId,
          );
        }
      } catch (_) {
        try {
          await _db.shootSessionDao
              .markSyncError(session.id)
              .timeout(const Duration(seconds: 3));
        } catch (_) {}
      }
    }
  }

  Future<void> _applyPullPayload(SyncPayload payload) async {
    await _cacheLocker(payload);
    await _bestEffort(
      _paperTargets.applyRemoteTargets(payload.paperTargets),
      const Duration(seconds: 5),
    );
    for (final logJson in payload.shootLogs) {
      try {
        final remote = ShootSessionModel.fromApiJson(logJson);
        if (remote.id == null) continue;
        await _db.shootSessionDao
            .upsertRemoteSession(
              insertCompanion: remoteSessionToCompanion(remote),
              updateCompanion: remoteSessionToUpdateCompanion(remote),
            )
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  Future<void> _cacheLocker(SyncPayload payload) async {
    final firearms = payload.firearms
        .map((json) => FirearmModel.fromJson(json))
        .toList();
    final ammo = payload.ammoLoads
        .map((json) => AmmoLoadModel.fromJson(json))
        .toList();
    final equipment = payload.equipment
        .map((json) => EquipmentModel.fromJson(json))
        .toList();

    await _db.lockerDao
        .replaceFirearms(firearms.map(firearmToCacheCompanion).toList())
        .timeout(const Duration(seconds: 5));
    await _db.lockerDao
        .replaceAmmoLoads(ammo.map(ammoToCacheCompanion).toList())
        .timeout(const Duration(seconds: 5));
    await _db.lockerDao
        .replaceEquipment(equipment.map(equipmentToCacheCompanion).toList())
        .timeout(const Duration(seconds: 5));
  }
}
