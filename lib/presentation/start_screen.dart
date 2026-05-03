import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import 'app_colors.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: _GlowOrb(size: 260, color: colors.glowOrbPrimary),
            ),
            Positioned(
              bottom: 60,
              left: -50,
              child: _GlowOrb(size: 200, color: colors.glowOrbSecondary),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: _LandingCard(
                      onStart: () => _startGame(context, ref),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, WidgetRef ref) {
    ref.read(gameControllerProvider.notifier).resetGame();
    Navigator.of(context).pushNamed(GameScreen.routeName);
  }
}

class _LandingCard extends StatelessWidget {
  const _LandingCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      key: const Key('start-screen'),
      padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 50,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ChessIcon(),
          const SizedBox(height: 28),
          Text(
            'Pocket Chess',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textHeading,
              fontSize: 36,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Play against the engine',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 36),
          FilledButton.icon(
            key: const Key('start-game-button'),
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: colors.accentPrimary,
              foregroundColor: const Color(0xFFF5F7FF),
              minimumSize: const Size.fromHeight(58),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            label: const Text('Start game'),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            key: const Key('open-settings-button'),
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.routeName),
            style: TextButton.styleFrom(
              foregroundColor: colors.textMuted,
              minimumSize: const Size.fromHeight(48),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}

class _ChessIcon extends StatelessWidget {
  const _ChessIcon();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [colors.chessIconGradientStart, colors.chessIconGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colors.chessIconBorder, width: 1),
      ),
      child: Center(
        child: Text(
          '\u265A',
          style: TextStyle(fontSize: 36, height: 1, color: colors.textHeading),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
