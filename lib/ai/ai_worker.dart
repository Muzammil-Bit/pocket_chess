import 'package:chess/chess.dart' as chess;

Map<String, String>? computeBestMove(Map<String, Object?> payload) {
  final fen = payload['fen']! as String;
  final depth = payload['depth']! as int;
  final game = chess.Chess.fromFEN(fen);
  final moves = _objectMoves(game);
  if (moves.isEmpty) {
    return null;
  }

  chess.Move? bestMove;
  var bestScore = double.negativeInfinity;

  for (final move in moves) {
    final next = game.copy();
    next.move(move);
    final score = _minimax(
      next,
      depth - 1,
      double.negativeInfinity,
      double.infinity,
    );
    if (score > bestScore) {
      bestScore = score;
      bestMove = move;
    }
  }

  if (bestMove == null) {
    return null;
  }

  return <String, String>{
    'from': bestMove.fromAlgebraic,
    'to': bestMove.toAlgebraic,
    if (bestMove.promotion != null) 'promotion': bestMove.promotion!.name,
  };
}

double _evaluate(chess.Chess game) {
  if (game.in_checkmate) {
    return game.turn == chess.Chess.WHITE ? 100000 : -100000;
  }

  if (game.in_stalemate ||
      game.in_draw ||
      game.insufficient_material ||
      game.in_threefold_repetition) {
    return 0;
  }

  var score = 0.0;
  for (var rank = 0; rank < 8; rank++) {
    for (var file = 0; file < 8; file++) {
      final square = '${String.fromCharCode(97 + file)}${8 - rank}';
      final piece = game.get(square);
      if (piece == null) {
        continue;
      }

      var value = 0;
      if (piece.type == chess.Chess.PAWN) value = 100;
      if (piece.type == chess.Chess.KNIGHT) value = 320;
      if (piece.type == chess.Chess.BISHOP) value = 330;
      if (piece.type == chess.Chess.ROOK) value = 500;
      if (piece.type == chess.Chess.QUEEN) value = 900;
      if (piece.type == chess.Chess.KING) value = 20000;

      score += piece.color == chess.Chess.BLACK ? value : -value;
    }
  }

  final mobility = _objectMoves(game).length * 0.1;
  return score + (game.turn == chess.Chess.BLACK ? mobility : -mobility);
}

double _minimax(chess.Chess game, int depth, double alpha, double beta) {
  if (depth <= 0 || game.game_over) {
    return _evaluate(game);
  }

  final moves = _objectMoves(game);
  final isBlackTurn = game.turn == chess.Chess.BLACK;

  if (isBlackTurn) {
    var best = double.negativeInfinity;
    for (final move in moves) {
      final next = game.copy();
      next.move(move);
      final score = _minimax(next, depth - 1, alpha, beta);
      if (score > best) {
        best = score;
      }
      if (score > alpha) {
        alpha = score;
      }
      if (beta <= alpha) {
        break;
      }
    }
    return best;
  }

  var best = double.infinity;
  for (final move in moves) {
    final next = game.copy();
    next.move(move);
    final score = _minimax(next, depth - 1, alpha, beta);
    if (score < best) {
      best = score;
    }
    if (score < beta) {
      beta = score;
    }
    if (beta <= alpha) {
      break;
    }
  }
  return best;
}

List<chess.Move> _objectMoves(chess.Chess game) {
  return game
      .moves(const {'asObjects': true})
      .cast<chess.Move>()
      .toList(growable: false);
}
