import '../../domain/models/game_session.dart';
import '../ai_service.dart';
import 'ai_strategy.dart';
import 'minimax_ai_strategy.dart';
import 'stockfish_client_base.dart';

class StockfishAiStrategy extends AiStrategy {
  StockfishAiStrategy({
    required StockfishClient client,
    AiStrategy? fallback,
  }) : _client = client,
       _fallback = fallback ?? const MinimaxAiStrategy();

  final StockfishClient _client;
  final AiStrategy _fallback;

  bool get isSupported => _client.isSupported;

  @override
  Future<AiMove?> chooseMove({
    required String fen,
    required GameAiConfig config,
  }) async {
    final bestMove = await _client.bestMove(
      fen: fen,
      difficulty: config.difficulty,
    );
    if (bestMove == null || bestMove.length < 4) {
      return _fallback.chooseMove(fen: fen, config: config);
    }

    return AiMove(
      from: bestMove.substring(0, 2),
      to: bestMove.substring(2, 4),
      promotion: bestMove.length > 4 ? bestMove.substring(4, 5) : null,
    );
  }

  Future<void> dispose() => _client.dispose();
}
