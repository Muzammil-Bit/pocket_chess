import '../../models/game_session.dart';
import '../../models/piece_data.dart';
import '../../models/saved_game.dart';
import '../../repositories/game_history_repository.dart';

class GameRecorder {
  GameRecorder(this._repository);

  final GameHistoryRepository _repository;
  String? _activeGameId;
  bool _isFinalized = true;

  Future<void> startRecording({
    required GameSession session,
    required String initialFen,
  }) async {
    await abandonIfActive(finalFen: initialFen);

    final game = await _repository.createGame(
      session: session,
      initialFen: initialFen,
      startedAt: DateTime.now(),
    );
    _activeGameId = game.header.id;
    _isFinalized = false;
  }

  Future<void> onMoveApplied(RecordedMove move) async {
    final activeGameId = _activeGameId;
    if (activeGameId == null || _isFinalized) {
      return;
    }

    await _repository.appendMove(gameId: activeGameId, move: move);
  }

  Future<void> finalize({
    required SavedGameResultKind result,
    PieceSide? winner,
    String? finalFen,
  }) async {
    final activeGameId = _activeGameId;
    if (activeGameId == null || _isFinalized) {
      return;
    }

    _isFinalized = true;
    await _repository.finalizeGame(
      gameId: activeGameId,
      result: result,
      completedAt: DateTime.now(),
      winner: winner,
      finalFen: finalFen,
    );
  }

  Future<void> abandonIfActive({String? finalFen}) {
    return finalize(result: SavedGameResultKind.abandoned, finalFen: finalFen);
  }

  Future<void> discardActiveRecording() async {
    final activeGameId = _activeGameId;
    if (activeGameId == null || _isFinalized) {
      return;
    }

    _isFinalized = true;
    _activeGameId = null;
    await _repository.deleteGame(activeGameId);
  }
}
