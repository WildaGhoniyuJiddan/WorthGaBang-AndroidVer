import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang/core/network/api_client.dart';
import 'package:worthbang/features/alerts/data/alert_check_service.dart';
import 'package:worthbang/features/alerts/data/alerts_api.dart';
import 'package:worthbang/features/price_check/data/price_check_api.dart';

/// Stub ApiClient: alerts tetap, harga pasar bisa diatur per test.
class _StubClient implements ApiClient {
  _StubClient({required this.marketPrice});

  int marketPrice;

  @override
  Stream<void> get onForceLogout => const Stream.empty();

  @override
  Future<Map<String, dynamic>> getJson(String path,
      {Map<String, dynamic>? query}) async {
    if (path == '/api/v1/alerts') {
      return {
        'items': [
          {
            'id': 5,
            'query': 'RTX 4060',
            'mode': 'pc',
            'target_price': 4300000,
            'current_price': marketPrice,
            'is_active': true,
          },
          {
            'id': 6,
            'query': 'Ryzen 5 5600',
            'mode': 'pc',
            'target_price': 1500000,
            'current_price': 1800000,
            'is_active': false, // nonaktif → diabaikan
          },
        ],
      };
    }
    throw UnimplementedError(path);
  }

  @override
  Future<Map<String, dynamic>> postJson(String path,
      {Map<String, dynamic>? body}) async {
    if (path == '/api/v1/analyze') {
      return {
        'mode': 'pc',
        'query': body?['query'],
        'input_price': body?['price'],
        'reference_price': marketPrice,
        'score': 80.0,
        'verdict': 'wajar',
      };
    }
    throw UnimplementedError(path);
  }

  @override
  Future<void> delete(String path) async {}

  @override
  void close() {}
}

class _FakeNotifier implements PriceAlertNotifier {
  final List<(int, String, int, int)> sent = [];

  @override
  Future<void> showPriceAlert({
    required int id,
    required String query,
    required int currentPrice,
    required int targetPrice,
  }) async {
    sent.add((id, query, currentPrice, targetPrice));
  }
}

class _FakeDedup implements AlertDedupStore {
  final Map<int, int> _m = {};

  @override
  Future<bool> wasNotified(int alertId, int price) async =>
      _m[alertId] == price;

  @override
  Future<void> markNotified(int alertId, int price) async =>
      _m[alertId] = price;

  @override
  Future<void> clear(int alertId) async => _m.remove(alertId);

  bool get hasEntry => _m.isNotEmpty;
}

AlertCheckService _service(
    _StubClient client, _FakeNotifier notifier, _FakeDedup dedup) {
  return AlertCheckService(
    alertsApi: AlertsApi(client),
    priceCheckApi: PriceCheckApi(client),
    notifier: notifier,
    dedup: dedup,
  );
}

void main() {
  group('AlertCheckService.checkNow', () {
    test('harga ≤ target → notifikasi sekali (dedup)', () async {
      final client = _StubClient(marketPrice: 4200000);
      final notifier = _FakeNotifier();
      final dedup = _FakeDedup();
      final svc = _service(client, notifier, dedup);

      expect(await svc.checkNow(), 1);
      expect(notifier.sent.length, 1);
      expect(notifier.sent.first.$2, 'RTX 4060');

      // Cek kedua: harga sama → tidak notif lagi.
      expect(await svc.checkNow(), 0);
      expect(notifier.sent.length, 1);
    });

    test('harga > target → tidak notif, dedup direset', () async {
      final client = _StubClient(marketPrice: 4200000);
      final notifier = _FakeNotifier();
      final dedup = _FakeDedup();
      final svc = _service(client, notifier, dedup);

      expect(await svc.checkNow(), 1);
      expect(dedup.hasEntry, isTrue);

      // Harga naik di atas target → dedup dibersihkan.
      client.marketPrice = 4500000;
      expect(await svc.checkNow(), 0);
      expect(dedup.hasEntry, isFalse);

      // Harga turun lagi → notif ulang (1x).
      client.marketPrice = 4100000;
      expect(await svc.checkNow(), 1);
      expect(notifier.sent.length, 2);
    });

    test('alert nonaktif diabaikan', () async {
      final client = _StubClient(marketPrice: 1000000);
      final notifier = _FakeNotifier();
      final svc = _service(client, notifier, _FakeDedup());
      // Hanya alert id 5 aktif (target 4.3jt, pasar 1jt → terpicu).
      // Alert id 6 nonaktif meski pasar < target → tidak terpicu.
      expect(await svc.checkNow(), 1);
      expect(notifier.sent.map((e) => e.$1), [5]);
    });

    test('model PriceAlert.fromJson sesuai kontrak B3', () {
      final a = PriceAlert.fromJson({
        'id': 5,
        'query': 'RTX 4060',
        'target_price': 4300000,
        'current_price': 4600000,
        'is_active': true,
      });
      expect(a.id, 5);
      expect(a.targetPrice, 4300000);
      expect(a.currentPrice, 4600000);
      expect(a.isActive, isTrue);
    });
  });
}
