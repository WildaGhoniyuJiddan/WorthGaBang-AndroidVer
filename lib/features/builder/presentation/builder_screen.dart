import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../../../core/sensors/shake_detector.dart';
import '../../../core/utils/rupiah.dart';
import '../../../core/widgets/tilt_card.dart';
import '../../../l10n/strings.dart';
import '../data/builder_api.dart';
import '../data/builder_models.dart';

/// Layar Random Builder: rakit PC acak sesuai budget.
/// Goyangkan HP (shake) untuk mengacak ulang — kartu hasil miring
/// mengikuti gyroscope (TiltCard).
class BuilderScreen extends ConsumerStatefulWidget {
  const BuilderScreen({super.key});

  @override
  ConsumerState<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends ConsumerState<BuilderScreen> {
  final _budget = TextEditingController(text: '10000000');
  String _useCase = 'gaming';
  ApiResult<RandomBuild>? _state;
  late final ShakeDetector _shake;

  @override
  void initState() {
    super.initState();
    _shake = ShakeDetector();
    _shake.start(() {
      if (mounted) {
        _build();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.shakeDetected),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _shake.stop();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _build() async {
    final budget =
        int.tryParse(_budget.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (budget <= 0) return;
    setState(() => _state = const ApiLoading());
    try {
      final build = await ref
          .read(builderApiProvider)
          .randomBuild(budget: budget, useCase: _useCase);
      setState(() => _state = ApiSuccess(build));
    } catch (e) {
      setState(() => _state = ApiError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final build =
        state is ApiSuccess<RandomBuild> ? state.data : null;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.builderTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.budgetLabel,
                prefixText: 'Rp ',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'gaming', label: Text('Gaming')),
                ButtonSegment(value: 'office', label: Text('Kantor')),
                ButtonSegment(value: 'editing', label: Text('Editing')),
              ],
              selected: {_useCase},
              onSelectionChanged: (s) =>
                  setState(() => _useCase = s.first),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: state is ApiLoading ? null : _build,
              icon: const Icon(Icons.casino_outlined),
              label: const Text(AppStrings.randomBuildButton),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.vibration, size: 16),
                  SizedBox(width: 4),
                  Text(AppStrings.shakeHint),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (state is ApiLoading)
              const Center(child: CircularProgressIndicator()),
            if (state is ApiError)
              Text(
                (state as ApiError<RandomBuild>).message,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error),
              ),
            if (build != null) ...[
              for (final (label, part) in build.parts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TiltCard(
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(label[0])),
                        title: Text(part.name),
                        subtitle: Text(label),
                        trailing: Text(
                          formatRupiah(part.price),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              Card(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(AppStrings.totalLabel,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${formatRupiah(build.total)} / ${formatRupiah(build.budget)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
