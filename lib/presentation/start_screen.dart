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
            colors: [Color(0xFF090B18), Color(0xFF121735), Color(0xFF1B2350)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -40,
              right: -10,
              child: _GlowOrb(size: 240, color: Color(0x70505FFF)),
            ),
            const Positioned(
              bottom: 100,
              left: -30,
              child: _GlowOrb(size: 220, color: Color(0x403B4275)),
            ),
            const Positioned.fill(child: _BackdropPattern()),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
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
    return Container(
      key: const Key('start-screen'),
      padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF121733).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: const Color(0xFF2E3564)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66070A16),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A3060),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Solo match',
              style: TextStyle(
                color: Color(0xFFD8DEFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Pocket Chess',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color(0xFFF6F7FF),
              fontSize: 50,
              height: 0.96,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.8,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'A cleaner, calmer board with the same sharp gameplay underneath.',
            style: TextStyle(
              color: Color(0xFFAEB7E5),
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          const _PreviewCard(),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('start-game-button'),
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4D5BFF),
              foregroundColor: const Color(0xFFF5F7FF),
              minimumSize: const Size.fromHeight(60),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start game'),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1128),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF262E57)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _avatar(const Color(0xFFFFD7E1), 'AI'),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Challenge the board',
                  style: TextStyle(
                    color: Color(0xFFF4F6FF),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3060),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Level 2',
                  style: TextStyle(
                    color: Color(0xFFDCE1FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: 1.08,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF101735), Color(0xFF171E47)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 64,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                        ),
                    itemBuilder: (context, index) {
                      final rank = index ~/ 8;
                      final file = index % 8;
                      final isLight = (rank + file).isEven;
                      return Container(
                        decoration: BoxDecoration(
                          color: isLight
                              ? const Color(0xFFF3F4FB)
                              : const Color(0xFF8C91AE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(Color color, String text) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0F1430),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BackdropPattern extends StatelessWidget {
  const _BackdropPattern();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _BackdropPainter()));
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = -1; i < 5; i++) {
      final path = Path()
        ..moveTo(size.width * 0.18 * i, 0)
        ..quadraticBezierTo(
          size.width * (0.12 + 0.18 * i),
          size.height * 0.28,
          size.width * (0.08 + 0.18 * i),
          size.height * 0.58,
        )
        ..quadraticBezierTo(
          size.width * (0.02 + 0.18 * i),
          size.height * 0.82,
          size.width * (0.16 + 0.18 * i),
          size.height,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
