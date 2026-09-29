import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

/// Nama task & tag untuk pengecekan price alert berkala.
const String priceAlertTaskName = 'worthbang.priceAlertCheck';

/// Entry point background — wajib top-level & annotated agar bisa
/// dipanggil isolate background WorkManager.
@pragma('vm:entry-point')
void workmanagerCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case priceAlertTaskName:
        // T7: baca price_alerts aktif dari Drift, bandingkan harga terbaru,
        // kirim notifikasi bila <= target. Untuk T1: no-op sukses.
        debugPrint('WorthBang: price alert check berjalan.');
        return true;
    }
    return true;
  });
}

/// Inisialisasi WorkManager: cek price alert tiap 15 menit.
///
/// Dipanggil sekali dari [main]. Tidak dipanggil di widget test
/// (butuh platform channel asli).
Future<void> initWorkManager() async {
  await Workmanager().initialize(workmanagerCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'worthbang-price-alert-periodic',
    priceAlertTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );
}
