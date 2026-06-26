import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _tokenKey = 'auth_token';
const _refreshKey = 'refresh_token';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final tokenRepositoryProvider = Provider<TokenRepository>((ref) {
  return TokenRepository(ref.read(secureStorageProvider));
});

class TokenRepository {
  const TokenRepository(this._storage);
  final FlutterSecureStorage _storage;

  Future<String?> getAccessToken() => _storage.read(key: _tokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> saveTokens({
    required String accessToken,
    required String? refreshToken,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
