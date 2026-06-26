import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sync_service.dart';
import 'sync_status_provider.dart';
/// Watches connectivity and syncs pending sessions when coming back online.
final syncOnReconnectProvider = Provider<void>((ref) {
  ref.listen<bool>(isOnlineProvider, (previous, next) async {
    if (next && previous == false) {
      await ref.read(syncStatusProvider.notifier).syncAll();
    }
  });
});
