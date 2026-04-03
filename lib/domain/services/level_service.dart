import 'dart:math';

import '../../core/constants.dart';
import '../models/game_state.dart';
import '../models/knife.dart';
import '../models/log.dart';

/// Generates level configurations based on level number.
class LevelService {
  final Random _rng = Random();

  /// Whether the given level is a boss level.
  static bool isBossLevel(int level) {
    return level > 0 && level % AppConstants.bossFrequency == 0;
  }

  /// Get the difficulty tier for a level (0-3).
  static int getTier(int level) {
    if (level >= AppConstants.tier4Start) return 3;
    if (level >= AppConstants.tier3Start) return 2;
    if (level >= AppConstants.tier2Start) return 1;
    return 0;
  }

  /// Get number of knives to throw for a level.
  int getKnifeCount(int level) {
    final tier = getTier(level);
    final range = AppConstants.knivesPerTier[tier];
    return range[0] + _rng.nextInt(range[1] - range[0] + 1);
  }

  /// Get the rotation speed for a level.
  double getRotationSpeed(int level) {
    final tier = getTier(level);
    return AppConstants.baseRotationSpeed * AppConstants.speedMultipliers[tier];
  }

  /// Get the rotation pattern for a level.
  RotationPattern getPattern(int level) {
    if (!isBossLevel(level)) {
      final tier = getTier(level);
      if (tier >= 2 && _rng.nextBool()) {
        return RotationPattern.reversing;
      }
      return RotationPattern.constant;
    }

    // Boss levels get special patterns.
    final tier = getTier(level);
    switch (tier) {
      case 0:
      case 1:
        return RotationPattern.variable;
      case 2:
        return _rng.nextBool()
            ? RotationPattern.reversing
            : RotationPattern.variable;
      case 3:
        return RotationPattern.oscillating;
      default:
        return RotationPattern.constant;
    }
  }

  /// Generate pre-placed knives for boss levels.
  List<Knife> generateBossKnives(int level) {
    if (!isBossLevel(level)) return [];

    final minKnives = AppConstants.bossPrePlacedKnives[0];
    final maxKnives = AppConstants.bossPrePlacedKnives[1];
    final count = minKnives + _rng.nextInt(maxKnives - minKnives + 1);

    final knives = <Knife>[];
    for (int i = 0; i < count; i++) {
      // Distribute pre-placed knives evenly around the log with some jitter.
      final baseAngle = (AppConstants.twoPi / count) * i;
      final jitter = (_rng.nextDouble() - 0.5) * 0.3;
      knives.add(Knife(
        id: -(i + 1), // Negative IDs for pre-placed knives.
        angleInLog: baseAngle + jitter,
        isStuck: true,
        isPrePlaced: true,
      ));
    }
    return knives;
  }

  /// Create a new game state for the given level.
  GameState createLevel(int level) {
    final isBoss = isBossLevel(level);
    final speed = getRotationSpeed(level);
    final pattern = getPattern(level);
    final knifeCount = getKnifeCount(level);
    final bossKnives = generateBossKnives(level);

    return GameState(
      level: level,
      isBoss: isBoss,
      log: GameLog(
        baseSpeed: speed,
        currentSpeed: speed,
        isBoss: isBoss,
        pattern: pattern,
      ),
      stuckKnives: bossKnives,
      knivesToThrow: knifeCount,
      currentKnifeId: 1,
    );
  }
}
