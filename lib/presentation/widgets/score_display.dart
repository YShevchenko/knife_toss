import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'neon_glow.dart';

/// Displays the current level, score, and remaining knives.
class ScoreDisplay extends StatelessWidget {
  final int level;
  final int score;
  final int knivesRemaining;
  final bool isBoss;
  final String levelLabel;
  final String scoreLabel;

  const ScoreDisplay({
    super.key,
    required this.level,
    required this.score,
    required this.knivesRemaining,
    required this.isBoss,
    required this.levelLabel,
    required this.scoreLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Level
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                levelLabel.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  NeonText(
                    '$level',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: isBoss
                              ? AppColors.bossRed
                              : AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                    glowColor: isBoss
                        ? AppColors.bossRed.withValues(alpha: 0.5)
                        : AppColors.primaryGlow,
                  ),
                  if (isBoss) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.bossRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.bossRed.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'BOSS',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.bossRed,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                scoreLabel.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 2),
              NeonText(
                '$score',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                    ),
                glowColor: AppColors.secondaryGlow,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Displays remaining knives as dots/icons below the throw area.
class KnifeCounter extends StatelessWidget {
  final int remaining;
  final int total;

  const KnifeCounter({
    super.key,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isUsed = i >= remaining;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            width: 4,
            height: isUsed ? 16 : 24,
            decoration: BoxDecoration(
              color: isUsed
                  ? AppColors.outline.withValues(alpha: 0.3)
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isUsed
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
            ),
          ),
        );
      }),
    );
  }
}
