import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/network/api_result.dart';
import '../../../core/utils/rupiah.dart';
import '../../../l10n/strings.dart';
import '../data/store_models.dart';
import '../data/stores_api.dart';

/// Koordinat fallback (demo Jakarta) bila izin lokasi ditolak / gagal.
const _demoLat = -6.2088;
const _demoLng = 106.8456;

/// Layar Toko Terdekat: peta + daftar termurah untuk produk yang dicari.
class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen> {
  final _query = TextEditingController();
  ApiResult<List<Store>>? _state;
  LatLng _center = const LatLng(_demoLat, _demoLng);
  bool _usingDemoLocation = true;

  @override
  void initState() {
    super.initState();
    _query.text = widget.initialQuery;
    _locateAndLoad();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _locateAndLoad() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.medium),
        ).timeout(const Duration(seconds: 8));
        _center = LatLng(pos.latitude, pos.longitude);
        _usingDemoLocation = false;
      }
    } catch (_) {
      // Tetap pakai lokasi demo.
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() => _state = const ApiLoading());
    try {
      final stores = await ref.read(storesApiProvider).nearby(
            lat: _center.latitude,
            lng: _center.longitude,
          );
      setState(() => _state = ApiSuccess(stores));
    } catch (e) {
      setState(() => _state = ApiError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final stores =
        state is ApiSuccess<List<Store>> ? state.data : null;
    final q = _query.text.trim();
    final withPrice = (stores ?? [])
        .map((s) => (store: s, price: q.isEmpty ? null : s.priceFor(q)))
        .toList()
      ..sort((a, b) {
        // Yang punya harga dulu, termurah pertama; tanpa harga urut jarak.
        if (a.price != null && b.price != null) {
          return a.price!.compareTo(b.price!);
        }
        if (a.price != null) return -1;
        if (b.price != null) return 1;
        return a.store.distanceKm.compareTo(b.store.distanceKm);
      });

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.storesTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _query,
                      decoration: const InputDecoration(
                        labelText: AppStrings.queryLabel,
                        prefixIcon: Icon(Icons.store_outlined),
                        isDense: true,
                      ),
                      onSubmitted: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: state is ApiLoading ? null : _load,
                    child: const Text(AppStrings.refreshLabel),
                  ),
                ],
              ),
            ),
            if (_usingDemoLocation)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  AppStrings.demoLocationNote,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            SizedBox(
              height: 220,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    // WAJIB: identifikasi aplikasi ke tile server OSM
                    // (tanpa ini request bisa diblokir).
                    userAgentPackageName: 'com.worthbang.worthbang',
                    maxNativeZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _center,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.my_location,
                            color: Colors.blue, size: 32),
                      ),
                      for (final s in stores ?? [])
                        Marker(
                          point: LatLng(s.lat, s.lng),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 32),
                        ),
                    ],
                  ),
                  // Wajib lisensi OSM: tampilkan atribusi kontributor.
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch (state) {
                ApiLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ApiError<List<Store>> e => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(e.message,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .error)),
                    ),
                  ),
                _ => withPrice.isEmpty
                    ? const Center(
                        child: Text(AppStrings.storesEmpty))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: withPrice.length,
                        itemBuilder: (context, i) {
                          final entry = withPrice[i];
                          final s = entry.store;
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.store),
                              title: Text(s.name),
                              subtitle: Text(
                                '${s.address}\n${s.distanceKm.toStringAsFixed(1)} km',
                              ),
                              isThreeLine: true,
                              trailing: entry.price != null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (i == 0 &&
                                            withPrice.length > 1)
                                          const Text(
                                            AppStrings.cheapestLabel,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        Text(
                                          formatRupiah(entry.price!),
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
