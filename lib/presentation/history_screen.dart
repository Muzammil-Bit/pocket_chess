import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/app_settings_controller.dart';
import '../application/providers.dart';
import '../domain/models/move_option.dart';
import '../domain/models/piece_data.dart';
import '../domain/models/saved_game.dart';
import '../domain/models/square_position.dart';
import 'app_colors.dart';
import 'widgets/chess_board.dart';

const _defaultStartFen =
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(savedGameHeadersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Previous games')),
      body: gamesAsync.when(
        data: (games) {
          if (games.isEmpty) {
            return const Center(
              child: Text('No saved games yet. Start one to build your history.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: games.length,
            separatorBuilder: (_, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final game = games[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                title: Text(game.configSummary),
                subtitle: Text(
                  '${_formatDateTime(game.startedAt)}  •  ${_statusLabel(game)}  •  ${game.moveCount} moves',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => HistoryDetailScreen(gameId: game.id),
                    ),
                  );
                },
              );
            },
          );
        },
        error: (error, _) => Center(child: Text('Could not load history: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _statusLabel(SavedGameHeader game) {
    if (game.completedAt == null) {
      return 'In progress';
    }
    return game.result.label(game.winner);
  }
}

class HistoryDetailScreen extends ConsumerStatefulWidget {
  const HistoryDetailScreen({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
  int _positionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(savedGameDetailProvider(widget.gameId));
    final pieceTheme = ref.watch(selectedPieceThemeProvider);
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Game review')),
      body: detailAsync.when(
        data: (game) {
          if (game == null) {
            return const Center(child: Text('This saved game is no longer available.'));
          }

          final positions = [
            _defaultStartFen,
            ...game.moves.map((move) => move.fenAfter),
          ];
          final clampedIndex = _positionIndex.clamp(0, positions.length - 1);
          if (clampedIndex != _positionIndex) {
            _positionIndex = clampedIndex;
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final boardSize = (constraints.maxWidth - 32).clamp(240.0, 440.0);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    game.header.configSummary,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatDateTime(game.header.startedAt)}  •  ${game.header.completedAt == null ? 'In progress' : game.header.result.label(game.header.winner)}',
                    style: TextStyle(color: colors.textMuted),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: ChessBoard(
                      fen: positions[_positionIndex],
                      boardSize: boardSize,
                      pieceAssets: pieceTheme.boardAssets,
                      validMovesByOrigin: const {},
                      onMove: (_) {},
                      playerSide: PlayerSide.none,
                      sideToMove: _sideToMoveForFen(positions[_positionIndex]),
                      isCheck: false,
                      lightSquareColor: colors.boardLightSquare,
                      darkSquareColor: colors.boardDarkSquare,
                      lastMoveHighlight: colors.boardLastMoveHighlight,
                      selectedHighlight: colors.boardSelectedHighlight,
                      validMovesColor: colors.boardValidMoveDot,
                      lastMove: _positionIndex == 0
                          ? null
                          : _moveOptionFromRecorded(game.moves[_positionIndex - 1]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _positionIndex == 0
                            ? null
                            : () => setState(() => _positionIndex = 0),
                        child: const Text('Start'),
                      ),
                      TextButton(
                        onPressed: _positionIndex == 0
                            ? null
                            : () => setState(() => _positionIndex -= 1),
                        child: const Text('Previous'),
                      ),
                      const Spacer(),
                      Text('$_positionIndex/${game.moves.length}'),
                      const Spacer(),
                      TextButton(
                        onPressed: _positionIndex >= game.moves.length
                            ? null
                            : () => setState(() => _positionIndex += 1),
                        child: const Text('Next'),
                      ),
                      TextButton(
                        onPressed: _positionIndex >= game.moves.length
                            ? null
                            : () => setState(() => _positionIndex = game.moves.length),
                        child: const Text('End'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Theme.of(context).dividerColor, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'Moves',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final pair in _groupMoves(game.moves))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('${pair.$1}. ${pair.$2.san}'),
                      subtitle: pair.$3 == null ? null : Text(pair.$3!.san),
                      selected: _positionIndex == pair.$2.ply ||
                          _positionIndex == pair.$3?.ply,
                      onTap: () {
                        setState(() {
                          _positionIndex = pair.$2.ply;
                        });
                      },
                    ),
                ],
              );
            },
          );
        },
        error: (error, _) => Center(child: Text('Could not load game: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
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
    if (parts.length > 1 && parts[1] == 'b') {
      return PieceSide.black;
    }
    return PieceSide.white;
  }

  List<(int, RecordedMove, RecordedMove?)> _groupMoves(List<RecordedMove> moves) {
    final pairs = <(int, RecordedMove, RecordedMove?)>[];
    for (var index = 0; index < moves.length; index += 2) {
      final white = moves[index];
      final black = index + 1 < moves.length ? moves[index + 1] : null;
      pairs.add(((index ~/ 2) + 1, white, black));
    }
    return pairs;
  }
}

String _formatDateTime(DateTime value) {
  String pad(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${pad(value.month)}-${pad(value.day)} ${pad(value.hour)}:${pad(value.minute)}';
}
