import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart' as dc;
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';

import '../../domain/models/move_option.dart';
import '../../domain/models/promotion_choice.dart';
import '../../domain/models/square_position.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({
    super.key,
    required this.fen,
    required this.boardSize,
    required this.pieceAssets,
    required this.validMovesByOrigin,
    required this.onMove,
    required this.isInteractive,
    required this.isCheck,
    this.lastMove,
  });

  final String fen;
  final double boardSize;
  final PieceAssets pieceAssets;
  final Map<SquarePosition, List<MoveOption>> validMovesByOrigin;
  final ValueChanged<MoveOption> onMove;
  final bool isInteractive;
  final bool isCheck;
  final MoveOption? lastMove;

  @override
  Widget build(BuildContext context) {
    return Chessboard(
      key: const Key('chessground-board'),
      size: boardSize,
      orientation: dc.Side.white,
      fen: fen,
      lastMove: _normalMoveFrom(lastMove),
      settings: ChessboardSettings(
        colorScheme: ChessboardColorScheme(
          lightSquare: Color(0xFFF3F4FB),
          darkSquare: Color(0xFF9198B5),
          background: SolidColorChessboardBackground(
            lightSquare: Color(0xFFF3F4FB),
            darkSquare: Color(0xFF9198B5),
          ),
          whiteCoordBackground: SolidColorChessboardBackground(
            lightSquare: Color(0xFFF3F4FB),
            darkSquare: Color(0xFF9198B5),
            coordinates: true,
          ),
          blackCoordBackground: SolidColorChessboardBackground(
            lightSquare: Color(0xFFF3F4FB),
            darkSquare: Color(0xFF9198B5),
            coordinates: true,
            orientation: dc.Side.black,
          ),
          lastMove: HighlightDetails(solidColor: Color(0x8C6270FF)),
          selected: HighlightDetails(solidColor: Color(0xAA4B58FF)),
          validMoves: Color(0xCC4B58FF),
          validPremoves: Color(0x994B58FF),
        ),
        pieceAssets: pieceAssets,
        animationDuration: Duration(milliseconds: 180),
        dragTargetKind: DragTargetKind.circle,
        pieceShiftMethod: PieceShiftMethod.either,
        enableCoordinates: false,
        showValidMoves: true,
        showLastMove: true,
      ),
      game: GameData(
        playerSide: isInteractive ? PlayerSide.white : PlayerSide.none,
        sideToMove: isInteractive ? dc.Side.white : dc.Side.black,
        validMoves: _toValidMoves(validMovesByOrigin),
        promotionMove: null,
        isCheck: isCheck,
        onMove: (move, {bool? viaDragAndDrop}) {
          if (move case dc.NormalMove(
            :final from,
            :final to,
            :final promotion,
          )) {
            onMove(
              MoveOption(
                from: SquarePosition.fromAlgebraic(from.name),
                to: SquarePosition.fromAlgebraic(to.name),
                isPromotion: promotion != null,
                promotion: _promotionChoiceFromRole(promotion),
              ),
            );
          }
        },
        onPromotionSelection: (_) {},
      ),
    );
  }

  dc.NormalMove? _normalMoveFrom(MoveOption? move) {
    if (move == null) {
      return null;
    }

    return dc.NormalMove(
      from: dc.Square.fromName(move.from.algebraic),
      to: dc.Square.fromName(move.to.algebraic),
      promotion: _roleFromPromotionChoice(move.promotion),
    );
  }

  ValidMoves _toValidMoves(Map<SquarePosition, List<MoveOption>> moves) {
    return IMap({
      for (final entry in moves.entries)
        dc.Square.fromName(entry.key.algebraic): ISet({
          for (final move in entry.value) dc.Square.fromName(move.to.algebraic),
        }),
    });
  }

  PromotionChoice? _promotionChoiceFromRole(dc.Role? role) {
    switch (role) {
      case dc.Role.queen:
        return PromotionChoice.queen;
      case dc.Role.rook:
        return PromotionChoice.rook;
      case dc.Role.bishop:
        return PromotionChoice.bishop;
      case dc.Role.knight:
        return PromotionChoice.knight;
      case _:
        return null;
    }
  }

  dc.Role? _roleFromPromotionChoice(PromotionChoice? choice) {
    switch (choice) {
      case PromotionChoice.queen:
        return dc.Role.queen;
      case PromotionChoice.rook:
        return dc.Role.rook;
      case PromotionChoice.bishop:
        return dc.Role.bishop;
      case PromotionChoice.knight:
        return dc.Role.knight;
      case null:
        return null;
    }
  }
}
