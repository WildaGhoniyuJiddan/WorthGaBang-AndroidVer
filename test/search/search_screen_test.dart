import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang/models/price_check_models.dart';
import 'package:worthbang/screens/price_check_screen.dart';
import 'package:worthbang/screens/search_screen.dart';
import 'package:worthbang/services/api_client.dart';
import 'package:worthbang/services/api_exception.dart';
import 'package:worthbang/services/price_check_api.dart';

class _MockPriceCheckApi extends PriceCheckApi {
  _MockPriceCheckApi({this.onAnalyze}) : super(_DummyApiClient());

  final Future<AnalysisResult> Function({
    required String mode,
    required String query,
    required int price,
    String? componentType,
    String condition,
  })? onAnalyze;

  @override
  Future<AnalysisResult> analyze({
    required String mode,
    required String query,
    required int price,
    String? componentType,
    String condition = 'any',
  }) async {
    if (onAnalyze != null) {
      return onAnalyze!(
        mode: mode,
        query: query,
        price: price,
        componentType: componentType,
        condition: condition,
      );
    }
    return AnalysisResult.fromJson({
      'mode': mode,
      'query': query,
      'input_price': price,
      'score': 85.0,
      'verdict': 'worth it',
      'recommendation': 'Bagus.',
      'reference_price': 4000000,
      'price_delta_percent': 0.0,
      'comparisons': [
        {
          'title': 'Test Item $query',
          'price': 3500000,
          'source': 'tokopedia',
          'similarity': 0.9,
          'condition': 'baru',
        },
      ],
    });
  }
}

class _DummyApiClient implements ApiClient {
  @override
  Future<Map<String, dynamic>> getJson(String path, {Map<String, dynamic>? query}) async => {};
  @override
  Future<Map<String, dynamic>> postJson(String path, {Map<String, dynamic>? body}) async => {};
  @override
  Future<void> delete(String path) async {}
  @override
  Future<Map<String, dynamic>> putMultipart(String path, {Map<String, String>? fields, Map<String, String>? files}) async => {};
  @override
  Stream<void> get onForceLogout => const Stream.empty();
  @override
  void close() {}
}

void main() {
  group('SearchFilterScreen widget tests', () {
    testWidgets('Cari produk tanpa harga memanggil API dengan price 0 tanpa error', (tester) async {
      String? capturedMode;
      String? capturedQuery;
      int? capturedPrice;

      final mockApi = _MockPriceCheckApi(
        onAnalyze: ({
          required mode,
          required query,
          required price,
          componentType,
          condition = 'any',
        }) async {
          capturedMode = mode;
          capturedQuery = query;
          capturedPrice = price;
          return AnalysisResult.fromJson({
            'mode': mode,
            'query': query,
            'input_price': price,
            'score': 90.0,
            'verdict': 'worth it',
            'recommendation': 'Ok',
            'reference_price': 4000000,
            'price_delta_percent': 0.0,
            'comparisons': [
              {
                'title': 'GeForce RTX 3060 12GB',
                'price': 4200000,
                'source': 'tokopedia',
                'similarity': 0.95,
                'condition': 'baru',
              },
            ],
          });
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            priceCheckApiProvider.overrideWithValue(mockApi),
          ],
          child: const MaterialApp(
            home: SearchFilterScreen(),
          ),
        ),
      );

      // Input query saja, biarkan harga kosong
      final queryField = find.byType(TextField).first;
      await tester.enterText(queryField, 'RTX 3060');

      // Tekan tombol Cari
      final searchButton = find.widgetWithText(FilledButton, 'Cari');
      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      expect(capturedMode, 'pc');
      expect(capturedQuery, 'RTX 3060');
      expect(capturedPrice, 0);

      // Memastikan hasil listing tampil di layar
      expect(find.text('GeForce RTX 3060 12GB'), findsOneWidget);
      expect(find.text('tokopedia • baru'), findsOneWidget);
      expect(find.textContaining('ApiException'), findsNothing);
    });

    testWidgets('Jika price 0 menghasilkan 422, otomatis fallback ke price 1', (tester) async {
      int callCount = 0;
      final pricesSent = <int>[];

      final mockApi = _MockPriceCheckApi(
        onAnalyze: ({
          required mode,
          required query,
          required price,
          componentType,
          condition = 'any',
        }) async {
          callCount++;
          pricesSent.add(price);
          if (price == 0) {
            throw const ApiException('Input should be greater than 0', 422);
          }
          return AnalysisResult.fromJson({
            'mode': mode,
            'query': query,
            'input_price': price,
            'score': 80.0,
            'verdict': 'worth it',
            'recommendation': 'Ok',
            'reference_price': 3000000,
            'price_delta_percent': 0.0,
            'comparisons': [
              {
                'title': 'Fallback Result',
                'price': 3000000,
                'source': 'tokopedia',
                'similarity': 0.9,
              },
            ],
          });
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            priceCheckApiProvider.overrideWithValue(mockApi),
          ],
          child: const MaterialApp(
            home: SearchFilterScreen(),
          ),
        ),
      );

      final queryField = find.byType(TextField).first;
      await tester.enterText(queryField, 'GTX 1650');
      await tester.tap(find.widgetWithText(FilledButton, 'Cari'));
      await tester.pumpAndSettle();

      expect(callCount, 2);
      expect(pricesSent, [0, 1]);
      expect(find.text('Fallback Result'), findsOneWidget);
      expect(find.textContaining('ApiException'), findsNothing);
    });

    testWidgets('Menampilkan pesan error yang ramah jika terjadi kegagalan jaringan', (tester) async {
      final mockApi = _MockPriceCheckApi(
        onAnalyze: ({
          required mode,
          required query,
          required price,
          componentType,
          condition = 'any',
        }) async {
          throw const ApiException('Tidak dapat terhubung ke server.', 503);
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            priceCheckApiProvider.overrideWithValue(mockApi),
          ],
          child: const MaterialApp(
            home: SearchFilterScreen(),
          ),
        ),
      );

      final queryField = find.byType(TextField).first;
      await tester.enterText(queryField, 'Ryzen 5');
      await tester.tap(find.widgetWithText(FilledButton, 'Cari'));
      await tester.pumpAndSettle();

      expect(find.text('Tidak dapat terhubung ke server.'), findsOneWidget);
      expect(find.textContaining('ApiException(503):'), findsNothing);
    });

    testWidgets('Mode switch PC dan Laptop dapat dipilih', (tester) async {
      String? capturedMode;

      final mockApi = _MockPriceCheckApi(
        onAnalyze: ({
          required mode,
          required query,
          required price,
          componentType,
          condition = 'any',
        }) async {
          capturedMode = mode;
          return AnalysisResult.fromJson({
            'mode': mode,
            'query': query,
            'input_price': price,
            'score': 80.0,
            'verdict': 'worth it',
            'recommendation': 'Ok',
            'reference_price': 10000000,
            'price_delta_percent': 0.0,
            'comparisons': [],
          });
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            priceCheckApiProvider.overrideWithValue(mockApi),
          ],
          child: const MaterialApp(
            home: SearchFilterScreen(),
          ),
        ),
      );

      // Pilih segmen Laptop
      await tester.tap(find.text('Laptop'));
      await tester.pumpAndSettle();

      final queryField = find.byType(TextField).first;
      await tester.enterText(queryField, 'ThinkPad');
      await tester.tap(find.widgetWithText(FilledButton, 'Cari'));
      await tester.pumpAndSettle();

      expect(capturedMode, 'laptop');
    });
  });
}
