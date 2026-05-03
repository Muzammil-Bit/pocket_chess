import '../../domain/models/ai_difficulty.dart';

abstract class StockfishClient {
  bool get isSupported;

  Future<String?> bestMove({
    required String fen,
    required AiDifficulty difficulty,
  });

  Future<void> dispose();
}
