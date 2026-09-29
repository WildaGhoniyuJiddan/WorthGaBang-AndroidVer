import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import 'game_models.dart';

final gameApiProvider = Provider<GameApi>(
  (ref) => GameApi(ref.watch(apiClientProvider)),
);

/// API game Tebak Harga (B8).
class GameApi {
  GameApi(this._client);

  final ApiClient _client;

  Future<GameQuestion> getQuestion() async {
    final json = await _client.getJson('/api/v1/game/question');
    return GameQuestion.fromJson(json);
  }

  Future<GuessResult> submitGuess({
    required String questionId,
    required int guessIdr,
  }) async {
    final json = await _client.postJson('/api/v1/game/submit', body: {
      'question_id': questionId,
      'guess_idr': guessIdr,
    });
    return GuessResult.fromJson(json);
  }
}

/// High score lokal (SharedPreferences).
class HighScoreStore {
  HighScoreStore(this._prefs);

  final SharedPreferences _prefs;

  static const _bestKey = 'game_high_score';
  static const _gamesKey = 'game_games_played';

  int get bestScore => _prefs.getInt(_bestKey) ?? 0;
  int get gamesPlayed => _prefs.getInt(_gamesKey) ?? 0;

  /// Simpan skor total permainan; kembalikan true bila rekor baru.
  Future<bool> saveScore(int totalScore) async {
    await _prefs.setInt(_gamesKey, gamesPlayed + 1);
    if (totalScore > bestScore) {
      await _prefs.setInt(_bestKey, totalScore);
      return true;
    }
    return false;
  }
}

final highScoreStoreProvider = FutureProvider<HighScoreStore>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return HighScoreStore(prefs);
});
