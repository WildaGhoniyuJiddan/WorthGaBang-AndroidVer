import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';

final alertsApiProvider = Provider<AlertsApi>(
  (ref) => AlertsApi(ref.watch(apiClientProvider)),
);

/// Price alert (kontrak: B3 GET/POST/DELETE /api/v1/alerts).
class PriceAlert {
  const PriceAlert({
    required this.id,
    required this.query,
    required this.targetPrice,
    this.mode = 'pc',
    this.currentPrice,
    this.isActive = true,
  });

  final int id;
  final String query;
  final int targetPrice;
  final String mode;
  final int? currentPrice;
  final bool isActive;

  factory PriceAlert.fromJson(Map<String, dynamic> json) =>
      PriceAlert(
        id: (json['id'] as num).toInt(),
        query: json['query'] as String? ?? '',
        targetPrice: (json['target_price'] as num).toInt(),
        mode: json['mode'] as String? ?? 'pc',
        currentPrice: (json['current_price'] as num?)?.toInt(),
        isActive: json['is_active'] as bool? ?? true,
      );
}

class AlertsApi {
  AlertsApi(this._client);

  final ApiClient _client;

  Future<List<PriceAlert>> getAlerts() async {
    final json = await _client.getJson('/api/v1/alerts');
    return ((json['items'] as List?) ?? [])
        .map((e) => PriceAlert.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PriceAlert> addAlert({
    required String query,
    required String mode,
    required int targetPrice,
    String condition = 'any',
  }) async {
    final json = await _client.postJson('/api/v1/alerts', body: {
      'query': query,
      'mode': mode,
      'target_price': targetPrice,
      'condition': condition,
    });
    return PriceAlert.fromJson(json);
  }

  Future<void> deleteAlert(int id) =>
      _client.delete('/api/v1/alerts/$id');
}
