import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../../../core/utils/rupiah.dart';
import '../../../l10n/strings.dart';
import '../data/game_api.dart';
import '../data/game_models.dart';

/// Game Tebak Harga: 5 ronde, tebak harga produk, skor per ronde 0–100.
/// Total disimpan sebagai high score lokal.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  static const rounds = 5;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final _guess = TextEditingController();

  int _round = 1;
  int _totalScore = 0;
  ApiResult<GameQuestion>? _questionState;
  GuessResult? _lastResult;
  bool _submitting = false;
  bool _finished = false;
  bool _newRecord = false;
  int _best = 0;

  @override
  void initState() {
    super.initState();
    _loadBest();
    _loadQuestion();
  }

  @override
  void dispose() {
    _guess.dispose();
    super.dispose();
  }

  Future<void> _loadBest() async {
    final store = await ref.read(highScoreStoreProvider.future);
    if (mounted) setState(() => _best = store.bestScore);
  }

  Future<void> _loadQuestion() async {
    setState(() {
      _questionState = const ApiLoading();
      _lastResult = null;
      _guess.clear();
    });
    try {
      final q = await ref.read(gameApiProvider).getQuestion();
      if (mounted) setState(() => _questionState = ApiSuccess(q));
    } catch (e) {
      if (mounted) setState(() => _questionState = ApiError(e.toString()));
    }
  }

  Future<void> _submit() async {
    final state = _questionState;
    if (state is! ApiSuccess<GameQuestion> || _submitting) return;
    final guess =
        int.tryParse(_guess.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (guess <= 0) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      final result = await ref.read(gameApiProvider).submitGuess(
            questionId: state.data.questionId,
            guessIdr: guess,
          );
      if (!mounted) return;
      setState(() {
        _lastResult = result;
        _totalScore += result.score;
        _submitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _next() async {
    if (_round >= GameScreen.rounds) {
      final store = await ref.read(highScoreStoreProvider.future);
      final isRecord = await store.saveScore(_totalScore);
      if (mounted) {
        setState(() {
          _finished = true;
          _newRecord = isRecord;
          _best = store.bestScore;
        });
      }
      return;
    }
    setState(() => _round++);
    await _loadQuestion();
  }

  void _restart() {
    setState(() {
      _round = 1;
      _totalScore = 0;
      _finished = false;
      _newRecord = false;
    });
    _loadQuestion();
  }

  @override
  Widget build(BuildContext context) {
    final state = _questionState;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.gameTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Skor: $_totalScore',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _finished
            ? _buildFinished()
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Ronde $_round/${GameScreen.rounds}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text('Rekor: $_best',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _round / GameScreen.rounds,
                    ),
                    const SizedBox(height: 16),
                    if (state is ApiLoading)
                      const Expanded(
                        child:
                            Center(child: CircularProgressIndicator()),
                      ),
                    if (state is ApiError)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text((state as ApiError<GameQuestion>)
                                  .message),
                              const SizedBox(height: 8),
                              FilledButton(
                                onPressed: _loadQuestion,
                                child: const Text(
                                    AppStrings.retryButton),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (state is ApiSuccess<GameQuestion>)
                      Expanded(child: _buildRound(state.data)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRound(GameQuestion q) {
    final result = _lastResult;
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.help_outline,
                    size: 48, color: Colors.amber),
                const SizedBox(height: 12),
                Text(q.product,
                    style:
                        Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(q.specs, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('💡 ${q.hint}',
                    style: const TextStyle(
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (result == null) ...[
          TextField(
            controller: _guess,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: AppStrings.guessLabel,
              prefixText: 'Rp ',
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(AppStrings.submitGuessButton),
          ),
        ] else ...[
          Card(
            color: result.score >= 80
                ? Colors.green.withValues(alpha: 0.12)
                : result.score >= 50
                    ? Colors.amber.withValues(alpha: 0.12)
                    : Colors.red.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('+${result.score}',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall),
                  const SizedBox(height: 4),
                  Text(
                      'Harga asli: ${formatRupiah(result.actualPrice)}'),
                  Text(
                    result.difference == 0
                        ? 'Tepat sekali! 🎯'
                        : result.difference > 0
                            ? 'Tebakanmu ${formatRupiah(result.difference)} lebih mahal'
                            : 'Tebakanmu ${formatRupiah(-result.difference)} lebih murah',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _next,
            child: Text(_round >= GameScreen.rounds
                ? AppStrings.finishButton
                : AppStrings.nextRoundButton),
          ),
        ],
      ],
    );
  }

  Widget _buildFinished() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events,
                size: 72, color: Colors.amber),
            const SizedBox(height: 16),
            Text(AppStrings.gameFinished,
                style:
                    Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Skor total: $_totalScore / ${GameScreen.rounds * 100}',
                style: Theme.of(context).textTheme.titleLarge),
            if (_newRecord)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(AppStrings.newRecord,
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold)),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Rekor: $_best'),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _restart,
              icon: const Icon(Icons.replay),
              label: const Text(AppStrings.playAgainButton),
            ),
          ],
        ),
      ),
    );
  }
}
