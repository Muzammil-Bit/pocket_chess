import 'stockfish_client_stub.dart'
    if (dart.library.io) 'stockfish_client_io.dart';
import 'stockfish_client_base.dart';

StockfishClient createStockfishClient() => createPlatformStockfishClient();
