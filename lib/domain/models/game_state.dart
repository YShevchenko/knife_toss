import 'package:equatable/equatable.dart';
import 'knife.dart';
import 'log.dart';

/// Phase of the game.
enum GamePhase {
  /// Waiting for player to tap.
  ready,

  /// Knife is flying toward the log.
  throwing,

  /// Knife hit another knife -- game over.
  hit,

  /// Level completed successfully.
  levelComplete,

  /// Game over screen.
  gameOver,
}

/// Immutable state of a single game session.
class GameState extends Equatable {
  /// Current level number.
  final int level;

  /// Whether this is a boss level.
  final bool isBoss;

  /// The rotating log.
  final GameLog log;

  /// All knives that are stuck in the log.
  final List<Knife> stuckKnives;

  /// Total knives the player needs to throw this level.
  final int knivesToThrow;

  /// How many knives the player has already thrown successfully.
  final int knivesThrown;

  /// Current game phase.
  final GamePhase phase;

  /// Current score for this session.
  final int score;

  /// Y position of the knife being thrown (0 = top, positive = down).
  /// Only meaningful during [GamePhase.throwing].
  final double throwY;

  /// The current knife ID being thrown.
  final int currentKnifeId;

  /// Elapsed time in seconds.
  final int elapsedSeconds;

  const GameState({
    required this.level,
    this.isBoss = false,
    required this.log,
    this.stuckKnives = const [],
    required this.knivesToThrow,
    this.knivesThrown = 0,
    this.phase = GamePhase.ready,
    this.score = 0,
    this.throwY = 0.0,
    this.currentKnifeId = 0,
    this.elapsedSeconds = 0,
  });

  /// Number of knives remaining to throw.
  int get knivesRemaining => knivesToThrow - knivesThrown;

  /// Whether the level is complete.
  bool get isComplete => phase == GamePhase.levelComplete;

  /// Whether the game is over.
  bool get isGameOver => phase == GamePhase.gameOver;

  GameState copyWith({
    int? level,
    bool? isBoss,
    GameLog? log,
    List<Knife>? stuckKnives,
    int? knivesToThrow,
    int? knivesThrown,
    GamePhase? phase,
    int? score,
    double? throwY,
    int? currentKnifeId,
    int? elapsedSeconds,
  }) {
    return GameState(
      level: level ?? this.level,
      isBoss: isBoss ?? this.isBoss,
      log: log ?? this.log,
      stuckKnives: stuckKnives ?? this.stuckKnives,
      knivesToThrow: knivesToThrow ?? this.knivesToThrow,
      knivesThrown: knivesThrown ?? this.knivesThrown,
      phase: phase ?? this.phase,
      score: score ?? this.score,
      throwY: throwY ?? this.throwY,
      currentKnifeId: currentKnifeId ?? this.currentKnifeId,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  @override
  List<Object?> get props => [
        level,
        isBoss,
        log,
        stuckKnives,
        knivesToThrow,
        knivesThrown,
        phase,
        score,
        throwY,
        currentKnifeId,
        elapsedSeconds,
      ];
}
