import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Blok riwayat analisis harga (sumber tampilan Riwayat + verifikasi).
class HistoryBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  // 'pc' | 'laptop' | 'bundle'
  TextColumn get mode => text()();
  TextColumn get query => text()();
  // Harga integer IDR (sesuai API_CONTRACT).
  IntColumn get inputPrice => integer()();
  RealColumn get score => real()();
  TextColumn get verdict => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Item wishlist user.
class WishlistItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()();
  TextColumn get mode => text()();
  IntColumn get targetPrice => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Alert harga: notifikasi saat harga <= target.
class PriceAlerts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()();
  TextColumn get mode => text()();
  IntColumn get targetPrice => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Cache hasil API (mis. suggest, trend) dengan TTL sederhana.
class CachedResults extends Table {
  TextColumn get key => text()();
  // Payload JSON mentah.
  TextColumn get payload => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [HistoryBlocks, WishlistItems, PriceAlerts, CachedResults],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
