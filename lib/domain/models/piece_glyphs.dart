import 'piece_data.dart';

extension PieceGlyphs on PieceData {
  String get glyph {
    return switch ((side, kind)) {
      (PieceSide.white, PieceKind.king) => '♔',
      (PieceSide.white, PieceKind.queen) => '♕',
      (PieceSide.white, PieceKind.rook) => '♖',
      (PieceSide.white, PieceKind.bishop) => '♗',
      (PieceSide.white, PieceKind.knight) => '♘',
      (PieceSide.white, PieceKind.pawn) => '♙',
      (PieceSide.black, PieceKind.king) => '♚',
      (PieceSide.black, PieceKind.queen) => '♛',
      (PieceSide.black, PieceKind.rook) => '♜',
      (PieceSide.black, PieceKind.bishop) => '♝',
      (PieceSide.black, PieceKind.knight) => '♞',
      (PieceSide.black, PieceKind.pawn) => '♟',
    };
  }
}
