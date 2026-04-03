import 'package:flutter_test/flutter_test.dart';
import 'package:knife_toss/core/constants.dart';
import 'package:knife_toss/domain/models/game_state.dart';
import 'package:knife_toss/domain/models/log.dart';
import 'package:knife_toss/domain/services/level_service.dart';

void main() {
  late LevelService levelService;

  setUp(() {
    levelService = LevelService();
  });

  group('LevelService.isBossLevel', () {
    test('level 5 is a boss level', () {
      expect(LevelService.isBossLevel(5), isTrue);
    });

    test('level 10 is a boss level', () {
      expect(LevelService.isBossLevel(10), isTrue);
    });

    test('level 15 is a boss level', () {
      expect(LevelService.isBossLevel(15), isTrue);
    });

    test('level 1 is not a boss level', () {
      expect(LevelService.isBossLevel(1), isFalse);
    });

    test('level 3 is not a boss level', () {
      expect(LevelService.isBossLevel(3), isFalse);
    });

    test('level 0 is not a boss level', () {
      expect(LevelService.isBossLevel(0), isFalse);
    });
  });

  group('LevelService.getTier', () {
    test('level 1 is tier 0', () {
      expect(LevelService.getTier(1), 0);
    });

    test('level 5 is tier 0', () {
      expect(LevelService.getTier(5), 0);
    });

    test('level 6 is tier 1', () {
      expect(LevelService.getTier(6), 1);
    });

    test('level 10 is tier 1', () {
      expect(LevelService.getTier(10), 1);
    });

    test('level 11 is tier 2', () {
      expect(LevelService.getTier(11), 2);
    });

    test('level 20 is tier 2', () {
      expect(LevelService.getTier(20), 2);
    });

    test('level 21 is tier 3', () {
      expect(LevelService.getTier(21), 3);
    });

    test('level 100 is tier 3', () {
      expect(LevelService.getTier(100), 3);
    });
  });

  group('LevelService.getKnifeCount', () {
    test('tier 0 gives 4-6 knives', () {
      for (int i = 0; i < 20; i++) {
        final count = levelService.getKnifeCount(1);
        expect(count, inInclusiveRange(4, 6));
      }
    });

    test('tier 1 gives 6-8 knives', () {
      for (int i = 0; i < 20; i++) {
        final count = levelService.getKnifeCount(7);
        expect(count, inInclusiveRange(6, 8));
      }
    });

    test('tier 2 gives 8-10 knives', () {
      for (int i = 0; i < 20; i++) {
        final count = levelService.getKnifeCount(15);
        expect(count, inInclusiveRange(8, 10));
      }
    });

    test('tier 3 gives 10-12 knives', () {
      for (int i = 0; i < 20; i++) {
        final count = levelService.getKnifeCount(25);
        expect(count, inInclusiveRange(10, 12));
      }
    });
  });

  group('LevelService.getRotationSpeed', () {
    test('speed increases with tier', () {
      final speed0 = levelService.getRotationSpeed(1);
      final speed1 = levelService.getRotationSpeed(7);
      final speed2 = levelService.getRotationSpeed(15);
      final speed3 = levelService.getRotationSpeed(25);

      expect(speed1, greaterThan(speed0));
      expect(speed2, greaterThan(speed1));
      expect(speed3, greaterThan(speed2));
    });

    test('tier 0 uses slow multiplier', () {
      final speed = levelService.getRotationSpeed(1);
      expect(speed,
          closeTo(AppConstants.baseRotationSpeed * 0.6, 0.001));
    });
  });

  group('LevelService.generateBossKnives', () {
    test('boss level generates pre-placed knives', () {
      final knives = levelService.generateBossKnives(5);
      expect(knives.length,
          inInclusiveRange(
              AppConstants.bossPrePlacedKnives[0],
              AppConstants.bossPrePlacedKnives[1]));

      for (final knife in knives) {
        expect(knife.isStuck, isTrue);
        expect(knife.isPrePlaced, isTrue);
        expect(knife.id, lessThan(0)); // Negative IDs for pre-placed.
      }
    });

    test('non-boss level generates no pre-placed knives', () {
      final knives = levelService.generateBossKnives(1);
      expect(knives, isEmpty);
    });

    test('pre-placed knives are spread around the log', () {
      final knives = levelService.generateBossKnives(10);
      if (knives.length >= 2) {
        // Check that knives are not all at the same angle.
        final angles = knives.map((k) => k.angleInLog).toSet();
        expect(angles.length, greaterThan(1));
      }
    });
  });

  group('LevelService.createLevel', () {
    test('creates valid game state for level 1', () {
      final state = levelService.createLevel(1);
      expect(state.level, 1);
      expect(state.isBoss, isFalse);
      expect(state.knivesToThrow, inInclusiveRange(4, 6));
      expect(state.stuckKnives, isEmpty);
      expect(state.phase, GamePhase.ready);
    });

    test('creates boss state for level 5', () {
      final state = levelService.createLevel(5);
      expect(state.level, 5);
      expect(state.isBoss, isTrue);
      expect(state.log.isBoss, isTrue);
      expect(state.stuckKnives, isNotEmpty);
    });

    test('higher tiers have faster rotation', () {
      final state1 = levelService.createLevel(1);
      final state20 = levelService.createLevel(20);
      expect(state20.log.baseSpeed, greaterThan(state1.log.baseSpeed));
    });

    test('boss levels get special rotation patterns', () {
      final state = levelService.createLevel(5);
      expect(state.log.pattern, isNot(RotationPattern.constant));
    });
  });
}

// ignore_for_file: constant_identifier_names
