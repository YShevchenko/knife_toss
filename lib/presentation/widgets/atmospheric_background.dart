import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Atmospheric background with floating colored blurs -- Neon Void style.
class AtmosphericBackground extends StatelessWidget {
  const AtmosphericBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -60,
            child: _BlurCircle(
              color: AppColors.primary,
              size: 200,
              opacity: 0.06,
            ),
          ),
          Positioned(
            bottom: -40,
            right: -60,
            child: _BlurCircle(
              color: AppColors.secondary,
              size: 250,
              opacity: 0.05,
            ),
          ),
          Positioned(
            top: 200,
            right: 40,
            child: _BlurCircle(
              color: AppColors.tertiary,
              size: 120,
              opacity: 0.04,
            ),
          ),
          Positioned(
            bottom: 200,
            left: 30,
            child: _BlurCircle(
              color: AppColors.primaryContainer,
              size: 100,
              opacity: 0.03,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _BlurCircle({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: size * 0.6,
            spreadRadius: size * 0.2,
          ),
        ],
      ),
    );
  }
}
