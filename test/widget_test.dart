import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_chess/app.dart';

void main() {
  Offset squareCenter(Rect rect, String algebraic) {
    final file = algebraic.codeUnitAt(0) - 97;
    final rank = int.parse(algebraic[1]);
    final squareSize = rect.width / 8;
    return Offset(
      rect.left + (file + 0.5) * squareSize,
      rect.top + ((8 - rank) + 0.5) * squareSize,
    );
  }

  testWidgets('landing page opens the dedicated game page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ChessApp()));

    expect(find.byKey(const Key('start-screen')), findsOneWidget);
    expect(find.byKey(const Key('start-game-button')), findsOneWidget);
    expect(find.text('Pocket Chess'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('start-game-button')));
    await tester.tap(find.byKey(const Key('start-game-button')));
    await tester.pumpAndSettle();

    expect(find.text('Game Room'), findsOneWidget);
    expect(find.byKey(const Key('chessground-board')), findsOneWidget);
  });

  testWidgets(
    'board renders on the dedicated game page and selecting a piece keeps the game screen alive',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: ChessApp()));
      await tester.ensureVisible(find.byKey(const Key('start-game-button')));
      await tester.tap(find.byKey(const Key('start-game-button')));
      await tester.pumpAndSettle();

      final boardRect = tester.getRect(
        find.byKey(const Key('chessground-board')),
      );
      await tester.tapAt(squareCenter(boardRect, 'e2'));
      await tester.pump();

      expect(find.text('Game Room'), findsOneWidget);
      expect(find.byKey(const Key('turn-label')), findsOneWidget);
    },
  );

  testWidgets('reset restores the starting state', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChessApp()));
    await tester.ensureVisible(find.byKey(const Key('start-game-button')));
    await tester.tap(find.byKey(const Key('start-game-button')));
    await tester.pumpAndSettle();

    final boardFinder = find.byKey(const Key('chessground-board'));
    final boardRect = tester.getRect(boardFinder);
    await tester.tapAt(squareCenter(boardRect, 'e2'));
    await tester.pump();
    await tester.tapAt(squareCenter(boardRect, 'e4'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Restart'));
    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();

    expect(find.text('Your move'), findsOneWidget);
    expect(find.byKey(const Key('chessground-board')), findsOneWidget);
  });
}
