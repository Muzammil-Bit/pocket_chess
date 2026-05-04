import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../game/game_history_repository.dart';
import '../models/game_session.dart';
import '../models/piece_data.dart';
import '../models/saved_game.dart';

class JsonGameHistoryRepository implements GameHistoryRepository {
  JsonGameHistoryRepository({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  Future<void> _writeQueue = Future<void>.value();

  static const _maxGames = 100;

  @override
  Future<SavedGameDetail> createGame({
    required GameSession session,
    required String initialFen,
    required DateTime startedAt,
  }) async {
    final game = SavedGameDetail(
      header: SavedGameHeader(
        id: _uuid.v4(),
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

    await _updateGames((games) {
      return [game, ...games].take(_maxGames).toList(growable: false);
    });
    return game;
  }

  @override
  Future<void> appendMove({
    required String gameId,
    required RecordedMove move,
  }) {
    return _updateGames((games) {
      return [
        for (final game in games)
          if (game.header.id == gameId)
            game.copyWith(
              header: game.header.copyWith(moveCount: game.moves.length + 1),
              moves: [...game.moves, move],
              finalFen: move.fenAfter,
            )
          else
            game,
      ];
    });
  }

  @override
  Future<void> finalizeGame({
    required String gameId,
    required SavedGameResultKind result,
    required DateTime completedAt,
    PieceSide? winner,
    String? finalFen,
  }) {
    return _updateGames((games) {
      return [
        for (final game in games)
          if (game.header.id == gameId)
            game.copyWith(
              header: game.header.copyWith(
                completedAt: completedAt,
                result: result,
                winner: winner,
                clearWinner: winner == null,
                moveCount: game.moves.length,
              ),
              finalFen: finalFen ?? game.finalFen,
            )
          else
            game,
      ];
    });
  }

  @override
  Future<SavedGameDetail?> loadGame(String id) async {
    final games = await _readGames();
    for (final game in games) {
      if (game.header.id == id) {
        return game;
      }
    }
    return null;
  }

  @override
  Future<List<SavedGameHeader>> loadHeaders() async {
    final games = await _readGames();
    return games.map((game) => game.header).toList(growable: false);
  }

  @override
  Future<void> deleteGame(String gameId) {
    return _updateGames((games) {
      return games
          .where((game) => game.header.id != gameId)
          .toList(growable: false);
    });
  }

  Future<File> _historyFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/pocket_chess_history.json');
  }

  Future<List<SavedGameDetail>> _readGames() async {
    final file = await _historyFile();
    if (!await file.exists()) {
      return const [];
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(SavedGameDetail.fromJson)
        .toList(growable: false);
  }

  Future<void> _updateGames(
    List<SavedGameDetail> Function(List<SavedGameDetail> current) update,
  ) {
    _writeQueue = _writeQueue.then((_) async {
      final current = await _readGames();
      final next = update(current);
      final file = await _historyFile();
      await file.writeAsString(
        jsonEncode(next.map((game) => game.toJson()).toList(growable: false)),
      );
    });
    return _writeQueue;
  }
}
