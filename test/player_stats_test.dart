import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:knife_toss/domain/models/player_stats.dart';

void main() {
  group('PlayerStats', () {
    test('default values are sensible', () {
      const stats = PlayerStats();
      expect(stats.highestLevel, 1);
      expect(stats.levelsCompleted, 0);
      expect(stats.totalScore, 0);
      expect(stats.bestScore, 0);
      expect(stats.totalKnivesThrown, 0);
      expect(stats.totalPlayTimeSeconds, 0);
      expect(stats.bossesDefeated, 0);
      expect(stats.adsRemoved, false);
    });

    test('withGameComplete updates stats correctly', () {
      const stats = PlayerStats();
      final updated = stats.withGameComplete(
        levelReached: 5,
        score: 1000,
        knivesThrown: 20,
        timeSeconds: 120,
        bossesBeaten: 1,
      );

      expect(updated.highestLevel, 5);
      expect(updated.levelsCompleted, 4); // levelReached - 1
      expect(updated.totalScore, 1000);
      expect(updated.bestScore, 1000);
      expect(updated.totalKnivesThrown, 20);
      expect(updated.totalPlayTimeSeconds, 120);
      expect(updated.bossesDefeated, 1);
    });

    test('withGameComplete accumulates across games', () {
      const stats = PlayerStats(
        highestLevel: 3,
        levelsCompleted: 5,
        totalScore: 500,
        bestScore: 600,
        totalKnivesThrown: 30,
        totalPlayTimeSeconds: 200,
        bossesDefeated: 1,
      );

      final updated = stats.withGameComplete(
        levelReached: 8,
        score: 700,
        knivesThrown: 25,
        timeSeconds: 90,
        bossesBeaten: 1,
      );

      expect(updated.highestLevel, 8);
      expect(updated.levelsCompleted, 12); // 5 + (8-1)
      expect(updated.totalScore, 1200); // 500 + 700
      expect(updated.bestScore, 700); // 700 > 600
      expect(updated.totalKnivesThrown, 55); // 30 + 25
      expect(updated.totalPlayTimeSeconds, 290); // 200 + 90
      expect(updated.bossesDefeated, 2);
    });

    test('best score only updates when higher', () {
      const stats = PlayerStats(bestScore: 1000);
      final updated = stats.withGameComplete(
        levelReached: 2,
        score: 500,
        knivesThrown: 10,
        timeSeconds: 60,
        bossesBeaten: 0,
      );

      expect(updated.bestScore, 1000); // Not updated.
    });

    test('highest level only updates when higher', () {
      const stats = PlayerStats(highestLevel: 10);
      final updated = stats.withGameComplete(
        levelReached: 3,
        score: 100,
        knivesThrown: 5,
        timeSeconds: 30,
        bossesBeaten: 0,
      );

      expect(updated.highestLevel, 10); // Not updated.
    });

    test('copyWith preserves unchanged fields', () {
      const stats = PlayerStats(
        highestLevel: 5,
        totalScore: 1000,
        adsRemoved: true,
      );

      final updated = stats.copyWith(totalScore: 2000);
      expect(updated.highestLevel, 5);
      expect(updated.totalScore, 2000);
      expect(updated.adsRemoved, true);
    });

    test('serialization round trip', () {
      const original = PlayerStats(
        highestLevel: 15,
        levelsCompleted: 42,
        totalScore: 5000,
        bestScore: 1200,
        totalKnivesThrown: 300,
        totalPlayTimeSeconds: 3600,
        bossesDefeated: 8,
        adsRemoved: true,
      );

      final json = original.toJson();
      final jsonStr = jsonEncode(json);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = PlayerStats.fromJson(decoded);

      expect(restored, original);
    });

    test('fromJson handles missing fields gracefully', () {
      final stats = PlayerStats.fromJson({});
      expect(stats.highestLevel, 1);
      expect(stats.totalScore, 0);
      expect(stats.adsRemoved, false);
    });

    test('equatable equality works', () {
      const a = PlayerStats(highestLevel: 5, totalScore: 100);
      const b = PlayerStats(highestLevel: 5, totalScore: 100);
      const c = PlayerStats(highestLevel: 5, totalScore: 200);

      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
