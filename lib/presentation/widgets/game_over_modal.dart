import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'neon_button.dart';
import 'neon_glow.dart';
import 'stats_row.dart';

/// Modal shown when the game ends (knife hit).
class GameOverModal extends StatelessWidget {
  final int level;
  final int score;
  final int knivesThrown;
  final bool isNewBest;
  final String gameOverText;
  final String levelLabel;
  final String scoreLabel;
  final String knivesLabel;
  final String bestScoreLabel;
  final String retryLabel;
  final String menuLabel;
  final bool hapticEnabled;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  const GameOverModal({
    super.key,
    required this.level,
    required this.score,
    required this.knivesThrown,
    required this.isNewBest,
    required this.gameOverText,
    required this.levelLabel,
    required this.scoreLabel,
    required this.knivesLabel,
    required this.bestScoreLabel,
    required this.retryLabel,
    required this.menuLabel,
    required this.hapticEnabled,
    required this.onRetry,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.15),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeonText(
            gameOverText,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w800,
                ),
            glowColor: AppColors.error.withValues(alpha: 0.5),
          ),
          if (isNewBest) ...[
            const SizedBox(height: 8),
            NeonText(
              bestScoreLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.starFilled,
                  ),
              glowColor: AppColors.starFilled.withValues(alpha: 0.4),
            ),
          ],
          const SizedBox(height: 24),
          StatsRow(
            stats: [
              StatItem(
                label: levelLabel.toUpperCase(),
                value: '$level',
                color: AppColors.primary,
              ),
              StatItem(
                label: scoreLabel.toUpperCase(),
                value: '$score',
                color: AppColors.secondary,
              ),
              StatItem(
                label: knivesLabel.toUpperCase(),
                value: '$knivesThrown',
                color: AppColors.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 32),
          NeonButton(
            label: retryLabel.toUpperCase(),
            onTap: onRetry,
            hapticEnabled: hapticEnabled,
            isLarge: true,
          ),
          const SizedBox(height: 12),
          NeonOutlinedButton(
            label: menuLabel.toUpperCase(),
            onTap: onMenu,
            hapticEnabled: hapticEnabled,
          ),
        ],
      ),
    );
  }
}
