import 'dart:math' as math;

import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/app_settings_controller.dart';
import '../application/game_controller.dart';
import '../application/providers.dart';
import '../domain/models/game_mode.dart';
import '../domain/models/game_session.dart';
import '../domain/models/piece_data.dart';
import '../domain/models/piece_theme_option.dart';
import 'app_colors.dart';
import 'widgets/chess_board.dart';
import 'widgets/promotion_dialog.dart';
import 'widgets/themed_piece_icon.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  static const routeName = '/game';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    ref.listen(
      gameControllerProvider.select((value) => value.pendingPromotionMove),
      (previous, next) async {
        if (next == null || previous == next) {
          return;
        }

        final controller = ref.read(gameControllerProvider.notifier);
        final choice = await showPromotionDialog(context);
        if (!context.mounted) {
          return;
        }

        if (choice == null) {
          controller.cancelPromotion();
        } else {
          await controller.choosePromotion(choice);
        }
      },
    );

    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final pieceTheme = ref.watch(selectedPieceThemeProvider);

    return PopScope<void>(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          await controller.abandonGame();
        }
      },
      child: Scaffold(
        backgroundColor: colors.gradientColors.first,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.textHeading,
          elevation: 0,
          title: Text(
            'Pocket Chess',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.textHeading,
            ),
          ),
          centerTitle: true,
        ),
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
                top: -40,
                right: -10,
                child: _GlowOrb(size: 240, color: colors.glowOrbPrimary),
              ),
              Positioned(
                bottom: 100,
                left: -30,
                child: _GlowOrb(size: 220, color: colors.glowOrbSecondary),
              ),
              const Positioned.fill(child: _BoardBackdrop()),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const screenPadding = 6.0;
                    const boardFrameAllowance = 50.0;
                    final boardSize = math.min(
                      (constraints.maxWidth -
                              (screenPadding * 2) -
                              boardFrameAllowance)
                          .clamp(240.0, 520.0),
                      (constraints.maxHeight - 280 - boardFrameAllowance)
                          .clamp(240.0, 520.0),
                    );

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(screenPadding),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 620,
                            minHeight:
                                constraints.maxHeight - (screenPadding * 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 20),
                                  _PlayersRow(
                                    session: state.session,
                                    activeSide: state.turn,
                                  ),
                                  const SizedBox(height: 20),
                                  _BoardStage(
                                    boardSize: boardSize,
                                    topStrip: _PieceStrip(
                                      pieces: state.blackCaptured,
                                      alignment: Alignment.centerRight,
                                      theme: pieceTheme,
                                    ),
                                    board: _BoardFrame(
                                      boardSize: boardSize,
                                      child: ChessBoard(
                                        fen: state.fen,
                                        boardSize: boardSize,
                                        pieceAssets: pieceTheme.boardAssets,
                                        validMovesByOrigin:
                                            state.legalMovesByOrigin,
                                        playerSide: _playerSideFor(
                                          state.session,
                                          controller,
                                        ),
                                        sideToMove: state.turn,
                                        isCheck: state.status.inCheck,
                                        lastMove: state.lastMove,
                                        onMove: (move) =>
                                            controller.handleMove(move),
                                        lightSquareColor:
                                            colors.boardLightSquare,
                                        darkSquareColor:
                                            colors.boardDarkSquare,
                                        lastMoveHighlight:
                                            colors.boardLastMoveHighlight,
                                        selectedHighlight:
                                            colors.boardSelectedHighlight,
                                        validMovesColor:
                                            colors.boardValidMoveDot,
                                      ),
                                    ),
                                    bottomStrip: _PieceStrip(
                                      pieces: state.whiteCaptured,
                                      alignment: Alignment.centerRight,
                                      theme: pieceTheme,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _ActionRow(
                                onRestart: () => controller.resetGame(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PlayerSide _playerSideFor(
    GameSession session,
    GameController controller,
  ) {
    if (!controller.canHumanInteract()) {
      return PlayerSide.none;
    }
    if (session.mode == GameMode.localTwoPlayer) {
      return PlayerSide.both;
    }
    if (session.isHumanControlled(PieceSide.white)) {
      return PlayerSide.white;
    }
    if (session.isHumanControlled(PieceSide.black)) {
      return PlayerSide.black;
    }
    return PlayerSide.none;
  }
}

class _PlayersRow extends StatelessWidget {
  const _PlayersRow({
    required this.session,
    required this.activeSide,
  });

  final GameSession session;
  final PieceSide activeSide;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlayerAvatar(
            label: _labelFor(PieceSide.white),
            initials: _initialsFor(PieceSide.white),
            accent: const Color(0xFFD8E1FF),
            isActive: activeSide == PieceSide.white,
            alignment: CrossAxisAlignment.start,
          ),
        ),
        const SizedBox(width: 12),
        const _TimerPill(time: '05:00'),
        const SizedBox(width: 12),
        Expanded(
          child: _PlayerAvatar(
            label: _labelFor(PieceSide.black),
            initials: _initialsFor(PieceSide.black),
            accent: const Color(0xFFFFD7E1),
            isActive: activeSide == PieceSide.black,
            alignment: CrossAxisAlignment.end,
          ),
        ),
      ],
    );
  }

  String _labelFor(PieceSide side) {
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

  String _initialsFor(PieceSide side) {
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

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({
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

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(
        painter: _ClockRingPainter(
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

class _ClockRingPainter extends CustomPainter {
  _ClockRingPainter({
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
  bool shouldRepaint(covariant _ClockRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor;
}

class _PieceStrip extends StatelessWidget {
  const _PieceStrip({
    required this.pieces,
    required this.alignment,
    required this.theme,
  });

  final List<PieceData> pieces;
  final Alignment alignment;
  final PieceThemeOption theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Align(
        alignment: alignment,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final piece in pieces)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ThemedPieceIcon(piece: piece, theme: theme, size: 30),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardFrame extends StatelessWidget {
  const _BoardFrame({required this.boardSize, required this.child});

  static const _fileLabels = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
  static const _rankLabels = ['8', '7', '6', '5', '4', '3', '2', '1'];

  final double boardSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const outerInset = 3.0;
    const labelBand = 14.0;
    const boardPadding = 4.0;
    const boardInset = outerInset + labelBand;
    final outerSize =
        boardSize + (boardPadding * 2) + ((labelBand + outerInset) * 2);

    return Center(
      child: SizedBox(
        width: outerSize,
        height: outerSize,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      colors.boardFrameGradientStart,
                      colors.boardFrameGradientEnd,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: colors.boardFrameBorder,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.boardInnerGlow.withValues(alpha: 0.18),
                      blurRadius: 32,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: colors.cardShadow,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: boardInset + boardPadding,
              top: outerInset,
              right: boardInset + boardPadding,
              height: labelBand,
              child: _BoardAxisLabels(
                labels: _fileLabels,
                axis: Axis.horizontal,
              ),
            ),
            Positioned(
              left: boardInset + boardPadding,
              bottom: outerInset,
              right: boardInset + boardPadding,
              height: labelBand,
              child: _BoardAxisLabels(
                labels: _fileLabels,
                axis: Axis.horizontal,
              ),
            ),
            Positioned(
              left: outerInset,
              top: boardInset + boardPadding,
              bottom: boardInset + boardPadding,
              width: labelBand,
              child: _BoardAxisLabels(labels: _rankLabels, axis: Axis.vertical),
            ),
            Positioned(
              right: outerInset,
              top: boardInset + boardPadding,
              bottom: boardInset + boardPadding,
              width: labelBand,
              child: _BoardAxisLabels(labels: _rankLabels, axis: Axis.vertical),
            ),
            Positioned(
              left: boardInset,
              top: boardInset,
              child: Container(
                width: boardSize + (boardPadding * 2),
                height: boardSize + (boardPadding * 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: colors.boardInnerBg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: colors.boardInnerGlow.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(boardPadding),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: boardSize,
                      height: boardSize,
                      child: child,
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
}

class _BoardAxisLabels extends StatelessWidget {
  const _BoardAxisLabels({required this.labels, required this.axis});

  final List<String> labels;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textStyle = TextStyle(
      color: colors.axisLabelColor,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    );

    return Flex(
      direction: axis,
      children: [
        for (final label in labels)
          Expanded(
            child: Center(child: Text(label.toUpperCase(), style: textStyle)),
          ),
      ],
    );
  }
}

class _BoardStage extends StatelessWidget {
  const _BoardStage({
    required this.boardSize,
    required this.topStrip,
    required this.board,
    required this.bottomStrip,
  });

  final double boardSize;
  final Widget topStrip;
  final Widget board;
  final Widget bottomStrip;

  @override
  Widget build(BuildContext context) {
    final glowWidth = math.min(boardSize + 80, 600.0);

    return Center(
      child: SizedBox(
        width: glowWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(
              child: IgnorePointer(child: _BoardStageGlow()),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                topStrip,
                const SizedBox(height: 16),
                board,
                const SizedBox(height: 16),
                bottomStrip,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardStageGlow extends StatelessWidget {
  const _BoardStageGlow();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final glowColors = colors.boardGlowColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            glowColors.first.withValues(alpha: 0.25),
            glowColors[1].withValues(alpha: 0.12),
            glowColors[2].withValues(alpha: 0.04),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.6, 1.0],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: _ActionButton(label: 'Resign', icon: Icons.flag_outlined),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _ActionButton(label: 'Draw', icon: Icons.handshake_outlined),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Restart',
            icon: Icons.refresh_rounded,
            highlight: true,
            onPressed: onRestart,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.highlight = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = highlight ? colors.textHeading : colors.inactiveText;

    return FilledButton.tonalIcon(
      onPressed: onPressed ?? () {},
      style: FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: foreground,
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: const RoundedRectangleBorder(),
      ),
      icon: Icon(icon),
      label: Text(
        label,
        style: TextStyle(
          decoration: highlight
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationColor: foreground,
        ),
      ),
    );
  }
}

class _BoardBackdrop extends StatelessWidget {
  const _BoardBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _BoardBackdropPainter(context.appColors)),
    );
  }
}

class _BoardBackdropPainter extends CustomPainter {
  _BoardBackdropPainter(this.colors);

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
  bool shouldRepaint(covariant _BoardBackdropPainter oldDelegate) =>
      oldDelegate.colors != colors;
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
