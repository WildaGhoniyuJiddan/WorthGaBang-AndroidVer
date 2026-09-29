import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/secure/token_storage.dart';
import 'auth_models.dart';

/// Repository auth: login/register/logout + sesi persisten.
///
/// Token & profil user tersimpan di [TokenStorage] (secure storage).
/// Semua bentuk request/response mengikuti API_CONTRACT.md B1.
class AuthRepository {
  AuthRepository({required ApiClient client, required TokenStorage storage})
      // ignore: prefer_initializing_formals — param publik, field privat.
      : _client = client,
        // ignore: prefer_initializing_formals — param publik, field privat.
        _storage = storage;

  final ApiClient _client;
  final TokenStorage _storage;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.postJson(
      '/api/v1/auth/login',
      body: {'email': email, 'password': password},
    );
    return _saveSession(json);
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _client.postJson(
      '/api/v1/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );
    return _saveSession(json);
  }

  /// Coba pulihkan sesi dari refresh token tersimpan.
  /// Return user bila berhasil, null bila tidak ada sesi / refresh gagal.
  Future<AppUser?> restoreSession() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final json = await _client.postJson(
        '/api/v1/auth/refresh',
        body: {'refresh_token': refreshToken},
      );
      final access = json['access_token'] as String?;
      final refresh = json['refresh_token'] as String?;
      if (access == null || refresh == null) {
        await _storage.clear();
        return null;
      }
      await _storage.saveTokens(accessToken: access, refreshToken: refresh);
      final user = await _storage.readUser();
      return user;
    } catch (_) {
      await _storage.clear();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _client.postJson('/api/v1/auth/logout');
    } catch (_) {
      // Logout lokal tetap jalan walau server unreachable.
    }
    await _storage.clear();
  }

  Future<AppUser?> currentUser() => _storage.readUser();

  Future<void> updateCachedUser(AppUser user) => _storage.saveUser(user);

  Future<AuthSession> _saveSession(Map<String, dynamic> json) async {
    final session = AuthSession.fromJson(json);
    await _storage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    await _storage.saveUser(session.user);
    return session;
  }
}

/// Tambahan penyimpanan profil user di secure storage.
extension UserStorageX on TokenStorage {
  static const _userKey = 'worthbang_user_json';
  static const _biometricKey = 'worthbang_biometric_enabled';

  Future<void> saveUser(AppUser user) => writeRaw(
        _userKey,
        const JsonEncoder().convert(user.toJson()),
      );

  Future<AppUser?> readUser() async {
    final raw = await readRaw(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AppUser.fromJson(
        const JsonDecoder().convert(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> isBiometricEnabled() async =>
      (await readRaw(_biometricKey)) == '1';

  Future<void> setBiometricEnabled(bool enabled) =>
      writeRaw(_biometricKey, enabled ? '1' : '0');
}
