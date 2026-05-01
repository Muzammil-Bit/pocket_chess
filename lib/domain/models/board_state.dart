import 'piece_data.dart';
import 'square_position.dart';

class BoardState {
  const BoardState(this._squares);

  final List<List<PieceData?>> _squares;

  PieceData? pieceAt(SquarePosition square) =>
      _squares[square.rank][square.file];

  List<List<PieceData?>> get rows => _squares
      .map((row) => List<PieceData?>.unmodifiable(row))
      .toList(growable: false);
}
