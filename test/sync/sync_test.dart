import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worthbang/core/network/api_exception.dart';
import 'package:worthbang/core/network/fake_api_client.dart';
import 'package:worthbang/core/storage/app_database.dart';
import 'package:worthbang/features/alerts/data/alerts_api.dart';
import 'package:worthbang/features/profile/data/profile_api.dart';
import 'package:worthbang/features/sync/data/sync_queue.dart';
import 'package:worthbang/features/sync/data/sync_service.dart';
import 'package:worthbang/features/wishlist/data/wishlist_api.dart';

AppDatabase _memDb() => AppDatabase(NativeDatabase.memory());

SyncService _service(SyncQueue q) {
  final fake = FakeApiClient();
  return SyncService(
    queue: q,
    profile: ProfileApi(fake),
    wishlist: WishlistApi(fake),
    alerts: AlertsApi(fake),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncQueue', () {
    test('enqueue → pending → remove → count', () async {
      final db = _memDb();
      addTearDown(db.close);
      final q = SyncQueue(db);

      expect(await q.count(), 0);
      await q.enqueue('feedback', {'rating': 5});
      await q.enqueue('wishlist', {'query': 'RTX 4060'});
      expect(await q.count(), 2);

      final items = await q.pending();
      expect(items.length, 2);
      expect(items.first.kind, 'feedback');

      await q.remove(items.first.id);
      expect(await q.count(), 1);
    });
  });

  group('SyncService.runOrQueue', () {
    test('sukses → sent, tanpa antrian', () async {
      SharedPreferences.setMockInitialValues({});
      final db = _memDb();
      addTearDown(db.close);
      final q = SyncQueue(db);

      final out = await _service(q).runOrQueue(
        kind: 'feedback',
        payload: {'rating': 5, 'kesan': 'ok', 'saran': '-'},
        action: () async {},
      );
      expect(out, SyncOutcome.sent);
      expect(await q.count(), 0);
    });

    test('gagal jaringan (tanpa statusCode) → queued', () async {
      SharedPreferences.setMockInitialValues({});
      final db = _memDb();
      addTearDown(db.close);
      final q = SyncQueue(db);

      final out = await _service(q).runOrQueue(
        kind: 'wishlist',
        payload: {'query': 'RTX 4060', 'mode': 'pc'},
        action: () =>
            throw const ApiException('Tidak dapat terhubung'),
      );
      expect(out, SyncOutcome.queued);
      expect(await q.count(), 1);
      final items = await q.pending();
      expect(items.single.kind, 'wishlist');
    });

    test('error server (ada statusCode) → dilempar, tidak diantre',
        () async {
      SharedPreferences.setMockInitialValues({});
      final db = _memDb();
      addTearDown(db.close);
      final q = SyncQueue(db);

      await expectLater(
        _service(q).runOrQueue(
          kind: 'alert',
          payload: {},
          action: () =>
              throw const ApiException('Validasi gagal', 422),
        ),
        throwsA(isA<ApiException>()),
      );
      expect(await q.count(), 0);
    });
  });

  group('SyncService.syncPending', () {
    test('antrian terkirim via FakeApiClient → kosong', () async {
      SharedPreferences.setMockInitialValues({});
      final db = _memDb();
      addTearDown(db.close);
      final q = SyncQueue(db);
      final svc = _service(q);

      await q.enqueue('feedback',
          {'rating': 4, 'kesan': 'bagus', 'saran': '-'});
      await q.enqueue('wishlist',
          {'query': 'RTX 4060', 'mode': 'pc', 'target_price': 4000000});
      await q.enqueue('alert',
          {'query': 'RX 7600', 'mode': 'pc', 'target_price': 3500000});

      final rest = await svc.syncPending();
      expect(rest, 0);
      expect(await q.count(), 0);
    });

    test('last sync tercatat di SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final db = _memDb();
      addTearDown(db.close);
      final svc = _service(SyncQueue(db));

      await svc.syncPending();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(SyncService.lastSyncKey), isNotNull);
    });
  });
}
