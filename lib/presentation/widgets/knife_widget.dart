import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Draws the knife the player is about to throw or is currently throwing.
class KnifePainter extends CustomPainter {
  final double knifeY;
  final double logRadius;
  final bool isFlying;
  final double trailOpacity;

  KnifePainter({
    required this.knifeY,
    required this.logRadius,
    required this.isFlying,
    this.trailOpacity = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    final bladeLength = logRadius * 0.5;
    final handleLength = logRadius * 0.4;
    final totalLength = bladeLength + handleLength;

    final topY = knifeY;

    // Trail effect when flying
    if (isFlying && trailOpacity > 0) {
      for (int i = 1; i <= 4; i++) {
        final trailY = topY + i * 12.0;
        final alpha = trailOpacity * (1.0 - i * 0.22);
        if (alpha <= 0) continue;

        final trailPaint = Paint()
          ..color = AppColors.primary.withValues(alpha: alpha)
          ..strokeWidth = 3.0 - i * 0.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(centerX, trailY),
          Offset(centerX, trailY + 8),
          trailPaint,
        );
      }
    }

    // Blade
    final bladePaint = Paint()
      ..color = AppColors.knifeMetallic
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Blade: sharp at top, from topY to topY + bladeLength.
    canvas.drawLine(
      Offset(centerX, topY),
      Offset(centerX, topY + bladeLength),
      bladePaint,
    );

    // Blade tip highlight
    final tipPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, topY),
      Offset(centerX, topY + 6),
      tipPaint,
    );

    // Handle
    final handlePaint = Paint()
      ..color = AppColors.knifeHandle
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, topY + bladeLength),
      Offset(centerX, topY + totalLength),
      handlePaint,
    );

    // Handle glow
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, topY + bladeLength),
      Offset(centerX, topY + totalLength),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant KnifePainter oldDelegate) {
    return oldDelegate.knifeY != knifeY ||
        oldDelegate.isFlying != isFlying ||
        oldDelegate.trailOpacity != trailOpacity;
  }
}
