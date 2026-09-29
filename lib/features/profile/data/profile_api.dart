import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/auth_models.dart';

final profileApiProvider = Provider<ProfileApi>(
  (ref) => ProfileApi(ref.watch(apiClientProvider)),
);

/// API profil & feedback (B9).
class ProfileApi {
  ProfileApi(this._client);

  final ApiClient _client;

  /// PUT /api/v1/users/me (multipart): nama dan/atau foto.
  Future<AppUser> updateProfile({String? name, String? photoPath}) async {
    final json = await _client.putMultipart(
      '/api/v1/users/me',
      fields: {'name': ?name},
      files: {'photo': ?photoPath},
    );
    return AppUser.fromJson(json);
  }

  /// POST /api/v1/feedback.
  Future<void> sendFeedback({
    required int rating,
    required String kesan,
    required String saran,
  }) async {
    await _client.postJson('/api/v1/feedback', body: {
      'rating': rating,
      'kesan': kesan,
      'saran': saran,
    });
  }
}

/// Pengaturan aplikasi: tilt 3D & tema (SharedPreferences).
/// AsyncNotifier agar hydrate dari disk selesai sebelum state dipakai.
class AppSettings {
  const AppSettings({
    this.tiltEnabled = true,
    this.themeMode = ThemeMode.system,
  });

  final bool tiltEnabled;
  final ThemeMode themeMode;

  AppSettings copyWith({bool? tiltEnabled, ThemeMode? themeMode}) =>
      AppSettings(
        tiltEnabled: tiltEnabled ?? this.tiltEnabled,
        themeMode: themeMode ?? this.themeMode,
      );
}

class SettingsController extends AsyncNotifier<AppSettings> {
  static const _tiltKey = 'settings_tilt_enabled';
  static const _themeKey = 'settings_theme_mode';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      tiltEnabled: prefs.getBool(_tiltKey) ?? true,
      themeMode: ThemeMode
          .values[(prefs.getInt(_themeKey) ?? 0).clamp(0, 2)],
    );
  }

  Future<void> setTiltEnabled(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tiltKey, v);
    final cur = state.value ?? const AppSettings();
    state = AsyncData(cur.copyWith(tiltEnabled: v));
  }

  Future<void> setThemeMode(ThemeMode m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, m.index);
    final cur = state.value ?? const AppSettings();
    state = AsyncData(cur.copyWith(themeMode: m));
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
        SettingsController.new);

/// Helper baca sinkron dengan fallback default.
extension SettingsX on AsyncValue<AppSettings> {
  AppSettings get orDefault => value ?? const AppSettings();
}
