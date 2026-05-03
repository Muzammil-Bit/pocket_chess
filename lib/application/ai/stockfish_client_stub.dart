import '../../domain/models/ai_difficulty.dart';
import 'stockfish_client_base.dart';

class UnsupportedStockfishClient implements StockfishClient {
  @override
  bool get isSupported => false;

  @override
  Future<String?> bestMove({
    required String fen,
    required AiDifficulty difficulty,
  }) async {
    return null;
  }

  @override
  Future<void> dispose() async {}
}

StockfishClient createPlatformStockfishClient() {
  return UnsupportedStockfishClient();
}
