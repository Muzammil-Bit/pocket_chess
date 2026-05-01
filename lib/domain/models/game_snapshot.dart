import 'board_state.dart';
import 'game_status.dart';
import 'piece_data.dart';

class GameSnapshot {
  const GameSnapshot({
    required this.fen,
    required this.board,
    required this.turn,
    required this.status,
  });

  final String fen;
  final BoardState board;
  final PieceSide turn;
  final GameStatus status;
}
