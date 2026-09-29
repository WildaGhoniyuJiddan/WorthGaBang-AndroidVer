import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../../../core/utils/rupiah.dart';
import '../../../l10n/strings.dart';
import '../../price_check/data/models.dart';
import '../../price_check/presentation/price_check_screen.dart';
import '../data/search_filter.dart';

/// Tab Cari: cari produk → filter (kondisi/sumber/harga maks) + sort.
class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() =>
      _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  final _query = TextEditingController();
  final _price = TextEditingController();
  final _maxPrice = TextEditingController();

  ApiResult<AnalysisResult>? _state;
  SearchFilter _filter = const SearchFilter();

  @override
  void dispose() {
    _query.dispose();
    _price.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_query.text.trim().length < 2) return;
    FocusScope.of(context).unfocus();
    setState(() => _state = const ApiLoading());
    try {
      final result = await ref.read(priceCheckApiProvider).analyze(
            mode: 'pc',
            query: _query.text.trim(),
            price: int.tryParse(
                    _price.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
                0,
          );
      setState(() => _state = ApiSuccess(result));
    } catch (e) {
      setState(() => _state = ApiError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final result = state is ApiSuccess<AnalysisResult> ? state.data : null;
    final filtered =
        result != null ? _filter.apply(result.comparisons) : const <PriceComparison>[];
    final sources =
        result?.comparisons.map((c) => c.source).toSet().toList() ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.searchScreenTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _query,
                    decoration: const InputDecoration(
                      labelText: AppStrings.queryLabel,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.priceLabel,
                      prefixText: 'Rp ',
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: state is ApiLoading ? null : _search,
                  child: const Text(AppStrings.searchButton),
                ),
              ],
            ),
            if (state is ApiLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (state is ApiError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  (state as ApiError<AnalysisResult>).message,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (result != null) ...[
              const SizedBox(height: 16),
              Text(
                '${result.query} — ${filtered.length} dari ${result.comparisons.length} listing',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Baru'),
                    selected: _filter.conditions.contains('baru'),
                    onSelected: (v) => setState(() {
                      final s = Set<String>.from(_filter.conditions);
                      v ? s.add('baru') : s.remove('baru');
                      _filter = _filter.copyWith(conditions: s);
                    }),
                  ),
                  FilterChip(
                    label: const Text('Bekas'),
                    selected: _filter.conditions.contains('bekas'),
                    onSelected: (v) => setState(() {
                      final s = Set<String>.from(_filter.conditions);
                      v ? s.add('bekas') : s.remove('bekas');
                      _filter = _filter.copyWith(conditions: s);
                    }),
                  ),
                  for (final src in sources)
                    FilterChip(
                      label: Text(src),
                      selected: _filter.sources.contains(src),
                      onSelected: (v) => setState(() {
                        final s = Set<String>.from(_filter.sources);
                        v ? s.add(src) : s.remove(src);
                        _filter = _filter.copyWith(sources: s);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _maxPrice,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: AppStrings.maxPriceLabel,
                        prefixText: 'Rp ',
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() {
                        final n = int.tryParse(
                            v.replaceAll(RegExp(r'[^0-9]'), ''));
                        _filter = _filter.copyWith(
                            maxPrice: () => n == null || n <= 0 ? null : n);
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<SortOption>(
                      initialValue: _filter.sort,
                      decoration: const InputDecoration(
                        labelText: AppStrings.sortLabel,
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: SortOption.priceAsc,
                          child: Text('Harga terendah'),
                        ),
                        DropdownMenuItem(
                          value: SortOption.priceDesc,
                          child: Text('Harga tertinggi'),
                        ),
                        DropdownMenuItem(
                          value: SortOption.similarity,
                          child: Text('Paling mirip'),
                        ),
                      ],
                      onChanged: (v) => setState(
                          () => _filter = _filter.copyWith(sort: v)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final c in filtered)
                Card(
                  child: ListTile(
                    title: Text(c.title,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        '${c.source}${c.condition != null ? ' • ${c.condition}' : ''}'),
                    trailing: Text(
                      formatRupiah(c.price),
                      style:
                          const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                      child: Text(AppStrings.searchEmpty)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
