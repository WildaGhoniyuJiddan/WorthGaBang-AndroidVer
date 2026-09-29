import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/tabs/presentation/tab_screens.dart';
import '../l10n/strings.dart';

/// Kunci navigator per tab — masing-masing tab punya back stack sendiri.
final _homeNavKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _searchNavKey = GlobalKey<NavigatorState>(debugLabel: 'searchNav');
final _historyNavKey = GlobalKey<NavigatorState>(debugLabel: 'historyNav');
final _profileNavKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');

/// Router aplikasi: bottom NavigationBar 4 tab dengan back stack per tab.
///
/// [StatefulShellRoute.indexedStack] menjaga state tiap tab (termasuk
/// riwayat navigasi di dalamnya) saat user berpindah tab.
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          BottomNavShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _searchNavKey,
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _historyNavKey,
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _profileNavKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Shell bottom navigation: 4 tab sesuai PRD (Beranda, Cari, Riwayat, Profil).
class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Kembali ke root tab bila tab aktif di-tap ulang.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: AppStrings.tabHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: AppStrings.tabSearch,
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: AppStrings.tabHistory,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppStrings.tabProfile,
          ),
        ],
      ),
    );
  }
}
