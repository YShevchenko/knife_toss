import 'package:equatable/equatable.dart';

/// Rotation pattern types for the log.
enum RotationPattern {
  /// Constant speed in one direction.
  constant,

  /// Speed changes periodically.
  variable,

  /// Direction reverses periodically.
  reversing,

  /// Oscillates back and forth.
  oscillating,
}

/// Represents the rotating log target.
class GameLog extends Equatable {
  /// Current rotation angle in radians (world space).
  final double angle;

  /// Base rotation speed in radians per second.
  final double baseSpeed;

  /// Current rotation speed (may vary for boss levels).
  final double currentSpeed;

  /// Whether this is a boss log.
  final bool isBoss;

  /// Rotation pattern.
  final RotationPattern pattern;

  /// Time accumulator for pattern calculations.
  final double patternTime;

  const GameLog({
    this.angle = 0.0,
    this.baseSpeed = 1.2,
    this.currentSpeed = 1.2,
    this.isBoss = false,
    this.pattern = RotationPattern.constant,
    this.patternTime = 0.0,
  });

  GameLog copyWith({
    double? angle,
    double? baseSpeed,
    double? currentSpeed,
    bool? isBoss,
    RotationPattern? pattern,
    double? patternTime,
  }) {
    return GameLog(
      angle: angle ?? this.angle,
      baseSpeed: baseSpeed ?? this.baseSpeed,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      isBoss: isBoss ?? this.isBoss,
      pattern: pattern ?? this.pattern,
      patternTime: patternTime ?? this.patternTime,
    );
  }

  @override
  List<Object?> get props =>
      [angle, baseSpeed, currentSpeed, isBoss, pattern, patternTime];
}
