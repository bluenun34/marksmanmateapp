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
  TokenRepository(this._storage);
  final FlutterSecureStorage _storage;

  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _storage.read(key: _tokenKey);
    return _cachedAccessToken;
  }

  Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    _cachedRefreshToken = await _storage.read(key: _refreshKey);
    return _cachedRefreshToken;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String? refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    await _storage.write(key: _tokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    await _storage.deleteAll();
  }
}
