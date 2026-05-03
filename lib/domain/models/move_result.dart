import 'game_snapshot.dart';
import 'move_option.dart';
import 'piece_data.dart';

class MoveResult {
  const MoveResult({
    required this.snapshot,
    required this.move,
    required this.san,
    required this.uci,
    this.capturedPiece,
  });

  final GameSnapshot snapshot;
  final MoveOption move;
  final String san;
  final String uci;
  final PieceData? capturedPiece;
}
