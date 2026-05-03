import '../../domain/models/game_session.dart';
import '../ai_service.dart';

abstract class AiStrategy {
  const AiStrategy();

  Future<AiMove?> chooseMove({
    required String fen,
    required GameAiConfig config,
  });
}
