import 'dart:math';

import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/knife.dart';

/// Custom painter for the rotating log and stuck knives.
class LogPainter extends CustomPainter {
  final double logAngle;
  final double logRadius;
  final List<Knife> stuckKnives;
  final bool isBoss;
  final double bossGlowPhase;

  LogPainter({
    required this.logAngle,
    required this.logRadius,
    required this.stuckKnives,
    required this.isBoss,
    this.bossGlowPhase = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    _drawLog(canvas, center);
    _drawStuckKnives(canvas, center);
  }

  void _drawLog(Canvas canvas, Offset center) {
    // Boss glow
    if (isBoss) {
      final glowAlpha = 0.2 + 0.15 * sin(bossGlowPhase);
      final glowPaint = Paint()
        ..color = AppColors.bossRed.withValues(alpha: glowAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      canvas.drawCircle(center, logRadius + 15, glowPaint);
    }

    // Outer ring shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, logRadius + 2, shadowPaint);

    // Main log body
    final logColor = isBoss
        ? const Color(AppConstants.bossLogColor)
        : const Color(AppConstants.logColor);
    final logDarkColor = isBoss
        ? const Color(AppConstants.bossLogDarkColor)
        : const Color(AppConstants.logDarkColor);

    final logPaint = Paint()
      ..shader = RadialGradient(
        colors: [logColor, logDarkColor],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: logRadius));
    canvas.drawCircle(center, logRadius, logPaint);

    // Wood grain lines
    final grainPaint = Paint()
      ..color = Color(AppConstants.logGrainColor).withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(logAngle);

    for (int i = 0; i < AppConstants.woodGrainLines; i++) {
      final angle = (AppConstants.twoPi / AppConstants.woodGrainLines) * i;
      final inner = logRadius * 0.2;
      final outer = logRadius * 0.95;
      canvas.drawLine(
        Offset(cos(angle) * inner, sin(angle) * inner),
        Offset(cos(angle) * outer, sin(angle) * outer),
        grainPaint,
      );
    }

    // Ring marks
    for (final r in [0.4, 0.65, 0.85]) {
      canvas.drawCircle(Offset.zero, logRadius * r, grainPaint);
    }

    canvas.restore();

    // Center circle
    final centerPaint = Paint()
      ..color = logDarkColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, logRadius * 0.12, centerPaint);

    // Highlight arc
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final highlightRect = Rect.fromCircle(center: center, radius: logRadius);
    canvas.drawArc(highlightRect, -pi * 0.8, pi * 0.4, true, highlightPaint);
  }

  void _drawStuckKnives(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(logAngle);

    for (final knife in stuckKnives) {
      _drawSingleStuckKnife(canvas, knife);
    }

    canvas.restore();
  }

  void _drawSingleStuckKnife(Canvas canvas, Knife knife) {
    canvas.save();
    // Rotate to knife's angle (0 = top, clockwise).
    // We subtract pi/2 because atan2-based angles have 0 pointing up,
    // but our canvas rotation is relative to the right.
    canvas.rotate(knife.angleInLog - pi / 2);

    final bladeLength = logRadius * AppConstants.knifeBladeRatio;
    final handleLength = logRadius * AppConstants.knifeHandleRatio;

    // Blade: from log edge inward toward center.
    // Origin is at log center (due to translate), knife sticks from edge outward.
    // Blade tip is at logRadius - bladeLength from center.
    final bladeStart = logRadius;
    final bladeEnd = logRadius + handleLength;

    // Blade (inside the log, from edge toward center).
    final bladePaint = Paint()
      ..color = AppColors.knifeMetallic
      ..strokeWidth = AppConstants.knifeBladeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(bladeStart - bladeLength * 0.5, 0),
      Offset(bladeStart, 0),
      bladePaint,
    );

    // Handle (sticking out from the log edge).
    final handleColor = knife.isPrePlaced
        ? AppColors.secondary
        : AppColors.knifeHandle;
    final handlePaint = Paint()
      ..color = handleColor
      ..strokeWidth = AppConstants.knifeHandleWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(bladeStart, 0),
      Offset(bladeEnd, 0),
      handlePaint,
    );

    // Handle glow
    final glowPaint = Paint()
      ..color = handleColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..strokeWidth = AppConstants.knifeHandleWidth + 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(bladeStart, 0),
      Offset(bladeEnd, 0),
      glowPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LogPainter oldDelegate) {
    return oldDelegate.logAngle != logAngle ||
        oldDelegate.stuckKnives != stuckKnives ||
        oldDelegate.isBoss != isBoss ||
        oldDelegate.bossGlowPhase != bossGlowPhase;
  }
}
