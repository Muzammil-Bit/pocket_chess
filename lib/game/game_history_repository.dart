import '../models/game_session.dart';
import '../models/piece_data.dart';
import '../models/saved_game.dart';

abstract class GameHistoryRepository {
  Future<SavedGameDetail> createGame({
    required GameSession session,
    required String initialFen,
    required DateTime startedAt,
  });

  Future<void> appendMove({required String gameId, required RecordedMove move});

  Future<void> finalizeGame({
    required String gameId,
    required SavedGameResultKind result,
    required DateTime completedAt,
    PieceSide? winner,
    String? finalFen,
  });

  Future<List<SavedGameHeader>> loadHeaders();

  Future<SavedGameDetail?> loadGame(String id);

  Future<void> deleteGame(String gameId);
}
