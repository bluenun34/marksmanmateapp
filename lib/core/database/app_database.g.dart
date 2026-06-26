// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$ShootSessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $ShootSessionsTable get shootSessions => attachedDatabase.shootSessions;
  $ShootEntriesTable get shootEntries => attachedDatabase.shootEntries;
  ShootSessionDaoManager get managers => ShootSessionDaoManager(this);
}

class ShootSessionDaoManager {
  final _$ShootSessionDaoMixin _db;
  ShootSessionDaoManager(this._db);
  $$ShootSessionsTableTableManager get shootSessions =>
      $$ShootSessionsTableTableManager(_db.attachedDatabase, _db.shootSessions);
  $$ShootEntriesTableTableManager get shootEntries =>
      $$ShootEntriesTableTableManager(_db.attachedDatabase, _db.shootEntries);
}

mixin _$PendingPhotoDaoMixin on DatabaseAccessor<AppDatabase> {
  $ShootSessionsTable get shootSessions => attachedDatabase.shootSessions;
  $PendingSessionPhotosTable get pendingSessionPhotos =>
      attachedDatabase.pendingSessionPhotos;
  PendingPhotoDaoManager get managers => PendingPhotoDaoManager(this);
}

class PendingPhotoDaoManager {
  final _$PendingPhotoDaoMixin _db;
  PendingPhotoDaoManager(this._db);
  $$ShootSessionsTableTableManager get shootSessions =>
      $$ShootSessionsTableTableManager(_db.attachedDatabase, _db.shootSessions);
  $$PendingSessionPhotosTableTableManager get pendingSessionPhotos =>
      $$PendingSessionPhotosTableTableManager(
        _db.attachedDatabase,
        _db.pendingSessionPhotos,
      );
}

mixin _$LockerDaoMixin on DatabaseAccessor<AppDatabase> {
  $CachedFirearmsTable get cachedFirearms => attachedDatabase.cachedFirearms;
  $CachedAmmoLoadsTable get cachedAmmoLoads => attachedDatabase.cachedAmmoLoads;
  $CachedEquipmentTable get cachedEquipment => attachedDatabase.cachedEquipment;
  LockerDaoManager get managers => LockerDaoManager(this);
}

class LockerDaoManager {
  final _$LockerDaoMixin _db;
  LockerDaoManager(this._db);
  $$CachedFirearmsTableTableManager get cachedFirearms =>
      $$CachedFirearmsTableTableManager(
        _db.attachedDatabase,
        _db.cachedFirearms,
      );
  $$CachedAmmoLoadsTableTableManager get cachedAmmoLoads =>
      $$CachedAmmoLoadsTableTableManager(
        _db.attachedDatabase,
        _db.cachedAmmoLoads,
      );
  $$CachedEquipmentTableTableManager get cachedEquipment =>
      $$CachedEquipmentTableTableManager(
        _db.attachedDatabase,
        _db.cachedEquipment,
      );
}

class $ShootSessionsTable extends ShootSessions
    with TableInfo<$ShootSessionsTable, ShootSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShootSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _disciplineMeta = const VerificationMeta(
    'discipline',
  );
  @override
  late final GeneratedColumn<String> discipline = GeneratedColumn<String>(
    'discipline',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionTypeMeta = const VerificationMeta(
    'sessionType',
  );
  @override
  late final GeneratedColumn<String> sessionType = GeneratedColumn<String>(
    'session_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rangeNameMeta = const VerificationMeta(
    'rangeName',
  );
  @override
  late final GeneratedColumn<String> rangeName = GeneratedColumn<String>(
    'range_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _venueTypeMeta = const VerificationMeta(
    'venueType',
  );
  @override
  late final GeneratedColumn<String> venueType = GeneratedColumn<String>(
    'venue_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firearmIdMeta = const VerificationMeta(
    'firearmId',
  );
  @override
  late final GeneratedColumn<int> firearmId = GeneratedColumn<int>(
    'firearm_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ammoLoadIdMeta = const VerificationMeta(
    'ammoLoadId',
  );
  @override
  late final GeneratedColumn<int> ammoLoadId = GeneratedColumn<int>(
    'ammo_load_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentIdsMeta = const VerificationMeta(
    'equipmentIds',
  );
  @override
  late final GeneratedColumn<String> equipmentIds = GeneratedColumn<String>(
    'equipment_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalRoundsMeta = const VerificationMeta(
    'totalRounds',
  );
  @override
  late final GeneratedColumn<int> totalRounds = GeneratedColumn<int>(
    'total_rounds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalHitsMeta = const VerificationMeta(
    'totalHits',
  );
  @override
  late final GeneratedColumn<int> totalHits = GeneratedColumn<int>(
    'total_hits',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMissesMeta = const VerificationMeta(
    'totalMisses',
  );
  @override
  late final GeneratedColumn<int> totalMisses = GeneratedColumn<int>(
    'total_misses',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalScoreMeta = const VerificationMeta(
    'totalScore',
  );
  @override
  late final GeneratedColumn<double> totalScore = GeneratedColumn<double>(
    'total_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherConditionMeta = const VerificationMeta(
    'weatherCondition',
  );
  @override
  late final GeneratedColumn<String> weatherCondition = GeneratedColumn<String>(
    'weather_condition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _windSpeedMeta = const VerificationMeta(
    'windSpeed',
  );
  @override
  late final GeneratedColumn<double> windSpeed = GeneratedColumn<double>(
    'wind_speed',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _windDirectionMeta = const VerificationMeta(
    'windDirection',
  );
  @override
  late final GeneratedColumn<String> windDirection = GeneratedColumn<String>(
    'wind_direction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _humidityMeta = const VerificationMeta(
    'humidity',
  );
  @override
  late final GeneratedColumn<double> humidity = GeneratedColumn<double>(
    'humidity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pressureMeta = const VerificationMeta(
    'pressure',
  );
  @override
  late final GeneratedColumn<double> pressure = GeneratedColumn<double>(
    'pressure',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voiceNotePathMeta = const VerificationMeta(
    'voiceNotePath',
  );
  @override
  late final GeneratedColumn<String> voiceNotePath = GeneratedColumn<String>(
    'voice_note_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _locallyModifiedMeta = const VerificationMeta(
    'locallyModified',
  );
  @override
  late final GeneratedColumn<bool> locallyModified = GeneratedColumn<bool>(
    'locally_modified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locally_modified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _conflictRemoteJsonMeta =
      const VerificationMeta('conflictRemoteJson');
  @override
  late final GeneratedColumn<String> conflictRemoteJson =
      GeneratedColumn<String>(
        'conflict_remote_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    date,
    discipline,
    sessionType,
    location,
    rangeName,
    venueType,
    latitude,
    longitude,
    firearmId,
    ammoLoadId,
    equipmentIds,
    totalRounds,
    totalHits,
    totalMisses,
    totalScore,
    rating,
    notes,
    weatherCondition,
    temperature,
    windSpeed,
    windDirection,
    humidity,
    pressure,
    syncStatus,
    eventId,
    voiceNotePath,
    serverUpdatedAt,
    locallyModified,
    conflictRemoteJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shoot_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShootSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('discipline')) {
      context.handle(
        _disciplineMeta,
        discipline.isAcceptableOrUnknown(data['discipline']!, _disciplineMeta),
      );
    } else if (isInserting) {
      context.missing(_disciplineMeta);
    }
    if (data.containsKey('session_type')) {
      context.handle(
        _sessionTypeMeta,
        sessionType.isAcceptableOrUnknown(
          data['session_type']!,
          _sessionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionTypeMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('range_name')) {
      context.handle(
        _rangeNameMeta,
        rangeName.isAcceptableOrUnknown(data['range_name']!, _rangeNameMeta),
      );
    }
    if (data.containsKey('venue_type')) {
      context.handle(
        _venueTypeMeta,
        venueType.isAcceptableOrUnknown(data['venue_type']!, _venueTypeMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('firearm_id')) {
      context.handle(
        _firearmIdMeta,
        firearmId.isAcceptableOrUnknown(data['firearm_id']!, _firearmIdMeta),
      );
    }
    if (data.containsKey('ammo_load_id')) {
      context.handle(
        _ammoLoadIdMeta,
        ammoLoadId.isAcceptableOrUnknown(
          data['ammo_load_id']!,
          _ammoLoadIdMeta,
        ),
      );
    }
    if (data.containsKey('equipment_ids')) {
      context.handle(
        _equipmentIdsMeta,
        equipmentIds.isAcceptableOrUnknown(
          data['equipment_ids']!,
          _equipmentIdsMeta,
        ),
      );
    }
    if (data.containsKey('total_rounds')) {
      context.handle(
        _totalRoundsMeta,
        totalRounds.isAcceptableOrUnknown(
          data['total_rounds']!,
          _totalRoundsMeta,
        ),
      );
    }
    if (data.containsKey('total_hits')) {
      context.handle(
        _totalHitsMeta,
        totalHits.isAcceptableOrUnknown(data['total_hits']!, _totalHitsMeta),
      );
    }
    if (data.containsKey('total_misses')) {
      context.handle(
        _totalMissesMeta,
        totalMisses.isAcceptableOrUnknown(
          data['total_misses']!,
          _totalMissesMeta,
        ),
      );
    }
    if (data.containsKey('total_score')) {
      context.handle(
        _totalScoreMeta,
        totalScore.isAcceptableOrUnknown(data['total_score']!, _totalScoreMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('weather_condition')) {
      context.handle(
        _weatherConditionMeta,
        weatherCondition.isAcceptableOrUnknown(
          data['weather_condition']!,
          _weatherConditionMeta,
        ),
      );
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('wind_speed')) {
      context.handle(
        _windSpeedMeta,
        windSpeed.isAcceptableOrUnknown(data['wind_speed']!, _windSpeedMeta),
      );
    }
    if (data.containsKey('wind_direction')) {
      context.handle(
        _windDirectionMeta,
        windDirection.isAcceptableOrUnknown(
          data['wind_direction']!,
          _windDirectionMeta,
        ),
      );
    }
    if (data.containsKey('humidity')) {
      context.handle(
        _humidityMeta,
        humidity.isAcceptableOrUnknown(data['humidity']!, _humidityMeta),
      );
    }
    if (data.containsKey('pressure')) {
      context.handle(
        _pressureMeta,
        pressure.isAcceptableOrUnknown(data['pressure']!, _pressureMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    }
    if (data.containsKey('voice_note_path')) {
      context.handle(
        _voiceNotePathMeta,
        voiceNotePath.isAcceptableOrUnknown(
          data['voice_note_path']!,
          _voiceNotePathMeta,
        ),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('locally_modified')) {
      context.handle(
        _locallyModifiedMeta,
        locallyModified.isAcceptableOrUnknown(
          data['locally_modified']!,
          _locallyModifiedMeta,
        ),
      );
    }
    if (data.containsKey('conflict_remote_json')) {
      context.handle(
        _conflictRemoteJsonMeta,
        conflictRemoteJson.isAcceptableOrUnknown(
          data['conflict_remote_json']!,
          _conflictRemoteJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShootSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShootSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      discipline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discipline'],
      )!,
      sessionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_type'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      rangeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}range_name'],
      ),
      venueType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venue_type'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      firearmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}firearm_id'],
      ),
      ammoLoadId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ammo_load_id'],
      ),
      equipmentIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_ids'],
      ),
      totalRounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_rounds'],
      ),
      totalHits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_hits'],
      ),
      totalMisses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_misses'],
      ),
      totalScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_score'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      weatherCondition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_condition'],
      ),
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      ),
      windSpeed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}wind_speed'],
      ),
      windDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wind_direction'],
      ),
      humidity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}humidity'],
      ),
      pressure: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pressure'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      ),
      voiceNotePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_note_path'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
      locallyModified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locally_modified'],
      )!,
      conflictRemoteJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_remote_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ShootSessionsTable createAlias(String alias) {
    return $ShootSessionsTable(attachedDatabase, alias);
  }
}

