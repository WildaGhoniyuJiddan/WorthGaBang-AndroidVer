import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

/// Root widget aplikasi WorthBang.
class WorthBangApp extends ConsumerWidget {
  const WorthBangApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'WorthBang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Ikuti tema sistem; user bisa override nanti dari Profil (T6).
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      // Semua string hardcode berbahasa Indonesia, terpusat di lib/l10n.
      locale: const Locale('id', 'ID'),
    );
  }
}
