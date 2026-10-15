import 'package:flutter/material.dart';

import 'package:worthbang/l10n/strings.dart';
import 'package:worthbang/screens/builder_screen.dart';
import 'package:worthbang/screens/chat_screen.dart';
import 'package:worthbang/screens/game_screen.dart';
import 'package:worthbang/screens/price_check_screen.dart';
import 'package:worthbang/screens/search_screen.dart';
import 'package:worthbang/screens/stores_screen.dart';
import 'package:worthbang/screens/tools_screen.dart';
import 'package:worthbang/screens/trends_screen.dart';
import 'package:worthbang/screens/wishlist_screen.dart';
import 'package:worthbang/widgets/app_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _menus = <_HomeMenuItem>[
    _HomeMenuItem(
      title: AppStrings.builderTitle,
      subtitle: AppStrings.homeBuilderSubtitle,
      icon: Icons.handyman_outlined,
      page: () => const BuilderScreen(),
    ),
    _HomeMenuItem(
      title: AppStrings.searchScreenTitle,
      subtitle: AppStrings.homeSearchSubtitle,
      icon: Icons.search_rounded,
      page: () => const SearchFilterScreen(),
    ),
    _HomeMenuItem(
      title: AppStrings.trendTitle,
      subtitle: AppStrings.homeTrendsSubtitle,
      icon: Icons.show_chart_rounded,
      page: () => const TrendsScreenContent(),
    ),
    _HomeMenuItem(
      title: AppStrings.storesTitle,
      subtitle: AppStrings.homeStoresSubtitle,
      icon: Icons.store_outlined,
      page: () => const StoresScreen(),
    ),
    _HomeMenuItem(
      title: AppStrings.toolsTitle,
      subtitle: AppStrings.homeToolsSubtitle,
      icon: Icons.calculate_outlined,
      page: () => const ToolsScreen(),
    ),
    _HomeMenuItem(
      title: AppStrings.wishlistTitle,
      subtitle: AppStrings.homeWishlistSubtitle,
      icon: Icons.favorite_border_rounded,
      page: () => const WishlistAlertsScreen(),
    ),
    _HomeMenuItem(
      title: AppStrings.gameTitle,
      subtitle: AppStrings.homeGameSubtitle,
      icon: Icons.sports_esports_outlined,
      page: () => const GameScreen(),
    ),
    _HomeMenuItem(
      title: AppStrings.chatTitle,
      subtitle: AppStrings.homeChatSubtitle,
      icon: Icons.smart_toy_outlined,
      page: () => const ChatScreen(),
    ),
  ];

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: AppLogo(size: 40, borderRadius: 10),
        ),
        title: const Text(AppStrings.homeTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            AppStrings.homeGreeting,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.appTagline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: colors.primaryContainer,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openPage(context, const PriceCheckScreen()),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.price_check_rounded,
                      size: 38,
                      color: colors.onPrimaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.priceCheckTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.homePriceCheckSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: colors.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.homeExploreTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 600 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _menus.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: columns == 2 ? 1.16 : 1.05,
                ),
                itemBuilder: (context, index) {
                  final menu = _menus[index];
                  return _HomeMenuCard(
                    item: menu,
                    onTap: () => _openPage(context, menu.page()),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeMenuItem {
  const _HomeMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() page;
}

class _HomeMenuCard extends StatelessWidget {
  const _HomeMenuCard({
    required this.item,
    required this.onTap,
  });

  final _HomeMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, size: 28, color: colors.primary),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
