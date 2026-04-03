import 'package:equatable/equatable.dart';

/// Represents a single knife, either stuck in the log or being thrown.
class Knife extends Equatable {
  /// Unique identifier for this knife.
  final int id;

  /// Angle in the log's local coordinate frame (radians).
  /// Only meaningful for stuck knives.
  final double angleInLog;

  /// Whether this knife is currently stuck in the log.
  final bool isStuck;

  /// Whether this knife is pre-placed (boss level).
  final bool isPrePlaced;

  const Knife({
    required this.id,
    this.angleInLog = 0.0,
    this.isStuck = false,
    this.isPrePlaced = false,
  });

  Knife stickAt(double angle) {
    return Knife(
      id: id,
      angleInLog: angle,
      isStuck: true,
      isPrePlaced: isPrePlaced,
    );
  }

  Knife copyWith({
    int? id,
    double? angleInLog,
    bool? isStuck,
    bool? isPrePlaced,
  }) {
    return Knife(
      id: id ?? this.id,
      angleInLog: angleInLog ?? this.angleInLog,
      isStuck: isStuck ?? this.isStuck,
      isPrePlaced: isPrePlaced ?? this.isPrePlaced,
    );
  }

  @override
  List<Object?> get props => [id, angleInLog, isStuck, isPrePlaced];
}
