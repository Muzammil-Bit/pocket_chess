import 'dart:math' as math;

import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/app_settings_controller.dart';
import '../application/game_controller.dart';
import '../application/providers.dart';
import '../domain/models/game_mode.dart';
import '../domain/models/game_session.dart';
import '../domain/models/game_status.dart';
import '../domain/models/piece_data.dart';
import 'app_colors.dart';
import 'game_win_screen.dart';
import 'widgets/chess_board.dart';
import 'widgets/game_ambient_stack.dart';
import 'widgets/game_board_shell.dart';
import 'widgets/game_players_header.dart';
import 'widgets/promotion_dialog.dart';

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

    ref.listen<GameStatus>(
      gameControllerProvider.select((value) => value.status),
      (previous, next) {
        if (next.phase != GamePhase.checkmate || next.winner == null) return;
        if (previous?.isGameOver ?? false) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          Navigator.of(context).pushNamed(GameWinScreen.routeName);
        });
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
          child: GameAmbientStack(
            child: SafeArea(
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
                                const SizedBox(height: 20),
                                GamePlayersHeader(
                                  session: state.session,
                                  activeSide: state.turn,
                                ),
                                const SizedBox(height: 20),
                                ChessBoardStage(
                                  boardSize: boardSize,
                                  topStrip: ChessBoardCapturedStrip(
                                    pieces: state.blackCaptured,
                                    alignment: Alignment.centerRight,
                                    theme: pieceTheme,
                                  ),
                                  board: ChessBoardFrame(
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
                                      lightSquareColor: colors.boardLightSquare,
                                      darkSquareColor: colors.boardDarkSquare,
                                      lastMoveHighlight:
                                          colors.boardLastMoveHighlight,
                                      selectedHighlight:
                                          colors.boardSelectedHighlight,
                                      validMovesColor: colors.boardValidMoveDot,
                                    ),
                                  ),
                                  bottomStrip: ChessBoardCapturedStrip(
                                    pieces: state.whiteCaptured,
                                    alignment: Alignment.centerRight,
                                    theme: pieceTheme,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _ActionRow(onRestart: () => controller.resetGame()),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  PlayerSide _playerSideFor(GameSession session, GameController controller) {
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
