import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'app/app.dart';

/// Entry point aplikasi WorthBang.
///
/// Semua teks user-facing berbahasa Indonesia (lihat [lib/l10n]).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Default locale Indonesia untuk formatter intl (Rp, tanggal).
  Intl.defaultLocale = 'id_ID';
  runApp(const ProviderScope(child: WorthBangApp()));
}
