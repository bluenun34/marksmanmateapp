import 'package:drift/drift.dart';

import '../../shared/models/ammo_load_model.dart';
import '../../shared/models/equipment_model.dart';
import '../../shared/models/firearm_model.dart';
import '../../shared/models/shoot_session_model.dart';
import '../database/app_database.dart';

ShootSession shootSessionFromRemote(
  ShootSessionModel remote, {
  String syncStatus = 'synced',
  int? firearmId,
  int? ammoLoadId,
  String? equipmentIds,
}) {
  final serverId = remote.id;
  return ShootSession(
    id: serverId ?? -remote.date.millisecondsSinceEpoch,
    serverId: serverId,
    date: remote.date,
    discipline: remote.discipline,
    sessionType: remote.sessionType,
    location: remote.location,
    rangeName: remote.rangeName,
    venueType: remote.venueType,
    latitude: remote.latitude,
    longitude: remote.longitude,
    firearmId: firearmId,
    ammoLoadId: ammoLoadId,
    equipmentIds: equipmentIds,
    totalRounds: remote.totalRounds,
    totalHits: remote.totalHits,
    totalMisses: remote.totalMisses,
    totalScore: remote.totalScore,
    rating: remote.rating,
    notes: remote.notes,
    weatherCondition: remote.weatherCondition,
    temperature: remote.temperature,
    windSpeed: remote.windSpeed,
    windDirection: remote.windDirection,
    humidity: remote.humidity,
    pressure: remote.pressure,
    syncStatus: syncStatus,
    serverUpdatedAt: remote.updatedAt,
    locallyModified: false,
    createdAt: DateTime.now(),
  );
}

ShootSession shootSessionFromCompanion(
  ShootSessionsCompanion companion, {
  required int id,
  required String syncStatus,
  int? serverId,
}) {
  return ShootSession(
    id: id,
    serverId: serverId,
    date: companion.date.value,
    discipline: companion.discipline.value,
    sessionType: companion.sessionType.value,
    location: companion.location.present ? companion.location.value : null,
    rangeName: companion.rangeName.present ? companion.rangeName.value : null,
    venueType: companion.venueType.present ? companion.venueType.value : null,
    latitude: companion.latitude.present ? companion.latitude.value : null,
    longitude: companion.longitude.present ? companion.longitude.value : null,
    firearmId:
        companion.firearmId.present ? companion.firearmId.value : null,
    ammoLoadId:
        companion.ammoLoadId.present ? companion.ammoLoadId.value : null,
    equipmentIds: companion.equipmentIds.present
        ? companion.equipmentIds.value
        : null,
    totalRounds:
        companion.totalRounds.present ? companion.totalRounds.value : null,
    totalHits: companion.totalHits.present ? companion.totalHits.value : null,
    totalMisses:
        companion.totalMisses.present ? companion.totalMisses.value : null,
    totalScore:
        companion.totalScore.present ? companion.totalScore.value : null,
    rating: companion.rating.present ? companion.rating.value : null,
    notes: companion.notes.present ? companion.notes.value : null,
    weatherCondition: companion.weatherCondition.present
        ? companion.weatherCondition.value
        : null,
    temperature:
        companion.temperature.present ? companion.temperature.value : null,
    windSpeed: companion.windSpeed.present ? companion.windSpeed.value : null,
    windDirection: companion.windDirection.present
        ? companion.windDirection.value
        : null,
    humidity: companion.humidity.present ? companion.humidity.value : null,
    pressure: companion.pressure.present ? companion.pressure.value : null,
    syncStatus: syncStatus,
    eventId: companion.eventId.present ? companion.eventId.value : null,
    voiceNotePath:
        companion.voiceNotePath.present ? companion.voiceNotePath.value : null,
    serverUpdatedAt: companion.serverUpdatedAt.present
        ? companion.serverUpdatedAt.value
        : null,
    locallyModified:
        companion.locallyModified.present ? companion.locallyModified.value : false,
    conflictRemoteJson: companion.conflictRemoteJson.present
        ? companion.conflictRemoteJson.value
        : null,
    createdAt: DateTime.now(),
  );
}