class ShootSession extends DataClass implements Insertable<ShootSession> {
  final int id;
  final int? serverId;
  final DateTime date;
  final String discipline;
  final String sessionType;
  final String? location;
  final String? rangeName;
  final String? venueType;
  final double? latitude;
  final double? longitude;
  final int? firearmId;
  final int? ammoLoadId;
  final String? equipmentIds;
  final int? totalRounds;
  final int? totalHits;
  final int? totalMisses;
  final double? totalScore;
  final int? rating;
  final String? notes;
  final String? weatherCondition;
  final double? temperature;
  final double? windSpeed;
  final String? windDirection;
  final double? humidity;
  final double? pressure;
  final String syncStatus;
  final int? eventId;
  final String? voiceNotePath;
  final DateTime? serverUpdatedAt;
  final bool locallyModified;
  final String? conflictRemoteJson;
  final DateTime createdAt;
  const ShootSession({
    required this.id,
    this.serverId,
    required this.date,
    required this.discipline,
    required this.sessionType,
    this.location,
    this.rangeName,
    this.venueType,
    this.latitude,
    this.longitude,
    this.firearmId,
    this.ammoLoadId,
    this.equipmentIds,
    this.totalRounds,
    this.totalHits,
    this.totalMisses,
    this.totalScore,
    this.rating,
    this.notes,
    this.weatherCondition,
    this.temperature,
    this.windSpeed,
    this.windDirection,
    this.humidity,
    this.pressure,
    required this.syncStatus,
    this.eventId,
    this.voiceNotePath,
    this.serverUpdatedAt,
    required this.locallyModified,
    this.conflictRemoteJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['date'] = Variable<DateTime>(date);
    map['discipline'] = Variable<String>(discipline);
    map['session_type'] = Variable<String>(sessionType);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || rangeName != null) {
      map['range_name'] = Variable<String>(rangeName);
    }
    if (!nullToAbsent || venueType != null) {
      map['venue_type'] = Variable<String>(venueType);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || firearmId != null) {
      map['firearm_id'] = Variable<int>(firearmId);
    }
    if (!nullToAbsent || ammoLoadId != null) {
      map['ammo_load_id'] = Variable<int>(ammoLoadId);
    }
    if (!nullToAbsent || equipmentIds != null) {
      map['equipment_ids'] = Variable<String>(equipmentIds);
    }
    if (!nullToAbsent || totalRounds != null) {
      map['total_rounds'] = Variable<int>(totalRounds);
    }
    if (!nullToAbsent || totalHits != null) {
      map['total_hits'] = Variable<int>(totalHits);
    }
    if (!nullToAbsent || totalMisses != null) {
      map['total_misses'] = Variable<int>(totalMisses);
    }
    if (!nullToAbsent || totalScore != null) {
      map['total_score'] = Variable<double>(totalScore);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || weatherCondition != null) {
      map['weather_condition'] = Variable<String>(weatherCondition);
    }
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || windSpeed != null) {
      map['wind_speed'] = Variable<double>(windSpeed);
    }
    if (!nullToAbsent || windDirection != null) {
      map['wind_direction'] = Variable<String>(windDirection);
    }
    if (!nullToAbsent || humidity != null) {
      map['humidity'] = Variable<double>(humidity);
    }
    if (!nullToAbsent || pressure != null) {
      map['pressure'] = Variable<double>(pressure);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<int>(eventId);
    }
    if (!nullToAbsent || voiceNotePath != null) {
      map['voice_note_path'] = Variable<String>(voiceNotePath);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    map['locally_modified'] = Variable<bool>(locallyModified);
    if (!nullToAbsent || conflictRemoteJson != null) {
      map['conflict_remote_json'] = Variable<String>(conflictRemoteJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShootSessionsCompanion toCompanion(bool nullToAbsent) {
    return ShootSessionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      date: Value(date),
      discipline: Value(discipline),
      sessionType: Value(sessionType),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      rangeName: rangeName == null && nullToAbsent
          ? const Value.absent()
          : Value(rangeName),
      venueType: venueType == null && nullToAbsent
          ? const Value.absent()
          : Value(venueType),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      firearmId: firearmId == null && nullToAbsent
          ? const Value.absent()
          : Value(firearmId),
      ammoLoadId: ammoLoadId == null && nullToAbsent
          ? const Value.absent()
          : Value(ammoLoadId),
      equipmentIds: equipmentIds == null && nullToAbsent
          ? const Value.absent()
          : Value(equipmentIds),
      totalRounds: totalRounds == null && nullToAbsent
          ? const Value.absent()
          : Value(totalRounds),
      totalHits: totalHits == null && nullToAbsent
          ? const Value.absent()
          : Value(totalHits),
      totalMisses: totalMisses == null && nullToAbsent
          ? const Value.absent()
          : Value(totalMisses),
      totalScore: totalScore == null && nullToAbsent
          ? const Value.absent()
          : Value(totalScore),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      weatherCondition: weatherCondition == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherCondition),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      windSpeed: windSpeed == null && nullToAbsent
          ? const Value.absent()
          : Value(windSpeed),
      windDirection: windDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(windDirection),
      humidity: humidity == null && nullToAbsent
          ? const Value.absent()
          : Value(humidity),
      pressure: pressure == null && nullToAbsent
          ? const Value.absent()
          : Value(pressure),
      syncStatus: Value(syncStatus),
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
      voiceNotePath: voiceNotePath == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceNotePath),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      locallyModified: Value(locallyModified),
      conflictRemoteJson: conflictRemoteJson == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictRemoteJson),
      createdAt: Value(createdAt),
    );
  }

  factory ShootSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShootSession(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      date: serializer.fromJson<DateTime>(json['date']),
      discipline: serializer.fromJson<String>(json['discipline']),
      sessionType: serializer.fromJson<String>(json['sessionType']),
      location: serializer.fromJson<String?>(json['location']),
      rangeName: serializer.fromJson<String?>(json['rangeName']),
      venueType: serializer.fromJson<String?>(json['venueType']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      firearmId: serializer.fromJson<int?>(json['firearmId']),
      ammoLoadId: serializer.fromJson<int?>(json['ammoLoadId']),
      equipmentIds: serializer.fromJson<String?>(json['equipmentIds']),
      totalRounds: serializer.fromJson<int?>(json['totalRounds']),
      totalHits: serializer.fromJson<int?>(json['totalHits']),
      totalMisses: serializer.fromJson<int?>(json['totalMisses']),
      totalScore: serializer.fromJson<double?>(json['totalScore']),
      rating: serializer.fromJson<int?>(json['rating']),
      notes: serializer.fromJson<String?>(json['notes']),
      weatherCondition: serializer.fromJson<String?>(json['weatherCondition']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      windSpeed: serializer.fromJson<double?>(json['windSpeed']),
      windDirection: serializer.fromJson<String?>(json['windDirection']),
      humidity: serializer.fromJson<double?>(json['humidity']),
      pressure: serializer.fromJson<double?>(json['pressure']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      eventId: serializer.fromJson<int?>(json['eventId']),
      voiceNotePath: serializer.fromJson<String?>(json['voiceNotePath']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      locallyModified: serializer.fromJson<bool>(json['locallyModified']),
      conflictRemoteJson: serializer.fromJson<String?>(
        json['conflictRemoteJson'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'date': serializer.toJson<DateTime>(date),
      'discipline': serializer.toJson<String>(discipline),
      'sessionType': serializer.toJson<String>(sessionType),
      'location': serializer.toJson<String?>(location),
      'rangeName': serializer.toJson<String?>(rangeName),
      'venueType': serializer.toJson<String?>(venueType),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'firearmId': serializer.toJson<int?>(firearmId),
      'ammoLoadId': serializer.toJson<int?>(ammoLoadId),
      'equipmentIds': serializer.toJson<String?>(equipmentIds),
      'totalRounds': serializer.toJson<int?>(totalRounds),
      'totalHits': serializer.toJson<int?>(totalHits),
      'totalMisses': serializer.toJson<int?>(totalMisses),
      'totalScore': serializer.toJson<double?>(totalScore),
      'rating': serializer.toJson<int?>(rating),
      'notes': serializer.toJson<String?>(notes),
      'weatherCondition': serializer.toJson<String?>(weatherCondition),
      'temperature': serializer.toJson<double?>(temperature),
      'windSpeed': serializer.toJson<double?>(windSpeed),
      'windDirection': serializer.toJson<String?>(windDirection),
      'humidity': serializer.toJson<double?>(humidity),
      'pressure': serializer.toJson<double?>(pressure),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'eventId': serializer.toJson<int?>(eventId),
      'voiceNotePath': serializer.toJson<String?>(voiceNotePath),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'locallyModified': serializer.toJson<bool>(locallyModified),
      'conflictRemoteJson': serializer.toJson<String?>(conflictRemoteJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ShootSession copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    DateTime? date,
    String? discipline,
    String? sessionType,
    Value<String?> location = const Value.absent(),
    Value<String?> rangeName = const Value.absent(),
    Value<String?> venueType = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<int?> firearmId = const Value.absent(),
    Value<int?> ammoLoadId = const Value.absent(),
    Value<String?> equipmentIds = const Value.absent(),
    Value<int?> totalRounds = const Value.absent(),
    Value<int?> totalHits = const Value.absent(),
    Value<int?> totalMisses = const Value.absent(),
    Value<double?> totalScore = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> weatherCondition = const Value.absent(),
    Value<double?> temperature = const Value.absent(),
    Value<double?> windSpeed = const Value.absent(),
    Value<String?> windDirection = const Value.absent(),
    Value<double?> humidity = const Value.absent(),
    Value<double?> pressure = const Value.absent(),
    String? syncStatus,
    Value<int?> eventId = const Value.absent(),
    Value<String?> voiceNotePath = const Value.absent(),
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
    bool? locallyModified,
    Value<String?> conflictRemoteJson = const Value.absent(),
    DateTime? createdAt,
  }) => ShootSession(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    date: date ?? this.date,
    discipline: discipline ?? this.discipline,
    sessionType: sessionType ?? this.sessionType,
    location: location.present ? location.value : this.location,
    rangeName: rangeName.present ? rangeName.value : this.rangeName,
    venueType: venueType.present ? venueType.value : this.venueType,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    firearmId: firearmId.present ? firearmId.value : this.firearmId,
    ammoLoadId: ammoLoadId.present ? ammoLoadId.value : this.ammoLoadId,
    equipmentIds: equipmentIds.present ? equipmentIds.value : this.equipmentIds,
    totalRounds: totalRounds.present ? totalRounds.value : this.totalRounds,
    totalHits: totalHits.present ? totalHits.value : this.totalHits,
    totalMisses: totalMisses.present ? totalMisses.value : this.totalMisses,
    totalScore: totalScore.present ? totalScore.value : this.totalScore,
    rating: rating.present ? rating.value : this.rating,
    notes: notes.present ? notes.value : this.notes,
    weatherCondition: weatherCondition.present
        ? weatherCondition.value
        : this.weatherCondition,
    temperature: temperature.present ? temperature.value : this.temperature,
    windSpeed: windSpeed.present ? windSpeed.value : this.windSpeed,
    windDirection: windDirection.present
        ? windDirection.value
        : this.windDirection,
    humidity: humidity.present ? humidity.value : this.humidity,
    pressure: pressure.present ? pressure.value : this.pressure,
    syncStatus: syncStatus ?? this.syncStatus,
    eventId: eventId.present ? eventId.value : this.eventId,
    voiceNotePath: voiceNotePath.present
        ? voiceNotePath.value
        : this.voiceNotePath,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    locallyModified: locallyModified ?? this.locallyModified,
    conflictRemoteJson: conflictRemoteJson.present
        ? conflictRemoteJson.value
        : this.conflictRemoteJson,
    createdAt: createdAt ?? this.createdAt,
  );
  ShootSession copyWithCompanion(ShootSessionsCompanion data) {
    return ShootSession(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      date: data.date.present ? data.date.value : this.date,
      discipline: data.discipline.present
          ? data.discipline.value
          : this.discipline,
      sessionType: data.sessionType.present
          ? data.sessionType.value
          : this.sessionType,
      location: data.location.present ? data.location.value : this.location,
      rangeName: data.rangeName.present ? data.rangeName.value : this.rangeName,
      venueType: data.venueType.present ? data.venueType.value : this.venueType,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      firearmId: data.firearmId.present ? data.firearmId.value : this.firearmId,
      ammoLoadId: data.ammoLoadId.present
          ? data.ammoLoadId.value
          : this.ammoLoadId,
      equipmentIds: data.equipmentIds.present
          ? data.equipmentIds.value
          : this.equipmentIds,
      totalRounds: data.totalRounds.present
          ? data.totalRounds.value
          : this.totalRounds,
      totalHits: data.totalHits.present ? data.totalHits.value : this.totalHits,
      totalMisses: data.totalMisses.present
          ? data.totalMisses.value
          : this.totalMisses,
      totalScore: data.totalScore.present
          ? data.totalScore.value
          : this.totalScore,
      rating: data.rating.present ? data.rating.value : this.rating,
      notes: data.notes.present ? data.notes.value : this.notes,
      weatherCondition: data.weatherCondition.present
          ? data.weatherCondition.value
          : this.weatherCondition,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      windSpeed: data.windSpeed.present ? data.windSpeed.value : this.windSpeed,
      windDirection: data.windDirection.present
          ? data.windDirection.value
          : this.windDirection,
      humidity: data.humidity.present ? data.humidity.value : this.humidity,
      pressure: data.pressure.present ? data.pressure.value : this.pressure,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      voiceNotePath: data.voiceNotePath.present
          ? data.voiceNotePath.value
          : this.voiceNotePath,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      locallyModified: data.locallyModified.present
          ? data.locallyModified.value
          : this.locallyModified,
      conflictRemoteJson: data.conflictRemoteJson.present
          ? data.conflictRemoteJson.value
          : this.conflictRemoteJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShootSession(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('date: $date, ')
          ..write('discipline: $discipline, ')
          ..write('sessionType: $sessionType, ')
          ..write('location: $location, ')
          ..write('rangeName: $rangeName, ')
          ..write('venueType: $venueType, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('firearmId: $firearmId, ')
          ..write('ammoLoadId: $ammoLoadId, ')
          ..write('equipmentIds: $equipmentIds, ')
          ..write('totalRounds: $totalRounds, ')
          ..write('totalHits: $totalHits, ')
          ..write('totalMisses: $totalMisses, ')
          ..write('totalScore: $totalScore, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('weatherCondition: $weatherCondition, ')
          ..write('temperature: $temperature, ')
          ..write('windSpeed: $windSpeed, ')
          ..write('windDirection: $windDirection, ')
          ..write('humidity: $humidity, ')
          ..write('pressure: $pressure, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('eventId: $eventId, ')
          ..write('voiceNotePath: $voiceNotePath, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('locallyModified: $locallyModified, ')
          ..write('conflictRemoteJson: $conflictRemoteJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    serverId,
    date,
    discipline,
    sessionType,
    location,
    rangeName,
    venueType,
    latitude,
    longitude,
    firearmId,
    ammoLoadId,
    equipmentIds,
    totalRounds,
    totalHits,
    totalMisses,
    totalScore,
    rating,
    notes,
    weatherCondition,
    temperature,
    windSpeed,
    windDirection,
    humidity,
    pressure,
    syncStatus,
    eventId,
    voiceNotePath,
    serverUpdatedAt,
    locallyModified,
    conflictRemoteJson,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShootSession &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.date == this.date &&
          other.discipline == this.discipline &&
          other.sessionType == this.sessionType &&
          other.location == this.location &&
          other.rangeName == this.rangeName &&
          other.venueType == this.venueType &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.firearmId == this.firearmId &&
          other.ammoLoadId == this.ammoLoadId &&
          other.equipmentIds == this.equipmentIds &&
          other.totalRounds == this.totalRounds &&
          other.totalHits == this.totalHits &&
          other.totalMisses == this.totalMisses &&
          other.totalScore == this.totalScore &&
          other.rating == this.rating &&
          other.notes == this.notes &&
          other.weatherCondition == this.weatherCondition &&
          other.temperature == this.temperature &&
          other.windSpeed == this.windSpeed &&
          other.windDirection == this.windDirection &&
          other.humidity == this.humidity &&
          other.pressure == this.pressure &&
          other.syncStatus == this.syncStatus &&
          other.eventId == this.eventId &&
          other.voiceNotePath == this.voiceNotePath &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.locallyModified == this.locallyModified &&
          other.conflictRemoteJson == this.conflictRemoteJson &&
          other.createdAt == this.createdAt);
}

class ShootSessionsCompanion extends UpdateCompanion<ShootSession> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<DateTime> date;
  final Value<String> discipline;
  final Value<String> sessionType;
  final Value<String?> location;
  final Value<String?> rangeName;
  final Value<String?> venueType;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int?> firearmId;
  final Value<int?> ammoLoadId;
  final Value<String?> equipmentIds;
  final Value<int?> totalRounds;
  final Value<int?> totalHits;
  final Value<int?> totalMisses;
  final Value<double?> totalScore;
  final Value<int?> rating;
  final Value<String?> notes;
  final Value<String?> weatherCondition;
  final Value<double?> temperature;
  final Value<double?> windSpeed;
  final Value<String?> windDirection;
  final Value<double?> humidity;
  final Value<double?> pressure;
  final Value<String> syncStatus;
  final Value<int?> eventId;
  final Value<String?> voiceNotePath;
  final Value<DateTime?> serverUpdatedAt;
  final Value<bool> locallyModified;
  final Value<String?> conflictRemoteJson;
  final Value<DateTime> createdAt;
  const ShootSessionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.date = const Value.absent(),
    this.discipline = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.location = const Value.absent(),
    this.rangeName = const Value.absent(),
    this.venueType = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.firearmId = const Value.absent(),
    this.ammoLoadId = const Value.absent(),
    this.equipmentIds = const Value.absent(),
    this.totalRounds = const Value.absent(),
    this.totalHits = const Value.absent(),
    this.totalMisses = const Value.absent(),
    this.totalScore = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.weatherCondition = const Value.absent(),
    this.temperature = const Value.absent(),
    this.windSpeed = const Value.absent(),
    this.windDirection = const Value.absent(),
    this.humidity = const Value.absent(),
    this.pressure = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.eventId = const Value.absent(),
    this.voiceNotePath = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.locallyModified = const Value.absent(),
    this.conflictRemoteJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ShootSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required DateTime date,
    required String discipline,
    required String sessionType,
    this.location = const Value.absent(),
    this.rangeName = const Value.absent(),
    this.venueType = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.firearmId = const Value.absent(),
    this.ammoLoadId = const Value.absent(),
    this.equipmentIds = const Value.absent(),
    this.totalRounds = const Value.absent(),
    this.totalHits = const Value.absent(),
    this.totalMisses = const Value.absent(),
    this.totalScore = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.weatherCondition = const Value.absent(),
    this.temperature = const Value.absent(),
    this.windSpeed = const Value.absent(),
    this.windDirection = const Value.absent(),
    this.humidity = const Value.absent(),
    this.pressure = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.eventId = const Value.absent(),
    this.voiceNotePath = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.locallyModified = const Value.absent(),
    this.conflictRemoteJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : date = Value(date),
       discipline = Value(discipline),
       sessionType = Value(sessionType);
  static Insertable<ShootSession> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<DateTime>? date,
    Expression<String>? discipline,
    Expression<String>? sessionType,
    Expression<String>? location,
    Expression<String>? rangeName,
    Expression<String>? venueType,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? firearmId,
    Expression<int>? ammoLoadId,
    Expression<String>? equipmentIds,
    Expression<int>? totalRounds,
    Expression<int>? totalHits,
    Expression<int>? totalMisses,
    Expression<double>? totalScore,
    Expression<int>? rating,
    Expression<String>? notes,
    Expression<String>? weatherCondition,
    Expression<double>? temperature,
    Expression<double>? windSpeed,
    Expression<String>? windDirection,
    Expression<double>? humidity,
    Expression<double>? pressure,
    Expression<String>? syncStatus,
    Expression<int>? eventId,
    Expression<String>? voiceNotePath,
    Expression<DateTime>? serverUpdatedAt,
    Expression<bool>? locallyModified,
    Expression<String>? conflictRemoteJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (date != null) 'date': date,
      if (discipline != null) 'discipline': discipline,
      if (sessionType != null) 'session_type': sessionType,
      if (location != null) 'location': location,
      if (rangeName != null) 'range_name': rangeName,
      if (venueType != null) 'venue_type': venueType,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (firearmId != null) 'firearm_id': firearmId,
      if (ammoLoadId != null) 'ammo_load_id': ammoLoadId,
      if (equipmentIds != null) 'equipment_ids': equipmentIds,
      if (totalRounds != null) 'total_rounds': totalRounds,
      if (totalHits != null) 'total_hits': totalHits,
      if (totalMisses != null) 'total_misses': totalMisses,
      if (totalScore != null) 'total_score': totalScore,
      if (rating != null) 'rating': rating,
      if (notes != null) 'notes': notes,
      if (weatherCondition != null) 'weather_condition': weatherCondition,
      if (temperature != null) 'temperature': temperature,
      if (windSpeed != null) 'wind_speed': windSpeed,
      if (windDirection != null) 'wind_direction': windDirection,
      if (humidity != null) 'humidity': humidity,
      if (pressure != null) 'pressure': pressure,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (eventId != null) 'event_id': eventId,
      if (voiceNotePath != null) 'voice_note_path': voiceNotePath,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (locallyModified != null) 'locally_modified': locallyModified,
      if (conflictRemoteJson != null)
        'conflict_remote_json': conflictRemoteJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ShootSessionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<DateTime>? date,
    Value<String>? discipline,
    Value<String>? sessionType,
    Value<String?>? location,
    Value<String?>? rangeName,
    Value<String?>? venueType,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<int?>? firearmId,
    Value<int?>? ammoLoadId,
    Value<String?>? equipmentIds,
    Value<int?>? totalRounds,
    Value<int?>? totalHits,
    Value<int?>? totalMisses,
    Value<double?>? totalScore,
    Value<int?>? rating,
    Value<String?>? notes,
    Value<String?>? weatherCondition,
    Value<double?>? temperature,
    Value<double?>? windSpeed,
    Value<String?>? windDirection,
    Value<double?>? humidity,
    Value<double?>? pressure,
    Value<String>? syncStatus,
    Value<int?>? eventId,
    Value<String?>? voiceNotePath,
    Value<DateTime?>? serverUpdatedAt,
    Value<bool>? locallyModified,
    Value<String?>? conflictRemoteJson,
    Value<DateTime>? createdAt,
  }) {
    return ShootSessionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      date: date ?? this.date,
      discipline: discipline ?? this.discipline,
      sessionType: sessionType ?? this.sessionType,
      location: location ?? this.location,
      rangeName: rangeName ?? this.rangeName,
      venueType: venueType ?? this.venueType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      firearmId: firearmId ?? this.firearmId,
      ammoLoadId: ammoLoadId ?? this.ammoLoadId,
      equipmentIds: equipmentIds ?? this.equipmentIds,
      totalRounds: totalRounds ?? this.totalRounds,
      totalHits: totalHits ?? this.totalHits,
      totalMisses: totalMisses ?? this.totalMisses,
      totalScore: totalScore ?? this.totalScore,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      temperature: temperature ?? this.temperature,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      syncStatus: syncStatus ?? this.syncStatus,
      eventId: eventId ?? this.eventId,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      locallyModified: locallyModified ?? this.locallyModified,
      conflictRemoteJson: conflictRemoteJson ?? this.conflictRemoteJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (discipline.present) {
      map['discipline'] = Variable<String>(discipline.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<String>(sessionType.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (rangeName.present) {
      map['range_name'] = Variable<String>(rangeName.value);
    }
    if (venueType.present) {
      map['venue_type'] = Variable<String>(venueType.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (firearmId.present) {
      map['firearm_id'] = Variable<int>(firearmId.value);
    }
    if (ammoLoadId.present) {
      map['ammo_load_id'] = Variable<int>(ammoLoadId.value);
    }
    if (equipmentIds.present) {
      map['equipment_ids'] = Variable<String>(equipmentIds.value);
    }
    if (totalRounds.present) {
      map['total_rounds'] = Variable<int>(totalRounds.value);
    }
    if (totalHits.present) {
      map['total_hits'] = Variable<int>(totalHits.value);
    }
    if (totalMisses.present) {
      map['total_misses'] = Variable<int>(totalMisses.value);
    }
    if (totalScore.present) {
      map['total_score'] = Variable<double>(totalScore.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (weatherCondition.present) {
      map['weather_condition'] = Variable<String>(weatherCondition.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (windSpeed.present) {
      map['wind_speed'] = Variable<double>(windSpeed.value);
    }
    if (windDirection.present) {
      map['wind_direction'] = Variable<String>(windDirection.value);
    }
    if (humidity.present) {
      map['humidity'] = Variable<double>(humidity.value);
    }
    if (pressure.present) {
      map['pressure'] = Variable<double>(pressure.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (voiceNotePath.present) {
      map['voice_note_path'] = Variable<String>(voiceNotePath.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (locallyModified.present) {
      map['locally_modified'] = Variable<bool>(locallyModified.value);
    }
    if (conflictRemoteJson.present) {
      map['conflict_remote_json'] = Variable<String>(conflictRemoteJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShootSessionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('date: $date, ')
          ..write('discipline: $discipline, ')
          ..write('sessionType: $sessionType, ')
          ..write('location: $location, ')
          ..write('rangeName: $rangeName, ')
          ..write('venueType: $venueType, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('firearmId: $firearmId, ')
          ..write('ammoLoadId: $ammoLoadId, ')
          ..write('equipmentIds: $equipmentIds, ')
          ..write('totalRounds: $totalRounds, ')
          ..write('totalHits: $totalHits, ')
          ..write('totalMisses: $totalMisses, ')
          ..write('totalScore: $totalScore, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('weatherCondition: $weatherCondition, ')
          ..write('temperature: $temperature, ')
          ..write('windSpeed: $windSpeed, ')
          ..write('windDirection: $windDirection, ')
          ..write('humidity: $humidity, ')
          ..write('pressure: $pressure, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('eventId: $eventId, ')
          ..write('voiceNotePath: $voiceNotePath, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('locallyModified: $locallyModified, ')
          ..write('conflictRemoteJson: $conflictRemoteJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ShootEntriesTable extends ShootEntries
    with TableInfo<$ShootEntriesTable, ShootEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShootEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shoot_sessions (id)',
    ),
  );
  static const VerificationMeta _firearmIdMeta = const VerificationMeta(
    'firearmId',
  );
  @override
  late final GeneratedColumn<int> firearmId = GeneratedColumn<int>(
    'firearm_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ammoLoadIdMeta = const VerificationMeta(
    'ammoLoadId',
  );
  @override
  late final GeneratedColumn<int> ammoLoadId = GeneratedColumn<int>(
    'ammo_load_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMeta = const VerificationMeta(
    'distance',
  );
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
    'distance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roundsFiredMeta = const VerificationMeta(
    'roundsFired',
  );
  @override
  late final GeneratedColumn<int> roundsFired = GeneratedColumn<int>(
    'rounds_fired',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hitsMeta = const VerificationMeta('hits');
  @override
  late final GeneratedColumn<int> hits = GeneratedColumn<int>(
    'hits',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _missesMeta = const VerificationMeta('misses');
  @override
  late final GeneratedColumn<int> misses = GeneratedColumn<int>(
    'misses',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupSizeMeta = const VerificationMeta(
    'groupSize',
  );
  @override
  late final GeneratedColumn<double> groupSize = GeneratedColumn<double>(
    'group_size',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stageNameMeta = const VerificationMeta(
    'stageName',
  );
  @override
  late final GeneratedColumn<String> stageName = GeneratedColumn<String>(
    'stage_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    firearmId,
    ammoLoadId,
    distance,
    roundsFired,
    hits,
    misses,
    groupSize,
    score,
    stageName,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shoot_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShootEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('firearm_id')) {
      context.handle(
        _firearmIdMeta,
        firearmId.isAcceptableOrUnknown(data['firearm_id']!, _firearmIdMeta),
      );
    }
    if (data.containsKey('ammo_load_id')) {
      context.handle(
        _ammoLoadIdMeta,
        ammoLoadId.isAcceptableOrUnknown(
          data['ammo_load_id']!,
          _ammoLoadIdMeta,
        ),
      );
    }
    if (data.containsKey('distance')) {
      context.handle(
        _distanceMeta,
        distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta),
      );
    }
    if (data.containsKey('rounds_fired')) {
      context.handle(
        _roundsFiredMeta,
        roundsFired.isAcceptableOrUnknown(
          data['rounds_fired']!,
          _roundsFiredMeta,
        ),
      );
    }
    if (data.containsKey('hits')) {
      context.handle(
        _hitsMeta,
        hits.isAcceptableOrUnknown(data['hits']!, _hitsMeta),
      );
    }
    if (data.containsKey('misses')) {
      context.handle(
        _missesMeta,
        misses.isAcceptableOrUnknown(data['misses']!, _missesMeta),
      );
    }
    if (data.containsKey('group_size')) {
      context.handle(
        _groupSizeMeta,
        groupSize.isAcceptableOrUnknown(data['group_size']!, _groupSizeMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('stage_name')) {
      context.handle(
        _stageNameMeta,
        stageName.isAcceptableOrUnknown(data['stage_name']!, _stageNameMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShootEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShootEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      firearmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}firearm_id'],
      ),
      ammoLoadId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ammo_load_id'],
      ),
      distance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance'],
      ),
      roundsFired: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds_fired'],
      ),
      hits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hits'],
      ),
      misses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}misses'],
      ),
      groupSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}group_size'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      ),
      stageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_name'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ShootEntriesTable createAlias(String alias) {
    return $ShootEntriesTable(attachedDatabase, alias);
  }
}

class ShootEntry extends DataClass implements Insertable<ShootEntry> {
  final int id;
  final int sessionId;
  final int? firearmId;
  final int? ammoLoadId;
  final double? distance;
  final int? roundsFired;
  final int? hits;
  final int? misses;
  final double? groupSize;
  final double? score;
  final String? stageName;
  final String? notes;
  const ShootEntry({
    required this.id,
    required this.sessionId,
    this.firearmId,
    this.ammoLoadId,
    this.distance,
    this.roundsFired,
    this.hits,
    this.misses,
    this.groupSize,
    this.score,
    this.stageName,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || firearmId != null) {
      map['firearm_id'] = Variable<int>(firearmId);
    }
    if (!nullToAbsent || ammoLoadId != null) {
      map['ammo_load_id'] = Variable<int>(ammoLoadId);
    }
    if (!nullToAbsent || distance != null) {
      map['distance'] = Variable<double>(distance);
    }
    if (!nullToAbsent || roundsFired != null) {
      map['rounds_fired'] = Variable<int>(roundsFired);
    }
    if (!nullToAbsent || hits != null) {
      map['hits'] = Variable<int>(hits);
    }
    if (!nullToAbsent || misses != null) {
      map['misses'] = Variable<int>(misses);
    }
    if (!nullToAbsent || groupSize != null) {
      map['group_size'] = Variable<double>(groupSize);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<double>(score);
    }
    if (!nullToAbsent || stageName != null) {
      map['stage_name'] = Variable<String>(stageName);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ShootEntriesCompanion toCompanion(bool nullToAbsent) {
    return ShootEntriesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      firearmId: firearmId == null && nullToAbsent
          ? const Value.absent()
          : Value(firearmId),
      ammoLoadId: ammoLoadId == null && nullToAbsent
          ? const Value.absent()
          : Value(ammoLoadId),
      distance: distance == null && nullToAbsent
          ? const Value.absent()
          : Value(distance),
      roundsFired: roundsFired == null && nullToAbsent
          ? const Value.absent()
          : Value(roundsFired),
      hits: hits == null && nullToAbsent ? const Value.absent() : Value(hits),
      misses: misses == null && nullToAbsent
          ? const Value.absent()
          : Value(misses),
      groupSize: groupSize == null && nullToAbsent
          ? const Value.absent()
          : Value(groupSize),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      stageName: stageName == null && nullToAbsent
          ? const Value.absent()
          : Value(stageName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory ShootEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShootEntry(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      firearmId: serializer.fromJson<int?>(json['firearmId']),
      ammoLoadId: serializer.fromJson<int?>(json['ammoLoadId']),
      distance: serializer.fromJson<double?>(json['distance']),
      roundsFired: serializer.fromJson<int?>(json['roundsFired']),
      hits: serializer.fromJson<int?>(json['hits']),
      misses: serializer.fromJson<int?>(json['misses']),
      groupSize: serializer.fromJson<double?>(json['groupSize']),
      score: serializer.fromJson<double?>(json['score']),
      stageName: serializer.fromJson<String?>(json['stageName']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'firearmId': serializer.toJson<int?>(firearmId),
      'ammoLoadId': serializer.toJson<int?>(ammoLoadId),
      'distance': serializer.toJson<double?>(distance),
      'roundsFired': serializer.toJson<int?>(roundsFired),
      'hits': serializer.toJson<int?>(hits),
      'misses': serializer.toJson<int?>(misses),
      'groupSize': serializer.toJson<double?>(groupSize),
      'score': serializer.toJson<double?>(score),
      'stageName': serializer.toJson<String?>(stageName),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ShootEntry copyWith({
    int? id,
    int? sessionId,
    Value<int?> firearmId = const Value.absent(),
    Value<int?> ammoLoadId = const Value.absent(),
    Value<double?> distance = const Value.absent(),
    Value<int?> roundsFired = const Value.absent(),
    Value<int?> hits = const Value.absent(),
    Value<int?> misses = const Value.absent(),
    Value<double?> groupSize = const Value.absent(),
    Value<double?> score = const Value.absent(),
    Value<String?> stageName = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => ShootEntry(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    firearmId: firearmId.present ? firearmId.value : this.firearmId,
    ammoLoadId: ammoLoadId.present ? ammoLoadId.value : this.ammoLoadId,
    distance: distance.present ? distance.value : this.distance,
    roundsFired: roundsFired.present ? roundsFired.value : this.roundsFired,
    hits: hits.present ? hits.value : this.hits,
    misses: misses.present ? misses.value : this.misses,
    groupSize: groupSize.present ? groupSize.value : this.groupSize,
    score: score.present ? score.value : this.score,
    stageName: stageName.present ? stageName.value : this.stageName,
    notes: notes.present ? notes.value : this.notes,
  );
  ShootEntry copyWithCompanion(ShootEntriesCompanion data) {
    return ShootEntry(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      firearmId: data.firearmId.present ? data.firearmId.value : this.firearmId,
      ammoLoadId: data.ammoLoadId.present
          ? data.ammoLoadId.value
          : this.ammoLoadId,
      distance: data.distance.present ? data.distance.value : this.distance,
      roundsFired: data.roundsFired.present
          ? data.roundsFired.value
          : this.roundsFired,
      hits: data.hits.present ? data.hits.value : this.hits,
      misses: data.misses.present ? data.misses.value : this.misses,
      groupSize: data.groupSize.present ? data.groupSize.value : this.groupSize,
      score: data.score.present ? data.score.value : this.score,
      stageName: data.stageName.present ? data.stageName.value : this.stageName,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShootEntry(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('firearmId: $firearmId, ')
          ..write('ammoLoadId: $ammoLoadId, ')
          ..write('distance: $distance, ')
          ..write('roundsFired: $roundsFired, ')
          ..write('hits: $hits, ')
          ..write('misses: $misses, ')
          ..write('groupSize: $groupSize, ')
          ..write('score: $score, ')
          ..write('stageName: $stageName, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    firearmId,
    ammoLoadId,
    distance,
    roundsFired,
    hits,
    misses,
    groupSize,
    score,
    stageName,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShootEntry &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.firearmId == this.firearmId &&
          other.ammoLoadId == this.ammoLoadId &&
          other.distance == this.distance &&
          other.roundsFired == this.roundsFired &&
          other.hits == this.hits &&
          other.misses == this.misses &&
          other.groupSize == this.groupSize &&
          other.score == this.score &&
          other.stageName == this.stageName &&
          other.notes == this.notes);
}

class ShootEntriesCompanion extends UpdateCompanion<ShootEntry> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int?> firearmId;
  final Value<int?> ammoLoadId;
  final Value<double?> distance;
  final Value<int?> roundsFired;
  final Value<int?> hits;
  final Value<int?> misses;
  final Value<double?> groupSize;
  final Value<double?> score;
  final Value<String?> stageName;
  final Value<String?> notes;
  const ShootEntriesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.firearmId = const Value.absent(),
    this.ammoLoadId = const Value.absent(),
    this.distance = const Value.absent(),
    this.roundsFired = const Value.absent(),
    this.hits = const Value.absent(),
    this.misses = const Value.absent(),
    this.groupSize = const Value.absent(),
    this.score = const Value.absent(),
    this.stageName = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ShootEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    this.firearmId = const Value.absent(),
    this.ammoLoadId = const Value.absent(),
    this.distance = const Value.absent(),
    this.roundsFired = const Value.absent(),
    this.hits = const Value.absent(),
    this.misses = const Value.absent(),
    this.groupSize = const Value.absent(),
    this.score = const Value.absent(),
    this.stageName = const Value.absent(),
    this.notes = const Value.absent(),
  }) : sessionId = Value(sessionId);
  static Insertable<ShootEntry> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? firearmId,
    Expression<int>? ammoLoadId,
    Expression<double>? distance,
    Expression<int>? roundsFired,
    Expression<int>? hits,
    Expression<int>? misses,
    Expression<double>? groupSize,
    Expression<double>? score,
    Expression<String>? stageName,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (firearmId != null) 'firearm_id': firearmId,
      if (ammoLoadId != null) 'ammo_load_id': ammoLoadId,
      if (distance != null) 'distance': distance,
      if (roundsFired != null) 'rounds_fired': roundsFired,
      if (hits != null) 'hits': hits,
      if (misses != null) 'misses': misses,
      if (groupSize != null) 'group_size': groupSize,
      if (score != null) 'score': score,
      if (stageName != null) 'stage_name': stageName,
      if (notes != null) 'notes': notes,
    });
  }

  ShootEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int?>? firearmId,
    Value<int?>? ammoLoadId,
    Value<double?>? distance,
    Value<int?>? roundsFired,
    Value<int?>? hits,
    Value<int?>? misses,
    Value<double?>? groupSize,
    Value<double?>? score,
    Value<String?>? stageName,
    Value<String?>? notes,
  }) {
    return ShootEntriesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      firearmId: firearmId ?? this.firearmId,
      ammoLoadId: ammoLoadId ?? this.ammoLoadId,
      distance: distance ?? this.distance,
      roundsFired: roundsFired ?? this.roundsFired,
      hits: hits ?? this.hits,
      misses: misses ?? this.misses,
      groupSize: groupSize ?? this.groupSize,
      score: score ?? this.score,
      stageName: stageName ?? this.stageName,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (firearmId.present) {
      map['firearm_id'] = Variable<int>(firearmId.value);
    }
    if (ammoLoadId.present) {
      map['ammo_load_id'] = Variable<int>(ammoLoadId.value);
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (roundsFired.present) {
      map['rounds_fired'] = Variable<int>(roundsFired.value);
    }
    if (hits.present) {
      map['hits'] = Variable<int>(hits.value);
    }
    if (misses.present) {
      map['misses'] = Variable<int>(misses.value);
    }
    if (groupSize.present) {
      map['group_size'] = Variable<double>(groupSize.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (stageName.present) {
      map['stage_name'] = Variable<String>(stageName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShootEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('firearmId: $firearmId, ')
          ..write('ammoLoadId: $ammoLoadId, ')
          ..write('distance: $distance, ')
          ..write('roundsFired: $roundsFired, ')
          ..write('hits: $hits, ')
          ..write('misses: $misses, ')
          ..write('groupSize: $groupSize, ')
          ..write('score: $score, ')
          ..write('stageName: $stageName, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $PendingSessionPhotosTable extends PendingSessionPhotos
    with TableInfo<$PendingSessionPhotosTable, PendingSessionPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSessionPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _localSessionIdMeta = const VerificationMeta(
    'localSessionId',
  );
  @override
  late final GeneratedColumn<int> localSessionId = GeneratedColumn<int>(
    'local_session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shoot_sessions (id)',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoTypeMeta = const VerificationMeta(
    'photoType',
  );
  @override
  late final GeneratedColumn<String> photoType = GeneratedColumn<String>(
    'photo_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localSessionId,
    filePath,
    photoType,
    fileName,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_session_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingSessionPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_session_id')) {
      context.handle(
        _localSessionIdMeta,
        localSessionId.isAcceptableOrUnknown(
          data['local_session_id']!,
          _localSessionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localSessionIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('photo_type')) {
      context.handle(
        _photoTypeMeta,
        photoType.isAcceptableOrUnknown(data['photo_type']!, _photoTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_photoTypeMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSessionPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSessionPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_session_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      photoType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_type'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingSessionPhotosTable createAlias(String alias) {
    return $PendingSessionPhotosTable(attachedDatabase, alias);
  }
}

class PendingSessionPhoto extends DataClass
    implements Insertable<PendingSessionPhoto> {
  final int id;
  final int localSessionId;
  final String filePath;
  final String photoType;
  final String fileName;
  final DateTime createdAt;
  const PendingSessionPhoto({
    required this.id,
    required this.localSessionId,
    required this.filePath,
    required this.photoType,
    required this.fileName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['local_session_id'] = Variable<int>(localSessionId);
    map['file_path'] = Variable<String>(filePath);
    map['photo_type'] = Variable<String>(photoType);
    map['file_name'] = Variable<String>(fileName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingSessionPhotosCompanion toCompanion(bool nullToAbsent) {
    return PendingSessionPhotosCompanion(
      id: Value(id),
      localSessionId: Value(localSessionId),
      filePath: Value(filePath),
      photoType: Value(photoType),
      fileName: Value(fileName),
      createdAt: Value(createdAt),
    );
  }

  factory PendingSessionPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSessionPhoto(
      id: serializer.fromJson<int>(json['id']),
      localSessionId: serializer.fromJson<int>(json['localSessionId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      photoType: serializer.fromJson<String>(json['photoType']),
      fileName: serializer.fromJson<String>(json['fileName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localSessionId': serializer.toJson<int>(localSessionId),
      'filePath': serializer.toJson<String>(filePath),
      'photoType': serializer.toJson<String>(photoType),
      'fileName': serializer.toJson<String>(fileName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingSessionPhoto copyWith({
    int? id,
    int? localSessionId,
    String? filePath,
    String? photoType,
    String? fileName,
    DateTime? createdAt,
  }) => PendingSessionPhoto(
    id: id ?? this.id,
    localSessionId: localSessionId ?? this.localSessionId,
    filePath: filePath ?? this.filePath,
    photoType: photoType ?? this.photoType,
    fileName: fileName ?? this.fileName,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingSessionPhoto copyWithCompanion(PendingSessionPhotosCompanion data) {
    return PendingSessionPhoto(
      id: data.id.present ? data.id.value : this.id,
      localSessionId: data.localSessionId.present
          ? data.localSessionId.value
          : this.localSessionId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      photoType: data.photoType.present ? data.photoType.value : this.photoType,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSessionPhoto(')
          ..write('id: $id, ')
          ..write('localSessionId: $localSessionId, ')
          ..write('filePath: $filePath, ')
          ..write('photoType: $photoType, ')
          ..write('fileName: $fileName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, localSessionId, filePath, photoType, fileName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSessionPhoto &&
          other.id == this.id &&
          other.localSessionId == this.localSessionId &&
          other.filePath == this.filePath &&
          other.photoType == this.photoType &&
          other.fileName == this.fileName &&
          other.createdAt == this.createdAt);
}

class PendingSessionPhotosCompanion
    extends UpdateCompanion<PendingSessionPhoto> {
  final Value<int> id;
  final Value<int> localSessionId;
  final Value<String> filePath;
  final Value<String> photoType;
  final Value<String> fileName;
  final Value<DateTime> createdAt;
  const PendingSessionPhotosCompanion({
    this.id = const Value.absent(),
    this.localSessionId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.photoType = const Value.absent(),
    this.fileName = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingSessionPhotosCompanion.insert({
    this.id = const Value.absent(),
    required int localSessionId,
    required String filePath,
    required String photoType,
    required String fileName,
    this.createdAt = const Value.absent(),
  }) : localSessionId = Value(localSessionId),
       filePath = Value(filePath),
       photoType = Value(photoType),
       fileName = Value(fileName);
  static Insertable<PendingSessionPhoto> custom({
    Expression<int>? id,
    Expression<int>? localSessionId,
    Expression<String>? filePath,
    Expression<String>? photoType,
    Expression<String>? fileName,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localSessionId != null) 'local_session_id': localSessionId,
      if (filePath != null) 'file_path': filePath,
      if (photoType != null) 'photo_type': photoType,
      if (fileName != null) 'file_name': fileName,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingSessionPhotosCompanion copyWith({
    Value<int>? id,
    Value<int>? localSessionId,
    Value<String>? filePath,
    Value<String>? photoType,
    Value<String>? fileName,
    Value<DateTime>? createdAt,
  }) {
    return PendingSessionPhotosCompanion(
      id: id ?? this.id,
      localSessionId: localSessionId ?? this.localSessionId,
      filePath: filePath ?? this.filePath,
      photoType: photoType ?? this.photoType,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localSessionId.present) {
      map['local_session_id'] = Variable<int>(localSessionId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (photoType.present) {
      map['photo_type'] = Variable<String>(photoType.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSessionPhotosCompanion(')
          ..write('id: $id, ')
          ..write('localSessionId: $localSessionId, ')
          ..write('filePath: $filePath, ')
          ..write('photoType: $photoType, ')
          ..write('fileName: $fileName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CachedFirearmsTable extends CachedFirearms
    with TableInfo<$CachedFirearmsTable, CachedFirearm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedFirearmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
    'make',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calibreMeta = const VerificationMeta(
    'calibre',
  );
  @override
  late final GeneratedColumn<String> calibre = GeneratedColumn<String>(
    'calibre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serialNumberMeta = const VerificationMeta(
    'serialNumber',
  );
  @override
  late final GeneratedColumn<String> serialNumber = GeneratedColumn<String>(
    'serial_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    make,
    model,
    calibre,
    serialNumber,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_firearms';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedFirearm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    } else if (isInserting) {
      context.missing(_makeMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('calibre')) {
      context.handle(
        _calibreMeta,
        calibre.isAcceptableOrUnknown(data['calibre']!, _calibreMeta),
      );
    }
    if (data.containsKey('serial_number')) {
      context.handle(
        _serialNumberMeta,
        serialNumber.isAcceptableOrUnknown(
          data['serial_number']!,
          _serialNumberMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedFirearm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFirearm(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      calibre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calibre'],
      ),
      serialNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_number'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CachedFirearmsTable createAlias(String alias) {
    return $CachedFirearmsTable(attachedDatabase, alias);
  }
}

class CachedFirearm extends DataClass implements Insertable<CachedFirearm> {
  final int id;
  final String name;
  final String make;
  final String model;
  final String? calibre;
  final String? serialNumber;
  final String? notes;
  const CachedFirearm({
    required this.id,
    required this.name,
    required this.make,
    required this.model,
    this.calibre,
    this.serialNumber,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['make'] = Variable<String>(make);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || calibre != null) {
      map['calibre'] = Variable<String>(calibre);
    }
    if (!nullToAbsent || serialNumber != null) {
      map['serial_number'] = Variable<String>(serialNumber);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CachedFirearmsCompanion toCompanion(bool nullToAbsent) {
    return CachedFirearmsCompanion(
      id: Value(id),
      name: Value(name),
      make: Value(make),
      model: Value(model),
      calibre: calibre == null && nullToAbsent
          ? const Value.absent()
          : Value(calibre),
      serialNumber: serialNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(serialNumber),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CachedFirearm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFirearm(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      make: serializer.fromJson<String>(json['make']),
      model: serializer.fromJson<String>(json['model']),
      calibre: serializer.fromJson<String?>(json['calibre']),
      serialNumber: serializer.fromJson<String?>(json['serialNumber']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'make': serializer.toJson<String>(make),
      'model': serializer.toJson<String>(model),
      'calibre': serializer.toJson<String?>(calibre),
      'serialNumber': serializer.toJson<String?>(serialNumber),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CachedFirearm copyWith({
    int? id,
    String? name,
    String? make,
    String? model,
    Value<String?> calibre = const Value.absent(),
    Value<String?> serialNumber = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => CachedFirearm(
    id: id ?? this.id,
    name: name ?? this.name,
    make: make ?? this.make,
    model: model ?? this.model,
    calibre: calibre.present ? calibre.value : this.calibre,
    serialNumber: serialNumber.present ? serialNumber.value : this.serialNumber,
    notes: notes.present ? notes.value : this.notes,
  );
  CachedFirearm copyWithCompanion(CachedFirearmsCompanion data) {
    return CachedFirearm(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      calibre: data.calibre.present ? data.calibre.value : this.calibre,
      serialNumber: data.serialNumber.present
          ? data.serialNumber.value
          : this.serialNumber,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFirearm(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('calibre: $calibre, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, make, model, calibre, serialNumber, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFirearm &&
          other.id == this.id &&
          other.name == this.name &&
          other.make == this.make &&
          other.model == this.model &&
          other.calibre == this.calibre &&
          other.serialNumber == this.serialNumber &&
          other.notes == this.notes);
}

class CachedFirearmsCompanion extends UpdateCompanion<CachedFirearm> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> make;
  final Value<String> model;
  final Value<String?> calibre;
  final Value<String?> serialNumber;
  final Value<String?> notes;
  const CachedFirearmsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.calibre = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.notes = const Value.absent(),
  });
  CachedFirearmsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String make,
    required String model,
    this.calibre = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.notes = const Value.absent(),
  }) : name = Value(name),
       make = Value(make),
       model = Value(model);
  static Insertable<CachedFirearm> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? make,
    Expression<String>? model,
    Expression<String>? calibre,
    Expression<String>? serialNumber,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (calibre != null) 'calibre': calibre,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (notes != null) 'notes': notes,
    });
  }

  CachedFirearmsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? make,
    Value<String>? model,
    Value<String?>? calibre,
    Value<String?>? serialNumber,
    Value<String?>? notes,
  }) {
    return CachedFirearmsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      calibre: calibre ?? this.calibre,
      serialNumber: serialNumber ?? this.serialNumber,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (calibre.present) {
      map['calibre'] = Variable<String>(calibre.value);
    }
    if (serialNumber.present) {
      map['serial_number'] = Variable<String>(serialNumber.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedFirearmsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('calibre: $calibre, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $CachedAmmoLoadsTable extends CachedAmmoLoads
    with TableInfo<$CachedAmmoLoadsTable, CachedAmmoLoad> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAmmoLoadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calibreMeta = const VerificationMeta(
    'calibre',
  );
  @override
  late final GeneratedColumn<String> calibre = GeneratedColumn<String>(
    'calibre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bulletWeightMeta = const VerificationMeta(
    'bulletWeight',
  );
  @override
  late final GeneratedColumn<double> bulletWeight = GeneratedColumn<double>(
    'bullet_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _powderChargeMeta = const VerificationMeta(
    'powderCharge',
  );
  @override
  late final GeneratedColumn<double> powderCharge = GeneratedColumn<double>(
    'powder_charge',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    calibre,
    manufacturer,
    bulletWeight,
    powderCharge,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_ammo_loads';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedAmmoLoad> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('calibre')) {
      context.handle(
        _calibreMeta,
        calibre.isAcceptableOrUnknown(data['calibre']!, _calibreMeta),
      );
    } else if (isInserting) {
      context.missing(_calibreMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('bullet_weight')) {
      context.handle(
        _bulletWeightMeta,
        bulletWeight.isAcceptableOrUnknown(
          data['bullet_weight']!,
          _bulletWeightMeta,
        ),
      );
    }
    if (data.containsKey('powder_charge')) {
      context.handle(
        _powderChargeMeta,
        powderCharge.isAcceptableOrUnknown(
          data['powder_charge']!,
          _powderChargeMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAmmoLoad map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAmmoLoad(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      calibre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calibre'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      bulletWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bullet_weight'],
      ),
      powderCharge: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}powder_charge'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CachedAmmoLoadsTable createAlias(String alias) {
    return $CachedAmmoLoadsTable(attachedDatabase, alias);
  }
}

class CachedAmmoLoad extends DataClass implements Insertable<CachedAmmoLoad> {
  final int id;
  final String name;
  final String calibre;
  final String? manufacturer;
  final double? bulletWeight;
  final double? powderCharge;
  final String? notes;
  const CachedAmmoLoad({
    required this.id,
    required this.name,
    required this.calibre,
    this.manufacturer,
    this.bulletWeight,
    this.powderCharge,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['calibre'] = Variable<String>(calibre);
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || bulletWeight != null) {
      map['bullet_weight'] = Variable<double>(bulletWeight);
    }
    if (!nullToAbsent || powderCharge != null) {
      map['powder_charge'] = Variable<double>(powderCharge);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CachedAmmoLoadsCompanion toCompanion(bool nullToAbsent) {
    return CachedAmmoLoadsCompanion(
      id: Value(id),
      name: Value(name),
      calibre: Value(calibre),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      bulletWeight: bulletWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(bulletWeight),
      powderCharge: powderCharge == null && nullToAbsent
          ? const Value.absent()
          : Value(powderCharge),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CachedAmmoLoad.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAmmoLoad(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      calibre: serializer.fromJson<String>(json['calibre']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      bulletWeight: serializer.fromJson<double?>(json['bulletWeight']),
      powderCharge: serializer.fromJson<double?>(json['powderCharge']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'calibre': serializer.toJson<String>(calibre),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'bulletWeight': serializer.toJson<double?>(bulletWeight),
      'powderCharge': serializer.toJson<double?>(powderCharge),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CachedAmmoLoad copyWith({
    int? id,
    String? name,
    String? calibre,
    Value<String?> manufacturer = const Value.absent(),
    Value<double?> bulletWeight = const Value.absent(),
    Value<double?> powderCharge = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => CachedAmmoLoad(
    id: id ?? this.id,
    name: name ?? this.name,
    calibre: calibre ?? this.calibre,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    bulletWeight: bulletWeight.present ? bulletWeight.value : this.bulletWeight,
    powderCharge: powderCharge.present ? powderCharge.value : this.powderCharge,
    notes: notes.present ? notes.value : this.notes,
  );
  CachedAmmoLoad copyWithCompanion(CachedAmmoLoadsCompanion data) {
    return CachedAmmoLoad(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      calibre: data.calibre.present ? data.calibre.value : this.calibre,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      bulletWeight: data.bulletWeight.present
          ? data.bulletWeight.value
          : this.bulletWeight,
      powderCharge: data.powderCharge.present
          ? data.powderCharge.value
          : this.powderCharge,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAmmoLoad(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('calibre: $calibre, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('bulletWeight: $bulletWeight, ')
          ..write('powderCharge: $powderCharge, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    calibre,
    manufacturer,
    bulletWeight,
    powderCharge,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAmmoLoad &&
          other.id == this.id &&
          other.name == this.name &&
          other.calibre == this.calibre &&
          other.manufacturer == this.manufacturer &&
          other.bulletWeight == this.bulletWeight &&
          other.powderCharge == this.powderCharge &&
          other.notes == this.notes);
}

class CachedAmmoLoadsCompanion extends UpdateCompanion<CachedAmmoLoad> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> calibre;
  final Value<String?> manufacturer;
  final Value<double?> bulletWeight;
  final Value<double?> powderCharge;
  final Value<String?> notes;
  const CachedAmmoLoadsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.calibre = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.bulletWeight = const Value.absent(),
    this.powderCharge = const Value.absent(),
    this.notes = const Value.absent(),
  });
  CachedAmmoLoadsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String calibre,
    this.manufacturer = const Value.absent(),
    this.bulletWeight = const Value.absent(),
    this.powderCharge = const Value.absent(),
    this.notes = const Value.absent(),
  }) : name = Value(name),
       calibre = Value(calibre);
  static Insertable<CachedAmmoLoad> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? calibre,
    Expression<String>? manufacturer,
    Expression<double>? bulletWeight,
    Expression<double>? powderCharge,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (calibre != null) 'calibre': calibre,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (bulletWeight != null) 'bullet_weight': bulletWeight,
      if (powderCharge != null) 'powder_charge': powderCharge,
      if (notes != null) 'notes': notes,
    });
  }

  CachedAmmoLoadsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? calibre,
    Value<String?>? manufacturer,
    Value<double?>? bulletWeight,
    Value<double?>? powderCharge,
    Value<String?>? notes,
  }) {
    return CachedAmmoLoadsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      calibre: calibre ?? this.calibre,
      manufacturer: manufacturer ?? this.manufacturer,
      bulletWeight: bulletWeight ?? this.bulletWeight,
      powderCharge: powderCharge ?? this.powderCharge,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (calibre.present) {
      map['calibre'] = Variable<String>(calibre.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (bulletWeight.present) {
      map['bullet_weight'] = Variable<double>(bulletWeight.value);
    }
    if (powderCharge.present) {
      map['powder_charge'] = Variable<double>(powderCharge.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAmmoLoadsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('calibre: $calibre, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('bulletWeight: $bulletWeight, ')
          ..write('powderCharge: $powderCharge, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $CachedEquipmentTable extends CachedEquipment
    with TableInfo<$CachedEquipmentTable, CachedEquipmentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedEquipmentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firearmIdMeta = const VerificationMeta(
    'firearmId',
  );
  @override
  late final GeneratedColumn<int> firearmId = GeneratedColumn<int>(
    'firearm_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    brand,
    model,
    firearmId,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_equipment';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedEquipmentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('firearm_id')) {
      context.handle(
        _firearmIdMeta,
        firearmId.isAcceptableOrUnknown(data['firearm_id']!, _firearmIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedEquipmentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedEquipmentData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      firearmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}firearm_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CachedEquipmentTable createAlias(String alias) {
    return $CachedEquipmentTable(attachedDatabase, alias);
  }
}

class CachedEquipmentData extends DataClass
    implements Insertable<CachedEquipmentData> {
  final int id;
  final String name;
  final String? category;
  final String? brand;
  final String? model;
  final int? firearmId;
  final String? notes;
  const CachedEquipmentData({
    required this.id,
    required this.name,
    this.category,
    this.brand,
    this.model,
    this.firearmId,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || firearmId != null) {
      map['firearm_id'] = Variable<int>(firearmId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CachedEquipmentCompanion toCompanion(bool nullToAbsent) {
    return CachedEquipmentCompanion(
      id: Value(id),
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      firearmId: firearmId == null && nullToAbsent
          ? const Value.absent()
          : Value(firearmId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CachedEquipmentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedEquipmentData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String?>(json['category']),
      brand: serializer.fromJson<String?>(json['brand']),
      model: serializer.fromJson<String?>(json['model']),
      firearmId: serializer.fromJson<int?>(json['firearmId']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String?>(category),
      'brand': serializer.toJson<String?>(brand),
      'model': serializer.toJson<String?>(model),
      'firearmId': serializer.toJson<int?>(firearmId),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CachedEquipmentData copyWith({
    int? id,
    String? name,
    Value<String?> category = const Value.absent(),
    Value<String?> brand = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<int?> firearmId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => CachedEquipmentData(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category.present ? category.value : this.category,
    brand: brand.present ? brand.value : this.brand,
    model: model.present ? model.value : this.model,
    firearmId: firearmId.present ? firearmId.value : this.firearmId,
    notes: notes.present ? notes.value : this.notes,
  );
  CachedEquipmentData copyWithCompanion(CachedEquipmentCompanion data) {
    return CachedEquipmentData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      firearmId: data.firearmId.present ? data.firearmId.value : this.firearmId,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedEquipmentData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('firearmId: $firearmId, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, category, brand, model, firearmId, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedEquipmentData &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.firearmId == this.firearmId &&
          other.notes == this.notes);
}

class CachedEquipmentCompanion extends UpdateCompanion<CachedEquipmentData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> category;
  final Value<String?> brand;
  final Value<String?> model;
  final Value<int?> firearmId;
  final Value<String?> notes;
  const CachedEquipmentCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.firearmId = const Value.absent(),
    this.notes = const Value.absent(),
  });
  CachedEquipmentCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.firearmId = const Value.absent(),
    this.notes = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CachedEquipmentData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<int>? firearmId,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (firearmId != null) 'firearm_id': firearmId,
      if (notes != null) 'notes': notes,
    });
  }

  CachedEquipmentCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? category,
    Value<String?>? brand,
    Value<String?>? model,
    Value<int?>? firearmId,
    Value<String?>? notes,
  }) {
    return CachedEquipmentCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      firearmId: firearmId ?? this.firearmId,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (firearmId.present) {
      map['firearm_id'] = Variable<int>(firearmId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedEquipmentCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('firearmId: $firearmId, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShootSessionsTable shootSessions = $ShootSessionsTable(this);
  late final $ShootEntriesTable shootEntries = $ShootEntriesTable(this);
  late final $PendingSessionPhotosTable pendingSessionPhotos =
      $PendingSessionPhotosTable(this);
  late final $CachedFirearmsTable cachedFirearms = $CachedFirearmsTable(this);
  late final $CachedAmmoLoadsTable cachedAmmoLoads = $CachedAmmoLoadsTable(
    this,
  );
  late final $CachedEquipmentTable cachedEquipment = $CachedEquipmentTable(
    this,
  );
  late final ShootSessionDao shootSessionDao = ShootSessionDao(
    this as AppDatabase,
  );
  late final PendingPhotoDao pendingPhotoDao = PendingPhotoDao(
    this as AppDatabase,
  );
  late final LockerDao lockerDao = LockerDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shootSessions,
    shootEntries,
    pendingSessionPhotos,
    cachedFirearms,
    cachedAmmoLoads,
    cachedEquipment,
  ];
}

typedef $$ShootSessionsTableCreateCompanionBuilder =
    ShootSessionsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      required DateTime date,
      required String discipline,
      required String sessionType,
      Value<String?> location,
      Value<String?> rangeName,
      Value<String?> venueType,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int?> firearmId,
      Value<int?> ammoLoadId,
      Value<String?> equipmentIds,
      Value<int?> totalRounds,
      Value<int?> totalHits,
      Value<int?> totalMisses,
      Value<double?> totalScore,
      Value<int?> rating,
      Value<String?> notes,
      Value<String?> weatherCondition,
      Value<double?> temperature,
      Value<double?> windSpeed,
      Value<String?> windDirection,
      Value<double?> humidity,
      Value<double?> pressure,
      Value<String> syncStatus,
      Value<int?> eventId,
      Value<String?> voiceNotePath,
      Value<DateTime?> serverUpdatedAt,
      Value<bool> locallyModified,
      Value<String?> conflictRemoteJson,
      Value<DateTime> createdAt,
    });
typedef $$ShootSessionsTableUpdateCompanionBuilder =
    ShootSessionsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      Value<DateTime> date,
      Value<String> discipline,
      Value<String> sessionType,
      Value<String?> location,
      Value<String?> rangeName,
      Value<String?> venueType,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int?> firearmId,
      Value<int?> ammoLoadId,
      Value<String?> equipmentIds,
      Value<int?> totalRounds,
      Value<int?> totalHits,
      Value<int?> totalMisses,
      Value<double?> totalScore,
      Value<int?> rating,
      Value<String?> notes,
      Value<String?> weatherCondition,
      Value<double?> temperature,
      Value<double?> windSpeed,
      Value<String?> windDirection,
      Value<double?> humidity,
      Value<double?> pressure,
      Value<String> syncStatus,
      Value<int?> eventId,
      Value<String?> voiceNotePath,
      Value<DateTime?> serverUpdatedAt,
      Value<bool> locallyModified,
      Value<String?> conflictRemoteJson,
      Value<DateTime> createdAt,
    });

final class $$ShootSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $ShootSessionsTable, ShootSession> {
  $$ShootSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ShootEntriesTable, List<ShootEntry>>
  _shootEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shootEntries,
    aliasName: $_aliasNameGenerator(
      db.shootSessions.id,
      db.shootEntries.sessionId,
    ),
  );

  $$ShootEntriesTableProcessedTableManager get shootEntriesRefs {
    final manager = $$ShootEntriesTableTableManager(
      $_db,
      $_db.shootEntries,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_shootEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PendingSessionPhotosTable,
    List<PendingSessionPhoto>
  >
  _pendingSessionPhotosRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pendingSessionPhotos,
        aliasName: $_aliasNameGenerator(
          db.shootSessions.id,
          db.pendingSessionPhotos.localSessionId,
        ),
      );

  $$PendingSessionPhotosTableProcessedTableManager
  get pendingSessionPhotosRefs {
    final manager = $$PendingSessionPhotosTableTableManager(
      $_db,
      $_db.pendingSessionPhotos,
    ).filter((f) => f.localSessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pendingSessionPhotosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShootSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ShootSessionsTable> {
  $$ShootSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discipline => $composableBuilder(
    column: $table.discipline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rangeName => $composableBuilder(
    column: $table.rangeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get venueType => $composableBuilder(
    column: $table.venueType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firearmId => $composableBuilder(
    column: $table.firearmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ammoLoadId => $composableBuilder(
    column: $table.ammoLoadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipmentIds => $composableBuilder(
    column: $table.equipmentIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalRounds => $composableBuilder(
    column: $table.totalRounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalHits => $composableBuilder(
    column: $table.totalHits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMisses => $composableBuilder(
    column: $table.totalMisses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherCondition => $composableBuilder(
    column: $table.weatherCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get windSpeed => $composableBuilder(
    column: $table.windSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get windDirection => $composableBuilder(
    column: $table.windDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get humidity => $composableBuilder(
    column: $table.humidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pressure => $composableBuilder(
    column: $table.pressure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceNotePath => $composableBuilder(
    column: $table.voiceNotePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locallyModified => $composableBuilder(
    column: $table.locallyModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictRemoteJson => $composableBuilder(
    column: $table.conflictRemoteJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> shootEntriesRefs(
    Expression<bool> Function($$ShootEntriesTableFilterComposer f) f,
  ) {
    final $$ShootEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shootEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShootEntriesTableFilterComposer(
            $db: $db,
            $table: $db.shootEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pendingSessionPhotosRefs(
    Expression<bool> Function($$PendingSessionPhotosTableFilterComposer f) f,
  ) {
    final $$PendingSessionPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pendingSessionPhotos,
      getReferencedColumn: (t) => t.localSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PendingSessionPhotosTableFilterComposer(
            $db: $db,
            $table: $db.pendingSessionPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShootSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShootSessionsTable> {
  $$ShootSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discipline => $composableBuilder(
    column: $table.discipline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rangeName => $composableBuilder(
    column: $table.rangeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get venueType => $composableBuilder(
    column: $table.venueType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firearmId => $composableBuilder(
    column: $table.firearmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ammoLoadId => $composableBuilder(
    column: $table.ammoLoadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipmentIds => $composableBuilder(
    column: $table.equipmentIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalRounds => $composableBuilder(
    column: $table.totalRounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalHits => $composableBuilder(
    column: $table.totalHits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMisses => $composableBuilder(
    column: $table.totalMisses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherCondition => $composableBuilder(
    column: $table.weatherCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get windSpeed => $composableBuilder(
    column: $table.windSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get windDirection => $composableBuilder(
    column: $table.windDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get humidity => $composableBuilder(
    column: $table.humidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pressure => $composableBuilder(
    column: $table.pressure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceNotePath => $composableBuilder(
    column: $table.voiceNotePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locallyModified => $composableBuilder(
    column: $table.locallyModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictRemoteJson => $composableBuilder(
    column: $table.conflictRemoteJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShootSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShootSessionsTable> {
  $$ShootSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get discipline => $composableBuilder(
    column: $table.discipline,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get rangeName =>
      $composableBuilder(column: $table.rangeName, builder: (column) => column);

  GeneratedColumn<String> get venueType =>
      $composableBuilder(column: $table.venueType, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get firearmId =>
      $composableBuilder(column: $table.firearmId, builder: (column) => column);

  GeneratedColumn<int> get ammoLoadId => $composableBuilder(
    column: $table.ammoLoadId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipmentIds => $composableBuilder(
    column: $table.equipmentIds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalRounds => $composableBuilder(
    column: $table.totalRounds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalHits =>
      $composableBuilder(column: $table.totalHits, builder: (column) => column);

  GeneratedColumn<int> get totalMisses => $composableBuilder(
    column: $table.totalMisses,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get weatherCondition => $composableBuilder(
    column: $table.weatherCondition,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get windSpeed =>
      $composableBuilder(column: $table.windSpeed, builder: (column) => column);

  GeneratedColumn<String> get windDirection => $composableBuilder(
    column: $table.windDirection,
    builder: (column) => column,
  );

  GeneratedColumn<double> get humidity =>
      $composableBuilder(column: $table.humidity, builder: (column) => column);

  GeneratedColumn<double> get pressure =>
      $composableBuilder(column: $table.pressure, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get voiceNotePath => $composableBuilder(
    column: $table.voiceNotePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get locallyModified => $composableBuilder(
    column: $table.locallyModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictRemoteJson => $composableBuilder(
    column: $table.conflictRemoteJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> shootEntriesRefs<T extends Object>(
    Expression<T> Function($$ShootEntriesTableAnnotationComposer a) f,
  ) {
    final $$ShootEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shootEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShootEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.shootEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pendingSessionPhotosRefs<T extends Object>(
    Expression<T> Function($$PendingSessionPhotosTableAnnotationComposer a) f,
  ) {
    final $$PendingSessionPhotosTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pendingSessionPhotos,
          getReferencedColumn: (t) => t.localSessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PendingSessionPhotosTableAnnotationComposer(
                $db: $db,
                $table: $db.pendingSessionPhotos,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ShootSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShootSessionsTable,
          ShootSession,
          $$ShootSessionsTableFilterComposer,
          $$ShootSessionsTableOrderingComposer,
          $$ShootSessionsTableAnnotationComposer,
          $$ShootSessionsTableCreateCompanionBuilder,
          $$ShootSessionsTableUpdateCompanionBuilder,
          (ShootSession, $$ShootSessionsTableReferences),
          ShootSession,
          PrefetchHooks Function({
            bool shootEntriesRefs,
            bool pendingSessionPhotosRefs,
          })
        > {
  $$ShootSessionsTableTableManager(_$AppDatabase db, $ShootSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShootSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShootSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShootSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> discipline = const Value.absent(),
                Value<String> sessionType = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> rangeName = const Value.absent(),
                Value<String?> venueType = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int?> firearmId = const Value.absent(),
                Value<int?> ammoLoadId = const Value.absent(),
                Value<String?> equipmentIds = const Value.absent(),
                Value<int?> totalRounds = const Value.absent(),
                Value<int?> totalHits = const Value.absent(),
                Value<int?> totalMisses = const Value.absent(),
                Value<double?> totalScore = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> weatherCondition = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<double?> windSpeed = const Value.absent(),
                Value<String?> windDirection = const Value.absent(),
                Value<double?> humidity = const Value.absent(),
                Value<double?> pressure = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> eventId = const Value.absent(),
                Value<String?> voiceNotePath = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<bool> locallyModified = const Value.absent(),
                Value<String?> conflictRemoteJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ShootSessionsCompanion(
                id: id,
                serverId: serverId,
                date: date,
                discipline: discipline,
                sessionType: sessionType,
                location: location,
                rangeName: rangeName,
                venueType: venueType,
                latitude: latitude,
                longitude: longitude,
                firearmId: firearmId,
                ammoLoadId: ammoLoadId,
                equipmentIds: equipmentIds,
                totalRounds: totalRounds,
                totalHits: totalHits,
                totalMisses: totalMisses,
                totalScore: totalScore,
                rating: rating,
                notes: notes,
                weatherCondition: weatherCondition,
                temperature: temperature,
                windSpeed: windSpeed,
                windDirection: windDirection,
                humidity: humidity,
                pressure: pressure,
                syncStatus: syncStatus,
                eventId: eventId,
                voiceNotePath: voiceNotePath,
                serverUpdatedAt: serverUpdatedAt,
                locallyModified: locallyModified,
                conflictRemoteJson: conflictRemoteJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required DateTime date,
                required String discipline,
                required String sessionType,
                Value<String?> location = const Value.absent(),
                Value<String?> rangeName = const Value.absent(),
                Value<String?> venueType = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int?> firearmId = const Value.absent(),
                Value<int?> ammoLoadId = const Value.absent(),
                Value<String?> equipmentIds = const Value.absent(),
                Value<int?> totalRounds = const Value.absent(),
                Value<int?> totalHits = const Value.absent(),
                Value<int?> totalMisses = const Value.absent(),
                Value<double?> totalScore = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> weatherCondition = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<double?> windSpeed = const Value.absent(),
                Value<String?> windDirection = const Value.absent(),
                Value<double?> humidity = const Value.absent(),
                Value<double?> pressure = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> eventId = const Value.absent(),
                Value<String?> voiceNotePath = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<bool> locallyModified = const Value.absent(),
                Value<String?> conflictRemoteJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ShootSessionsCompanion.insert(
                id: id,
                serverId: serverId,
                date: date,
                discipline: discipline,
                sessionType: sessionType,
                location: location,
                rangeName: rangeName,
                venueType: venueType,
                latitude: latitude,
                longitude: longitude,
                firearmId: firearmId,
                ammoLoadId: ammoLoadId,
                equipmentIds: equipmentIds,
                totalRounds: totalRounds,
                totalHits: totalHits,
                totalMisses: totalMisses,
                totalScore: totalScore,
                rating: rating,
                notes: notes,
                weatherCondition: weatherCondition,
                temperature: temperature,
                windSpeed: windSpeed,
                windDirection: windDirection,
                humidity: humidity,
                pressure: pressure,
                syncStatus: syncStatus,
                eventId: eventId,
                voiceNotePath: voiceNotePath,
                serverUpdatedAt: serverUpdatedAt,
                locallyModified: locallyModified,
                conflictRemoteJson: conflictRemoteJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShootSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({shootEntriesRefs = false, pendingSessionPhotosRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (shootEntriesRefs) db.shootEntries,
                    if (pendingSessionPhotosRefs) db.pendingSessionPhotos,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (shootEntriesRefs)
                        await $_getPrefetchedData<
                          ShootSession,
                          $ShootSessionsTable,
                          ShootEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ShootSessionsTableReferences
                              ._shootEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShootSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).shootEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pendingSessionPhotosRefs)
                        await $_getPrefetchedData<
                          ShootSession,
                          $ShootSessionsTable,
                          PendingSessionPhoto
                        >(
                          currentTable: table,
                          referencedTable: $$ShootSessionsTableReferences
                              ._pendingSessionPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShootSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).pendingSessionPhotosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.localSessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ShootSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShootSessionsTable,
      ShootSession,
      $$ShootSessionsTableFilterComposer,
      $$ShootSessionsTableOrderingComposer,
      $$ShootSessionsTableAnnotationComposer,
      $$ShootSessionsTableCreateCompanionBuilder,
      $$ShootSessionsTableUpdateCompanionBuilder,
      (ShootSession, $$ShootSessionsTableReferences),
      ShootSession,
      PrefetchHooks Function({
        bool shootEntriesRefs,
        bool pendingSessionPhotosRefs,
      })
    >;
typedef $$ShootEntriesTableCreateCompanionBuilder =
    ShootEntriesCompanion Function({
      Value<int> id,
      required int sessionId,
      Value<int?> firearmId,
      Value<int?> ammoLoadId,
      Value<double?> distance,
      Value<int?> roundsFired,
      Value<int?> hits,
      Value<int?> misses,
      Value<double?> groupSize,
      Value<double?> score,
      Value<String?> stageName,
      Value<String?> notes,
    });
typedef $$ShootEntriesTableUpdateCompanionBuilder =
    ShootEntriesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int?> firearmId,
      Value<int?> ammoLoadId,
      Value<double?> distance,
      Value<int?> roundsFired,
      Value<int?> hits,
      Value<int?> misses,
      Value<double?> groupSize,
      Value<double?> score,
      Value<String?> stageName,
      Value<String?> notes,
    });

final class $$ShootEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $ShootEntriesTable, ShootEntry> {
  $$ShootEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShootSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.shootSessions.createAlias(
        $_aliasNameGenerator(db.shootEntries.sessionId, db.shootSessions.id),
      );

  $$ShootSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$ShootSessionsTableTableManager(
      $_db,
      $_db.shootSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShootEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ShootEntriesTable> {
  $$ShootEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firearmId => $composableBuilder(
    column: $table.firearmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ammoLoadId => $composableBuilder(
    column: $table.ammoLoadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundsFired => $composableBuilder(
    column: $table.roundsFired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hits => $composableBuilder(
    column: $table.hits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get misses => $composableBuilder(
    column: $table.misses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get groupSize => $composableBuilder(
    column: $table.groupSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageName => $composableBuilder(
    column: $table.stageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ShootSessionsTableFilterComposer get sessionId {
    final $$ShootSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.shootSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShootSessionsTableFilterComposer(
            $db: $db,
            $table: $db.shootSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShootEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShootEntriesTable> {
  $$ShootEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firearmId => $composableBuilder(
    column: $table.firearmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ammoLoadId => $composableBuilder(
    column: $table.ammoLoadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundsFired => $composableBuilder(
    column: $table.roundsFired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hits => $composableBuilder(
    column: $table.hits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get misses => $composableBuilder(
    column: $table.misses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get groupSize => $composableBuilder(
    column: $table.groupSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageName => $composableBuilder(
    column: $table.stageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShootSessionsTableOrderingComposer get sessionId {
    final $$ShootSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.shootSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShootSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.shootSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShootEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShootEntriesTable> {
  $$ShootEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get firearmId =>
      $composableBuilder(column: $table.firearmId, builder: (column) => column);

  GeneratedColumn<int> get ammoLoadId => $composableBuilder(
    column: $table.ammoLoadId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<int> get roundsFired => $composableBuilder(
    column: $table.roundsFired,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hits =>
      $composableBuilder(column: $table.hits, builder: (column) => column);

  GeneratedColumn<int> get misses =>
      $composableBuilder(column: $table.misses, builder: (column) => column);

  GeneratedColumn<double> get groupSize =>
      $composableBuilder(column: $table.groupSize, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get stageName =>
      $composableBuilder(column: $table.stageName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ShootSessionsTableAnnotationComposer get sessionId {
    final $$ShootSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.shootSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShootSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.shootSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShootEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShootEntriesTable,
          ShootEntry,
          $$ShootEntriesTableFilterComposer,
          $$ShootEntriesTableOrderingComposer,
          $$ShootEntriesTableAnnotationComposer,
          $$ShootEntriesTableCreateCompanionBuilder,
          $$ShootEntriesTableUpdateCompanionBuilder,
          (ShootEntry, $$ShootEntriesTableReferences),
          ShootEntry,
          PrefetchHooks Function({bool sessionId})
        > {
  $$ShootEntriesTableTableManager(_$AppDatabase db, $ShootEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShootEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShootEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShootEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int?> firearmId = const Value.absent(),
                Value<int?> ammoLoadId = const Value.absent(),
                Value<double?> distance = const Value.absent(),
                Value<int?> roundsFired = const Value.absent(),
                Value<int?> hits = const Value.absent(),
                Value<int?> misses = const Value.absent(),
                Value<double?> groupSize = const Value.absent(),
                Value<double?> score = const Value.absent(),
                Value<String?> stageName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ShootEntriesCompanion(
                id: id,
                sessionId: sessionId,
                firearmId: firearmId,
                ammoLoadId: ammoLoadId,
                distance: distance,
                roundsFired: roundsFired,
                hits: hits,
                misses: misses,
                groupSize: groupSize,
                score: score,
                stageName: stageName,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                Value<int?> firearmId = const Value.absent(),
                Value<int?> ammoLoadId = const Value.absent(),
                Value<double?> distance = const Value.absent(),
                Value<int?> roundsFired = const Value.absent(),
                Value<int?> hits = const Value.absent(),
                Value<int?> misses = const Value.absent(),
                Value<double?> groupSize = const Value.absent(),
                Value<double?> score = const Value.absent(),
                Value<String?> stageName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ShootEntriesCompanion.insert(
                id: id,
                sessionId: sessionId,
                firearmId: firearmId,
                ammoLoadId: ammoLoadId,
                distance: distance,
                roundsFired: roundsFired,
                hits: hits,
                misses: misses,
                groupSize: groupSize,
                score: score,
                stageName: stageName,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShootEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$ShootEntriesTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$ShootEntriesTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShootEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShootEntriesTable,
      ShootEntry,
      $$ShootEntriesTableFilterComposer,
      $$ShootEntriesTableOrderingComposer,
      $$ShootEntriesTableAnnotationComposer,
      $$ShootEntriesTableCreateCompanionBuilder,
      $$ShootEntriesTableUpdateCompanionBuilder,
      (ShootEntry, $$ShootEntriesTableReferences),
      ShootEntry,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$PendingSessionPhotosTableCreateCompanionBuilder =
    PendingSessionPhotosCompanion Function({
      Value<int> id,
      required int localSessionId,
      required String filePath,
      required String photoType,
      required String fileName,
      Value<DateTime> createdAt,
    });
typedef $$PendingSessionPhotosTableUpdateCompanionBuilder =
    PendingSessionPhotosCompanion Function({
      Value<int> id,
      Value<int> localSessionId,
      Value<String> filePath,
      Value<String> photoType,
      Value<String> fileName,
      Value<DateTime> createdAt,
    });

final class $$PendingSessionPhotosTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PendingSessionPhotosTable,
          PendingSessionPhoto
        > {
  $$PendingSessionPhotosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ShootSessionsTable _localSessionIdTable(_$AppDatabase db) =>
      db.shootSessions.createAlias(
        $_aliasNameGenerator(
          db.pendingSessionPhotos.localSessionId,
          db.shootSessions.id,
        ),
      );

  $$ShootSessionsTableProcessedTableManager get localSessionId {
    final $_column = $_itemColumn<int>('local_session_id')!;

    final manager = $$ShootSessionsTableTableManager(
      $_db,
      $_db.shootSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_localSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PendingSessionPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PendingSessionPhotosTable> {
  $$PendingSessionPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoType => $composableBuilder(
    column: $table.photoType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ShootSessionsTableFilterComposer get localSessionId {
    final $$ShootSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localSessionId,
      referencedTable: $db.shootSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShootSessionsTableFilterComposer(
            $db: $db,
            $table: $db.shootSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingSessionPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingSessionPhotosTable> {
  $$PendingSessionPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoType => $composableBuilder(
    column: $table.photoType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShootSessionsTableOrderingComposer get localSessionId {
    final $$ShootSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localSessionId,
      referencedTable: $db.shootSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShootSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.shootSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingSessionPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingSessionPhotosTable> {
  $$PendingSessionPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get photoType =>
      $composableBuilder(column: $table.photoType, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ShootSessionsTableAnnotationComposer get localSessionId {
    final $$ShootSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localSessionId,
      referencedTable: $db.shootSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShootSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.shootSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingSessionPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingSessionPhotosTable,
          PendingSessionPhoto,
          $$PendingSessionPhotosTableFilterComposer,
          $$PendingSessionPhotosTableOrderingComposer,
          $$PendingSessionPhotosTableAnnotationComposer,
          $$PendingSessionPhotosTableCreateCompanionBuilder,
          $$PendingSessionPhotosTableUpdateCompanionBuilder,
          (PendingSessionPhoto, $$PendingSessionPhotosTableReferences),
          PendingSessionPhoto,
          PrefetchHooks Function({bool localSessionId})
        > {
  $$PendingSessionPhotosTableTableManager(
    _$AppDatabase db,
    $PendingSessionPhotosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingSessionPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingSessionPhotosTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingSessionPhotosTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> localSessionId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> photoType = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingSessionPhotosCompanion(
                id: id,
                localSessionId: localSessionId,
                filePath: filePath,
                photoType: photoType,
                fileName: fileName,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int localSessionId,
                required String filePath,
                required String photoType,
                required String fileName,
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingSessionPhotosCompanion.insert(
                id: id,
                localSessionId: localSessionId,
                filePath: filePath,
                photoType: photoType,
                fileName: fileName,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PendingSessionPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localSessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (localSessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.localSessionId,
                                referencedTable:
                                    $$PendingSessionPhotosTableReferences
                                        ._localSessionIdTable(db),
                                referencedColumn:
                                    $$PendingSessionPhotosTableReferences
                                        ._localSessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PendingSessionPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingSessionPhotosTable,
      PendingSessionPhoto,
      $$PendingSessionPhotosTableFilterComposer,
      $$PendingSessionPhotosTableOrderingComposer,
      $$PendingSessionPhotosTableAnnotationComposer,
      $$PendingSessionPhotosTableCreateCompanionBuilder,
      $$PendingSessionPhotosTableUpdateCompanionBuilder,
      (PendingSessionPhoto, $$PendingSessionPhotosTableReferences),
      PendingSessionPhoto,
      PrefetchHooks Function({bool localSessionId})
    >;
typedef $$CachedFirearmsTableCreateCompanionBuilder =
    CachedFirearmsCompanion Function({
      Value<int> id,
      required String name,
      required String make,
      required String model,
      Value<String?> calibre,
      Value<String?> serialNumber,
      Value<String?> notes,
    });
typedef $$CachedFirearmsTableUpdateCompanionBuilder =
    CachedFirearmsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> make,
      Value<String> model,
      Value<String?> calibre,
      Value<String?> serialNumber,
      Value<String?> notes,
    });

class $$CachedFirearmsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedFirearmsTable> {
  $$CachedFirearmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calibre => $composableBuilder(
    column: $table.calibre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedFirearmsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedFirearmsTable> {
  $$CachedFirearmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calibre => $composableBuilder(
    column: $table.calibre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedFirearmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedFirearmsTable> {
  $$CachedFirearmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get calibre =>
      $composableBuilder(column: $table.calibre, builder: (column) => column);

  GeneratedColumn<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$CachedFirearmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedFirearmsTable,
          CachedFirearm,
          $$CachedFirearmsTableFilterComposer,
          $$CachedFirearmsTableOrderingComposer,
          $$CachedFirearmsTableAnnotationComposer,
          $$CachedFirearmsTableCreateCompanionBuilder,
          $$CachedFirearmsTableUpdateCompanionBuilder,
          (
            CachedFirearm,
            BaseReferences<_$AppDatabase, $CachedFirearmsTable, CachedFirearm>,
          ),
          CachedFirearm,
          PrefetchHooks Function()
        > {
  $$CachedFirearmsTableTableManager(
    _$AppDatabase db,
    $CachedFirearmsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedFirearmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedFirearmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedFirearmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> make = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String?> calibre = const Value.absent(),
                Value<String?> serialNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => CachedFirearmsCompanion(
                id: id,
                name: name,
                make: make,
                model: model,
                calibre: calibre,
                serialNumber: serialNumber,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String make,
                required String model,
                Value<String?> calibre = const Value.absent(),
                Value<String?> serialNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => CachedFirearmsCompanion.insert(
                id: id,
                name: name,
                make: make,
                model: model,
                calibre: calibre,
                serialNumber: serialNumber,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedFirearmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedFirearmsTable,
      CachedFirearm,
      $$CachedFirearmsTableFilterComposer,
      $$CachedFirearmsTableOrderingComposer,
      $$CachedFirearmsTableAnnotationComposer,
      $$CachedFirearmsTableCreateCompanionBuilder,
      $$CachedFirearmsTableUpdateCompanionBuilder,
      (
        CachedFirearm,
        BaseReferences<_$AppDatabase, $CachedFirearmsTable, CachedFirearm>,
      ),
      CachedFirearm,
      PrefetchHooks Function()
    >;
typedef $$CachedAmmoLoadsTableCreateCompanionBuilder =
    CachedAmmoLoadsCompanion Function({
      Value<int> id,
      required String name,
      required String calibre,
      Value<String?> manufacturer,
      Value<double?> bulletWeight,
      Value<double?> powderCharge,
      Value<String?> notes,
    });
typedef $$CachedAmmoLoadsTableUpdateCompanionBuilder =
    CachedAmmoLoadsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> calibre,
      Value<String?> manufacturer,
      Value<double?> bulletWeight,
      Value<double?> powderCharge,
      Value<String?> notes,
    });

class $$CachedAmmoLoadsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAmmoLoadsTable> {
  $$CachedAmmoLoadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calibre => $composableBuilder(
    column: $table.calibre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bulletWeight => $composableBuilder(
    column: $table.bulletWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get powderCharge => $composableBuilder(
    column: $table.powderCharge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedAmmoLoadsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAmmoLoadsTable> {
  $$CachedAmmoLoadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calibre => $composableBuilder(
    column: $table.calibre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bulletWeight => $composableBuilder(
    column: $table.bulletWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get powderCharge => $composableBuilder(
    column: $table.powderCharge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedAmmoLoadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAmmoLoadsTable> {
  $$CachedAmmoLoadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get calibre =>
      $composableBuilder(column: $table.calibre, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bulletWeight => $composableBuilder(
    column: $table.bulletWeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get powderCharge => $composableBuilder(
    column: $table.powderCharge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$CachedAmmoLoadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedAmmoLoadsTable,
          CachedAmmoLoad,
          $$CachedAmmoLoadsTableFilterComposer,
          $$CachedAmmoLoadsTableOrderingComposer,
          $$CachedAmmoLoadsTableAnnotationComposer,
          $$CachedAmmoLoadsTableCreateCompanionBuilder,
          $$CachedAmmoLoadsTableUpdateCompanionBuilder,
          (
            CachedAmmoLoad,
            BaseReferences<
              _$AppDatabase,
              $CachedAmmoLoadsTable,
              CachedAmmoLoad
            >,
          ),
          CachedAmmoLoad,
          PrefetchHooks Function()
        > {
  $$CachedAmmoLoadsTableTableManager(
    _$AppDatabase db,
    $CachedAmmoLoadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAmmoLoadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAmmoLoadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAmmoLoadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> calibre = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<double?> bulletWeight = const Value.absent(),
                Value<double?> powderCharge = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => CachedAmmoLoadsCompanion(
                id: id,
                name: name,
                calibre: calibre,
                manufacturer: manufacturer,
                bulletWeight: bulletWeight,
                powderCharge: powderCharge,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String calibre,
                Value<String?> manufacturer = const Value.absent(),
                Value<double?> bulletWeight = const Value.absent(),
                Value<double?> powderCharge = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => CachedAmmoLoadsCompanion.insert(
                id: id,
                name: name,
                calibre: calibre,
                manufacturer: manufacturer,
                bulletWeight: bulletWeight,
                powderCharge: powderCharge,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedAmmoLoadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedAmmoLoadsTable,
      CachedAmmoLoad,
      $$CachedAmmoLoadsTableFilterComposer,
      $$CachedAmmoLoadsTableOrderingComposer,
      $$CachedAmmoLoadsTableAnnotationComposer,
      $$CachedAmmoLoadsTableCreateCompanionBuilder,
      $$CachedAmmoLoadsTableUpdateCompanionBuilder,
      (
        CachedAmmoLoad,
        BaseReferences<_$AppDatabase, $CachedAmmoLoadsTable, CachedAmmoLoad>,
      ),
      CachedAmmoLoad,
      PrefetchHooks Function()
    >;
typedef $$CachedEquipmentTableCreateCompanionBuilder =
    CachedEquipmentCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> category,
      Value<String?> brand,
      Value<String?> model,
      Value<int?> firearmId,
      Value<String?> notes,
    });
typedef $$CachedEquipmentTableUpdateCompanionBuilder =
    CachedEquipmentCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> category,
      Value<String?> brand,
      Value<String?> model,
      Value<int?> firearmId,
      Value<String?> notes,
    });

class $$CachedEquipmentTableFilterComposer
    extends Composer<_$AppDatabase, $CachedEquipmentTable> {
  $$CachedEquipmentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firearmId => $composableBuilder(
    column: $table.firearmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedEquipmentTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedEquipmentTable> {
  $$CachedEquipmentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firearmId => $composableBuilder(
    column: $table.firearmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedEquipmentTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedEquipmentTable> {
  $$CachedEquipmentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get firearmId =>
      $composableBuilder(column: $table.firearmId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$CachedEquipmentTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedEquipmentTable,
          CachedEquipmentData,
          $$CachedEquipmentTableFilterComposer,
          $$CachedEquipmentTableOrderingComposer,
          $$CachedEquipmentTableAnnotationComposer,
          $$CachedEquipmentTableCreateCompanionBuilder,
          $$CachedEquipmentTableUpdateCompanionBuilder,
          (
            CachedEquipmentData,
            BaseReferences<
              _$AppDatabase,
              $CachedEquipmentTable,
              CachedEquipmentData
            >,
          ),
          CachedEquipmentData,
          PrefetchHooks Function()
        > {
  $$CachedEquipmentTableTableManager(
    _$AppDatabase db,
    $CachedEquipmentTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedEquipmentTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedEquipmentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedEquipmentTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<int?> firearmId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => CachedEquipmentCompanion(
                id: id,
                name: name,
                category: category,
                brand: brand,
                model: model,
                firearmId: firearmId,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> category = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<int?> firearmId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => CachedEquipmentCompanion.insert(
                id: id,
                name: name,
                category: category,
                brand: brand,
                model: model,
                firearmId: firearmId,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedEquipmentTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedEquipmentTable,
      CachedEquipmentData,
      $$CachedEquipmentTableFilterComposer,
      $$CachedEquipmentTableOrderingComposer,
      $$CachedEquipmentTableAnnotationComposer,
      $$CachedEquipmentTableCreateCompanionBuilder,
      $$CachedEquipmentTableUpdateCompanionBuilder,
      (
        CachedEquipmentData,
        BaseReferences<
          _$AppDatabase,
          $CachedEquipmentTable,
          CachedEquipmentData
        >,
      ),
      CachedEquipmentData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShootSessionsTableTableManager get shootSessions =>
      $$ShootSessionsTableTableManager(_db, _db.shootSessions);
  $$ShootEntriesTableTableManager get shootEntries =>
      $$ShootEntriesTableTableManager(_db, _db.shootEntries);
  $$PendingSessionPhotosTableTableManager get pendingSessionPhotos =>
      $$PendingSessionPhotosTableTableManager(_db, _db.pendingSessionPhotos);
  $$CachedFirearmsTableTableManager get cachedFirearms =>
      $$CachedFirearmsTableTableManager(_db, _db.cachedFirearms);
  $$CachedAmmoLoadsTableTableManager get cachedAmmoLoads =>
      $$CachedAmmoLoadsTableTableManager(_db, _db.cachedAmmoLoads);
  $$CachedEquipmentTableTableManager get cachedEquipment =>
      $$CachedEquipmentTableTableManager(_db, _db.cachedEquipment);
}
