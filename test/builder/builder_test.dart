import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:worthbang/core/sensors/shake_detector.dart';
import 'package:worthbang/features/builder/data/builder_models.dart';

void main() {
  group('RandomBuild.fromJson (kontrak B6)', () {
    test('parse response lengkap', () {
      final b = RandomBuild.fromJson({
        'cpu': {'name': 'Ryzen 5 5600', 'price': 1850000},
        'gpu': {'name': 'RTX 4060 8GB', 'price': 4790000},
        'ram': {'name': 'TeamGroup 2x8GB', 'price': 650000},
        'ssd': {'name': 'ADATA 512GB', 'price': 550000},
        'psu': {'name': 'MSI 550W', 'price': 750000},
        'total': 8590000,
        'budget': 10000000,
      });
      expect(b.cpu.name, 'Ryzen 5 5600');
      expect(b.parts.length, 5);
      expect(b.total, 8590000);
      expect(b.total <= b.budget, isTrue);
    });
  });

  group('ShakeDetector', () {
    test('goyangan kuat memicu callback', () async {
      final ctrl = StreamController<AccelerometerEvent>();
      var shakes = 0;
      final d = ShakeDetector(
        stream: ctrl.stream,
        threshold: 5.0,
        cooldown: Duration.zero,
      );
      d.start(() => shakes++);

      ctrl.add(AccelerometerEvent(0, 0, 9.8, DateTime.now()));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(shakes, 0); // sampel pertama = baseline

      // Gerakan kecil: di bawah threshold.
      ctrl.add(AccelerometerEvent(0.5, 0.3, 9.9, DateTime.now()));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(shakes, 0);

      // Goyangan kuat.
      ctrl.add(AccelerometerEvent(12, -8, 2, DateTime.now()));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(shakes, 1);

      d.stop();
      await ctrl.close();
    });

    test('cooldown menahan trigger ganda', () async {
      final ctrl = StreamController<AccelerometerEvent>();
      var shakes = 0;
      final d = ShakeDetector(
        stream: ctrl.stream,
        threshold: 5.0,
        cooldown: const Duration(seconds: 30),
      );
      d.start(() => shakes++);

      ctrl.add(AccelerometerEvent(0, 0, 9.8, DateTime.now()));
      ctrl.add(AccelerometerEvent(12, -8, 2, DateTime.now()));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      ctrl.add(AccelerometerEvent(-12, 8, 18, DateTime.now()));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(shakes, 1);

      d.stop();
      await ctrl.close();
    });
  });
}
