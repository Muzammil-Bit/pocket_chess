import 'package:chessground/chessground.dart';
import 'package:flutter/foundation.dart';

import 'piece_data.dart';
import 'promotion_choice.dart';

@immutable
class PieceThemeOption {
  const PieceThemeOption({
    required this.id,
    required this.label,
    required this.boardAssets,
  });

  final String id;
  final String label;
  final PieceAssets boardAssets;

  String assetPathForPiece(PieceData piece) {
    return 'assets/pieces/$id/${_assetCodeForPiece(piece)}.svg';
  }

  String assetPathForPromotion(PromotionChoice choice) {
    return assetPathForPiece(
      PieceData(side: PieceSide.white, kind: choice.pieceKind),
    );
  }

  static String _assetCodeForPiece(PieceData piece) {
    final sideCode = piece.side == PieceSide.white ? 'w' : 'b';
    final kindCode = switch (piece.kind) {
      PieceKind.king => 'k',
      PieceKind.queen => 'q',
      PieceKind.rook => 'r',
      PieceKind.bishop => 'b',
      PieceKind.knight => 'n',
      PieceKind.pawn => 'p',
    };
    return '$sideCode$kindCode';
  }
}

extension PromotionChoicePieceKind on PromotionChoice {
  PieceKind get pieceKind {
    return switch (this) {
      PromotionChoice.queen => PieceKind.queen,
      PromotionChoice.rook => PieceKind.rook,
      PromotionChoice.bishop => PieceKind.bishop,
      PromotionChoice.knight => PieceKind.knight,
    };
  }
}
