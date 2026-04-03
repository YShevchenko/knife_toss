import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/game_state.dart';
import '../../domain/services/game_engine.dart';
import '../../domain/services/level_service.dart';

class GameNotifier extends Notifier<GameState?> {
  final LevelService _levelService = LevelService();

  /// Track bosses beaten in current run for stats.
  int bossesBeatenInRun = 0;

  /// Track total knives thrown in current run.
  int totalKnivesInRun = 0;

  @override
  GameState? build() {
    return null;
  }

  /// Start a new game from level 1.
  void startNewGame() {
    bossesBeatenInRun = 0;
    totalKnivesInRun = 0;
    _startLevel(1, 0);
  }

  /// Advance to the next level, keeping score.
  void nextLevel() {
    final current = state;
    if (current == null) return;

    if (current.isBoss) bossesBeatenInRun++;
    totalKnivesInRun += current.knivesThrown;

    _startLevel(current.level + 1, current.score);
  }

  void _startLevel(int level, int carryOverScore) {
    final newState = _levelService.createLevel(level);
    state = newState.copyWith(score: carryOverScore);
  }

  /// Begin throwing the current knife.
  void throwKnife() {
    final current = state;
    if (current == null || current.phase != GamePhase.ready) return;

    state = current.copyWith(phase: GamePhase.throwing);
  }

  /// Called each frame while knife is in flight.
  /// Returns the new throwY position. When the knife reaches the log,
  /// it either sticks or triggers game over.
  void updateThrow(double throwY, double logRadius, double logCenterY) {
    final current = state;
    if (current == null || current.phase != GamePhase.throwing) return;

    // Knife tip position relative to log center.
    final knifeTopY = logCenterY + throwY;
    final logTopY = logCenterY - logRadius;

    if (knifeTopY <= logTopY) {
      // Knife has reached the log.
      // The knife approaches from directly below: angle in world = 0 (pointing up).
      // In the log's local frame:
      final angleInLog =
          GameEngine.normalizeAngle(-current.log.angle);

      if (GameEngine.checkCollision(angleInLog, current.stuckKnives)) {
        // Hit another knife!
        totalKnivesInRun += current.knivesThrown;
        state = current.copyWith(
          phase: GamePhase.hit,
          throwY: throwY,
        );
      } else {
        // Stick the knife.
        state = GameEngine.stickKnife(current, angleInLog);
      }
    } else {
      state = current.copyWith(throwY: throwY);
    }
  }

  /// Transition from hit to game over.
  void confirmGameOver() {
    final current = state;
    if (current == null || current.phase != GamePhase.hit) return;
    state = current.copyWith(phase: GamePhase.gameOver);
  }

  /// Update log rotation each frame.
  void updateRotation(double dt) {
    final current = state;
    if (current == null) return;
    if (current.phase == GamePhase.gameOver ||
        current.phase == GamePhase.hit) {
      return;
    }

    final newLog = GameEngine.updateRotation(current.log, dt);
    state = current.copyWith(log: newLog);
  }

  /// Increment elapsed seconds.
  void tick() {
    final current = state;
    if (current == null) return;
    if (current.phase == GamePhase.gameOver ||
        current.phase == GamePhase.levelComplete) {
      return;
    }

    state = current.copyWith(elapsedSeconds: current.elapsedSeconds + 1);
  }
}
