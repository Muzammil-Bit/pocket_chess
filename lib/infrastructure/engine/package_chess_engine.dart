import 'package:chess/chess.dart' as chess;

import '../../domain/engine/chess_engine.dart';
import '../../domain/models/board_state.dart';
import '../../domain/models/game_snapshot.dart';
import '../../domain/models/game_status.dart';
import '../../domain/models/move_option.dart';
import '../../domain/models/move_result.dart';
import '../../domain/models/piece_data.dart';
import '../../domain/models/promotion_choice.dart';
import '../../domain/models/square_position.dart';

class PackageChessEngine implements ChessEngine {
  @override
  MoveResult? applyMove(
    String fen,
    MoveOption move, {
    PromotionChoice? promotion,
  }) {
    final game = chess.Chess.fromFEN(fen);
    final candidate = _findMatchingMove(game, move, promotion: promotion);
    if (candidate == null) {
      return null;
    }

    final applied = game.move({
      'from': candidate.fromAlgebraic,
      'to': candidate.toAlgebraic,
      if (candidate.promotion != null) 'promotion': candidate.promotion!.name,
    });
    if (!applied) {
      return null;
    }

    return MoveResult(
      snapshot: _snapshotFromGame(game),
      move: _moveOptionFromMove(candidate),
      capturedPiece: _capturedPiece(candidate),
    );
  }

  @override
  List<MoveOption> legalMoves(String fen, {SquarePosition? from}) {
    final game = chess.Chess.fromFEN(fen);
    final options = <String, dynamic>{'asObjects': true};
    if (from != null) {
      options['square'] = from.algebraic;
    }

    return _objectMoves(
      game,
      options,
    ).map(_moveOptionFromMove).toList(growable: false);
  }

  @override
  GameSnapshot newGame() => _snapshotFromGame(chess.Chess());

  @override
  GameSnapshot snapshotFromFen(String fen) {
    final game = chess.Chess.fromFEN(fen);
    return _snapshotFromGame(game);
  }

  chess.Move? _findMatchingMove(
    chess.Chess game,
    MoveOption move, {
    PromotionChoice? promotion,
  }) {
    for (final candidate in _objectMoves(game, const {'asObjects': true})) {
      if (candidate.fromAlgebraic != move.from.algebraic ||
          candidate.toAlgebraic != move.to.algebraic) {
        continue;
      }

      final promotionCode = candidate.promotion?.name;
      if (promotionCode == null) {
        if (promotion != null && move.isPromotion) {
          continue;
        }
        return candidate;
      }

      if (_promotionCode(promotion ?? move.promotion) == promotionCode) {
        return candidate;
      }
    }

    return null;
  }

  PieceData? _capturedPiece(chess.Move move) {
    final captured = move.captured;
    if (captured == null) {
      return null;
    }

    return PieceData(
      side: move.color == chess.Chess.WHITE ? PieceSide.black : PieceSide.white,
      kind: _pieceKind(captured),
    );
  }

  GamePhase _phaseFor(chess.Chess game) {
    if (game.in_checkmate) {
      return GamePhase.checkmate;
    }
    if (game.in_stalemate) {
      return GamePhase.stalemate;
    }
    if (game.in_draw ||
        game.insufficient_material ||
        game.in_threefold_repetition) {
      return GamePhase.draw;
    }
    return GamePhase.active;
  }

  PieceKind _pieceKind(dynamic type) {
    if (type == chess.Chess.KING) return PieceKind.king;
    if (type == chess.Chess.QUEEN) return PieceKind.queen;
    if (type == chess.Chess.ROOK) return PieceKind.rook;
    if (type == chess.Chess.BISHOP) return PieceKind.bishop;
    if (type == chess.Chess.KNIGHT) return PieceKind.knight;
    return PieceKind.pawn;
  }

  MoveOption _moveOptionFromMove(chess.Move move) {
    final flags = move.flags;
    return MoveOption(
      from: SquarePosition.fromAlgebraic(move.fromAlgebraic),
      to: SquarePosition.fromAlgebraic(move.toAlgebraic),
      isCapture:
          _hasFlag(flags, chess.Chess.BITS_CAPTURE) ||
          _hasFlag(flags, chess.Chess.BITS_EP_CAPTURE),
      isPromotion: _hasFlag(flags, chess.Chess.BITS_PROMOTION),
      isKingSideCastle: _hasFlag(flags, chess.Chess.BITS_KSIDE_CASTLE),
      isQueenSideCastle: _hasFlag(flags, chess.Chess.BITS_QSIDE_CASTLE),
      isEnPassant: _hasFlag(flags, chess.Chess.BITS_EP_CAPTURE),
      promotion: _promotionChoiceFromCode(move.promotion?.name),
    );
  }

  PromotionChoice? _promotionChoiceFromCode(String? code) {
    switch (code) {
      case 'q':
        return PromotionChoice.queen;
      case 'r':
        return PromotionChoice.rook;
      case 'b':
        return PromotionChoice.bishop;
      case 'n':
        return PromotionChoice.knight;
      default:
        return null;
    }
  }

  String? _promotionCode(PromotionChoice? promotion) {
    switch (promotion) {
      case PromotionChoice.queen:
        return 'q';
      case PromotionChoice.rook:
        return 'r';
      case PromotionChoice.bishop:
        return 'b';
      case PromotionChoice.knight:
        return 'n';
      case null:
        return null;
    }
  }

  bool _hasFlag(int flags, int target) => (flags & target) != 0;

  GameSnapshot _snapshotFromGame(chess.Chess game) {
    final rows = List.generate(8, (rank) {
      return List.generate(8, (file) {
        final square = SquarePosition(file: file, rank: rank).algebraic;
        final piece = game.get(square);
        if (piece == null) {
          return null;
        }

        return PieceData(
          side: piece.color == chess.Chess.WHITE
              ? PieceSide.white
              : PieceSide.black,
          kind: _pieceKind(piece.type),
        );
      }, growable: false);
    }, growable: false);

    return GameSnapshot(
      fen: game.fen,
      board: BoardState(rows),
      turn: game.turn == chess.Chess.WHITE ? PieceSide.white : PieceSide.black,
      status: GameStatus(
        phase: _phaseFor(game),
        inCheck: game.in_check,
        winner: game.in_checkmate
            ? (game.turn == chess.Chess.WHITE
                  ? PieceSide.black
                  : PieceSide.white)
            : null,
      ),
    );
  }

  List<chess.Move> _objectMoves(
    chess.Chess game, [
    Map<String, dynamic>? options,
  ]) {
    return game.moves(options).cast<chess.Move>().toList(growable: false);
  }
}
