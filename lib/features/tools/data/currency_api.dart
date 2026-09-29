import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';

final currencyApiProvider = Provider<CurrencyApi>(
  (ref) => CurrencyApi(ref.watch(apiClientProvider)),
);

/// API kurs (B9 GET /api/v1/currency/rates).
class CurrencyApi {
  CurrencyApi(this._client);

  final ApiClient _client;

  Future<CurrencyRates> getRates({String base = 'IDR'}) async {
    final json = await _client.getJson(
      '/api/v1/currency/rates',
      query: {'base': base},
    );
    return CurrencyRates.fromJson(json);
  }
}

class CurrencyRates {
  const CurrencyRates({
    required this.base,
    required this.rates,
    this.updatedAt,
  });

  final String base;
  final Map<String, double> rates;
  final DateTime? updatedAt;

  factory CurrencyRates.fromJson(Map<String, dynamic> json) {
    final r = (json['rates'] as Map?)?.cast<String, dynamic>() ?? {};
    DateTime? updated;
    final u = json['updated_at'] as String?;
    if (u != null) updated = DateTime.tryParse(u);
    return CurrencyRates(
      base: json['base'] as String? ?? 'IDR',
      rates: r.map((k, v) => MapEntry(k, (v as num).toDouble())),
      updatedAt: updated,
    );
  }
}

/// Konversi nominal: rates dinyatakan per 1 [base] (mis. 1 IDR = x USD).
double convertCurrency(double amount, double rate) => amount * rate;

/// Zona waktu Indonesia (offset jam dari UTC).
enum WibZone {
  wib('WIB', 7),
  wita('WITA', 8),
  wit('WIT', 9),
  utc('UTC', 0);

  const WibZone(this.label, this.offsetHours);
  final String label;
  final int offsetHours;
}

/// Konversi waktu antar zona: [dt] dianggap sudah dalam zona [from].
DateTime convertTimezone(DateTime dt, WibZone from, WibZone to) {
  final utc = dt.subtract(Duration(hours: from.offsetHours));
  return utc.add(Duration(hours: to.offsetHours));
}
