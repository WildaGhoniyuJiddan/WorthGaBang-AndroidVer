import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'store_models.dart';

final storesApiProvider = Provider<StoresApi>((ref) => StoresApi());

/// Toko terdekat — sekarang 100% lokal dari assets/data/stores_jakarta.csv.
/// Tidak butuh backend maupun jaringan.
class StoresApi {
  List<_CsvStore>? _cache;

  Future<List<_CsvStore>> _load() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(
      'assets/data/stores_jakarta.csv',
    );
    final rows = _parseCsv(raw);
    final out = <_CsvStore>[];
    for (var i = 1; i < rows.length; i++) {
      final r = rows[i];
      if (r.length < 6) continue;
      Map<String, int> prices = {};
      try {
        final pj = jsonDecode(r[5]) as Map<String, dynamic>;
        prices = pj.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {}
      out.add(_CsvStore(
        id: i,
        name: r[0],
        address: r[1],
        lat: double.tryParse(r[3]) ?? 0,
        lng: double.tryParse(r[4]) ?? 0,
        prices: prices,
      ));
    }
    _cache = out;
    return out;
  }

  Future<List<Store>> nearby({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    final stores = await _load();
    final result = <Store>[];
    for (final s in stores) {
      final d = _haversineKm(lat, lng, s.lat, s.lng);
      if (d <= radiusKm) {
        result.add(Store(
          id: s.id,
          name: s.name,
          address: s.address,
          lat: s.lat,
          lng: s.lng,
          distanceKm: d,
          prices: s.prices,
        ));
      }
    }
    result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return result;
  }
}

class _CsvStore {
  _CsvStore({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.prices,
  });

  final int id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final Map<String, int> prices;
}

double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  final dLat = _rad(lat2 - lat1);
  final dLng = _rad(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  return 2 * r * asin(sqrt(a));
}

double _rad(double deg) => deg * pi / 180;

/// Parser CSV minimal: dukung field ber-quote ("...") berisi koma.
List<List<String>> _parseCsv(String raw) {
  final rows = <List<String>>[];
  var row = <String>[];
  final buf = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < raw.length; i++) {
    final ch = raw[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < raw.length && raw[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        buf.write(ch);
      }
    } else if (ch == '"') {
      inQuotes = true;
    } else if (ch == ',') {
      row.add(buf.toString());
      buf.clear();
    } else if (ch == '\n' || ch == '\r') {
      if (ch == '\r' && i + 1 < raw.length && raw[i + 1] == '\n') i++;
      row.add(buf.toString());
      buf.clear();
      if (row.any((c) => c.isNotEmpty)) rows.add(row);
      row = <String>[];
    } else {
      buf.write(ch);
    }
  }
  if (buf.isNotEmpty || row.isNotEmpty) {
    row.add(buf.toString());
    rows.add(row);
  }
  return rows;
}
