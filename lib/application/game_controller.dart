import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/engine/chess_engine.dart';
import '../domain/models/game_mode.dart';
import '../domain/models/game_snapshot.dart';
import '../domain/models/move_option.dart';
import '../domain/models/piece_data.dart';
import '../domain/models/promotion_choice.dart';
import '../domain/models/square_position.dart';
import '../infrastructure/engine/package_chess_engine.dart';
import 'ai_service.dart';
import 'game_state.dart';

final chessEngineProvider = Provider<ChessEngine>(
  (ref) => PackageChessEngine(),
);

class GameController extends Notifier<GameState> {
  late final ChessEngine _engine;

  @override
  GameState build() {
    _engine = ref.read(chessEngineProvider);
    final snapshot = _engine.newGame();
    return _stateFromSnapshot(snapshot);
  }

  Future<void> handleSquareTap(SquarePosition square) async {
    if (state.isAiThinking ||
        state.pendingPromotionMove != null ||
        state.status.isGameOver) {
      return;
    }

    final selectedSquare = state.selectedSquare;
    if (selectedSquare != null) {
      MoveOption? chosenMove;
      for (final move in state.legalMoves) {
        if (move.to == square) {
          chosenMove = move;
          break;
        }
      }
      if (chosenMove != null) {
        await _playMove(chosenMove);
        return;
      }
    }

    final piece = state.board.pieceAt(square);
    final isPlayersPiece =
        piece != null &&
        piece.side == PieceSide.white &&
        state.turn == PieceSide.white;
    if (!isPlayersPiece) {
      state = state.copyWith(clearSelectedSquare: true, legalMoves: const []);
      return;
    }

    state = state.copyWith(
      selectedSquare: square,
      legalMoves: _engine.legalMoves(state.fen, from: square),
    );
  }

  Future<void> handleMove(MoveOption move) async {
    if (state.isAiThinking ||
        state.pendingPromotionMove != null ||
        state.status.isGameOver ||
        state.turn != PieceSide.white) {
      return;
    }

    await _playMove(move);
  }

  Future<void> choosePromotion(PromotionChoice choice) async {
    final pendingMove = state.pendingPromotionMove;
    if (pendingMove == null) {
      return;
    }

    await _commitMove(pendingMove, promotion: choice);
  }

  void cancelPromotion() {
    state = state.copyWith(clearPendingPromotion: true);
  }

  void resetGame() {
    final snapshot = _engine.newGame();
    state = _stateFromSnapshot(snapshot);
  }

  Future<void> _commitMove(
    MoveOption move, {
    PromotionChoice? promotion,
  }) async {
    final result = _engine.applyMove(state.fen, move, promotion: promotion);
    if (result == null) {
      return;
    }

    final nextWhiteCaptured = List<PieceData>.from(state.whiteCaptured);
    final nextBlackCaptured = List<PieceData>.from(state.blackCaptured);
    final capturedPiece = result.capturedPiece;
    if (capturedPiece != null) {
      if (capturedPiece.side == PieceSide.white) {
        nextWhiteCaptured.add(capturedPiece);
      } else {
        nextBlackCaptured.add(capturedPiece);
      }
    }

    state = state.copyWith(
      fen: result.snapshot.fen,
      board: result.snapshot.board,
      turn: result.snapshot.turn,
      status: result.snapshot.status,
      legalMovesByOrigin: _groupLegalMoves(result.snapshot.fen),
      whiteCaptured: nextWhiteCaptured,
      blackCaptured: nextBlackCaptured,
      clearSelectedSquare: true,
      legalMoves: const [],
      clearPendingPromotion: true,
      lastMove: result.move,
    );

    await _maybeRunAiTurn();
  }

  Future<void> _maybeRunAiTurn() async {
    if (state.turn != PieceSide.black || state.status.isGameOver) {
      return;
    }

    state = state.copyWith(isAiThinking: true);
    final aiMove = await chooseAiMove(fen: state.fen);
    if (aiMove == null) {
      final refreshed = _engine.snapshotFromFen(state.fen);
      state = state.copyWith(isAiThinking: false, status: refreshed.status);
      return;
    }

    MoveOption? matchingMove;
    for (final move in _engine.legalMoves(state.fen)) {
      if (move.from.algebraic != aiMove.from ||
          move.to.algebraic != aiMove.to) {
        continue;
      }
      if (_promotionCode(move.promotion) != aiMove.promotion) {
        continue;
      }
      matchingMove = move;
      break;
    }

    if (matchingMove == null) {
      state = state.copyWith(isAiThinking: false);
      return;
    }

    final result = _engine.applyMove(
      state.fen,
      matchingMove,
      promotion: matchingMove.promotion,
    );
    if (result == null) {
      state = state.copyWith(isAiThinking: false);
      return;
    }

    final nextWhiteCaptured = List<PieceData>.from(state.whiteCaptured);
    final nextBlackCaptured = List<PieceData>.from(state.blackCaptured);
    final capturedPiece = result.capturedPiece;
    if (capturedPiece != null) {
      if (capturedPiece.side == PieceSide.white) {
        nextWhiteCaptured.add(capturedPiece);
      } else {
        nextBlackCaptured.add(capturedPiece);
      }
    }

    state = state.copyWith(
      fen: result.snapshot.fen,
      board: result.snapshot.board,
      turn: result.snapshot.turn,
      status: result.snapshot.status,
      legalMovesByOrigin: _groupLegalMoves(result.snapshot.fen),
      whiteCaptured: nextWhiteCaptured,
      blackCaptured: nextBlackCaptured,
      isAiThinking: false,
      lastMove: result.move,
    );
  }

  Future<void> _playMove(MoveOption move) async {
    if (move.isPromotion) {
      state = state.copyWith(pendingPromotionMove: move);
      return;
    }

    await _commitMove(move);
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

  GameState _stateFromSnapshot(GameSnapshot snapshot) {
    return GameState(
      fen: snapshot.fen,
      board: snapshot.board,
      turn: snapshot.turn,
      status: snapshot.status,
      mode: GameMode.humanVsAi,
      legalMovesByOrigin: _groupLegalMoves(snapshot.fen),
    );
  }

  Map<SquarePosition, List<MoveOption>> _groupLegalMoves(String fen) {
    final grouped = <SquarePosition, List<MoveOption>>{};

    for (final move in _engine.legalMoves(fen)) {
      grouped.putIfAbsent(move.from, () => <MoveOption>[]).add(move);
    }

    return {
      for (final entry in grouped.entries)
        entry.key: List<MoveOption>.unmodifiable(entry.value),
    };
  }
}
