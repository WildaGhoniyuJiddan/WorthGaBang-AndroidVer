import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/utils/rupiah.dart';
import '../../../core/widgets/verdict_badge.dart';
import '../../../l10n/strings.dart';
import '../../price_check/data/models.dart';
import '../../price_check/presentation/price_check_screen.dart';
import 'verify_screen.dart';

/// Tab Riwayat: daftar analisis tersimpan (offline-first, Drift) + verifikasi.
class HistoryListScreen extends ConsumerStatefulWidget {
  const HistoryListScreen({super.key});

  @override
  ConsumerState<HistoryListScreen> createState() =>
      _HistoryListScreenState();
}

class _HistoryListScreenState extends ConsumerState<HistoryListScreen> {
  List<HistoryBlock> _blocks = [];
  bool _loading = true;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final blocks =
        await ref.read(historyRepositoryProvider).latest();
    if (mounted) {
      setState(() {
        _blocks = blocks;
        _loading = false;
      });
    }
  }

  Future<void> _sync() async {
    setState(() => _syncing = true);
    final sent =
        await ref.read(historyRepositoryProvider).syncToServer();
    if (!mounted) return;
    setState(() => _syncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terkirim $sent riwayat ke server')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.historyScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_outlined),
            tooltip: AppStrings.verifyChainButton,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VerifyScreen()),
            ),
          ),
          IconButton(
            icon: _syncing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            tooltip: AppStrings.syncButton,
            onPressed: _syncing ? null : _sync,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _blocks.isEmpty
              ? const Center(child: Text(AppStrings.historyEmpty))
              : RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _blocks.length,
                    itemBuilder: (context, i) {
                      final b = _blocks[i];
                      return Card(
                        child: ListTile(
                          title: Text(b.query,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            '${DateFormat('d MMM yyyy HH:mm', 'id_ID').format(b.createdAt.toLocal())}'
                            ' • blok #${b.id}'
                            '${b.hash.isEmpty ? ' (legacy)' : ''}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              VerdictBadge(
                                  verdict: verdictFromString(b.verdict)),
                              const SizedBox(height: 4),
                              Text(formatRupiah(b.inputPrice),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const VerifyScreen()),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
