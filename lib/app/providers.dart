import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/network/dio_api_client.dart';
import '../core/secure/token_storage.dart';
import '../core/storage/app_database.dart';

/// Penyimpanan token aman (flutter_secure_storage).
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// HTTP client — ganti ke [FakeApiClient] untuk demo tanpa backend:
/// `apiClientProvider.overrideWithValue(FakeApiClient())`.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = DioApiClient(tokenStorage: ref.watch(tokenStorageProvider));
  ref.onDispose(client.close);
  return client;
});

/// Database lokal Drift (SQLite).
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(NativeDatabase.memory());
  ref.onDispose(db.close);
  return db;
});
