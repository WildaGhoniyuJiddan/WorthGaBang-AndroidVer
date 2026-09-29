import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/work_manager.dart';
import '../features/alerts/data/alert_check_service.dart';
import '../features/profile/data/profile_api.dart';
import 'router.dart';
import 'theme.dart';

/// Root widget aplikasi WorthBang.
class WorthBangApp extends ConsumerStatefulWidget {
  const WorthBangApp({super.key});

  @override
  ConsumerState<WorthBangApp> createState() => _WorthBangAppState();
}

class _WorthBangAppState extends ConsumerState<WorthBangApp> {
  Timer? _alertTimer;

  @override
  void initState() {
    super.initState();
    // Fallback foreground: cek alert tiap 15 menit selagi app terbuka.
    // (Di widget test, provider di-override — timer tetap jalan tapi
    // checkNow memakai FakeApiClient bila di-override.)
    _startChecker();
  }

  Future<void> _startChecker() async {
    try {
      final service = await ref.read(alertCheckServiceProvider.future);
      if (mounted) {
        _alertTimer = startForegroundAlertChecker(service: service);
      }
    } catch (_) {
      // Mis. SharedPreferences belum siap di test — abaikan.
    }
  }

  @override
  void dispose() {
    _alertTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode =
        ref.watch(settingsControllerProvider).orDefault.themeMode;
    return MaterialApp.router(
      title: 'WorthBang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      // Semua string hardcode berbahasa Indonesia, terpusat di lib/l10n.
      locale: const Locale('id', 'ID'),
    );
  }
}
