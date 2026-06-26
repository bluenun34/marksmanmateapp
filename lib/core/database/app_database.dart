import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

// ─── Tables ───────────────────────────────────────────────────────────────────

class ShootSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get discipline => text()();
  TextColumn get sessionType => text()();
  TextColumn get location => text().nullable()();
  TextColumn get rangeName => text().nullable()();
  TextColumn get venueType => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get firearmId => integer().nullable()();
  IntColumn get ammoLoadId => integer().nullable()();
  TextColumn get equipmentIds => text().nullable()();
  IntColumn get totalRounds => integer().nullable()();
  IntColumn get totalHits => integer().nullable()();
  IntColumn get totalMisses => integer().nullable()();
  RealColumn get totalScore => real().nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get weatherCondition => text().nullable()();
  RealColumn get temperature => real().nullable()();
  RealColumn get windSpeed => real().nullable()();
  TextColumn get windDirection => text().nullable()();
  RealColumn get humidity => real().nullable()();
  RealColumn get pressure => real().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  IntColumn get eventId => integer().nullable()();
  TextColumn get voiceNotePath => text().nullable()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  BoolColumn get locallyModified =>
      boolean().withDefault(const Constant(false))();
  TextColumn get conflictRemoteJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class PendingSessionPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get localSessionId => integer().references(ShootSessions, #id)();
  TextColumn get filePath => text()();
  TextColumn get photoType => text()();
  TextColumn get fileName => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ShootEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(ShootSessions, #id)();
  IntColumn get firearmId => integer().nullable()();
  IntColumn get ammoLoadId => integer().nullable()();
  RealColumn get distance => real().nullable()();
  IntColumn get roundsFired => integer().nullable()();
  IntColumn get hits => integer().nullable()();
  IntColumn get misses => integer().nullable()();
  RealColumn get groupSize => real().nullable()();
  RealColumn get score => real().nullable()();
  TextColumn get stageName => text().nullable()();
  TextColumn get notes => text().nullable()();
}

class CachedFirearms extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get make => text()();
  TextColumn get model => text()();
  TextColumn get calibre => text().nullable()();
  TextColumn get serialNumber => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedAmmoLoads extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get calibre => text()();
  TextColumn get manufacturer => text().nullable()();
  RealColumn get bulletWeight => real().nullable()();
  RealColumn get powderCharge => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedEquipment extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()();
  TextColumn get brand => text().nullable()();
  TextColumn get model => text().nullable()();
  IntColumn get firearmId => integer().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── DAOs ─────────────────────────────────────────────────────────────────────

@DriftAccessor(tables: [ShootSessions, ShootEntries])
class ShootSessionDao extends DatabaseAccessor<AppDatabase>
    with _$ShootSessionDaoMixin {
  ShootSessionDao(super.db);

  Stream<List<ShootSession>> watchAllSessions() =>
      (select(shootSessions)..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<List<ShootSession>> getAllSessions() =>
      (select(shootSessions)..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<int> insertSession(ShootSessionsCompanion entry) =>
      into(shootSessions).insert(entry);

  Future<bool> updateSession(ShootSessionsCompanion entry) =>
      update(shootSessions).replace(entry);

  Future<List<ShootSession>> getPendingSessions() =>
      (select(shootSessions)..where((t) => t.syncStatus.equals('pending'))).get();

  Future<ShootSession?> getByServerId(int serverId) => (select(shootSessions)
        ..where((t) => t.serverId.equals(serverId)))
      .getSingleOrNull();

  Future<void> markSynced(int localId, int serverId) =>
      (update(shootSessions)..where((t) => t.id.equals(localId))).write(
        ShootSessionsCompanion(
          serverId: Value(serverId),
          syncStatus: const Value('synced'),
        ),
      );

  Future<void> markSyncError(int localId) =>
      (update(shootSessions)..where((t) => t.id.equals(localId))).write(
        const ShootSessionsCompanion(syncStatus: Value('error')),
      );

  Future<void> upsertRemoteSession({
    required ShootSessionsCompanion insertCompanion,
    required ShootSessionsCompanion updateCompanion,
  }) async {
    final serverId = insertCompanion.serverId.value;
    if (serverId == null) return;

    final existing = await getByServerId(serverId);
    if (existing == null) {
      await into(shootSessions).insert(insertCompanion);
      return;
    }

    if (existing.syncStatus == 'pending') return;

    await (update(shootSessions)..where((t) => t.id.equals(existing.id)))
        .write(updateCompanion);
  }

  Future<ShootSession?> getByLocalId(int localId) => (select(shootSessions)
        ..where((t) => t.id.equals(localId)))
      .getSingleOrNull();

  Future<List<ShootSession>> getErrorSessions() =>
      (select(shootSessions)..where((t) => t.syncStatus.equals('error'))).get();

  Future<void> deleteSession(int localId) =>
      (delete(shootSessions)..where((t) => t.id.equals(localId))).go();

  Future<void> markConflict(
    int localId,
    String remoteJson,
  ) =>
      (update(shootSessions)..where((t) => t.id.equals(localId))).write(
        ShootSessionsCompanion(
          syncStatus: const Value('conflict'),
          conflictRemoteJson: Value(remoteJson),
        ),
      );

  Future<void> clearConflict(int localId) =>
      (update(shootSessions)..where((t) => t.id.equals(localId))).write(
        const ShootSessionsCompanion(
          syncStatus: Value('synced'),
          conflictRemoteJson: Value(null),
          locallyModified: Value(false),
        ),
      );

  Future<int> insertEntry(ShootEntriesCompanion entry) =>
      into(shootEntries).insert(entry);
}

@DriftAccessor(tables: [PendingSessionPhotos])
class PendingPhotoDao extends DatabaseAccessor<AppDatabase>
    with _$PendingPhotoDaoMixin {
  PendingPhotoDao(super.db);

  Future<List<PendingSessionPhoto>> forSession(int localSessionId) =>
      (select(pendingSessionPhotos)
            ..where((t) => t.localSessionId.equals(localSessionId)))
          .get();

  Future<int> insertPhoto(PendingSessionPhotosCompanion entry) =>
      into(pendingSessionPhotos).insert(entry);

  Future<void> deleteForSession(int localSessionId) => (delete(pendingSessionPhotos)
        ..where((t) => t.localSessionId.equals(localSessionId)))
      .go();

  Future<void> deletePhoto(int id) =>
      (delete(pendingSessionPhotos)..where((t) => t.id.equals(id))).go();

  Future<int> pendingCount() async {
    final rows = await select(pendingSessionPhotos).get();
    return rows.length;
  }
}

@DriftAccessor(tables: [CachedFirearms, CachedAmmoLoads, CachedEquipment])
class LockerDao extends DatabaseAccessor<AppDatabase> with _$LockerDaoMixin {
  LockerDao(super.db);

  Future<List<CachedFirearm>> getAllFirearms() => select(cachedFirearms).get();
  Future<List<CachedAmmoLoad>> getAllAmmoLoads() =>
      select(cachedAmmoLoads).get();
  Future<List<CachedEquipmentData>> getAllEquipment() =>
      select(cachedEquipment).get();

  Future<void> replaceFirearms(List<CachedFirearmsCompanion> items) =>
      transaction(() async {
        await delete(cachedFirearms).go();
        await batch((b) => b.insertAll(cachedFirearms, items));
      });

  Future<void> replaceAmmoLoads(List<CachedAmmoLoadsCompanion> items) =>
      transaction(() async {
        await delete(cachedAmmoLoads).go();
        await batch((b) => b.insertAll(cachedAmmoLoads, items));
      });

  Future<void> replaceEquipment(List<CachedEquipmentCompanion> items) =>
      transaction(() async {
        await delete(cachedEquipment).go();
        await batch((b) => b.insertAll(cachedEquipment, items));
      });
}

List<int> decodeEquipmentIds(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.whereType<num>().map((value) => value.toInt()).toList();
  } catch (_) {
    return const [];
  }
}

String encodeEquipmentIds(List<int> ids) => jsonEncode(ids);

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    ShootSessions,
    ShootEntries,
    PendingSessionPhotos,
    CachedFirearms,
    CachedAmmoLoads,
    CachedEquipment,
  ],
  daos: [ShootSessionDao, PendingPhotoDao, LockerDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(shootSessions, shootSessions.location);
            await m.addColumn(shootSessions, shootSessions.latitude);
            await m.addColumn(shootSessions, shootSessions.longitude);
          }
          if (from < 3) {
            await m.addColumn(shootSessions, shootSessions.firearmId);
            await m.addColumn(shootSessions, shootSessions.ammoLoadId);
            await m.addColumn(shootSessions, shootSessions.equipmentIds);
            await m.createTable(cachedEquipment);
          }
          if (from < 4) {
            await m.addColumn(shootSessions, shootSessions.eventId);
            await m.createTable(pendingSessionPhotos);
          }
          if (from < 5) {
            await m.addColumn(shootSessions, shootSessions.voiceNotePath);
            await m.addColumn(shootSessions, shootSessions.serverUpdatedAt);
            await m.addColumn(shootSessions, shootSessions.locallyModified);
            await m.addColumn(shootSessions, shootSessions.conflictRemoteJson);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'marksmanmate_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  ref.keepAlive();
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
