import 'package:drift/drift.dart';

import '../../../core/hashchain/hash_chain_service.dart';
import '../../../core/storage/app_database.dart';
import 'models.dart';

/// Repository riwayat: simpan hasil analisis sebagai blok hash chain (Drift).
class HistoryRepository {
  HistoryRepository(this._db);

  final AppDatabase _db;

  /// Simpan [result] sebagai blok baru di ujung rantai.
  ///
  /// Hash dihitung setelah insert agar `id` (auto-increment) bisa dipakai
  /// sebagai index sesuai format D12.
  Future<HistoryBlock> appendAnalysis(AnalysisResult result) async {
    final createdAt = DateTime.now().toUtc();
    final dataJson = HashChainService.canonicalDataJson(
      mode: result.mode,
      query: result.query,
      inputPrice: result.inputPrice,
      score: result.score,
      verdict: result.verdict,
    );

    return _db.transaction(() async {
      final id = await _db.into(_db.historyBlocks).insert(
            HistoryBlocksCompanion.insert(
              mode: result.mode,
              query: result.query,
              inputPrice: result.inputPrice,
              score: result.score,
              verdict: result.verdict,
              createdAt: Value(createdAt),
            ),
          );
      final prev = await _lastHash();
      final hash = HashChainService.computeHash(
        index: id,
        timestampIso: createdAt.toIso8601String(),
        dataJson: dataJson,
        prevHash: prev,
      );
      await (_db.update(_db.historyBlocks)..where((t) => t.id.equals(id)))
          .write(HistoryBlocksCompanion(
        dataJson: Value(dataJson),
        prevHash: Value(prev),
        hash: Value(hash),
      ));
      return (await (_db.select(_db.historyBlocks)
                ..where((t) => t.id.equals(id)))
              .getSingle());
    });
  }

  /// Daftar blok terbaru dulu (untuk layar Riwayat).
  Future<List<HistoryBlock>> latest({int limit = 100}) =>
      (_db.select(_db.historyBlocks)
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(limit))
          .get();

  /// Verifikasi seluruh rantai (urut id menaik).
  Future<List<HashVerificationResult>> verify() async {
    final blocks = await (_db.select(_db.historyBlocks)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return HashChainService.verifyChain(
      blocks
          .map((b) => HashBlock(
                id: b.id,
                timestampIso: b.createdAt.toIso8601String(),
                dataJson: b.dataJson,
                prevHash: b.prevHash,
                hash: b.hash,
              ))
          .toList(),
    );
  }

  /// Hapus satu blok (demo; merusak rantai — untuk self-test T6).
  Future<void> deleteBlock(int id) =>
      (_db.delete(_db.historyBlocks)..where((t) => t.id.equals(id))).go();

  Future<String> _lastHash() async {
    final last = await (_db.select(_db.historyBlocks)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
    final h = last?.hash;
    return (h == null || h.isEmpty)
        ? HashChainService.genesisPrevHash
        : h;
  }
}
