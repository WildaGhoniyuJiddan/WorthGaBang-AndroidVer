import 'package:flutter/material.dart';

/// Tema aplikasi WorthBang: light & dark.
///
/// Aturan aksesibilitas: warna verdict (hijau/amber/merah) TIDAK PERNAH
/// berdiri sendiri — selalu disertai label teks (lihat [VerdictBadge]).
abstract final class AppTheme {
  /// Hijau — harga "worth it" / sangat murah.
  static const Color verdictGood = Color(0xFF2E7D32);

  /// Amber — harga wajar.
  static const Color verdictFair = Color(0xFFF9A825);

  /// Merah — kemahalan.
  static const Color verdictBad = Color(0xFFC62828);

  static const _seed = Color(0xFF1B5E20);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.light,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      );

  /// Warna verdict sesuai skor 0–100 (diselaraskan dengan backend scoring).
  static Color verdictColorFor(double score) {
    if (score >= 75) return verdictGood;
    if (score >= 50) return verdictFair;
    return verdictBad;
  }
}
