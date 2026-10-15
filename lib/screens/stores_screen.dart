import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:worthbang/services/api_result.dart';
import 'package:worthbang/utils/rupiah.dart';
import 'package:worthbang/l10n/strings.dart';
import 'package:worthbang/models/store_models.dart';
import 'package:worthbang/services/stores_api.dart';

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
  final _mapController = MapController();
  ApiResult<List<Store>>? _state;
  LatLng _center = const LatLng(_demoLat, _demoLng);
  bool _usingDemoLocation = true;
  bool _mapReady = false;
  bool _isLocating = false;
  String? _locationMessage;

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
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
      _locationMessage = null;
    });
    String? locationMessage;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        locationMessage =
            'Aktifkan layanan lokasi/GPS untuk memakai lokasi Anda.';
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.deniedForever) {
        locationMessage = 'Izin lokasi diblokir. Buka Pengaturan aplikasi untuk mengizinkannya.';
        return;
      }

      if (perm != LocationPermission.always &&
          perm != LocationPermission.whileInUse) {
        locationMessage =
            'Izin lokasi ditolak. Peta tetap memakai lokasi demo Jakarta.';
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 12));
      if (!mounted) return;
      final location = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _center = location;
        _usingDemoLocation = false;
      });
      if (_mapReady) _mapController.move(location, 13);
    } on LocationServiceDisabledException {
      locationMessage =
          'Aktifkan layanan lokasi/GPS untuk memakai lokasi Anda.';
    } on TimeoutException {
      locationMessage =
          'Lokasi belum ditemukan. Pastikan GPS aktif lalu coba lagi.';
    } catch (e) {
      locationMessage = 'Lokasi gagal didapatkan: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
          _locationMessage = locationMessage;
        });
        await _load();
      }
    }
  }

  Future<void> _load() async {
    setState(() => _state = const ApiLoading());
    try {
      final stores = await ref
          .read(storesApiProvider)
          .nearby(lat: _center.latitude, lng: _center.longitude);
      if (!mounted) return;
      setState(() => _state = ApiSuccess(stores));
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = ApiError(e.toString()));
    }
  }

  Future<void> _openLocationSettings() async {
    final opened = await Geolocator.openAppSettings();
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan aplikasi tidak dapat dibuka.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final stores = state is ApiSuccess<List<Store>> ? state.data : null;
    final q = _query.text.trim();
    final withPrice =
        (stores ?? [])
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
            if (_usingDemoLocation || _locationMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _locationMessage ?? AppStrings.demoLocationNote,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    if (_locationMessage?.contains('Pengaturan') ?? false)
                      TextButton(
                        onPressed: _openLocationSettings,
                        child: const Text('Pengaturan'),
                      ),
                  ],
                ),
              ),
            SizedBox(
              height: 220,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 13,
                      onMapReady: () {
                        _mapReady = true;
                        _mapController.move(_center, 13);
                      },
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
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),
                          for (final s in stores ?? [])
                            Marker(
                              point: LatLng(s.lat, s.lng),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 32,
                              ),
                            ),
                        ],
                      ),
                      // Wajib lisensi OSM: tampilkan atribusi kontributor.
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution('OpenStreetMap contributors'),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: FloatingActionButton.small(
                      heroTag: 'stores-current-location',
                      tooltip: 'Ke lokasi saya',
                      onPressed: _isLocating ? null : _locateAndLoad,
                      child: _isLocating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                    ),
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
                    child: Text(
                      e.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
                _ =>
                  withPrice.isEmpty
                      ? const Center(child: Text(AppStrings.storesEmpty))
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
                                          if (i == 0 && withPrice.length > 1)
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
                                              fontWeight: FontWeight.bold,
                                            ),
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
