import 'package:flutter/material.dart';

import '../../history/presentation/history_screen.dart';
import '../../price_check/presentation/price_check_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../search/presentation/search_screen.dart';

/// Tab Beranda: form cek harga (T3).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const PriceCheckScreen();
}

/// Tab Cari: filter & sort hasil (T5).
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) => const SearchFilterScreen();
}

/// Tab Riwayat: daftar + verifikasi hash chain (T6).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => const HistoryListScreen();
}

/// Tab Profil (T14).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => const ProfileContentScreen();
}
