import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/app_settings_controller.dart';
import '../application/providers.dart';
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

    return Scaffold(
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
                    (constraints.maxHeight - 280 - boardFrameAllowance).clamp(
                      240.0,
                      520.0,
                    ),
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
                                _PlayersRow(
                                  isWhiteTurn: state.turn == PieceSide.white,
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
                                      isInteractive:
                                          !state.isAiThinking &&
                                          state.pendingPromotionMove == null &&
                                          !state.status.isGameOver &&
                                          state.turn == PieceSide.white,
                                      isCheck: state.status.inCheck,
                                      lastMove: state.lastMove,
                                      onMove: (move) =>
                                          controller.handleMove(move),
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
                            _ActionRow(onRestart: controller.resetGame),
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
    );
  }
}

class _PlayersRow extends StatelessWidget {
  const _PlayersRow({required this.isWhiteTurn});

  final bool isWhiteTurn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlayerAvatar(
            label: 'You',
            initials: 'YU',
            accent: const Color(0xFFD8E1FF),
            isActive: isWhiteTurn,
            alignment: CrossAxisAlignment.start,
          ),
        ),
        const SizedBox(width: 12),
        const _TimerPill(time: '05:00'),
        const SizedBox(width: 12),
        Expanded(
          child: _PlayerAvatar(
            label: 'Computer',
            initials: 'AI',
            accent: const Color(0xFFFFD7E1),
            isActive: !isWhiteTurn,
            alignment: CrossAxisAlignment.end,
          ),
        ),
      ],
    );
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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [accent, accent.withValues(alpha: 0.82)],
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.38),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: colors.avatarInitialsColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? colors.activeText : colors.inactiveText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedOpacity(
                opacity: isActive ? 1 : 0.25,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  width: 56,
                  height: 2,
                  color: isActive
                      ? colors.activeIndicator
                      : colors.inactiveIndicator,
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

    return Column(
      children: [
        Text(
          time,
          style: TextStyle(
            color: colors.textHeading,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text('Timer', style: TextStyle(color: colors.textMuted, fontSize: 12)),
      ],
    );
  }
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
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      colors.boardFrameGradientStart,
                      colors.boardFrameGradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: colors.boardFrameBorder,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accentBorder.withValues(alpha: 0.16),
                      blurRadius: 30,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: colors.cardShadow,
                      blurRadius: 18,
                      offset: const Offset(0, 10),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: boardSize + (boardPadding * 2),
                  height: boardSize + (boardPadding * 2),
                  child: ColoredBox(
                    color: colors.boardInnerBg,
                    child: Padding(
                      padding: const EdgeInsets.all(boardPadding),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: boardSize,
                          height: boardSize,
                          child: child,
                        ),
                      ),
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
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
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
    final glowWidth = math.min(boardSize + 104, 620.0);

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

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.08,
          colors: colors.boardGlowColors,
          stops: const [0.0, 0.38, 0.72, 1.0],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.boardGlowColors.last,
              colors.boardGlowColors[1],
              colors.boardGlowColors.first,
              colors.boardGlowColors[1],
              colors.boardGlowColors.last,
            ],
            stops: const [0.0, 0.18, 0.5, 0.82, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
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
