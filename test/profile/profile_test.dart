import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worthbang/core/network/fake_api_client.dart';
import 'package:worthbang/features/profile/data/profile_api.dart';

void main() {
  group('ProfileApi (FakeApiClient, kontrak B9)', () {
    test('updateProfile nama', () async {
      final api = ProfileApi(FakeApiClient());
      final user = await api.updateProfile(name: 'Budi');
      expect(user.name, 'Budi');
      expect(user.email, 'dan@example.com');
    });

    test('updateProfile foto → photo_url terisi', () async {
      final api = ProfileApi(FakeApiClient());
      final user = await api.updateProfile(photoPath: '/tmp/foto.jpg');
      expect(user.photoUrl, isNotNull);
    });

    test('sendFeedback sukses', () async {
      final api = ProfileApi(FakeApiClient());
      await api.sendFeedback(rating: 5, kesan: 'Bagus', saran: '-');
    });
  });

  group('SettingsController', () {
    test('default + ubah tilt & tema tersimpan', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Tunggu hydrate dari disk selesai.
      await container.read(settingsControllerProvider.future);
      final ctrl =
          container.read(settingsControllerProvider.notifier);
      expect(container.read(settingsControllerProvider).orDefault.tiltEnabled,
          isTrue);
      expect(container.read(settingsControllerProvider).orDefault.themeMode,
          ThemeMode.system);

      await ctrl.setTiltEnabled(false);
      expect(container.read(settingsControllerProvider).orDefault.tiltEnabled,
          isFalse);

      await ctrl.setThemeMode(ThemeMode.dark);
      expect(container.read(settingsControllerProvider).orDefault.themeMode,
          ThemeMode.dark);

      // Persistensi: baca ulang dari prefs.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('settings_tilt_enabled'), isFalse);
      expect(prefs.getInt('settings_theme_mode'),
          ThemeMode.dark.index);
    });
  });
}
