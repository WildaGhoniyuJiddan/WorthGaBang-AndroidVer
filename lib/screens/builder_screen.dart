import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:worthbang/services/api_result.dart';
import 'package:worthbang/core/theme/monex_theme.dart';
import 'package:worthbang/core/widgets/monex_widgets.dart';
import 'package:worthbang/services/shake_detector.dart';
import 'package:worthbang/utils/rupiah.dart';
import 'package:worthbang/widgets/tilt_card.dart';
import 'package:worthbang/l10n/strings.dart';
import 'package:worthbang/services/profile_api.dart';
import 'package:worthbang/services/builder_api.dart';
import 'package:worthbang/models/builder_models.dart';

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
        showMonexToast(context, AppStrings.shakeDetected, isSuccess: true);
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
      final msg = e is BuilderException
          ? e.message
          : e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      setState(() => _state = ApiError(msg));
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
          padding: const EdgeInsets.fromLTRB(
            MonexSpacing.screenPaddingH,
            MonexSpacing.screenPaddingV,
            MonexSpacing.screenPaddingH,
            24,
          ),
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
            const SizedBox(height: MonexSpacing.gridGap),
            MonexSegmentedControl<String>(
              value: _useCase,
              onChanged: (v) => setState(() => _useCase = v),
              items: const [
                MonexSegment(value: 'gaming', label: 'Gaming'),
                MonexSegment(value: 'office', label: 'Kantor'),
                MonexSegment(value: 'editing', label: 'Editing'),
              ],
            ),
            const SizedBox(height: MonexSpacing.gridGap),
            MonexPrimaryButton(
              onPressed: state is ApiLoading ? null : _build,
              icon: Icons.casino_outlined,
              label: AppStrings.randomBuildButton,
              loading: state is ApiLoading,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.vibration, size: 16),
                  SizedBox(width: 4),
                  // Flexible: teks hint boleh wrap, tidak memaksa Row melebar.
                  Flexible(
                    child: Text(
                      AppStrings.shakeHint,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (state is ApiLoading)
              const Center(child: MonexOrbitLoader(size: 56)),
            if (state is ApiError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: MonexSurfaceCard(
                  color: MonexColors.dangerMuted,
                  borderColor: MonexColors.danger.withValues(alpha: 0.4),
                  radius: MonexSpacing.radiusMd,
                  padding: const EdgeInsets.all(
                      MonexSpacing.cardPaddingCompact),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: MonexColors.danger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (state as ApiError<RandomBuild>).message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (build != null) ...[
              for (final (label, part) in build.parts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TiltCard(
                    enabled: ref
                        .watch(settingsControllerProvider)
                        .orDefault
                        .tiltEnabled,
                    child: MonexSurfaceCard(
                      padding: const EdgeInsets.all(
                          MonexSpacing.cardPaddingCompact),
                      radius: MonexSpacing.radiusMd,
                      child: MonexTransactionTile(
                        title: part.name,
                        subtitle: label,
                        padding: EdgeInsets.zero,
                        leadingIcon: Icons.memory_rounded,
                        trailing: Text(
                          formatRupiah(part.price),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ),
                  ),
                ),
              MonexGradientCard(
                padding: const EdgeInsets.all(MonexSpacing.cardPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.totalLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: MonexColors.textDark,
                          ),
                    ),
                    Flexible(
                      child: Text(
                        '${formatRupiah(build.total)} / ${formatRupiah(build.budget)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: MonexColors.textDark,
                            ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
