import '../models/game_snapshot.dart';
import '../models/move_option.dart';
import '../models/move_result.dart';
import '../models/promotion_choice.dart';
import '../models/square_position.dart';

abstract class ChessEngine {
  GameSnapshot newGame();

  GameSnapshot snapshotFromFen(String fen);

  List<MoveOption> legalMoves(String fen, {SquarePosition? from});

  MoveResult? applyMove(
    String fen,
    MoveOption move, {
    PromotionChoice? promotion,
  });
}
