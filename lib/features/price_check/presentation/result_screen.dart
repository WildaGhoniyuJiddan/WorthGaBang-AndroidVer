import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/rupiah.dart';
import '../../../core/widgets/verdict_badge.dart';
import '../../../l10n/strings.dart';
import '../../trends/presentation/trends_screen.dart';
import '../data/models.dart';

/// Layar hasil analisis: verdict, skor, rentang wajar, pembanding, alternatif.
///
/// Hasil sudah tersimpan sebagai blok hash chain (lihat [blockId]) saat layar
/// ini dibuka — diverifikasi di tab Riwayat (T6).
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.result, required this.blockId});

  final AnalysisResult result;
  final int blockId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = result;
    return Scaffold(
      appBar: AppBar(title: Text(r.query)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              VerdictBadge(verdict: verdictFromString(r.verdict)),
              const SizedBox(width: 12),
              Text(
                'Skor ${r.score.toStringAsFixed(0)}/100',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Harga input: ${formatRupiah(r.inputPrice)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (r.referencePrice != null)
            Text('Median pasar: ${formatRupiah(r.referencePrice!)}'),
          if (r.fairPriceLow != null && r.fairPriceHigh != null)
            Text(
              'Rentang wajar: ${formatRupiah(r.fairPriceLow!)} – ${formatRupiah(r.fairPriceHigh!)}',
            ),
          if (r.priceDeltaPercent != null)
            Text(
              'Selisih: ${r.priceDeltaPercent!.toStringAsFixed(1)}% dari median',
            ),
          if (r.recommendation != null) ...[
            const SizedBox(height: 12),
            Text(r.recommendation!),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    TrendsScreenContent(initialQuery: r.query),
              ),
            ),
            icon: const Icon(Icons.show_chart),
            label: const Text(AppStrings.viewTrendButton),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.link, size: 16),
              const SizedBox(width: 4),
              Text(
                'Tersimpan di riwayat (blok #$blockId, hash chain)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (r.freshnessLabel != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.update, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Data: ${r.freshnessLabel!}${r.isStale ? ' (basi)' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
          if (r.comparisons.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Pembanding (${r.listingCount} listing)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final c in r.comparisons)
              Card(
                child: ListTile(
                  title: Text(c.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                      '${c.source}${c.condition != null ? ' • ${c.condition}' : ''}'),
                  trailing: Text(
                    formatRupiah(c.price),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
          if (r.alternatives.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Alternatif',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final a in r.alternatives)
              Card(
                child: ListTile(
                  title: Text(a.name),
                  subtitle: a.gainPercent != null
                      ? Text(
                          '+${a.gainPercent!.toStringAsFixed(0)}% performa')
                      : null,
                  trailing: Text(formatRupiah(a.estPriceIdr)),
                ),
              ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check),
            label: const Text(AppStrings.doneButton),
          ),
        ],
      ),
    );
  }
}
