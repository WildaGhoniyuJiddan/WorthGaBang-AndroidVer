import 'package:worthbang/services/api_client.dart';
import 'package:worthbang/models/bundle_models.dart';
import 'package:worthbang/models/price_check_models.dart';

/// Akses endpoint pencarian dan price check backend.
class PriceCheckApi {
  PriceCheckApi(this._client);

  final ApiClient _client;

  /// POST /api/v1/analyze — analisis kelayakan satu harga.
  Future<AnalysisResult> analyze({
    required String mode, // 'pc' | 'laptop'
    required String query,
    required int price,
    String? componentType,
    String condition = 'any', // 'any' | 'baru' | 'bekas'
  }) async {
    final json = await _client.postJson(
      '/api/v1/analyze',
      body: {
        'mode': mode,
        'query': query,
        'price': price,
        'component_type': componentType,
        'condition': condition,
      },
    );
    return AnalysisResult.fromJson(json);
  }

  /// POST /api/v1/search — pencarian listing tanpa analisis benchmark.
  Future<List<PriceComparison>> search({
    required String mode,
    required String query,
    String? componentType,
    String condition = 'any',
  }) async {
    final json = await _client.postJson(
      '/api/v1/search',
      body: {
        'mode': mode,
        'query': query,
        'component_type': componentType,
        'condition': condition,
      },
    );
    return (json['comparisons'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PriceComparison.fromJson)
        .toList();
  }

  /// POST /api/v1/analyze-bundle — analisis paket 1–6 komponen.
  Future<BundleResult> analyzeBundle({
    required List<BundleInputItem> items,
    required int bundlePrice,
    String condition = 'any',
  }) async {
    final json = await _client.postJson(
      '/api/v1/analyze-bundle',
      body: {
        'items': items.map((e) => e.toJson()).toList(),
        'bundle_price': bundlePrice,
        'condition': condition,
      },
    );
    return BundleResult.fromJson(json);
  }

  /// GET /api/v1/suggest/{section} — autocomplete (frontend debounce 300ms).
  Future<List<String>> suggest({
    required String section, // 'pc' | 'laptop'
    required String query,
    int limit = 8,
  }) async {
    if (query.trim().length < 2) return const [];
    final json = await _client.getJson(
      '/api/v1/suggest/$section',
      query: {'q': query, 'limit': limit},
    );
    final raw = json['suggestions'] as List? ?? const [];
    // Backend bisa mengembalikan list string atau list objek {name,...}.
    return raw
        .map((e) {
          if (e is String) return e;
          if (e is Map) return (e['name'] ?? e['title'] ?? '').toString();
          return e.toString();
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
