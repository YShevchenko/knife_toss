import 'package:flutter/material.dart';

/// Subtle CRT-style scanline overlay for the neon aesthetic.
class ScanlineOverlay extends StatelessWidget {
  final double opacity;

  const ScanlineOverlay({super.key, this.opacity = 0.03});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ScanlinePainter(opacity: opacity),
        ),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double opacity;
  _ScanlinePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
