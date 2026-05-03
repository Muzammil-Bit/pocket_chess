import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Decorative background layers used on play and victory screens (orbs +
/// faint field arcs).
class GameAmbientStack extends StatelessWidget {
  const GameAmbientStack({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -40,
          right: -10,
          child: GameAmbientGlowOrb(size: 240, color: colors.glowOrbPrimary),
        ),
        Positioned(
          bottom: 100,
          left: -30,
          child: GameAmbientGlowOrb(size: 220, color: colors.glowOrbSecondary),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _FieldArcPainter(colors)),
          ),
        ),
        child,
      ],
    );
  }
}

class GameAmbientGlowOrb extends StatelessWidget {
  const GameAmbientGlowOrb({
    super.key,
    required this.size,
    required this.color,
  });

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

class _FieldArcPainter extends CustomPainter {
  _FieldArcPainter(this.colors);

  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors.boardBackdropStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final rect = Rect.fromLTWH(
        size.width * (0.08 + i * 0.16),
        size.height * 0.12,
        size.width * 0.28,
        size.height * 0.76,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(120)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FieldArcPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
