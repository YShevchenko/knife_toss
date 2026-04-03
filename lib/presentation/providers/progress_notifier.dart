import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/player_stats.dart';
import '../../domain/repositories/progress_repository.dart';

class ProgressNotifier extends Notifier<PlayerStats> {
  late final ProgressRepository _repo;

  @override
  PlayerStats build() {
    _repo = ref.read(progressRepoInternalProvider);
    return const PlayerStats();
  }

  /// Load saved stats from persistent storage.
  Future<void> load() async {
    state = await _repo.load();
  }

  /// Record a completed game session and persist.
  Future<void> completeGame({
    required int levelReached,
    required int score,
    required int knivesThrown,
    required int timeSeconds,
    required int bossesBeaten,
  }) async {
    state = state.withGameComplete(
      levelReached: levelReached,
      score: score,
      knivesThrown: knivesThrown,
      timeSeconds: timeSeconds,
      bossesBeaten: bossesBeaten,
    );
    await _repo.save(state);
  }

  /// Mark ads as removed (or re-enabled) and persist.
  Future<void> setAdsRemoved(bool removed) async {
    state = state.copyWith(adsRemoved: removed);
    await _repo.save(state);
  }

  /// Reset all stats and clear storage.
  Future<void> reset() async {
    state = const PlayerStats();
    await _repo.clear();
  }
}

/// Internal provider so ProgressNotifier can access the repo.
/// Overridden in providers.dart.
final progressRepoInternalProvider = Provider<ProgressRepository>((_) {
  throw UnimplementedError('Must be overridden in providers.dart');
});
