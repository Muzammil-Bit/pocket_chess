import '../models/ai_difficulty.dart';
import '../models/game_session.dart';
import 'ai_move.dart';
import 'ai_strategy.dart';

class MinimaxAiStrategy extends AiStrategy {
  const MinimaxAiStrategy();

  @override
  Future<AiMove?> chooseMove({
    required String fen,
    required GameAiConfig config,
  }) {
    return chooseAiMove(
      fen: fen,
      depth: config.difficulty.minimaxDepth,
    );
  }
}
