import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/token_repository.dart';

const _lastSyncKey = 'last_sync_at';

final lastSyncRepositoryProvider = Provider<LastSyncRepository>((ref) {
  return LastSyncRepository(ref.read(secureStorageProvider));
});

class LastSyncRepository {
  const LastSyncRepository(this._storage);
  final FlutterSecureStorage _storage;

  Future<DateTime?> read() async {
    final value = await _storage.read(key: _lastSyncKey);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> write(DateTime value) async {
    await _storage.write(
      key: _lastSyncKey,
      value: value.toUtc().toIso8601String(),
    );
  }
}
