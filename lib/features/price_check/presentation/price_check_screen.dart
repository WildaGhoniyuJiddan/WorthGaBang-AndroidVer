import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_result.dart';
import '../../../l10n/strings.dart';
import '../data/history_repository.dart';
import '../data/models.dart';
import '../data/price_check_api.dart';
import 'result_screen.dart';
import 'bundle_screen.dart';

final priceCheckApiProvider = Provider<PriceCheckApi>(
  (ref) => PriceCheckApi(ref.watch(apiClientProvider)),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(databaseProvider)),
);

/// Layar utama Beranda: form cek harga + autocomplete (debounce 300ms).
class PriceCheckScreen extends ConsumerStatefulWidget {
  const PriceCheckScreen({super.key});

  @override
  ConsumerState<PriceCheckScreen> createState() => _PriceCheckScreenState();
}

class _PriceCheckScreenState extends ConsumerState<PriceCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _query = TextEditingController();
  final _price = TextEditingController();

  String _mode = 'pc';
  String _condition = 'any';
  List<String> _suggestions = [];
  Timer? _debounce;
  ApiResult<AnalysisResult>? _state;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _price.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final list = await ref
          .read(priceCheckApiProvider)
          .suggest(section: _mode, query: value);
      if (mounted) setState(() => _suggestions = list);
    });
  }

  int? _parsePrice(String raw) {
    final digits = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
    return (digits == null || digits <= 0) ? null : digits;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _state = const ApiLoading());
    try {
      final result = await ref.read(priceCheckApiProvider).analyze(
            mode: _mode,
            query: _query.text.trim(),
            price: _parsePrice(_price.text) ?? 0,
            condition: _condition,
          );
      setState(() => _state = ApiSuccess(result));
      if (!mounted) return;
      // Simpan ke hash chain, lalu buka layar hasil.
      final block =
          await ref.read(historyRepositoryProvider).appendAnalysis(result);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result, blockId: block.id),
        ),
      );
    } catch (e) {
      setState(() => _state = ApiError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final String? errorMessage =
        state is ApiError<AnalysisResult> ? state.message : null;
    final bool isLoading = state is ApiLoading<AnalysisResult>;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.priceCheckTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'pc',
                      label: Text('Komponen PC'),
                      icon: Icon(Icons.memory_outlined),
                    ),
                    ButtonSegment(
                      value: 'laptop',
                      label: Text('Laptop'),
                      icon: Icon(Icons.laptop_outlined),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _query,
                  onChanged: _onQueryChanged,
                  decoration: const InputDecoration(
                    labelText: AppStrings.queryLabel,
                    hintText: AppStrings.queryHint,
                    prefixIcon: Icon(Icons.search),
                  ),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? AppStrings.queryMin
                      : null,
                ),
                if (_suggestions.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.only(top: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final s in _suggestions)
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.history, size: 18),
                            title: Text(s),
                            onTap: () {
                              _query.text = s;
                              setState(() => _suggestions = []);
                            },
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: AppStrings.priceLabel,
                    prefixText: 'Rp ',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (v) => _parsePrice(v ?? '') == null
                      ? AppStrings.priceInvalid
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _condition,
                  decoration: const InputDecoration(
                    labelText: AppStrings.conditionLabel,
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'any', child: Text('Semua kondisi')),
                    DropdownMenuItem(value: 'baru', child: Text('Baru')),
                    DropdownMenuItem(value: 'bekas', child: Text('Bekas')),
                  ],
                  onChanged: (v) => setState(() => _condition = v ?? 'any'),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.analytics_outlined),
                  label: const Text(AppStrings.checkButton),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const BundleScreen()),
                  ),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text(AppStrings.bundleModeButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
