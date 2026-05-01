import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_chess/app.dart';

void main() {
  testWidgets('landing page opens the dedicated game page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ChessApp()));

    expect(find.byKey(const Key('start-screen')), findsOneWidget);
    expect(find.byKey(const Key('start-game-button')), findsOneWidget);
    expect(find.text('Pocket Chess'), findsOneWidget);

    await tester.tap(find.byKey(const Key('start-game-button')));
    await tester.pumpAndSettle();

    expect(find.text('Game Room'), findsOneWidget);
    expect(find.byKey(const Key('square-e2')), findsOneWidget);
  });

  testWidgets(
    'board renders on the dedicated game page and selecting a piece keeps the game screen alive',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: ChessApp()));
      await tester.tap(find.byKey(const Key('start-game-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('square-e2')));
      await tester.pump();

      expect(find.text('Game Room'), findsOneWidget);
      expect(find.byKey(const Key('turn-label')), findsOneWidget);
    },
  );

  testWidgets('reset restores the starting state', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChessApp()));
    await tester.tap(find.byKey(const Key('start-game-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('square-e2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('square-e4')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();

    expect(find.text('Turn: White'), findsOneWidget);
    expect(find.byKey(const Key('square-e2')), findsOneWidget);
  });
}
