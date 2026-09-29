import 'dart:async';

import 'api_client.dart';
import 'api_exception.dart';

/// [ApiClient] palsu untuk demo & test widget.
///
/// Mengikuti bentuk request/response di API_CONTRACT.md (B1–B9) dengan data
/// contoh Bahasa Indonesia. Tidak melakukan panggilan jaringan sama sekali.
class FakeApiClient implements ApiClient {
  FakeApiClient();

  final _logoutController = StreamController<void>.broadcast();

  /// Bila true, refresh berikutnya gagal 401 → memicu logout paksa.
  bool failRefresh = false;

  static const _fakeTokens = {
    'access_token': 'fake-access-token',
    'refresh_token': 'fake-refresh-token',
    'token_type': 'bearer',
  };

  static Map<String, dynamic> _authResponse() => {
        ..._fakeTokens,
        'user': {
          'id': 1,
          'name': 'Dan',
          'email': 'dan@example.com',
          'photo_url': null,
        },
      };

  @override
  Stream<void> get onForceLogout => _logoutController.stream;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return switch (path) {
      '/api/v1/history' => {
          'items': [
            {
              'id': 12,
              'mode': 'pc',
              'query': 'RTX 4060',
              'input_price': 4500000,
              'score': 82.5,
              'verdict': 'wajar',
              'created_at': '2026-09-28T10:00:00Z',
            },
          ],
        },
      '/api/v1/wishlist' => {
          'items': [
            {
              'id': 3,
              'query': 'Ryzen 5 7600',
              'mode': 'pc',
              'target_price': 2800000,
              'created_at': '2026-09-27T08:30:00Z',
            },
          ],
        },
      '/api/v1/alerts' => {
          'items': [
            {
              'id': 5,
              'query': 'RTX 4060',
              'mode': 'pc',
              'target_price': 4200000,
              'current_price': 4500000,
              'is_active': true,
              'created_at': '2026-09-26T12:00:00Z',
            },
          ],
        },
      '/api/v1/freshness' => {
          'last_scrape_at': '2026-09-29T06:00:00Z',
          'sources': ['tokopedia', 'shopee'],
        },
      _ when path.startsWith('/api/v1/suggest/') => {
          'section': 'pc',
          'suggestions': ['RTX 4060 8GB', 'RTX 4060 Ti 8GB'],
        },
      _ when path.startsWith('/api/v1/trend') => () {
          final q = query?['query'] as String? ?? 'RTX 4060';
          final days = int.tryParse(query?['days']?.toString() ?? '30') ?? 30;
          final now = DateTime.now();
          final points = List.generate(days, (i) {
            final d = now.subtract(Duration(days: days - 1 - i));
            // Pola turun landai + noise deterministik (fake).
            final price = 4800000 - (i * 8000) - ((i * 37) % 90000);
            return {
              'date':
                  '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
              'price': price,
            };
          });
          final prices = points.map((p) => p['price'] as int).toList();
          final min = prices.reduce((a, b) => a < b ? a : b);
          final max = prices.reduce((a, b) => a > b ? a : b);
          final avg = prices.reduce((a, b) => a + b) / prices.length;
          final change = (prices.last - prices.first) / prices.first * 100;
          return {
            'query': q,
            'days': days,
            'points': points,
            'min': min,
            'max': max,
            'avg': avg,
            'change_percent': double.parse(change.toStringAsFixed(1)),
            'summary': null,
          };
        }(),
      _ when path.startsWith('/api/v1/game/question') => {
          'product_name': 'RTX 4060 8GB',
          'image_url': null,
          'price_min': 3000000,
          'price_max': 6000000,
        },
      _ when path.startsWith('/api/v1/currency/rates') => {
          'base': 'IDR',
          'rates': {
            'USD': 0.000062,
            'SGD': 0.000083,
            'MYR': 0.00029,
            'EUR': 0.000057,
          },
          'updated_at': DateTime.now().toIso8601String(),
        },
      _ when path.startsWith('/api/v1/stores/nearby') => {
          'stores': [
            {
              'id': 1,
              'name': 'Toko Komputer ABC',
              'address': 'Jl. Mangga Dua Raya No. 1, Jakarta',
              'lat': -6.19,
              'lng': 106.83,
              'distance_km': 1.2,
              'prices': {'RTX 4060': 4450000, 'Ryzen 5 5600': 1790000},
            },
            {
              'id': 2,
              'name': 'Enter Komputer',
              'address': 'Jl. Cempaka Mas No. 8, Jakarta',
              'lat': -6.22,
              'lng': 106.86,
              'distance_km': 2.5,
              'prices': {'RTX 4060': 4590000, 'Ryzen 5 5600': 1850000},
            },
            {
              'id': 3,
              'name': 'Nano Komputer',
              'address': 'Jl. Daan Mogot No. 45, Jakarta',
              'lat': -6.18,
              'lng': 106.79,
              'distance_km': 3.8,
              'prices': {'RTX 4060': 4380000},
            },
          ],
        },
      _ => throw const ApiException('Endpoint tidak dikenal di FakeApiClient', 404),
    };
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    switch (path) {
      case '/api/v1/auth/login':
        if (body?['email'] == 'gagal@example.com') {
          throw const ApiException('Invalid email or password', 401);
        }
        return _authResponse();
      case '/api/v1/auth/register':
        if (body?['email'] == 'dan@example.com') {
          throw const ApiException('Email already registered', 409);
        }
        return _authResponse();
      case '/api/v1/auth/refresh':
        if (failRefresh) {
          // Sesuai kontrak: refresh 401 → app harus logout paksa.
          _logoutController.add(null);
          throw const ApiException('Refresh token tidak valid', 401);
        }
        return _fakeTokens;
      case '/api/v1/auth/logout':
        return const {};
      case '/api/v1/wishlist':
        return {
          'id': 99,
          'query': body?['query'],
          'mode': body?['mode'],
          'target_price': body?['target_price'],
          'created_at': '2026-09-29T10:00:00Z',
        };
      case '/api/v1/alerts':
        return {
          'id': 100,
          'query': body?['query'],
          'mode': body?['mode'],
          'target_price': body?['target_price'],
          'current_price': 4500000,
          'is_active': true,
          'created_at': '2026-09-29T10:00:00Z',
        };
      case '/api/v1/analyze':
        final price = (body?['price'] as num?)?.toInt() ?? 4500000;
        return {
          'mode': body?['mode'] ?? 'pc',
          'query': body?['query'] ?? 'RTX 4060',
          'input_price': price,
          'score': 82.5,
          'verdict': 'wajar',
          'recommendation':
              'Harga masih dalam rentang wajar untuk kondisi pasar saat ini.',
          'reference_price': 4600000,
          'price_delta_percent': -2.2,
          'fair_price_low': 4200000,
          'fair_price_high': 4900000,
          'tier_label': null,
          'new_reference_price': 5200000,
          'used_reference_price': 4100000,
          'cross_market_advice': 'Bandingkan harga baru vs bekas.',
          'comparisons': [
            {
              'title': 'RTX 4060 8GB Dual Fan',
              'price': 4550000,
              'source': 'tokopedia',
              'listing_url': 'https://example.com/1',
              'similarity': 0.92,
              'condition': 'baru',
            },
            {
              'title': 'RTX 4060 8GB Bekas Mulus',
              'price': 3900000,
              'source': 'shopee',
              'listing_url': 'https://example.com/2',
              'similarity': 0.88,
              'condition': 'bekas',
            },
          ],
          'alternatives': [
            {
              'name': 'RTX 4060 Ti',
              'score': 12345,
              'est_price_idr': 6800000,
              'gain_percent': 18.0,
            },
          ],
          'freshness': {
            'last_updated_at': '2026-09-29T06:00:00Z',
            'age_seconds': 3600,
            'label': '1 jam lalu',
            'is_stale': false,
            'primary_source': 'tokopedia',
          },
        };
      case '/api/v1/analyze-bundle':
        final items = (body?['items'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
        return {
          'bundle_price': body?['bundle_price'] ?? 15000000,
          'reference_total': 14800000,
          'score': 78.0,
          'verdict': 'wajar',
          'recommendation': 'Harga paket masih wajar.',
          'savings_percent': 2.5,
          'items': [
            for (final it in items)
              {
                'query': it['query'] ?? '',
                'price': it['price'] ?? 0,
                'reference_price': 4600000,
                'score': 80.0,
                'verdict': 'wajar',
              },
          ],
        };
      case '/api/v1/chat/ask':
        return {
          'answer': 'Berdasarkan data pasar, harga tersebut masih wajar.',
        };
      case '/api/v1/game/submit':
        return {'correct': true, 'actual_price': 4500000, 'score_delta': 10};
      case '/api/v1/feedback':
        return const {'ok': true};
      case '/api/v1/builder/random':
        // Kontrak B6: cpu/gpu/ram/ssd/psu + total + budget.
        final budget = (body?['budget'] as num?)?.toInt() ?? 10000000;
        Map<String, dynamic> part(String name, double share) => {
              'name': name,
              'price': (budget * share).round(),
            };
        final cpu = part('Ryzen 5 5600', 0.18);
        final gpu = part('RTX 4060 8GB', 0.42);
        final ram = part('TeamGroup T-Force 2x8GB DDR4', 0.07);
        final ssd = part('ADATA Legend 710 512GB', 0.06);
        final psu = part('MSI MAG A550BN 550W', 0.08);
        final total = (cpu['price'] as int) +
            (gpu['price'] as int) +
            (ram['price'] as int) +
            (ssd['price'] as int) +
            (psu['price'] as int);
        return {
          'cpu': cpu,
          'gpu': gpu,
          'ram': ram,
          'ssd': ssd,
          'psu': psu,
          'total': total,
          'budget': budget,
        };
    }
    throw const ApiException('Endpoint tidak dikenal di FakeApiClient', 404);
  }

  @override
  Future<void> delete(String path) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    // Kontrak: DELETE wishlist/{id}, alerts/{id} → 204. Fake: selalu sukses.
  }

  @override
  void close() => _logoutController.close();
}
