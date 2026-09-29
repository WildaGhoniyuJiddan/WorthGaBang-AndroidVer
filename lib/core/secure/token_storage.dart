import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan token auth.
///
/// ATURAN KEAMANAN: token HANYA boleh disimpan via [FlutterSecureStorage]
/// (Keychain/Keystore terenkripsi). DILARANG menyimpan token di
/// SharedPreferences, file biasa, atau log.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'worthbang_access_token';
  static const _refreshTokenKey = 'worthbang_refresh_token';

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Hapus semua token — dipakai saat logout / refresh gagal.
  Future<void> clear() => _storage.deleteAll();
}
