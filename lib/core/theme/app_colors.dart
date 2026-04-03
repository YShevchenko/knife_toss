import 'package:flutter/material.dart';

/// Neon Void color palette -- Knife Toss.
abstract final class AppColors {
  // Core surfaces
  static const background = Color(0xFF0E0E13);
  static const surface = Color(0xFF0E0E13);
  static const surfaceContainer = Color(0xFF16161C);
  static const surfaceContainerLow = Color(0xFF121217);
  static const surfaceContainerHigh = Color(0xFF1C1C24);
  static const surfaceContainerHighest = Color(0xFF22222C);
  static const surfaceContainerLowest = Color(0xFF0A0A0E);
  static const surfaceBright = Color(0xFF2A2A36);

  // Primary (neon green)
  static const primary = Color(0xFFA9FFDF);
  static const primaryContainer = Color(0xFF00FFA0);
  static const primaryDim = Color(0xFF00C880);
  static const onPrimary = Color(0xFF003428);
  static const onPrimaryFixed = Color(0xFF002418);
  static const neonGreen = Color(0xFFA9FFDF);

  // Secondary (neon pink)
  static const secondary = Color(0xFFFF59E3);
  static const secondaryContainer = Color(0xFFFF29D6);
  static const onSecondary = Color(0xFF3E0036);

  // Tertiary (neon purple)
  static const tertiary = Color(0xFFAC89FF);
  static const tertiaryContainer = Color(0xFF9B6FFF);
  static const tertiaryDim = Color(0xFF8B69E0);

  // Error
  static const error = Color(0xFFFF716C);
  static const errorContainer = Color(0xFF9F0519);
  static const onErrorContainer = Color(0xFFFFA8A3);

  // Text / surface
  static const onSurface = Color(0xFFF3EFF6);
  static const onSurfaceVariant = Color(0xFF8A8E9E);
  static const onBackground = Color(0xFFF3EFF6);
  static const outline = Color(0xFF5A5E70);
  static const outlineVariant = Color(0xFF36384A);

  // Glow presets
  static const primaryGlow = Color(0x66A9FFDF);
  static const primaryGlowStrong = Color(0x9900FFA0);
  static const secondaryGlow = Color(0x44FF59E3);
  static const tertiaryGlow = Color(0x44AC89FF);

  // Game-specific
  static const knifeMetallic = Color(0xFFD4D8E0);
  static const knifeHandle = Color(0xFFA9FFDF);
  static const logBrown = Color(0xFF8B6914);
  static const logDark = Color(0xFF5C4400);
  static const bossRed = Color(0xFFCC2244);
  static const bossPurple = Color(0xFFAC89FF);

  // Star colors
  static const starFilled = Color(0xFFFFD700);
  static const starEmpty = Color(0xFF36384A);
}
