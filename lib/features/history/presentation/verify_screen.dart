import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/hashchain/hash_chain_service.dart';
import '../../../core/storage/app_database.dart';
import '../../../l10n/strings.dart';
import '../../price_check/presentation/price_check_screen.dart';

/// Layar verifikasi hash chain: hitung ulang tiap blok, tandai yang rusak.
///
/// Termasuk self-test (debug): simulasi tampering in-memory untuk
/// mendemonstrasikan bahwa manipulasi data terdeteksi.
class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  List<HashVerificationResult>? _results;
  List<HistoryBlock> _blocks = [];
  bool _tamperedDemo = false;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    final repo = ref.read(historyRepositoryProvider);
    final results = await repo.verify();
    final blocks = await repo.latest(limit: 1000);
    if (mounted) {
      setState(() {
        _results = results;
        _blocks = blocks.reversed.toList(); // urut id menaik
        _tamperedDemo = false;
      });
    }
  }

  /// Self-test: ubah satu blok IN-MEMORY (DB tidak disentuh), verifikasi lagi.
  void _tamperSelfTest() {
    if (_blocks.isEmpty) return;
    final tampered = _blocks.map((b) {
      if (b.id == _blocks.first.id) {
        return HashBlock(
          id: b.id,
          timestampIso: b.createdAt.toIso8601String(),
          dataJson: '{"rusak":true}',
          prevHash: b.prevHash,
          hash: b.hash,
        );
      }
      return HashBlock(
        id: b.id,
        timestampIso: b.createdAt.toIso8601String(),
        dataJson: b.dataJson,
        prevHash: b.prevHash,
        hash: b.hash,
      );
    }).toList();
    setState(() {
      _results = HashChainService.verifyChain(tampered);
      _tamperedDemo = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final allOk = results != null &&
        results.isNotEmpty &&
        results.every((r) => r.ok);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.verifyTitle)),
      body: results == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  color: results.isEmpty
                      ? null
                      : allOk
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.red.withValues(alpha: 0.12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          results.isEmpty
                              ? Icons.info_outline
                              : allOk
                                  ? Icons.verified
                                  : Icons.warning_amber_rounded,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            results.isEmpty
                                ? AppStrings.verifyEmpty
                                : allOk
                                    ? AppStrings.verifyOk(
                                        results.length)
                                    : AppStrings.verifyFailed,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_tamperedDemo)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(AppStrings.tamperDemoNote),
                  ),
                const SizedBox(height: 12),
                for (final r in results)
                  ListTile(
                    leading: Icon(
                      r.ok ? Icons.check_circle : Icons.cancel,
                      color: r.ok ? Colors.green : Colors.red,
                    ),
                    title: Text('Blok #${r.block.id}'),
                    subtitle: Text(
                      'hash: ${r.block.hash.isEmpty ? '-' : r.block.hash.substring(0, 12)}…',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    trailing: Text(
                      r.ok ? 'VALID' : 'RUSAK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: r.ok ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _verify,
                  icon: const Icon(Icons.refresh),
                  label:
                      const Text(AppStrings.verifyChainButton),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed:
                      _blocks.isEmpty ? null : _tamperSelfTest,
                  icon: const Icon(Icons.bug_report_outlined),
                  label: const Text(AppStrings.tamperSelfTest),
                ),
              ],
            ),
    );
  }
}
