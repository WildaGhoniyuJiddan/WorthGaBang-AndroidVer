import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/secure/token_storage.dart';
import '../../../core/storage/app_database.dart';
import 'auth_models.dart';

/// Repository auth: login/register/logout + sesi persisten.
///
/// Token & profil user tersimpan di [TokenStorage] (secure storage).
/// Semua bentuk request/response mengikuti API_CONTRACT.md B1.
class AuthRepository {
  AuthRepository({
    required ApiClient client,
    required TokenStorage storage,
    AppDatabase? localDatabase,
    this.localOnly = false,
  })  : assert(!localOnly || localDatabase != null),
        // ignore: prefer_initializing_formals — param publik, field privat.
        _client = client,
        _localDatabase = localDatabase,
        // ignore: prefer_initializing_formals — param publik, field privat.
        _storage = storage;

  final ApiClient _client;
  final TokenStorage _storage;
  final AppDatabase? _localDatabase;
  final bool localOnly;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (localOnly) return _loginLocally(email, password);
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
    if (localOnly) return _registerLocally(name, email, password);
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
    if (localOnly) {
      if (!refreshToken.startsWith('local-refresh-')) {
        await _storage.clear();
        return null;
      }
      return _storage.readUser();
    }
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
    if (!localOnly) {
      try {
        await _client.postJson('/api/v1/auth/logout');
      } catch (_) {
        // Logout lokal tetap jalan walau server unreachable.
      }
    }
    await _storage.clear();
  }

  Future<AppUser?> currentUser() => _storage.readUser();

  Future<void> updateCachedUser(AppUser user) => _storage.saveUser(user);

  Future<AuthSession> _loginLocally(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final account = await (_localDatabase!.select(_localDatabase.localAccounts)
          ..where((row) => row.email.equals(normalizedEmail)))
        .getSingleOrNull();
    if (account == null ||
        !(await _verifyPassword(
          password,
          account.passwordSalt,
          account.passwordHash,
        ))) {
      throw const ApiException('Email atau password salah', 401);
    }
    return _saveLocalSession(account.id, account.name, account.email);
  }

  Future<AuthSession> _registerLocally(
    String name,
    String email,
    String password,
  ) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existing = await (_localDatabase!.select(_localDatabase.localAccounts)
          ..where((row) => row.email.equals(normalizedEmail)))
        .getSingleOrNull();
    if (existing != null) {
      throw const ApiException('Email sudah terdaftar di perangkat ini', 409);
    }

    final salt = base64Encode(
      List<int>.generate(16, (_) => Random.secure().nextInt(256)),
    );
    final hash = await _derivePasswordHash(password, salt);
    final id = await _localDatabase.into(_localDatabase.localAccounts).insert(
          LocalAccountsCompanion.insert(
            name: name.trim(),
            email: normalizedEmail,
            passwordSalt: salt,
            passwordHash: hash,
          ),
        );
    return _saveLocalSession(id, name.trim(), normalizedEmail);
  }

  Future<AuthSession> _saveLocalSession(int id, String name, String email) {
    return _saveSession({
      'access_token': 'local-access-$id',
      'refresh_token': 'local-refresh-$id',
      'token_type': 'bearer',
      'user': {'id': id, 'name': name, 'email': email, 'photo_url': null},
    });
  }

  Future<bool> _verifyPassword(
    String password,
    String salt,
    String expectedHash,
  ) async =>
      await _derivePasswordHash(password, salt) == expectedHash;

  Future<String> _derivePasswordHash(String password, String salt) =>
      Isolate.run(() {
        final hmac = Hmac(sha256, base64Decode(salt));
        var digest = hmac.convert(utf8.encode(password)).bytes;
        for (var i = 1; i < 100000; i++) {
          digest = hmac.convert(digest).bytes;
        }
        return base64Encode(digest);
      });

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
