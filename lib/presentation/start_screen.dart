import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import 'game_screen.dart';

class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F1E8), Color(0xFFE7DDCE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              left: -30,
              child: _GlowOrb(size: 240, color: Color(0x30FFFFFF)),
            ),
            const Positioned(
              bottom: -90,
              right: -20,
              child: _GlowOrb(size: 220, color: Color(0x3AD8C4A8)),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _LandingCopy(
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

class _LandingCopy extends StatelessWidget {
  const _LandingCopy({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('start-screen'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Pocket Chess',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF172321),
            fontSize: 52,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.8,
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          key: const Key('start-game-button'),
          onPressed: onStart,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1F302D),
            foregroundColor: const Color(0xFFF8F3EA),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start game'),
        ),
      ],
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
