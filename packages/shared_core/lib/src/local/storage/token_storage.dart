import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _roleKey = 'auth_role';

  TokenStorage(this._storage);

  Future<void> save({required String token, String? refreshToken, required String role}) async {
    await _storage.write(key: _tokenKey, value: token);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> getToken() async => _storage.read(key: _tokenKey);

  Future<String?> getRefreshToken() async => _storage.read(key: _refreshTokenKey);

  Future<String?> getRole() async => _storage.read(key: _roleKey);

  /// P1 (audit): lightweight metadata (e.g. 'validated_at') used for session
  /// freshness enforcement without a schema change.
  Future<void> setMetadata(String key, String value) async {
    await _storage.write(key: 'meta_$key', value: value);
  }

  Future<String?> getMetadata(String key) async => _storage.read(key: 'meta_$key');

  Future<void> updateToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearAll() async {
    // FIX (audit QA BUG-023): deleteAll() can throw (Android Keystore /
    // platform exceptions). Fall back to deleting each key individually so
    // logout always clears credentials.
    try {
      await _storage.deleteAll();
    } catch (_) {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _roleKey);
    }
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});
