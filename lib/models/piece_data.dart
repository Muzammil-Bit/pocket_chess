enum PieceSide { white, black }

enum PieceKind { king, queen, rook, bishop, knight, pawn }

class PieceData {
  const PieceData({required this.side, required this.kind});

  final PieceSide side;
  final PieceKind kind;

  @override
  bool operator ==(Object other) {
    return other is PieceData && other.side == side && other.kind == kind;
  }

  @override
  int get hashCode => Object.hash(side, kind);
}
