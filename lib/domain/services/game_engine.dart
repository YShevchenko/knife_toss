import 'dart:math';

import '../models/game_state.dart';
import '../models/knife.dart';
import '../models/log.dart';
import '../../core/constants.dart';

/// Core game engine that handles rotation, collision, and knife sticking.
class GameEngine {
  /// Normalize an angle to [0, 2*pi).
  static double normalizeAngle(double angle) {
    double result = angle % AppConstants.twoPi;
    if (result < 0) result += AppConstants.twoPi;
    return result;
  }

  /// Update the log's rotation based on elapsed time.
  static GameLog updateRotation(GameLog log, double dt) {
    double newAngle;
    double newSpeed;
    double newPatternTime = log.patternTime + dt;

    switch (log.pattern) {
      case RotationPattern.constant:
        newSpeed = log.baseSpeed;
        newAngle = log.angle + newSpeed * dt;
        break;

      case RotationPattern.variable:
        // Speed oscillates between 0.5x and 1.5x base speed.
        final speedFactor = 0.5 + sin(newPatternTime * 1.5).abs();
        newSpeed = log.baseSpeed * speedFactor;
        newAngle = log.angle + newSpeed * dt;
        break;

      case RotationPattern.reversing:
        // Reverses direction every 2 seconds.
        final cycle = (newPatternTime / 2.0).floor();
        final direction = cycle.isEven ? 1.0 : -1.0;
        newSpeed = log.baseSpeed * direction;
        newAngle = log.angle + newSpeed * dt;
        break;

      case RotationPattern.oscillating:
        // Smooth oscillation using sine wave.
        newSpeed = log.baseSpeed * sin(newPatternTime * 2.0);
        newAngle = log.angle + newSpeed * dt;
        break;
    }

    return log.copyWith(
      angle: normalizeAngle(newAngle),
      currentSpeed: newSpeed,
      patternTime: newPatternTime,
    );
  }

  /// Check if a thrown knife at the given angle collides with any stuck knife.
  /// Returns true if there IS a collision.
  static bool checkCollision(
    double thrownAngleInLog,
    List<Knife> stuckKnives,
  ) {
    final normalizedThrown = normalizeAngle(thrownAngleInLog);

    for (final stuck in stuckKnives) {
      final normalizedStuck = normalizeAngle(stuck.angleInLog);
      double diff = (normalizedThrown - normalizedStuck).abs();
      if (diff > pi) diff = AppConstants.twoPi - diff;
      if (diff < AppConstants.knifeAngularWidth) return true;
    }
    return false;
  }

  /// Calculate the angle of a thrown knife relative to the log's frame.
  /// knifeX/knifeY are in world coordinates, logCX/logCY is log center.
  static double calculateKnifeAngleInLog(
    double knifeX,
    double knifeY,
    double logCX,
    double logCY,
    double logAngle,
  ) {
    // Angle of knife in world frame (0 = up, clockwise positive).
    final worldAngle = atan2(knifeX - logCX, logCY - knifeY);
    // Convert to log's local frame.
    return normalizeAngle(worldAngle - logAngle);
  }

  /// Calculate score for sticking a knife.
  static int calculateKnifeScore(int level, bool isBoss) {
    final base = AppConstants.baseScorePerKnife * level;
    return isBoss ? (base * AppConstants.bossMultiplier).round() : base;
  }

  /// Calculate level complete bonus.
  static int calculateLevelBonus(int level, bool isBoss) {
    final base = AppConstants.levelCompleteBonus * level;
    return isBoss ? (base * AppConstants.bossMultiplier).round() : base;
  }

  /// Stick a knife into the log at the given angle.
  static GameState stickKnife(GameState state, double angleInLog) {
    final knife = Knife(
      id: state.currentKnifeId,
      angleInLog: angleInLog,
      isStuck: true,
    );

    final newStuck = [...state.stuckKnives, knife];
    final newThrown = state.knivesThrown + 1;
    final knifeScore = calculateKnifeScore(state.level, state.isBoss);
    final newScore = state.score + knifeScore;

    // Check if level is complete.
    if (newThrown >= state.knivesToThrow) {
      final bonus = calculateLevelBonus(state.level, state.isBoss);
      return state.copyWith(
        stuckKnives: newStuck,
        knivesThrown: newThrown,
        phase: GamePhase.levelComplete,
        score: newScore + bonus,
        currentKnifeId: state.currentKnifeId + 1,
      );
    }

    return state.copyWith(
      stuckKnives: newStuck,
      knivesThrown: newThrown,
      phase: GamePhase.ready,
      score: newScore,
      currentKnifeId: state.currentKnifeId + 1,
      throwY: 0.0,
    );
  }
}
