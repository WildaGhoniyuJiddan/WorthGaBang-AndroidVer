import 'package:flutter/material.dart';

import '../../../l10n/strings.dart';
import '../../price_check/presentation/price_check_screen.dart';

/// Tab Beranda: form cek harga (T3).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const PriceCheckScreen();
}

/// Placeholder tab Cari — diganti Search & filter di T4.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderTab(
      title: AppStrings.searchTitle,
      message: AppStrings.searchPlaceholder,
      icon: Icons.search_outlined,
    );
  }
}

/// Placeholder tab Riwayat — diganti History list di T5.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderTab(
      title: AppStrings.historyTitle,
      message: AppStrings.historyPlaceholder,
      icon: Icons.history_outlined,
    );
  }
}

/// Placeholder tab Profil — diganti Profile di T6.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderTab(
      title: AppStrings.profileTitle,
      message: AppStrings.profilePlaceholder,
      icon: Icons.person_outline,
    );
  }
}

/// Layout placeholder bersama untuk keempat tab.
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
