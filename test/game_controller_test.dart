import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pocket_chess/settings/app_settings_controller.dart';
import 'package:pocket_chess/game/game_controller.dart';
import 'package:pocket_chess/game/game_history_repository.dart';
import 'package:pocket_chess/providers.dart';
import 'package:pocket_chess/models/ai_difficulty.dart';
import 'package:pocket_chess/models/game_mode.dart';
import 'package:pocket_chess/models/game_session.dart';
import 'package:pocket_chess/models/piece_data.dart';
import 'package:pocket_chess/models/saved_game.dart';
import 'package:pocket_chess/models/square_position.dart';
import 'package:pocket_chess/engine/package_chess_engine.dart';

class _MemoryGameHistoryRepository implements GameHistoryRepository {
  final Map<String, SavedGameDetail> _games = {};
  int _nextId = 0;

  @override
  Future<void> appendMove({
    required String gameId,
    required RecordedMove move,
  }) async {
    final game = _games[gameId];
    if (game == null) {
      return;
    }
    _games[gameId] = game.copyWith(
      moves: [...game.moves, move],
      finalFen: move.fenAfter,
      header: game.header.copyWith(moveCount: game.moves.length + 1),
    );
  }

  @override
  Future<SavedGameDetail> createGame({
    required GameSession session,
    required String initialFen,
    required DateTime startedAt,
  }) async {
    final id = 'game-${_nextId++}';
    final game = SavedGameDetail(
      header: SavedGameHeader(
        id: id,
        startedAt: startedAt,
        completedAt: null,
        mode: session.mode,
        session: session,
        configSummary: session.summary,
        result: SavedGameResultKind.abandoned,
        winner: null,
        moveCount: 0,
      ),
      moves: const [],
      finalFen: initialFen,
    );
    _games[id] = game;
    return game;
  }

  @override
  Future<void> finalizeGame({
    required String gameId,
    required SavedGameResultKind result,
    required DateTime completedAt,
    PieceSide? winner,
    String? finalFen,
  }) async {
    final game = _games[gameId];
    if (game == null) {
      return;
    }
    _games[gameId] = game.copyWith(
      finalFen: finalFen ?? game.finalFen,
      header: game.header.copyWith(
        completedAt: completedAt,
        result: result,
        winner: winner,
        clearWinner: winner == null,
        moveCount: game.moves.length,
      ),
    );
  }

  @override
  Future<SavedGameDetail?> loadGame(String id) async => _games[id];

  @override
  Future<List<SavedGameHeader>> loadHeaders() async {
    return _games.values.map((game) => game.header).toList(growable: false);
  }

  @override
  Future<void> deleteGame(String gameId) async {
    _games.remove(gameId);
  }
}

void main() {
  Future<ProviderContainer> createContainer() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    return ProviderContainer(
      overrides: [
        chessEngineProvider.overrideWithValue(PackageChessEngine()),
        sharedPreferencesProvider.overrideWithValue(preferences),
        gameHistoryRepositoryProvider.overrideWithValue(
          _MemoryGameHistoryRepository(),
        ),
      ],
    );
  }

  test('controller updates selection state correctly', () async {
    final container = await createContainer();
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);

    await controller.handleSquareTap(const SquarePosition(file: 4, rank: 6));
    final state = container.read(gameControllerProvider);

    expect(state.selectedSquare?.algebraic, 'e2');
    expect(state.legalMoves.isNotEmpty, isTrue);
  });

  test(
    'human vs ai session triggers ai and returns control to white',
    () async {
      final container = await createContainer();
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);

      await controller.startSession(
        const GameSession(
          mode: GameMode.humanVsAi,
          blackAi: GameAiConfig(
            engine: AiEngineKind.minimax,
            difficulty: AiDifficulty.easy,
          ),
          aiMoveDelay: Duration.zero,
        ),
      );
      await controller.handleSquareTap(const SquarePosition(file: 4, rank: 6));
      await controller.handleSquareTap(const SquarePosition(file: 4, rank: 4));

      final state = container.read(gameControllerProvider);

      expect(state.turn, PieceSide.white);
      expect(state.lastMove, isNotNull);
    },
  );

  test('local two-player mode skips ai and leaves turn on black', () async {
    final container = await createContainer();
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);

    await controller.startSession(
      const GameSession(mode: GameMode.localTwoPlayer),
    );
    await controller.handleSquareTap(const SquarePosition(file: 4, rank: 6));
    await controller.handleSquareTap(const SquarePosition(file: 4, rank: 4));

    final state = container.read(gameControllerProvider);

    expect(state.turn, PieceSide.black);
    expect(state.isAiThinking, isFalse);
  });
}
