import 'package:drift/drift.dart';

import '../../../core/hashchain/hash_chain_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/app_database.dart';
import 'models.dart';

/// Repository riwayat: simpan hasil analisis sebagai blok hash chain (Drift).
class HistoryRepository {
  HistoryRepository(this._db, [ApiClient? client]) : _client = client;

  final AppDatabase _db;
  final ApiClient? _client;

  /// Simpan [result] sebagai blok baru di ujung rantai.
  ///
  /// Hash dihitung setelah insert agar `id` (auto-increment) bisa dipakai
  /// sebagai index sesuai format D12.
  Future<HistoryBlock> appendAnalysis(AnalysisResult result) async {
    // Drift menyimpan DateTime sebagai unix seconds dan membacanya sebagai
    // LOCAL time — truncate ke detik & pakai local agar string ISO yang
    // di-hash identik dengan yang dibaca saat verifikasi.
    final now = DateTime.now();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      (now.millisecondsSinceEpoch ~/ 1000) * 1000,
    );
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
      // Blok sebelumnya = id terbesar yang LEBIH KECIL dari id baru
      // (baris baru sendiri hash-nya masih kosong).
      final prev = await (_db.select(_db.historyBlocks)
            ..where((t) => t.id.isSmallerThanValue(id))
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(1))
          .getSingleOrNull();
      final prevHash = (prev == null || prev.hash.isEmpty)
          ? HashChainService.genesisPrevHash
          : prev.hash;
      final hash = HashChainService.computeHash(
        index: id,
        timestampIso: createdAt.toIso8601String(),
        dataJson: dataJson,
        prevHash: prevHash,
      );
      await (_db.update(_db.historyBlocks)..where((t) => t.id.equals(id)))
          .write(HistoryBlocksCompanion(
        dataJson: Value(dataJson),
        prevHash: Value(prevHash),
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

  /// Sync opsional ke server (B10 POST /api/v1/history) — best effort.
  /// Mengembalikan jumlah blok yang berhasil terkirim.
  Future<int> syncToServer() async {
    final client = _client;
    if (client == null) return 0;
    final blocks = await (_db.select(_db.historyBlocks)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    var sent = 0;
    for (final b in blocks) {
      try {
        await client.postJson('/api/v1/history', body: {
          'mode': b.mode,
          'query': b.query,
          'input_price': b.inputPrice,
          'score': b.score,
          'verdict': b.verdict,
          'created_at': b.createdAt.toIso8601String(),
        });
        sent++;
      } catch (_) {
        break; // berhenti saat offline; sisanya antre (T15)
      }
    }
    return sent;
  }

}
