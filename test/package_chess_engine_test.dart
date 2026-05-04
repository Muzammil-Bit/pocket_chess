import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_chess/models/promotion_choice.dart';
import 'package:pocket_chess/models/square_position.dart';
import 'package:pocket_chess/engine/package_chess_engine.dart';

void main() {
  final engine = PackageChessEngine();

  test('moving into check is blocked', () {
    const fen = '4k3/8/8/8/8/8/4r3/4K3 w - - 0 1';
    final moves = engine.legalMoves(
      fen,
      from: const SquarePosition(file: 4, rank: 7),
    );

    expect(moves.any((move) => move.to.algebraic == 'e2'), isTrue);
    expect(moves.any((move) => move.to.algebraic == 'd2'), isFalse);
  });

  test('castling appears only when legal', () {
    const fen = 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1';
    final moves = engine.legalMoves(
      fen,
      from: const SquarePosition(file: 4, rank: 7),
    );

    expect(moves.any((move) => move.isKingSideCastle), isTrue);
    expect(moves.any((move) => move.isQueenSideCastle), isTrue);
  });

  test('en passant exists only in valid positions', () {
    const fen = '4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1';
    final moves = engine.legalMoves(
      fen,
      from: const SquarePosition(file: 4, rank: 3),
    );

    expect(
      moves.any((move) => move.isEnPassant && move.to.algebraic == 'd6'),
      isTrue,
    );
  });

  test('promotion move can be applied', () {
    const fen = '4k3/P7/8/8/8/8/8/4K3 w - - 0 1';
    final move = engine
        .legalMoves(fen, from: const SquarePosition(file: 0, rank: 1))
        .firstWhere((candidate) => candidate.to.algebraic == 'a8');

    final result = engine.applyMove(
      fen,
      move,
      promotion: PromotionChoice.queen,
    );

    expect(result, isNotNull);
    expect(
      result!.snapshot.board.pieceAt(const SquarePosition(file: 0, rank: 0)),
      isNotNull,
    );
  });

  test('checkmate and stalemate are reported correctly', () {
    final mate = engine.snapshotFromFen('7k/6Q1/6K1/8/8/8/8/8 b - - 0 1');
    final stalemate = engine.snapshotFromFen('7k/5Q2/6K1/8/8/8/8/8 b - - 0 1');

    expect(mate.status.phase.name, 'checkmate');
    expect(stalemate.status.phase.name, 'stalemate');
  });
}
