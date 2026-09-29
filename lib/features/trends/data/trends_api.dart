import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import 'trend_models.dart';

final trendsApiProvider = Provider<TrendsApi>(
  (ref) => TrendsApi(ref.watch(apiClientProvider)),
);

/// API tren harga (B5 GET /api/v1/trend).
class TrendsApi {
  TrendsApi(this._client);

  final ApiClient _client;

  Future<TrendData> getTrend(String query, {int days = 30}) async {
    final json = await _client.getJson(
      '/api/v1/trend',
      query: {'query': query, 'days': '$days'},
    );
    return TrendData.fromJson(json);
  }
}
