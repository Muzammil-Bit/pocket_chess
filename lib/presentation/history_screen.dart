import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/app_settings_controller.dart';
import '../application/providers.dart';
import '../domain/models/game_mode.dart';
import '../domain/models/move_option.dart';
import '../domain/models/piece_data.dart';
import '../domain/models/saved_game.dart';
import '../domain/models/square_position.dart';
import 'app_colors.dart';
import 'widgets/chess_board.dart';

const _defaultStartFen =
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

// ===========================================================================
// History list
// ===========================================================================

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final gamesAsync = ref.watch(savedGameHeadersProvider);

    return Scaffold(
      backgroundColor: colors.gradientColors.first,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textHeading,
        elevation: 0,
        title: Text(
          'Game History',
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
        child: gamesAsync.when(
          data: (games) {
            if (games.isEmpty) {
              return _EmptyState(colors: colors);
            }
            return _GamesList(games: games);
          },
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: colors.textMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load history',
                    style: TextStyle(color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          loading: () => Center(
            child: CircularProgressIndicator(color: colors.accentPrimary),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.panelBackground.withValues(alpha: 0.5),
                border: Border.all(
                  color: colors.panelBorder.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 36,
                color: colors.textMuted.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No games yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textHeading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a match to build your history.\nCompleted games will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamesList extends StatelessWidget {
  const _GamesList({required this.games});

  final List<SavedGameHeader> games;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 8,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _GameCard(game: games[index]),
        );
      },
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});

  final SavedGameHeader game;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final result = _ResultInfo.from(game);

    return GestureDetector(
      onTap: () {
        context.push('/history/${game.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.panelBackground.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.panelBorder.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            _ModeIcon(mode: game.mode, colors: colors),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.configSummary,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: colors.textHeading,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: colors.textMuted.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(game.startedAt),
                        style: TextStyle(color: colors.textMuted, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 14,
                        color: colors.textMuted.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${game.moveCount} moves',
                        style: TextStyle(color: colors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _ResultBadge(info: result, colors: colors),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textMuted.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeIcon extends StatelessWidget {
  const _ModeIcon({required this.mode, required this.colors});

  final GameMode mode;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (mode) {
      GameMode.humanVsAi => (Icons.smart_toy_outlined, 'AI'),
      GameMode.localTwoPlayer => (Icons.people_outline_rounded, '2P'),
      GameMode.aiVsAi => (Icons.memory_rounded, 'AA'),
    };

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: colors.accentPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.accentPrimary.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: colors.accentPrimary),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: colors.accentPrimary.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultInfo {
  const _ResultInfo({
    required this.label,
    required this.shortLabel,
    required this.color,
    required this.icon,
  });

  final String label;
  final String shortLabel;
  final Color color;
  final IconData icon;

  factory _ResultInfo.from(SavedGameHeader game) {
    if (game.completedAt == null) {
      return const _ResultInfo(
        label: 'In progress',
        shortLabel: 'Live',
        color: Color(0xFF64B5F6),
        icon: Icons.play_circle_outline_rounded,
      );
    }
    switch (game.result) {
      case SavedGameResultKind.checkmate:
        return _ResultInfo(
          label: game.result.label(game.winner),
          shortLabel: game.winner == PieceSide.white ? 'W' : 'B',
          color: const Color(0xFF66BB6A),
          icon: Icons.emoji_events_outlined,
        );
      case SavedGameResultKind.stalemate:
        return const _ResultInfo(
          label: 'Stalemate',
          shortLabel: '½',
          color: Color(0xFFFFB74D),
          icon: Icons.handshake_outlined,
        );
      case SavedGameResultKind.draw:
        return const _ResultInfo(
          label: 'Draw',
          shortLabel: '½',
          color: Color(0xFFFFB74D),
          icon: Icons.handshake_outlined,
        );
      case SavedGameResultKind.abandoned:
        return const _ResultInfo(
          label: 'Abandoned',
          shortLabel: '—',
          color: Color(0xFF9E9E9E),
          icon: Icons.cancel_outlined,
        );
    }
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.info, required this.colors});

  final _ResultInfo info;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: info.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 14, color: info.color),
          const SizedBox(width: 4),
          Text(
            info.shortLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: info.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// History detail / game review
// ===========================================================================

class HistoryDetailScreen extends ConsumerStatefulWidget {
  const HistoryDetailScreen({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<HistoryDetailScreen> createState() =>
      _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
  int _positionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(savedGameDetailProvider(widget.gameId));
    final pieceTheme = ref.watch(selectedPieceThemeProvider);
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.gradientColors.first,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textHeading,
        elevation: 0,
        title: Text(
          'Game Review',
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
        child: detailAsync.when(
          data: (game) {
            if (game == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: colors.textMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Game no longer available',
                      style: TextStyle(color: colors.textMuted),
                    ),
                  ],
                ),
              );
            }
            return _DetailBody(
              game: game,
              positionIndex: _positionIndex,
              onPositionChanged: (i) => setState(() => _positionIndex = i),
              pieceTheme: pieceTheme,
            );
          },
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: colors.textMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load game',
                    style: TextStyle(color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          loading: () => Center(
            child: CircularProgressIndicator(color: colors.accentPrimary),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.game,
    required this.positionIndex,
    required this.onPositionChanged,
    required this.pieceTheme,
  });

  final SavedGameDetail game;
  final int positionIndex;
  final ValueChanged<int> onPositionChanged;
  final dynamic pieceTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final positions = [_defaultStartFen, ...game.moves.map((m) => m.fenAfter)];
    final idx = positionIndex.clamp(0, positions.length - 1);
    final result = _ResultInfo.from(game.header);

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = (constraints.maxWidth - 40).clamp(240.0, 440.0);

        return ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 16,
            right: 16,
            bottom: 24,
          ),
          children: [
            _GameInfoHeader(game: game, result: result, colors: colors),
            const SizedBox(height: 20),
            Center(
              child: ChessBoard(
                fen: positions[idx],
                boardSize: boardSize,
                pieceAssets: pieceTheme.boardAssets,
                validMovesByOrigin: const {},
                onMove: (_) {},
                playerSide: PlayerSide.none,
                sideToMove: _sideToMoveForFen(positions[idx]),
                isCheck: false,
                lightSquareColor: colors.boardLightSquare,
                darkSquareColor: colors.boardDarkSquare,
                lastMoveHighlight: colors.boardLastMoveHighlight,
                selectedHighlight: colors.boardSelectedHighlight,
                validMovesColor: colors.boardValidMoveDot,
                lastMove: idx == 0
                    ? null
                    : _moveOptionFromRecorded(game.moves[idx - 1]),
              ),
            ),
            const SizedBox(height: 16),
            _MoveNavigator(
              current: idx,
              total: game.moves.length,
              onChanged: onPositionChanged,
            ),
            const SizedBox(height: 20),
            _MoveSheet(
              moves: game.moves,
              currentPly: idx,
              onTapPly: onPositionChanged,
            ),
          ],
        );
      },
    );
  }

  MoveOption _moveOptionFromRecorded(RecordedMove move) {
    return MoveOption(
      from: SquarePosition.fromAlgebraic(move.uci.substring(0, 2)),
      to: SquarePosition.fromAlgebraic(move.uci.substring(2, 4)),
    );
  }

  PieceSide _sideToMoveForFen(String fen) {
    final parts = fen.split(' ');
    if (parts.length > 1 && parts[1] == 'b') return PieceSide.black;
    return PieceSide.white;
  }
}

// ---------------------------------------------------------------------------
// Game info header card
// ---------------------------------------------------------------------------

class _GameInfoHeader extends StatelessWidget {
  const _GameInfoHeader({
    required this.game,
    required this.result,
    required this.colors,
  });

  final SavedGameDetail game;
  final _ResultInfo result;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.panelBackground.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.panelBorder.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  game.header.configSummary,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textHeading,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: result.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: result.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(result.icon, size: 14, color: result.color),
                    const SizedBox(width: 5),
                    Text(
                      result.shortLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: result.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.label,
            style: TextStyle(
              color: result.color.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: colors.textMuted.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(game.header.startedAt),
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.swap_horiz_rounded,
                size: 14,
                color: colors.textMuted.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 3),
              Text(
                '${game.header.moveCount} moves',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Move navigator
// ---------------------------------------------------------------------------

class _MoveNavigator extends StatelessWidget {
  const _MoveNavigator({
    required this.current,
    required this.total,
    required this.onChanged,
  });

  final int current;
  final int total;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: colors.panelBackground.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.panelBorder.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          _NavButton(
            icon: Icons.first_page_rounded,
            onPressed: current > 0 ? () => onChanged(0) : null,
          ),
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onPressed: current > 0 ? () => onChanged(current - 1) : null,
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.accentPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$current / $total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textHeading,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onPressed: current < total ? () => onChanged(current + 1) : null,
          ),
          _NavButton(
            icon: Icons.last_page_rounded,
            onPressed: current < total ? () => onChanged(total) : null,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Icon(
          icon,
          size: 24,
          color: enabled
              ? colors.textHeading
              : colors.textMuted.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Move sheet (grid of moves)
// ---------------------------------------------------------------------------

class _MoveSheet extends StatelessWidget {
  const _MoveSheet({
    required this.moves,
    required this.currentPly,
    required this.onTapPly,
  });

  final List<RecordedMove> moves;
  final int currentPly;
  final ValueChanged<int> onTapPly;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final pairs = _groupMoves(moves);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.panelBackground.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.panelBorder.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt_rounded,
                size: 18,
                color: colors.accentPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Moves',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: colors.textHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: colors.panelBorder.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    '#',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.textMuted.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'WHITE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.textMuted.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'BLACK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.textMuted.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          for (final (moveNum, white, black) in pairs)
            _MoveRow(
              moveNumber: moveNum,
              white: white,
              black: black,
              currentPly: currentPly,
              onTapPly: onTapPly,
            ),
        ],
      ),
    );
  }

  List<(int, RecordedMove, RecordedMove?)> _groupMoves(
    List<RecordedMove> moves,
  ) {
    final pairs = <(int, RecordedMove, RecordedMove?)>[];
    for (var i = 0; i < moves.length; i += 2) {
      final white = moves[i];
      final black = i + 1 < moves.length ? moves[i + 1] : null;
      pairs.add(((i ~/ 2) + 1, white, black));
    }
    return pairs;
  }
}

class _MoveRow extends StatelessWidget {
  const _MoveRow({
    required this.moveNumber,
    required this.white,
    required this.black,
    required this.currentPly,
    required this.onTapPly,
  });

  final int moveNumber;
  final RecordedMove white;
  final RecordedMove? black;
  final int currentPly;
  final ValueChanged<int> onTapPly;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isEven = moveNumber.isEven;

    return Container(
      decoration: BoxDecoration(
        color: isEven
            ? colors.panelBorder.withValues(alpha: 0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '$moveNumber.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textMuted.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: _MoveCell(
              san: white.san,
              isActive: currentPly == white.ply,
              onTap: () => onTapPly(white.ply),
            ),
          ),
          Expanded(
            child: black != null
                ? _MoveCell(
                    san: black!.san,
                    isActive: currentPly == black!.ply,
                    onTap: () => onTapPly(black!.ply),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _MoveCell extends StatelessWidget {
  const _MoveCell({
    required this.san,
    required this.isActive,
    required this.onTap,
  });

  final String san;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        decoration: BoxDecoration(
          color: isActive
              ? colors.accentPrimary.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isActive
              ? Border.all(color: colors.accentPrimary.withValues(alpha: 0.35))
              : null,
        ),
        child: Text(
          san,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? colors.accentPrimary : colors.textHeading,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Helpers
// ===========================================================================

String _formatDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}

String _formatDateTime(DateTime value) {
  String pad(int n) => n.toString().padLeft(2, '0');
  return '${_formatDate(value)} at ${pad(value.hour)}:${pad(value.minute)}';
}
