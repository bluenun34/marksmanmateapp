import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:workmanager/workmanager.dart';

import '../database/app_database.dart';
import '../network/api_service.dart';
import '../network/dio_client.dart';
import '../network/token_repository.dart';
import '../../features/tools/data/paper_target_library_service.dart';
import '../../features/tools/data/saved_target_store.dart';
import 'pending_photo_repository.dart';
import 'sync_service.dart';

const backgroundSyncTaskName = 'marksmanmate-sync-pending';

Future<void> initBackgroundSync() async {
  if (kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    return;
  }

  await Workmanager().initialize(backgroundSyncDispatcher);
  await Workmanager().registerPeriodicTask(
    backgroundSyncTaskName,
    backgroundSyncTaskName,
    frequency: const Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
}

/// Runs in a background isolate — must not depend on Riverpod.
@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final tokenRepo = TokenRepository(const FlutterSecureStorage());
      final dio = createApiClient(tokenRepo);
      final db = AppDatabase();
      final api = ApiService(dio);
      final sync = SyncService(
        db,
        api,
        PendingPhotoRepository(db),
        PaperTargetLibraryService(SavedTargetStore(), api),
      );
      await sync.syncPendingSessions();
      return true;
    } catch (_) {
      return false;
    }
  });
}
