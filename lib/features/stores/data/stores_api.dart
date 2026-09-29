import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import 'store_models.dart';

final storesApiProvider = Provider<StoresApi>(
  (ref) => StoresApi(ref.watch(apiClientProvider)),
);

/// API toko terdekat (B4 GET /api/v1/stores/nearby).
class StoresApi {
  StoresApi(this._client);

  final ApiClient _client;

  Future<List<Store>> nearby({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    final json = await _client.getJson(
      '/api/v1/stores/nearby',
      query: {
        'lat': '$lat',
        'lng': '$lng',
        'radius_km': '$radiusKm',
      },
    );
    return ((json['stores'] as List?) ?? [])
        .map((e) => Store.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
