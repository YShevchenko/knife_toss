import 'package:equatable/equatable.dart';

/// Persistent player statistics and progress.
class PlayerStats extends Equatable {
  /// Highest level reached.
  final int highestLevel;

  /// Total number of levels completed.
  final int levelsCompleted;

  /// Total score across all games.
  final int totalScore;

  /// Best score in a single game run.
  final int bestScore;

  /// Total knives thrown.
  final int totalKnivesThrown;

  /// Total play time in seconds.
  final int totalPlayTimeSeconds;

  /// Boss levels defeated.
  final int bossesDefeated;

  /// Whether ads have been removed via IAP.
  final bool adsRemoved;

  const PlayerStats({
    this.highestLevel = 1,
    this.levelsCompleted = 0,
    this.totalScore = 0,
    this.bestScore = 0,
    this.totalKnivesThrown = 0,
    this.totalPlayTimeSeconds = 0,
    this.bossesDefeated = 0,
    this.adsRemoved = false,
  });

  /// Update stats after a game session ends.
  PlayerStats withGameComplete({
    required int levelReached,
    required int score,
    required int knivesThrown,
    required int timeSeconds,
    required int bossesBeaten,
  }) {
    return PlayerStats(
      highestLevel: levelReached > highestLevel ? levelReached : highestLevel,
      levelsCompleted: levelsCompleted + levelReached - 1,
      totalScore: totalScore + score,
      bestScore: score > bestScore ? score : bestScore,
      totalKnivesThrown: totalKnivesThrown + knivesThrown,
      totalPlayTimeSeconds: totalPlayTimeSeconds + timeSeconds,
      bossesDefeated: bossesDefeated + bossesBeaten,
      adsRemoved: adsRemoved,
    );
  }

  PlayerStats copyWith({
    int? highestLevel,
    int? levelsCompleted,
    int? totalScore,
    int? bestScore,
    int? totalKnivesThrown,
    int? totalPlayTimeSeconds,
    int? bossesDefeated,
    bool? adsRemoved,
  }) {
    return PlayerStats(
      highestLevel: highestLevel ?? this.highestLevel,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      totalScore: totalScore ?? this.totalScore,
      bestScore: bestScore ?? this.bestScore,
      totalKnivesThrown: totalKnivesThrown ?? this.totalKnivesThrown,
      totalPlayTimeSeconds:
          totalPlayTimeSeconds ?? this.totalPlayTimeSeconds,
      bossesDefeated: bossesDefeated ?? this.bossesDefeated,
      adsRemoved: adsRemoved ?? this.adsRemoved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'highestLevel': highestLevel,
      'levelsCompleted': levelsCompleted,
      'totalScore': totalScore,
      'bestScore': bestScore,
      'totalKnivesThrown': totalKnivesThrown,
      'totalPlayTimeSeconds': totalPlayTimeSeconds,
      'bossesDefeated': bossesDefeated,
      'adsRemoved': adsRemoved,
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      highestLevel: json['highestLevel'] as int? ?? 1,
      levelsCompleted: json['levelsCompleted'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      totalKnivesThrown: json['totalKnivesThrown'] as int? ?? 0,
      totalPlayTimeSeconds: json['totalPlayTimeSeconds'] as int? ?? 0,
      bossesDefeated: json['bossesDefeated'] as int? ?? 0,
      adsRemoved: json['adsRemoved'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        highestLevel,
        levelsCompleted,
        totalScore,
        bestScore,
        totalKnivesThrown,
        totalPlayTimeSeconds,
        bossesDefeated,
        adsRemoved,
      ];
}
