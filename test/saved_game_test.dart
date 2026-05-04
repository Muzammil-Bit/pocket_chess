import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_chess/models/ai_difficulty.dart';
import 'package:pocket_chess/models/game_mode.dart';
import 'package:pocket_chess/models/game_session.dart';
import 'package:pocket_chess/models/piece_data.dart';
import 'package:pocket_chess/models/saved_game.dart';

void main() {
  test('saved game detail round-trips through json', () {
    final detail = SavedGameDetail(
      header: SavedGameHeader(
        id: 'game-42',
        startedAt: DateTime.parse('2026-05-03T10:00:00Z'),
        completedAt: DateTime.parse('2026-05-03T10:12:00Z'),
        mode: GameMode.aiVsAi,
        session: const GameSession(
          mode: GameMode.aiVsAi,
          whiteAi: GameAiConfig(
            engine: AiEngineKind.minimax,
            difficulty: AiDifficulty.easy,
          ),
          blackAi: GameAiConfig(
            engine: AiEngineKind.stockfish,
            difficulty: AiDifficulty.hard,
          ),
        ),
        configSummary: 'Minimax Easy vs Stockfish Hard',
        result: SavedGameResultKind.checkmate,
        winner: PieceSide.black,
        moveCount: 2,
      ),
      moves: const [
        RecordedMove(
          ply: 1,
          side: PieceSide.white,
          san: 'e4',
          uci: 'e2e4',
          fenAfter: 'fen-1',
        ),
        RecordedMove(
          ply: 2,
          side: PieceSide.black,
          san: 'e5',
          uci: 'e7e5',
          fenAfter: 'fen-2',
        ),
      ],
      finalFen: 'fen-2',
    );

    final jsonMap = jsonDecode(jsonEncode(detail.toJson())) as Map<String, dynamic>;
    final decoded = SavedGameDetail.fromJson(jsonMap);

    expect(decoded.header.id, detail.header.id);
    expect(decoded.header.session.summary, detail.header.session.summary);
    expect(decoded.moves.length, 2);
    expect(decoded.moves.last.san, 'e5');
    expect(decoded.finalFen, 'fen-2');
  });
}
