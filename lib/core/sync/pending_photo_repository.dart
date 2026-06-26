import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';

/// Persists session/target photos on disk until the session syncs to the server.
class PendingPhotoRepository {
  PendingPhotoRepository(this._db);

  final AppDatabase _db;

  Future<void> queuePhotos({
    required int localSessionId,
    required List<XFile> targetPhotos,
    required List<XFile> sessionPhotos,
  }) async {
    final dir = await _sessionDir(localSessionId);
    var index = 0;

    for (final file in targetPhotos) {
      await _saveOne(
        localSessionId: localSessionId,
        source: file,
        photoType: 'target',
        dir: dir,
        index: index++,
      );
    }
    index = 0;
    for (final file in sessionPhotos) {
      await _saveOne(
        localSessionId: localSessionId,
        source: file,
        photoType: 'session',
        dir: dir,
        index: index++,
      );
    }
  }

  Future<void> _saveOne({
    required int localSessionId,
    required XFile source,
    required String photoType,
    required Directory dir,
    required int index,
  }) async {
    final ext =
        p.extension(source.name).isNotEmpty ? p.extension(source.name) : '.jpg';
    final fileName = '${photoType}_$index$ext';
    final destPath = p.join(dir.path, fileName);
    await File(destPath).writeAsBytes(await source.readAsBytes());
    await _db.pendingPhotoDao.insertPhoto(
      PendingSessionPhotosCompanion.insert(
        localSessionId: localSessionId,
        filePath: destPath,
        photoType: photoType,
        fileName: source.name.isNotEmpty ? source.name : fileName,
      ),
    );
  }

  Future<List<PendingSessionPhoto>> photosForSession(int localSessionId) =>
      _db.pendingPhotoDao.forSession(localSessionId);

  Future<int> totalPendingCount() => _db.pendingPhotoDao.pendingCount();

  Future<void> clearSession(int localSessionId) async {
    final photos = await _db.pendingPhotoDao.forSession(localSessionId);
    for (final photo in photos) {
      try {
        final file = File(photo.filePath);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    await _db.pendingPhotoDao.deleteForSession(localSessionId);
    try {
      final dir = await _sessionDir(localSessionId);
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
  }

  Future<Directory> _sessionDir(int localSessionId) async {
    final root = await getApplicationDocumentsDirectory();
    final dir =
        Directory(p.join(root.path, 'pending_photos', '$localSessionId'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}

final pendingPhotoRepositoryProvider = Provider<PendingPhotoRepository>((ref) {
  return PendingPhotoRepository(ref.read(appDatabaseProvider));
});
