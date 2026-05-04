import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_session.dart';
import 'ai_strategy.dart';
import 'minimax_ai_strategy.dart';
import 'stockfish_ai_strategy.dart';
import 'stockfish_client.dart';

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
