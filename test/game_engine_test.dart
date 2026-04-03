import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:knife_toss/core/constants.dart';
import 'package:knife_toss/domain/models/knife.dart';
import 'package:knife_toss/domain/models/log.dart';
import 'package:knife_toss/domain/models/game_state.dart';
import 'package:knife_toss/domain/services/game_engine.dart';

void main() {
  group('GameEngine.normalizeAngle', () {
    test('normalizes positive angle within range', () {
      final result = GameEngine.normalizeAngle(1.5);
      expect(result, closeTo(1.5, 0.001));
    });

    test('normalizes angle greater than 2*pi', () {
      final result = GameEngine.normalizeAngle(3 * pi);
      expect(result, closeTo(pi, 0.001));
    });

    test('normalizes negative angle', () {
      final result = GameEngine.normalizeAngle(-pi / 2);
      expect(result, closeTo(3 * pi / 2, 0.001));
    });

    test('normalizes zero', () {
      final result = GameEngine.normalizeAngle(0);
      expect(result, closeTo(0, 0.001));
    });

    test('normalizes exactly 2*pi to 0', () {
      final result = GameEngine.normalizeAngle(2 * pi);
      expect(result, closeTo(0, 0.001));
    });

    test('normalizes large negative angle', () {
      final result = GameEngine.normalizeAngle(-4 * pi + 0.5);
      expect(result, closeTo(0.5, 0.001));
    });
  });

  group('GameEngine.checkCollision', () {
    test('detects collision when knives at same angle', () {
      final stuckKnives = [
        const Knife(id: 1, angleInLog: 1.0, isStuck: true),
      ];
      expect(GameEngine.checkCollision(1.0, stuckKnives), isTrue);
    });

    test('detects collision within angular width', () {
      final stuckKnives = [
        const Knife(id: 1, angleInLog: 1.0, isStuck: true),
      ];
      final threshold = AppConstants.knifeAngularWidth;
      expect(
          GameEngine.checkCollision(1.0 + threshold * 0.5, stuckKnives),
          isTrue);
    });

    test('no collision when knives far apart', () {
      final stuckKnives = [
        const Knife(id: 1, angleInLog: 1.0, isStuck: true),
      ];
      expect(GameEngine.checkCollision(3.0, stuckKnives), isFalse);
    });

    test('no collision with empty stuck list', () {
      expect(GameEngine.checkCollision(1.0, []), isFalse);
    });

    test('detects collision wrapping around 0/2pi boundary', () {
      final stuckKnives = [
        const Knife(id: 1, angleInLog: 0.05, isStuck: true),
      ];
      // Knife at just below 2pi should collide with knife at 0.05.
      final almostTwoPi = 2 * pi - 0.05;
      expect(GameEngine.checkCollision(almostTwoPi, stuckKnives), isTrue);
    });

    test('no collision just outside angular width', () {
      final stuckKnives = [
        const Knife(id: 1, angleInLog: 1.0, isStuck: true),
      ];
      final justOutside = 1.0 + AppConstants.knifeAngularWidth + 0.01;
      expect(GameEngine.checkCollision(justOutside, stuckKnives), isFalse);
    });

    test('checks against all stuck knives', () {
      final stuckKnives = [
        const Knife(id: 1, angleInLog: 0.0, isStuck: true),
        const Knife(id: 2, angleInLog: pi / 2, isStuck: true),
        const Knife(id: 3, angleInLog: pi, isStuck: true),
        const Knife(id: 4, angleInLog: 3 * pi / 2, isStuck: true),
      ];
      // Should collide with knife at pi.
      expect(GameEngine.checkCollision(pi + 0.01, stuckKnives), isTrue);
      // Should not collide at pi/4.
      expect(GameEngine.checkCollision(pi / 4, stuckKnives), isFalse);
    });
  });

  group('GameEngine.updateRotation', () {
    test('constant pattern rotates at constant speed', () {
      const log = GameLog(
        angle: 0,
        baseSpeed: 2.0,
        currentSpeed: 2.0,
        pattern: RotationPattern.constant,
      );

      final result = GameEngine.updateRotation(log, 0.5);
      expect(result.angle, closeTo(1.0, 0.001)); // 2.0 * 0.5 = 1.0
    });

    test('rotation wraps around', () {
      const log = GameLog(
        angle: 6.0,
        baseSpeed: 2.0,
        currentSpeed: 2.0,
        pattern: RotationPattern.constant,
      );

      final result = GameEngine.updateRotation(log, 0.5);
      // 6.0 + 1.0 = 7.0, normalized: 7.0 - 2*pi ≈ 0.717
      expect(result.angle, closeTo(7.0 - 2 * pi, 0.01));
    });

    test('reversing pattern changes direction', () {
      const log = GameLog(
        angle: 0,
        baseSpeed: 2.0,
        currentSpeed: 2.0,
        pattern: RotationPattern.reversing,
        patternTime: 0.0,
      );

      // First half second: cycle 0, direction = 1
      final r1 = GameEngine.updateRotation(log, 0.5);
      expect(r1.currentSpeed, greaterThan(0));

      // At time = 2.5, cycle = 1, direction = -1
      final log2 = log.copyWith(patternTime: 2.0);
      final r2 = GameEngine.updateRotation(log2, 0.5);
      expect(r2.currentSpeed, lessThan(0));
    });

    test('variable pattern oscillates speed', () {
      const log = GameLog(
        angle: 0,
        baseSpeed: 2.0,
        currentSpeed: 2.0,
        pattern: RotationPattern.variable,
        patternTime: 0.0,
      );

      final r1 = GameEngine.updateRotation(log, 0.1);
      // Speed should be between 0.5x and 1.5x base (1.0 to 3.0).
      expect(r1.currentSpeed, greaterThanOrEqualTo(0.9));
      expect(r1.currentSpeed, lessThanOrEqualTo(3.1));
    });
  });

  group('GameEngine.calculateKnifeAngleInLog', () {
    test('knife directly above log gives correct angle', () {
      // Knife at (100, 0), log center at (100, 100), log angle = 0.
      final angle = GameEngine.calculateKnifeAngleInLog(
          100, 0, 100, 100, 0);
      // atan2(0, 100) = 0 (pointing straight up).
      expect(angle, closeTo(0, 0.001));
    });

    test('knife to the right of log center', () {
      // Knife at (200, 100), log center at (100, 100), log angle = 0.
      final angle = GameEngine.calculateKnifeAngleInLog(
          200, 100, 100, 100, 0);
      // atan2(100, 0) = pi/2.
      expect(angle, closeTo(pi / 2, 0.001));
    });

    test('accounts for log rotation', () {
      // Knife directly above, log rotated by pi/4.
      final angle = GameEngine.calculateKnifeAngleInLog(
          100, 0, 100, 100, pi / 4);
      // World angle = 0, in log frame = 0 - pi/4, normalized.
      expect(angle, closeTo(2 * pi - pi / 4, 0.001));
    });
  });

  group('GameEngine.stickKnife', () {
    test('sticks knife and increments count', () {
      const state = GameState(
        level: 1,
        log: GameLog(),
        knivesToThrow: 5,
        knivesThrown: 0,
        currentKnifeId: 1,
      );

      final result = GameEngine.stickKnife(state, 1.0);
      expect(result.stuckKnives.length, 1);
      expect(result.stuckKnives.first.angleInLog, closeTo(1.0, 0.001));
      expect(result.knivesThrown, 1);
      expect(result.phase, GamePhase.ready);
      expect(result.currentKnifeId, 2);
    });

    test('completes level when all knives thrown', () {
      const state = GameState(
        level: 1,
        log: GameLog(),
        knivesToThrow: 1,
        knivesThrown: 0,
        currentKnifeId: 5,
      );

      final result = GameEngine.stickKnife(state, 0.5);
      expect(result.phase, GamePhase.levelComplete);
      expect(result.knivesThrown, 1);
    });

    test('adds score when knife sticks', () {
      const state = GameState(
        level: 3,
        log: GameLog(),
        knivesToThrow: 5,
        knivesThrown: 0,
        score: 0,
        currentKnifeId: 1,
      );

      final result = GameEngine.stickKnife(state, 1.0);
      expect(result.score, greaterThan(0));
    });

    test('boss level gives double score', () {
      const normalState = GameState(
        level: 5,
        log: GameLog(),
        knivesToThrow: 5,
        knivesThrown: 0,
        score: 0,
        currentKnifeId: 1,
      );
      const bossState = GameState(
        level: 5,
        isBoss: true,
        log: GameLog(isBoss: true),
        knivesToThrow: 5,
        knivesThrown: 0,
        score: 0,
        currentKnifeId: 1,
      );

      final normalResult = GameEngine.stickKnife(normalState, 1.0);
      final bossResult = GameEngine.stickKnife(bossState, 1.0);
      expect(bossResult.score, normalResult.score * 2);
    });
  });

  group('Score calculation', () {
    test('base knife score scales with level', () {
      final score1 = GameEngine.calculateKnifeScore(1, false);
      final score5 = GameEngine.calculateKnifeScore(5, false);
      expect(score5, score1 * 5);
    });

    test('boss multiplier doubles knife score', () {
      final normal = GameEngine.calculateKnifeScore(3, false);
      final boss = GameEngine.calculateKnifeScore(3, true);
      expect(boss, (normal * AppConstants.bossMultiplier).round());
    });

    test('level bonus scales with level', () {
      final bonus1 = GameEngine.calculateLevelBonus(1, false);
      final bonus10 = GameEngine.calculateLevelBonus(10, false);
      expect(bonus10, bonus1 * 10);
    });
  });
}
