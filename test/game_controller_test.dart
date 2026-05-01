import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_chess/application/game_controller.dart';
import 'package:pocket_chess/application/providers.dart';
import 'package:pocket_chess/domain/models/piece_data.dart';
import 'package:pocket_chess/domain/models/square_position.dart';
import 'package:pocket_chess/infrastructure/engine/package_chess_engine.dart';

void main() {
  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [chessEngineProvider.overrideWithValue(PackageChessEngine())],
    );
  }

  test('controller updates selection state correctly', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);

    await controller.handleSquareTap(const SquarePosition(file: 4, rank: 6));
    final state = container.read(gameControllerProvider);

    expect(state.selectedSquare?.algebraic, 'e2');
    expect(state.legalMoves.isNotEmpty, isTrue);
  });

  test(
    'ai turn triggers after a player move and returns control to white',
    () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);

      await controller.handleSquareTap(const SquarePosition(file: 4, rank: 6));
      await controller.handleSquareTap(const SquarePosition(file: 4, rank: 4));

      final state = container.read(gameControllerProvider);

      expect(state.turn, PieceSide.white);
      expect(state.lastMove, isNotNull);
    },
  );
}
