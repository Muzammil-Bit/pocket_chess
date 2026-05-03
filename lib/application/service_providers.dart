import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/game_session.dart';
import '../domain/models/saved_game.dart';
import '../infrastructure/history/json_game_history_repository.dart';
import 'ai/ai_strategy.dart';
import 'ai/minimax_ai_strategy.dart';
import 'ai/stockfish_ai_strategy.dart';
import 'ai/stockfish_client.dart';
import 'game_history_repository.dart';
import 'game_session_controller.dart';

final stockfishSupportedProvider = Provider<bool>((ref) {
  final client = createStockfishClient();
  return client.isSupported;
});

final stockfishAiStrategyProvider = Provider<StockfishAiStrategy>((ref) {
  final strategy = StockfishAiStrategy(client: createStockfishClient());
  ref.onDispose(() {
    strategy.dispose();
  });
  return strategy;
});

final minimaxAiStrategyProvider = Provider<AiStrategy>((ref) {
  return const MinimaxAiStrategy();
});

class AiStrategyFactory {
  const AiStrategyFactory({
    required this.minimax,
    required this.stockfish,
  });

  final AiStrategy minimax;
  final StockfishAiStrategy stockfish;

  AiStrategy forConfig(GameAiConfig config) {
    switch (config.engine) {
      case AiEngineKind.minimax:
        return minimax;
      case AiEngineKind.stockfish:
        return stockfish;
    }
  }
}

final aiStrategyFactoryProvider = Provider<AiStrategyFactory>((ref) {
  return AiStrategyFactory(
    minimax: ref.watch(minimaxAiStrategyProvider),
    stockfish: ref.watch(stockfishAiStrategyProvider),
  );
});

final gameSessionProvider =
    NotifierProvider<GameSessionController, GameSession>(
      GameSessionController.new,
    );

final gameHistoryRepositoryProvider = Provider<GameHistoryRepository>((ref) {
  return JsonGameHistoryRepository();
});

final savedGameHeadersProvider = FutureProvider<List<SavedGameHeader>>((ref) {
  return ref.watch(gameHistoryRepositoryProvider).loadHeaders();
});

final savedGameDetailProvider = FutureProvider.family<SavedGameDetail?, String>((
  ref,
  id,
) {
  return ref.watch(gameHistoryRepositoryProvider).loadGame(id);
});
