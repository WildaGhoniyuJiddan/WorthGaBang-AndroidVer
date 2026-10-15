import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:worthbang/models/builder_models.dart';

import 'local_catalog.dart';

final builderApiProvider = Provider<BuilderApi>((ref) => BuilderApi());

/// Random builder — sekarang 100% lokal dari katalog bundled.
/// Logika di-port 1:1 dari backend (alokasi per use-case + PSU estimasi).
class BuilderApi {
  Future<RandomBuild> randomBuild({
    required int budget,
    required String useCase,
  }) async {
    final cat = await LocalCatalog.load();
    final alloc =
        _allocations[useCase.toLowerCase()] ?? _allocations['gaming']!;

    CatalogItem pick(String section, double share) {
      final items =
          (cat[section] ?? const <CatalogItem>[]).where((e) => e.price > 0).toList();
      if (items.isEmpty) {
        return const CatalogItem(model: 'Tidak tersedia', price: 0);
      }
      final budgetShare = (budget * share).toInt();
      final affordable =
          items.where((e) => e.price <= budgetShare).toList();
      final pool = affordable.isEmpty ? items : affordable;
      pool.sort((a, b) => b.price.compareTo(a.price));
      return pool.first;
    }

    final cpu = pick('cpu', alloc['cpu']!);
    final gpu = pick('gpu', alloc['gpu']!);
    final ram = pick('ram', alloc['ram']!);
    final ssd = pick('storage', alloc['storage']!);

    final psuBudget = (budget * alloc['psu']!).toInt();
    final psuCands =
        _psuEstimates.where((p) => p.price <= psuBudget).toList();
    final psuPool =
        psuCands.isEmpty ? List<CatalogItem>.of(_psuEstimates) : psuCands;
    psuPool.sort(
      (a, b) => (a.price - psuBudget).abs().compareTo(
            (b.price - psuBudget).abs(),
          ),
    );
    final psu = psuPool.first;

    BuildComponent part(CatalogItem e) =>
        BuildComponent(name: e.model, price: e.price);

    final total = cpu.price + gpu.price + ram.price + ssd.price + psu.price;
    return RandomBuild(
      cpu: part(cpu),
      gpu: part(gpu),
      ram: part(ram),
      ssd: part(ssd),
      psu: part(psu),
      total: total,
      budget: budget,
    );
  }
}

const _allocations = {
  'gaming': {
    'gpu': 0.40,
    'cpu': 0.25,
    'ram': 0.12,
    'storage': 0.10,
    'motherboard': 0.08,
    'psu': 0.05,
  },
  'office': {
    'cpu': 0.28,
    'gpu': 0.10,
    'ram': 0.15,
    'storage': 0.12,
    'motherboard': 0.10,
    'psu': 0.08,
  },
  'editing': {
    'cpu': 0.28,
    'gpu': 0.25,
    'ram': 0.15,
    'storage': 0.12,
    'motherboard': 0.10,
    'psu': 0.10,
  },
};

const _psuEstimates = [
  CatalogItem(model: 'PSU 550W 80+ Bronze (estimasi)', price: 750000),
  CatalogItem(model: 'PSU 650W 80+ Bronze (estimasi)', price: 950000),
  CatalogItem(model: 'PSU 750W 80+ Gold (estimasi)', price: 1350000),
];
