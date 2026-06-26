import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../database/app_database.dart';
import '../network/api_service.dart';
import 'pending_photo_repository.dart';
import 'shoot_session_payload.dart';

Map<String, dynamic> payloadFromLocalSession(ShootSession session) {
  return shootSessionToPayload(
    date: session.date,
    discipline: session.discipline,
    sessionType: session.sessionType,
    location: session.location,
    rangeName: session.rangeName,
    venueType: session.venueType,
    latitude: session.latitude,
    longitude: session.longitude,
    firearmId: session.firearmId,
    ammoLoadId: session.ammoLoadId,
    equipmentIds: decodeEquipmentIds(session.equipmentIds),
    totalRounds: session.totalRounds,
    totalHits: session.totalHits,
    totalMisses: session.totalMisses,
    totalScore: session.totalScore,
    rating: session.rating,
    notes: session.notes,
    weatherCondition: session.weatherCondition,
    temperature: session.temperature,
    windSpeed: session.windSpeed,
    windDirection: session.windDirection,
    humidity: session.humidity,
    pressure: session.pressure,
    eventId: session.eventId,
  );
}

Future<String?> uploadQueuedPhotos({
  required ApiService api,
  required PendingPhotoRepository photoRepo,
  required int localSessionId,
  required int serverId,
  int? entryId,
}) async {
  final queued = await photoRepo.photosForSession(localSessionId);
  if (queued.isEmpty) return null;

  final targetFiles = <XFile>[];
  final sessionFiles = <XFile>[];
  for (final photo in queued) {
    final file = File(photo.filePath);
    if (!await file.exists()) continue;
    final xFile = XFile(photo.filePath, name: photo.fileName);
    if (photo.photoType == 'target') {
      targetFiles.add(xFile);
    } else {
      sessionFiles.add(xFile);
    }
  }

  try {
    if (sessionFiles.isNotEmpty) {
      await api.uploadSessionPhotos(shootLogId: serverId, files: sessionFiles);
    }
    if (targetFiles.isNotEmpty) {
      if (entryId == null) {
        return 'Session synced but target photos still waiting for an entry';
      }
      await api.uploadTargetPhotos(
        shootLogId: serverId,
        entryId: entryId,
        files: targetFiles,
      );
    }
    await photoRepo.clearSession(localSessionId);
    return null;
  } catch (_) {
    return 'Session synced but photos could not upload yet';
  }
}
