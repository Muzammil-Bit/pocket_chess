import 'package:flutter/material.dart';

import '../../domain/models/board_state.dart';
import '../../domain/models/move_option.dart';
import '../../domain/models/piece_data.dart';
import '../../domain/models/piece_glyphs.dart';
import '../../domain/models/square_position.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({
    super.key,
    required this.board,
    required this.boardSize,
    required this.onSquareTap,
    this.selectedSquare,
    this.legalMoves = const [],
    this.lastMove,
  });

  final BoardState board;
  final double boardSize;
  final SquarePosition? selectedSquare;
  final List<MoveOption> legalMoves;
  final MoveOption? lastMove;
  final ValueChanged<SquarePosition> onSquareTap;

  @override
  Widget build(BuildContext context) {
    final squareSize = boardSize / 8;
    final rows = board.rows;
    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Column(
        children: [
          for (var rank = 0; rank < 8; rank++)
            Expanded(
              child: Row(
                children: [
                  for (var file = 0; file < 8; file++)
                    _BoardSquare(
                      square: SquarePosition(file: file, rank: rank),
                      squareSize: squareSize,
                      piece: rows[rank][file],
                      isLight: (file + rank).isEven,
                      isSelected:
                          selectedSquare ==
                          SquarePosition(file: file, rank: rank),
                      isLegalMove: legalMoves.any(
                        (move) =>
                            move.to == SquarePosition(file: file, rank: rank),
                      ),
                      isLastMoveSquare:
                          lastMove?.from ==
                              SquarePosition(file: file, rank: rank) ||
                          lastMove?.to ==
                              SquarePosition(file: file, rank: rank),
                      onTap: onSquareTap,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BoardSquare extends StatelessWidget {
  const _BoardSquare({
    required this.square,
    required this.squareSize,
    required this.piece,
    required this.isLight,
    required this.isSelected,
    required this.isLegalMove,
    required this.isLastMoveSquare,
    required this.onTap,
  });

  final SquarePosition square;
  final double squareSize;
  final PieceData? piece;
  final bool isLight;
  final bool isSelected;
  final bool isLegalMove;
  final bool isLastMoveSquare;
  final ValueChanged<SquarePosition> onTap;

  @override
  Widget build(BuildContext context) {
    final baseColor = isLight
        ? const Color(0xFFE8D8BE)
        : const Color(0xFF7B5B47);
    final overlayColor = isSelected
        ? const Color(0xFF3BA58A).withValues(alpha: 0.7)
        : isLastMoveSquare
        ? const Color(0xFFF3C969).withValues(alpha: 0.55)
        : Colors.transparent;

    return Expanded(
      child: GestureDetector(
        key: Key('square-${square.algebraic}'),
        onTap: () => onTap(square),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: baseColor,
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: overlayColor)),
              if (isLegalMove)
                Center(
                  child: Container(
                    width: piece == null
                        ? squareSize * 0.24
                        : squareSize * 0.86,
                    height: piece == null
                        ? squareSize * 0.24
                        : squareSize * 0.86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: piece == null
                          ? const Color(0xFF2A7B65).withValues(alpha: 0.8)
                          : Colors.transparent,
                      border: piece == null
                          ? null
                          : Border.all(
                              color: const Color(
                                0xFF2A7B65,
                              ).withValues(alpha: 0.8),
                              width: 4,
                            ),
                    ),
                  ),
                ),
              if (square.file == 0)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Text(
                    '${8 - square.rank}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isLight
                          ? const Color(0xFF7B5B47)
                          : const Color(0xFFE8D8BE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (square.rank == 7)
                Positioned(
                  right: 4,
                  bottom: 2,
                  child: Text(
                    String.fromCharCode(97 + square.file),
                    style: TextStyle(
                      fontSize: 11,
                      color: isLight
                          ? const Color(0xFF7B5B47)
                          : const Color(0xFFE8D8BE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (piece != null)
                Center(
                  child: Text(
                    piece!.glyph,
                    style: TextStyle(fontSize: squareSize * 0.68, height: 1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
