import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import '../domain/models/piece_data.dart';
import '../domain/models/piece_glyphs.dart';
import 'widgets/chess_board.dart';
import 'widgets/promotion_dialog.dart';
import 'widgets/status_panel.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  static const routeName = '/game';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF4EFE7),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Game Room',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
        actions: [
          TextButton.icon(
            onPressed: controller.resetGame,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Restart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F4EA), Color(0xFFE7E1D6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wideLayout = constraints.maxWidth >= 940;
            final boardHasSideCaptures = constraints.maxWidth >= 760;
            final boardSize = wideLayout
                ? math.min(
                    (constraints.maxWidth - 320).clamp(320.0, 640.0),
                    (constraints.maxHeight - 120).clamp(320.0, 680.0),
                  )
                : math.min(
                    (constraints.maxWidth - 32).clamp(240.0, 520.0),
                    (constraints.maxHeight - 220).clamp(240.0, 420.0),
                  );

            final panel = StatusPanel(
              status: state.status,
              turn: state.turn,
              isAiThinking: state.isAiThinking,
            );

            final boardArea = _BoardWithCapturedPieces(
              boardSize: boardSize,
              sideCaptures: boardHasSideCaptures,
              blackCaptured: state.blackCaptured,
              whiteCaptured: state.whiteCaptured,
              board: ChessBoard(
                board: state.board,
                boardSize: boardSize,
                selectedSquare: state.selectedSquare,
                legalMoves: state.legalMoves,
                lastMove: state.lastMove,
                onSquareTap: (square) => controller.handleSquareTap(square),
              ),
            );

            final content = wideLayout
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: boardSize + 176,
                        child: Center(child: boardArea),
                      ),
                      const SizedBox(width: 32),
                      SizedBox(width: 220, child: panel),
                      const Spacer(),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: boardArea),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: math.min(320, constraints.maxWidth),
                        child: panel,
                      ),
                    ],
                  );

            return SafeArea(
              child: Padding(padding: const EdgeInsets.all(16), child: content),
            );
          },
        ),
      ),
    );
  }
}

class _BoardWithCapturedPieces extends StatelessWidget {
  const _BoardWithCapturedPieces({
    required this.boardSize,
    required this.sideCaptures,
    required this.blackCaptured,
    required this.whiteCaptured,
    required this.board,
  });

  final double boardSize;
  final bool sideCaptures;
  final List<PieceData> blackCaptured;
  final List<PieceData> whiteCaptured;
  final Widget board;

  @override
  Widget build(BuildContext context) {
    if (!sideCaptures) {
      return SizedBox(
        width: boardSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CapturedStrip(
              label: 'Black',
              pieces: blackCaptured,
              pieceFontSize: boardSize >= 360 ? 24 : 20,
            ),
            const SizedBox(height: 12),
            SizedBox(width: boardSize, height: boardSize, child: board),
            const SizedBox(height: 12),
            _CapturedStrip(
              label: 'White',
              pieces: whiteCaptured,
              pieceFontSize: boardSize >= 360 ? 24 : 20,
            ),
          ],
        ),
      );
    }

    final sideWidth = boardSize >= 420 ? 72.0 : 56.0;
    final gap = boardSize >= 420 ? 16.0 : 10.0;

    return SizedBox(
      width: boardSize + sideWidth * 2 + gap * 2,
      height: boardSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: sideWidth,
            height: boardSize,
            child: _CapturedColumn(
              label: 'Black',
              pieces: blackCaptured,
              pieceFontSize: boardSize >= 420 ? 28 : 24,
            ),
          ),
          SizedBox(width: gap),
          SizedBox(width: boardSize, height: boardSize, child: board),
          SizedBox(width: gap),
          SizedBox(
            width: sideWidth,
            height: boardSize,
            child: _CapturedColumn(
              label: 'White',
              pieces: whiteCaptured,
              pieceFontSize: boardSize >= 420 ? 28 : 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _CapturedStrip extends StatelessWidget {
  const _CapturedStrip({
    required this.label,
    required this.pieces,
    required this.pieceFontSize,
  });

  final String label;
  final List<PieceData> pieces;
  final double pieceFontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF6B6254),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final piece in pieces)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        piece.glyph,
                        style: TextStyle(fontSize: pieceFontSize, height: 1),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapturedColumn extends StatelessWidget {
  const _CapturedColumn({
    required this.label,
    required this.pieces,
    required this.pieceFontSize,
  });

  final String label;
  final List<PieceData> pieces;
  final double pieceFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF6B6254),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final piece in pieces)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      piece.glyph,
                      style: TextStyle(fontSize: pieceFontSize, height: 1),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
