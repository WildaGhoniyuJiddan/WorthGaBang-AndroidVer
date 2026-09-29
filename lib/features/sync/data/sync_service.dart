import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_exception.dart';
import '../../alerts/data/alerts_api.dart';
import '../../profile/data/profile_api.dart';
import '../../wishlist/data/wishlist_api.dart';
import 'sync_queue.dart';

/// Hasil percobaan aksi yang butuh jaringan.
enum SyncOutcome {
  /// Terkirim langsung ke server.
  sent,

  /// Gagal jaringan → disimpan di antrian, dikirim saat online.
  queued,
}

/// Orkestrasi kirim-atau-antre + sinkronisasi ulang (T15).
class SyncService {
  SyncService({
    required this.queue,
    required this.profile,
    required this.wishlist,
    required this.alerts,
  });

  final SyncQueue queue;
  final ProfileApi profile;
  final WishlistApi wishlist;
  final AlertsApi alerts;

  static const lastSyncKey = 'sync_last_at';

  /// Jalankan [action]; bila gagal karena jaringan (ApiException tanpa
  /// statusCode), simpan [payload] ke antrian. Error server tetap dilempar.
  Future<SyncOutcome> runOrQueue({
    required String kind,
    required Map<String, dynamic> payload,
    required Future<void> Function() action,
  }) async {
    try {
      await action();
      await _touchLastSync();
      return SyncOutcome.sent;
    } on ApiException catch (e) {
      if (e.statusCode == null) {
        await queue.enqueue(kind, payload);
        return SyncOutcome.queued;
      }
      rethrow;
    }
  }

  /// Kirim semua antrian. Berhenti di item pertama yang masih gagal
  /// jaringan; item yang ditolak server (ada statusCode) dibuang.
  /// Mengembalikan sisa antrian.
  Future<int> syncPending() async {
    final items = await queue.pending();
    for (final m in items) {
      try {
        await _execute(
            m.kind, jsonDecode(m.payload) as Map<String, dynamic>);
        await queue.remove(m.id);
      } on ApiException catch (e) {
        if (e.statusCode == null) break; // masih offline
        await queue.remove(m.id); // ditolak server → buang
      }
    }
    await _touchLastSync();
    return queue.count();
  }

  Future<void> _execute(
      String kind, Map<String, dynamic> p) async {
    switch (kind) {
      case 'feedback':
        await profile.sendFeedback(
          rating: (p['rating'] as num).toInt(),
          kesan: p['kesan'] as String? ?? '',
          saran: p['saran'] as String? ?? '',
        );
      case 'wishlist':
        await wishlist.addWishlist(
          query: p['query'] as String,
          mode: p['mode'] as String,
          targetPrice: (p['target_price'] as num?)?.toInt(),
        );
      case 'alert':
        await alerts.addAlert(
          query: p['query'] as String,
          mode: p['mode'] as String,
          targetPrice: (p['target_price'] as num).toInt(),
        );
      default:
        throw ArgumentError('kind mutasi tak dikenal: $kind');
    }
  }

  Future<void> _touchLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    queue: ref.watch(syncQueueProvider),
    profile: ref.watch(profileApiProvider),
    wishlist: ref.watch(wishlistApiProvider),
    alerts: ref.watch(alertsApiProvider),
  );
});

/// Waktu sinkron terakhir yang sukses (ms epoch) — untuk "Terakhir
/// diperbarui" di Riwayat.
final lastSyncAtProvider = FutureProvider<DateTime?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final ms = prefs.getInt(SyncService.lastSyncKey);
  return ms == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(ms);
});
