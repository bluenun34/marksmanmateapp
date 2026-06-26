import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../models/paper_target_type.dart';
import 'saved_target_store.dart';

final paperTargetLibraryProvider = Provider<PaperTargetLibraryService>((ref) {
  return PaperTargetLibraryService(
    SavedTargetStore(),
    ref.read(apiServiceProvider),
  );
});

/// Local saved targets plus optional sync to the user's MarksmanMate account.
class PaperTargetLibraryService {
  PaperTargetLibraryService(this._store, this._api);

  final SavedTargetStore _store;
  final ApiService _api;

  Future<List<PaperTargetType>> loadAll() => _store.loadAll();

  Future<PaperTargetType> save(PaperTargetType target, {bool sync = true}) async {
    var saved = target.copyWith(isUserSaved: true);
    await _store.save(saved);

    if (!sync) return saved;

    try {
      final remote = await _api.upsertPaperTarget(saved.toApiJson());
      saved = PaperTargetType.fromApiJson(remote);
      await _store.save(saved);
    } catch (_) {
      // Keep local copy when offline or unauthenticated.
    }

    return saved;
  }

  Future<void> remove(PaperTargetType target) async {
    if (target.serverId != null) {
      try {
        await _api.deletePaperTarget(target.serverId!);
      } catch (_) {}
    }
    await _store.remove(target.id);
  }

  Future<void> applyRemoteTargets(List<Map<String, dynamic>> rawTargets) async {
    final remoteTargets = <PaperTargetType>[];
    for (final json in rawTargets) {
      try {
        remoteTargets.add(PaperTargetType.fromApiJson(json));
      } catch (_) {}
    }

    final local = await _store.loadAll();
    final remoteClientIds = remoteTargets.map((t) => t.id).toSet();
    final remoteServerIds =
        remoteTargets.map((t) => t.serverId).whereType<int>().toSet();

    final keptLocalOnly = local.where((target) {
      if (target.serverId != null &&
          !remoteServerIds.contains(target.serverId)) {
        return false;
      }
      if (remoteClientIds.contains(target.id)) {
        return false;
      }
      return true;
    });

    await _store.replaceAll([
      ...keptLocalOnly,
      ...remoteTargets,
    ]);
  }

  /// Upload local-only saved targets after sign-in or reconnect.
  Future<void> pushUnsyncedLocal() async {
    final local = await _store.loadAll();
    for (final target in local) {
      if (target.serverId != null) continue;
      try {
        final remote = await _api.upsertPaperTarget(target.toApiJson());
        await _store.save(PaperTargetType.fromApiJson(remote));
      } catch (_) {}
    }
  }

  PaperTargetType? parseShareCode(String text) => _store.parseShareCode(text);

  String shareCodeFor(PaperTargetType target) => _store.shareCodeFor(target);
}
