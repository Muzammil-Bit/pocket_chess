import 'piece_data.dart';

enum GamePhase { active, checkmate, stalemate, draw }

class GameStatus {
  const GameStatus({required this.phase, required this.inCheck, this.winner});

  final GamePhase phase;
  final bool inCheck;
  final PieceSide? winner;

  bool get isGameOver => phase != GamePhase.active;
}
