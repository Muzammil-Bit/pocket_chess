import 'game_snapshot.dart';
import 'move_option.dart';
import 'piece_data.dart';

class MoveResult {
  const MoveResult({
    required this.snapshot,
    required this.move,
    this.capturedPiece,
  });

  final GameSnapshot snapshot;
  final MoveOption move;
  final PieceData? capturedPiece;
}
