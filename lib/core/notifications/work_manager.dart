import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/alerts/data/alert_check_service.dart';
import '../../features/alerts/data/alerts_api.dart';
import '../../features/price_check/data/price_check_api.dart';
import '../network/dio_api_client.dart';
import '../secure/token_storage.dart';

/// Nama task & tag untuk pengecekan price alert berkala.
const String priceAlertTaskName = 'worthbang.priceAlertCheck';

/// Entry point background — wajib top-level & annotated agar bisa
/// dipanggil isolate background WorkManager.
@pragma('vm:entry-point')
void workmanagerCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case priceAlertTaskName:
        try {
          // Rakit dependensi manual (tanpa Riverpod — isolate terpisah).
          final client = DioApiClient(tokenStorage: TokenStorage());
          final prefs = await SharedPreferences.getInstance();
          final service = AlertCheckService(
            alertsApi: AlertsApi(client),
            priceCheckApi: PriceCheckApi(client),
            notifier: LocalNotificationAlertNotifier(),
            dedup: SharedPrefsDedupStore(prefs),
          );
          final n = await service.checkNow();
          debugPrint('WorthBang: price alert check selesai, $n terpicu.');
          client.close();
          return true;
        } catch (e) {
          debugPrint('WorthBang: price alert check gagal: $e');
          return false;
        }
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

/// Fallback foreground: cek tiap 15 menit selagi app terbuka.
/// Dipakai bersama WorkManager (dedup mencegah notif ganda).
Timer startForegroundAlertChecker({
  required AlertCheckService service,
  Duration interval = const Duration(minutes: 15),
}) {
  return Timer.periodic(interval, (_) async {
    try {
      await service.checkNow();
    } catch (e) {
      debugPrint('WorthBang: foreground alert check gagal: $e');
    }
  });
}
