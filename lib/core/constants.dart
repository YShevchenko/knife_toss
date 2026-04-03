import 'dart:math';

/// App tuning constants. Change here, not scattered through code.
abstract final class AppConstants {
  // -- Log --

  /// Log radius as fraction of screen width.
  static const double logRadiusFraction = 0.15;

  /// Knife angular width in radians for collision detection.
  static const double knifeAngularWidth = 0.15;

  /// Knife blade length as fraction of log radius.
  static const double knifeBladeRatio = 0.55;

  /// Knife handle length as fraction of log radius.
  static const double knifeHandleRatio = 0.45;

  /// Knife blade width in logical pixels.
  static const double knifeBladeWidth = 4.0;

  /// Knife handle width in logical pixels.
  static const double knifeHandleWidth = 8.0;

  // -- Throw --

  /// Knife throw speed in logical pixels per second.
  static const double throwSpeed = 1800.0;

  /// Distance from log center at which throw starts.
  static const double throwStartOffsetY = 200.0;

  // -- Rotation --

  /// Base rotation speed in radians per second.
  static const double baseRotationSpeed = 1.2;

  // -- Difficulty --

  /// Level thresholds for difficulty tiers.
  static const int tier2Start = 6;
  static const int tier3Start = 11;
  static const int tier4Start = 21;

  /// Knives to throw per tier [min, max].
  static const List<List<int>> knivesPerTier = [
    [4, 6], // tier 1: levels 1-5
    [6, 8], // tier 2: levels 6-10
    [8, 10], // tier 3: levels 11-20
    [10, 12], // tier 4: levels 21+
  ];

  /// Rotation speed multipliers per tier.
  static const List<double> speedMultipliers = [
    0.6, // tier 1: slow
    1.0, // tier 2: medium
    1.4, // tier 3: fast
    1.8, // tier 4: very fast
  ];

  /// Boss level frequency.
  static const int bossFrequency = 5;

  /// Pre-placed knives on boss levels [min, max].
  static const List<int> bossPrePlacedKnives = [2, 4];

  // -- Scoring --

  /// Base score per knife stuck.
  static const int baseScorePerKnife = 50;

  /// Bonus score per level completed.
  static const int levelCompleteBonus = 200;

  /// Boss level bonus multiplier.
  static const double bossMultiplier = 2.0;

  // -- Ads --

  /// Show interstitial ad every N levels completed.
  static const int adFrequencyLevels = 3;

  /// IAP product IDs.
  static const String removeAdsProductId = 'knife_toss_remove_ads';

  /// Available locales.
  static const Map<String, String> supportedLocales = {
    'en': 'English',
    'de': 'Deutsch',
    'es': 'Espanol',
    'uk': 'Ukrainska',
  };

  // -- Animation --

  /// Knife throw animation duration in milliseconds.
  static const int throwDurationMs = 200;

  /// Hit flash duration in milliseconds.
  static const int hitFlashDurationMs = 300;

  /// Shake duration in milliseconds.
  static const int shakeDurationMs = 400;

  /// Level complete celebration duration in milliseconds.
  static const int celebrationDurationMs = 1200;

  // -- Knife colors --

  /// Wood grain line count on log.
  static const int woodGrainLines = 12;

  /// Log circle color (amber/brown).
  static const int logColor = 0xFF8B6914;
  static const int logDarkColor = 0xFF5C4400;
  static const int logGrainColor = 0xFF704B0A;

  /// Boss log color.
  static const int bossLogColor = 0xFFCC2244;
  static const int bossLogDarkColor = 0xFF881133;

  /// Two pi for convenience.
  static const double twoPi = 2 * pi;
}
