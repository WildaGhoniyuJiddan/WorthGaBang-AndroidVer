import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/rupiah.dart';
import '../../../l10n/strings.dart';
import '../../alerts/data/alert_check_service.dart';
import '../../alerts/data/alerts_api.dart';
import '../data/wishlist_api.dart';

/// Layar gabungan Wishlist & Alert Harga (dua tab).
class WishlistAlertsScreen extends ConsumerStatefulWidget {
  const WishlistAlertsScreen({super.key});

  @override
  ConsumerState<WishlistAlertsScreen> createState() =>
      _WishlistAlertsScreenState();
}

class _WishlistAlertsScreenState
    extends ConsumerState<WishlistAlertsScreen> {
  List<WishlistItem>? _wishlist;
  List<PriceAlert>? _alerts;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final w =
          await ref.read(wishlistApiProvider).getWishlist();
      final a = await ref.read(alertsApiProvider).getAlerts();
      if (mounted) {
        setState(() {
          _wishlist = w;
          _alerts = a;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _deleteWishlist(int id) async {
    await ref.read(wishlistApiProvider).deleteWishlist(id);
    await _reload();
  }

  Future<void> _deleteAlert(int id) async {
    await ref.read(alertsApiProvider).deleteAlert(id);
    await _reload();
  }

  /// Cek alert manual — memicu [AlertCheckService] langsung.
  Future<void> _checkNow() async {
    setState(() => _checking = true);
    try {
      final service = await ref.read(alertCheckServiceProvider.future);
      final n = await service.checkNow();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(n > 0
                ? '$n alert terpicu — cek notifikasi.'
                : AppStrings.alertCheckNone)),
      );
      await _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.wishlistTitle),
          bottom: const TabBar(
            tabs: [
              Tab(text: AppStrings.wishlistTab, icon: Icon(Icons.favorite_outline)),
              Tab(text: AppStrings.alertsTab, icon: Icon(Icons.notifications_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _wishlist == null
                ? const Center(child: CircularProgressIndicator())
                : _wishlist!.isEmpty
                    ? const Center(
                        child: Text(AppStrings.wishlistEmpty))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _wishlist!.length,
                        itemBuilder: (context, i) {
                          final w = _wishlist![i];
                          return Card(
                            child: ListTile(
                              title: Text(w.query),
                              subtitle: Text(
                                w.targetPrice != null
                                    ? 'Target: ${formatRupiah(w.targetPrice!)}'
                                    : 'Tanpa target harga',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _deleteWishlist(w.id),
                              ),
                            ),
                          );
                        },
                      ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FilledButton.icon(
                    onPressed: _checking ? null : _checkNow,
                    icon: _checking
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label:
                        const Text(AppStrings.checkAlertsNow),
                  ),
                ),
                Expanded(
                  child: _alerts == null
                      ? const Center(
                          child: CircularProgressIndicator())
                      : _alerts!.isEmpty
                          ? const Center(
                              child:
                                  Text(AppStrings.alertsEmpty))
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _alerts!.length,
                              itemBuilder: (context, i) {
                                final a = _alerts![i];
                                final hit = a.currentPrice != null &&
                                    a.currentPrice! <=
                                        a.targetPrice;
                                return Card(
                                  child: ListTile(
                                    leading: Icon(
                                      hit
                                          ? Icons.notifications_active
                                          : Icons
                                              .notifications_outlined,
                                      color: hit
                                          ? Colors.green
                                          : null,
                                    ),
                                    title: Text(a.query),
                                    subtitle: Text(
                                      'Target: ${formatRupiah(a.targetPrice)}'
                                      '${a.currentPrice != null ? ' • kini ${formatRupiah(a.currentPrice!)}' : ''}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline),
                                      onPressed: () =>
                                          _deleteAlert(a.id),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