ShootSessionsCompanion remoteSessionToCompanion(ShootSessionModel remote) {
  return ShootSessionsCompanion.insert(
    serverId: Value(remote.id!),
    date: remote.date,
    discipline: remote.discipline,
    sessionType: remote.sessionType,
    location: Value(remote.location),
    rangeName: Value(remote.rangeName),
    venueType: Value(remote.venueType),
    latitude: Value(remote.latitude),
    longitude: Value(remote.longitude),
    totalRounds: Value(remote.totalRounds),
    totalHits: Value(remote.totalHits),
    totalMisses: Value(remote.totalMisses),
    totalScore: Value(remote.totalScore),
    rating: Value(remote.rating),
    notes: Value(remote.notes),
    weatherCondition: Value(remote.weatherCondition),
    temperature: Value(remote.temperature),
    windSpeed: Value(remote.windSpeed),
    windDirection: Value(remote.windDirection),
    humidity: Value(remote.humidity),
    pressure: Value(remote.pressure),
    serverUpdatedAt: Value(remote.updatedAt),
    locallyModified: const Value(false),
    syncStatus: const Value('synced'),
  );
}

ShootSessionsCompanion remoteSessionToUpdateCompanion(ShootSessionModel remote) {
  return ShootSessionsCompanion(
    serverId: Value(remote.id!),
    date: Value(remote.date),
    discipline: Value(remote.discipline),
    sessionType: Value(remote.sessionType),
    location: Value(remote.location),
    rangeName: Value(remote.rangeName),
    venueType: Value(remote.venueType),
    latitude: Value(remote.latitude),
    longitude: Value(remote.longitude),
    totalRounds: Value(remote.totalRounds),
    totalHits: Value(remote.totalHits),
    totalMisses: Value(remote.totalMisses),
    totalScore: Value(remote.totalScore),
    rating: Value(remote.rating),
    notes: Value(remote.notes),
    weatherCondition: Value(remote.weatherCondition),
    temperature: Value(remote.temperature),
    windSpeed: Value(remote.windSpeed),
    windDirection: Value(remote.windDirection),
    humidity: Value(remote.humidity),
    pressure: Value(remote.pressure),
    serverUpdatedAt: Value(remote.updatedAt),
    locallyModified: const Value(false),
    conflictRemoteJson: const Value(null),
    syncStatus: const Value('synced'),
  );
}

CachedFirearmsCompanion firearmToCacheCompanion(FirearmModel firearm) {
  return CachedFirearmsCompanion.insert(
    id: Value(firearm.id),
    name: firearm.name,
    make: firearm.make ?? '',
    model: firearm.model ?? '',
    calibre: Value(firearm.calibre),
    serialNumber: Value(firearm.serialNumber),
    notes: Value(firearm.notes),
  );
}

CachedAmmoLoadsCompanion ammoToCacheCompanion(AmmoLoadModel ammo) {
  return CachedAmmoLoadsCompanion.insert(
    id: Value(ammo.id),
    name: ammo.name,
    calibre: ammo.calibre ?? '',
    manufacturer: Value(ammo.manufacturer),
    bulletWeight: Value(ammo.bulletWeight),
    powderCharge: Value(ammo.powderCharge),
    notes: Value(ammo.notes),
  );
}

CachedEquipmentCompanion equipmentToCacheCompanion(EquipmentModel equipment) {
  return CachedEquipmentCompanion.insert(
    id: Value(equipment.id),
    name: equipment.name,
    category: Value(equipment.category),
    brand: Value(equipment.brand),
    model: Value(equipment.model),
    firearmId: Value(equipment.firearmId),
    notes: Value(equipment.notes),
  );
}
