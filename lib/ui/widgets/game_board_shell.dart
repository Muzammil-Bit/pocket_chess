import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/piece_data.dart';
import '../../models/piece_theme_option.dart';
import '../app_colors.dart';
import 'themed_piece_icon.dart';

class ChessBoardCapturedStrip extends StatelessWidget {
  const ChessBoardCapturedStrip({
    super.key,
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

class ChessBoardFrame extends StatelessWidget {
  const ChessBoardFrame({
    super.key,
    required this.boardSize,
    required this.child,
  });

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
              child: ChessBoardAxisLabels(
                labels: _fileLabels,
                axis: Axis.horizontal,
              ),
            ),
            Positioned(
              left: boardInset + boardPadding,
              bottom: outerInset,
              right: boardInset + boardPadding,
              height: labelBand,
              child: ChessBoardAxisLabels(
                labels: _fileLabels,
                axis: Axis.horizontal,
              ),
            ),
            Positioned(
              left: outerInset,
              top: boardInset + boardPadding,
              bottom: boardInset + boardPadding,
              width: labelBand,
              child: ChessBoardAxisLabels(
                labels: _rankLabels,
                axis: Axis.vertical,
              ),
            ),
            Positioned(
              right: outerInset,
              top: boardInset + boardPadding,
              bottom: boardInset + boardPadding,
              width: labelBand,
              child: ChessBoardAxisLabels(
                labels: _rankLabels,
                axis: Axis.vertical,
              ),
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

class ChessBoardAxisLabels extends StatelessWidget {
  const ChessBoardAxisLabels({
    super.key,
    required this.labels,
    required this.axis,
  });

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

class ChessBoardStage extends StatelessWidget {
  const ChessBoardStage({
    super.key,
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
            Positioned.fill(
              child: IgnorePointer(
                child: _BoardStageGlow(colors: context.appColors),
              ),
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
  const _BoardStageGlow({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
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
