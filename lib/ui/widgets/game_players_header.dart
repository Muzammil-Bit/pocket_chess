import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/game_mode.dart';
import '../../models/game_session.dart';
import '../../models/piece_data.dart';
import '../app_colors.dart';

/// Top row with White / timer / Black, matching labels to [GameSession] roles.
class GamePlayersHeader extends StatelessWidget {
  const GamePlayersHeader({
    super.key,
    required this.session,
    required this.activeSide,
  });

  final GameSession session;
  final PieceSide activeSide;

  static String participantLabel(GameSession session, PieceSide side) {
    if (session.mode == GameMode.localTwoPlayer) {
      return side == PieceSide.white ? 'White' : 'Black';
    }
    if (session.mode == GameMode.aiVsAi) {
      return side == PieceSide.white ? 'White AI' : 'Black AI';
    }
    if (session.isHumanControlled(side)) {
      return 'You';
    }
    return 'Computer';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GamePlayerAvatar(
            label: participantLabel(session, PieceSide.white),
            initials: _initialsFor(session, PieceSide.white),
            accent: const Color(0xFFD8E1FF),
            isActive: activeSide == PieceSide.white,
            alignment: CrossAxisAlignment.start,
          ),
        ),
        const SizedBox(width: 12),
        const GameTimerPlaceholder(time: '05:00'),
        const SizedBox(width: 12),
        Expanded(
          child: GamePlayerAvatar(
            label: participantLabel(session, PieceSide.black),
            initials: _initialsFor(session, PieceSide.black),
            accent: const Color(0xFFFFD7E1),
            isActive: activeSide == PieceSide.black,
            alignment: CrossAxisAlignment.end,
          ),
        ),
      ],
    );
  }

  static String _initialsFor(GameSession session, PieceSide side) {
    if (session.mode == GameMode.localTwoPlayer) {
      return side == PieceSide.white ? 'WH' : 'BK';
    }
    if (session.mode == GameMode.aiVsAi) {
      return 'AI';
    }
    if (session.isHumanControlled(side)) {
      return 'YU';
    }
    return 'AI';
  }
}

class GamePlayerAvatar extends StatelessWidget {
  const GamePlayerAvatar({
    super.key,
    required this.label,
    required this.initials,
    required this.accent,
    required this.isActive,
    required this.alignment,
  });

  final String label;
  final String initials;
  final Color accent;
  final bool isActive;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        SizedBox(
          width: 88,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isActive
                        ? [accent, accent.withValues(alpha: 0.85)]
                        : [
                            accent.withValues(alpha: 0.35),
                            accent.withValues(alpha: 0.2),
                          ],
                  ),
                  border: Border.all(
                    color: isActive ? accent : accent.withValues(alpha: 0.15),
                    width: isActive ? 2.0 : 1.0,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.45),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: accent.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: isActive
                        ? colors.avatarInitialsColor
                        : colors.avatarInitialsColor.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  child: Text(initials),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isActive ? colors.activeText : colors.inactiveText,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                child: Text(label, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: isActive ? 32 : 0,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isActive ? colors.activeIndicator : Colors.transparent,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: colors.activeIndicator.withValues(
                              alpha: 0.5,
                            ),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Placeholder clock ring (matches in-game shell).
class GameTimerPlaceholder extends StatelessWidget {
  const GameTimerPlaceholder({super.key, required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(
        painter: GameClockRingPainter(
          progress: 1.0,
          trackColor: colors.panelBorder.withValues(alpha: 0.2),
          fillColor: colors.activeIndicator,
          glowColor: colors.activeIndicator.withValues(alpha: 0.3),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              color: colors.textHeading,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class GameClockRingPainter extends CustomPainter {
  GameClockRingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.glowColor,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 4;
    const strokeWidth = 3.5;
    const startAngle = -math.pi / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;

      final glowPaint = Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        fillPaint,
      );
    }

    _drawTickMarks(canvas, center, radius, size);
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius, Size size) {
    final tickPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 12; i++) {
      final angle = (i * math.pi / 6) - (math.pi / 2);
      final isQuarter = i % 3 == 0;
      final innerRadius = radius - (isQuarter ? 6 : 4);
      final outerRadius = radius - 1;

      tickPaint.strokeWidth = isQuarter ? 1.5 : 0.8;

      final start = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );

      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GameClockRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor;
}
