import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/game_state.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/game_over_modal.dart';
import '../widgets/knife_widget.dart';
import '../widgets/log_painter.dart';
import '../widgets/neon_glow.dart';
import '../widgets/score_display.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Timer? _secondTimer;

  double _throwY = 0.0;
  bool _isFlying = false;
  double _trailOpacity = 0.0;

  // Hit animation state
  double _shakeOffset = 0.0;
  double _hitFlashOpacity = 0.0;
  bool _showGameOver = false;

  // Level complete animation
  double _celebrationOpacity = 0.0;
  bool _showLevelComplete = false;

  // Boss glow phase
  double _bossGlowPhase = 0.0;

  // Layout values computed once
  double _logCenterY = 0.0;
  double _logRadius = 0.0;
  double _knifeStartY = 0.0;

  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();

    _secondTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(gameProvider.notifier).tick();
    });

    Future.microtask(() {
      ref.read(gameProvider.notifier).startNewGame();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _secondTimer?.cancel();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTick == Duration.zero
        ? 1 / 60
        : (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;

    // Cap dt to prevent huge jumps
    final safeDt = dt.clamp(0.0, 0.05);

    final game = ref.read(gameProvider);
    if (game == null) return;

    // Update rotation
    ref.read(gameProvider.notifier).updateRotation(safeDt);

    // Boss glow
    if (game.isBoss) {
      setState(() {
        _bossGlowPhase += safeDt * 3.0;
      });
    }

    // Handle throwing animation
    if (_isFlying && game.phase == GamePhase.throwing) {
      setState(() {
        _throwY -= AppConstants.throwSpeed * safeDt;
        _trailOpacity = 0.8;
      });
      ref
          .read(gameProvider.notifier)
          .updateThrow(_throwY, _logRadius, _logCenterY);
    }

    // After throw completes, check result
    final updatedGame = ref.read(gameProvider);
    if (updatedGame == null) return;

    if (_isFlying && updatedGame.phase == GamePhase.hit) {
      _onKnifeHit();
    } else if (_isFlying && updatedGame.phase == GamePhase.ready) {
      // Knife stuck successfully
      _onKnifeStuck();
    } else if (_isFlying && updatedGame.phase == GamePhase.levelComplete) {
      _onKnifeStuck();
      _onLevelComplete();
    }

    // Decay trail
    if (!_isFlying && _trailOpacity > 0) {
      setState(() {
        _trailOpacity = (_trailOpacity - safeDt * 4).clamp(0.0, 1.0);
      });
    }

    // Decay shake
    if (_shakeOffset != 0) {
      setState(() {
        _shakeOffset *= 0.85;
        if (_shakeOffset.abs() < 0.5) _shakeOffset = 0;
      });
    }

    // Decay hit flash
    if (_hitFlashOpacity > 0) {
      setState(() {
        _hitFlashOpacity = (_hitFlashOpacity - safeDt * 3).clamp(0.0, 1.0);
      });
    }

    // Decay celebration
    if (_celebrationOpacity > 0 && !_showLevelComplete) {
      setState(() {
        _celebrationOpacity =
            (_celebrationOpacity - safeDt * 2).clamp(0.0, 1.0);
      });
    }
  }

  void _onTap() {
    final game = ref.read(gameProvider);
    if (game == null) return;

    if (game.phase == GamePhase.ready && !_isFlying) {
      final settings = ref.read(settingsProvider);
      if (settings.hapticEnabled) HapticFeedback.lightImpact();

      ref.read(gameProvider.notifier).throwKnife();
      setState(() {
        _isFlying = true;
        _throwY = _knifeStartY;
      });
    } else if (_showLevelComplete) {
      _advanceLevel();
    }
  }

  void _onKnifeStuck() {
    final settings = ref.read(settingsProvider);
    if (settings.hapticEnabled) HapticFeedback.mediumImpact();

    setState(() {
      _isFlying = false;
      _throwY = _knifeStartY;
    });
  }

  void _onKnifeHit() {
    final settings = ref.read(settingsProvider);
    if (settings.hapticEnabled) HapticFeedback.heavyImpact();

    setState(() {
      _isFlying = false;
      _hitFlashOpacity = 1.0;
      _shakeOffset = 12.0;
    });

    // Transition to game over after a brief pause
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      ref.read(gameProvider.notifier).confirmGameOver();
      _recordGameOver();
      setState(() {
        _showGameOver = true;
      });
    });
  }

  void _onLevelComplete() {
    final settings = ref.read(settingsProvider);
    if (settings.hapticEnabled) HapticFeedback.heavyImpact();

    setState(() {
      _celebrationOpacity = 1.0;
      _showLevelComplete = true;
    });

  }

  void _advanceLevel() {
    setState(() {
      _showLevelComplete = false;
      _celebrationOpacity = 0.0;
      _throwY = _knifeStartY;
      _isFlying = false;
    });
    ref.read(gameProvider.notifier).nextLevel();
  }

  void _recordGameOver() {
    final game = ref.read(gameProvider);
    if (game == null) return;

    final notifier = ref.read(gameProvider.notifier);
    ref.read(progressProvider.notifier).completeGame(
          levelReached: game.level,
          score: game.score,
          knivesThrown: notifier.totalKnivesInRun + game.knivesThrown,
          timeSeconds: game.elapsedSeconds,
          bossesBeaten: notifier.bossesBeatenInRun,
        );
  }

  void _onRetry() {
    setState(() {
      _showGameOver = false;
      _hitFlashOpacity = 0.0;
      _shakeOffset = 0.0;
      _throwY = _knifeStartY;
      _isFlying = false;
    });
    ref.read(gameProvider.notifier).startNewGame();
  }

  void _onMenu() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final l10n = AppLocalizations.of(context)!;

    if (game == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      _logRadius = constraints.maxWidth * AppConstants.logRadiusFraction;
      _logCenterY = constraints.maxHeight * 0.32;
      _knifeStartY = constraints.maxHeight * 0.72;

      return Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _onTap(),
          child: Stack(
            children: [
              const AtmosphericBackground(),
              // Main game area
              Transform.translate(
                offset: Offset(
                    _shakeOffset * sin(_bossGlowPhase * 20), 0),
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: LogPainter(
                      logAngle: game.log.angle,
                      logRadius: _logRadius,
                      stuckKnives: game.stuckKnives,
                      isBoss: game.isBoss,
                      bossGlowPhase: _bossGlowPhase,
                    ),
                    foregroundPainter: _shouldShowKnife(game)
                        ? KnifePainter(
                            knifeY: _isFlying ? _throwY : _knifeStartY,
                            logRadius: _logRadius,
                            isFlying: _isFlying,
                            trailOpacity: _trailOpacity,
                          )
                        : null,
                  ),
                ),
              ),
              // HUD
              SafeArea(
                child: Column(
                  children: [
                    // Top bar with back button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: AppColors.neonGreen),
                            onPressed: () {
                              if (game.phase != GamePhase.gameOver) {
                                _recordGameOver();
                              }
                              Navigator.pop(context);
                            },
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    ScoreDisplay(
                      level: game.level,
                      score: game.score,
                      knivesRemaining: game.knivesRemaining,
                      isBoss: game.isBoss,
                      levelLabel: l10n.level,
                      scoreLabel: l10n.score,
                    ),
                    const Spacer(),
                    // Knife counter at bottom
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: KnifeCounter(
                        remaining: game.knivesRemaining,
                        total: game.knivesToThrow,
                      ),
                    ),
                  ],
                ),
              ),
              // Hit flash overlay
              if (_hitFlashOpacity > 0)
                IgnorePointer(
                  child: Container(
                    color: AppColors.error
                        .withValues(alpha: _hitFlashOpacity * 0.3),
                  ),
                ),
              // Level complete overlay
              if (_showLevelComplete)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => _advanceLevel(),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NeonText(
                            l10n.levelComplete,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                            glowColor: AppColors.primaryGlowStrong,
                          ),
                          const SizedBox(height: 12),
                          if (game.isBoss) ...[
                            NeonText(
                              l10n.bossDefeated,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppColors.secondary,
                                  ),
                              glowColor: AppColors.secondaryGlow,
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            l10n.tapToContinue,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      letterSpacing: 2,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Game over modal
              if (_showGameOver)
                Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: GameOverModal(
                      level: game.level,
                      score: game.score,
                      knivesThrown: ref
                              .read(gameProvider.notifier)
                              .totalKnivesInRun +
                          game.knivesThrown,
                      isNewBest: game.score >
                          (ref.read(progressProvider).bestScore),
                      gameOverText: l10n.gameOver,
                      levelLabel: l10n.level,
                      scoreLabel: l10n.score,
                      knivesLabel: l10n.knives,
                      bestScoreLabel: l10n.newBest,
                      retryLabel: l10n.retry,
                      menuLabel: l10n.menu,
                      hapticEnabled: ref.read(settingsProvider).hapticEnabled,
                      onRetry: _onRetry,
                      onMenu: _onMenu,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  bool _shouldShowKnife(GameState game) {
    return game.phase == GamePhase.ready ||
        game.phase == GamePhase.throwing;
  }
}
