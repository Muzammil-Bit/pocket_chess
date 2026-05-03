import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pocket_chess/app.dart';
import 'package:pocket_chess/application/app_settings_controller.dart';
import 'package:pocket_chess/application/piece_theme_catalog.dart';
import 'package:pocket_chess/domain/models/piece_theme_option.dart';

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

  final availableThemes = <PieceThemeOption>[
    pieceThemeFromId('cburnett'),
    pieceThemeFromId('maestro'),
  ];

  Future<void> pumpChessApp(
    WidgetTester tester,
    SharedPreferences preferences,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          availablePieceThemesProvider.overrideWith(
            (ref) async => availableThemes,
          ),
        ],
        child: const ChessApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('landing page opens the dedicated game page', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await pumpChessApp(tester, preferences);

    expect(find.byKey(const Key('start-screen')), findsOneWidget);
    expect(find.byKey(const Key('start-game-button')), findsOneWidget);
    expect(find.text('Pocket Chess'), findsWidgets);

    await tester.ensureVisible(find.byKey(const Key('start-game-button')));
    await tester.tap(find.byKey(const Key('start-game-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chessground-board')), findsOneWidget);
    expect(find.byType(Chessboard), findsOneWidget);
  });

  testWidgets('settings screen opens from the landing page', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await pumpChessApp(tester, preferences);

    await tester.tap(find.byKey(const Key('open-settings-button')));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byKey(const Key('piece-theme-cburnett')), findsOneWidget);
    expect(find.byKey(const Key('piece-theme-maestro')), findsOneWidget);
  });

  testWidgets('selecting a theme updates the board piece set', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await pumpChessApp(tester, preferences);

    await tester.tap(find.byKey(const Key('open-settings-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('piece-theme-maestro')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('start-game-button')));
    await tester.tap(find.byKey(const Key('start-game-button')));
    await tester.pumpAndSettle();

    final board = tester.widget<Chessboard>(find.byType(Chessboard));
    expect(board.settings.pieceAssets, PieceSet.maestro.assets);
  });

  testWidgets('selected theme persists after rebuilding the app', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await pumpChessApp(tester, preferences);

    await tester.tap(find.byKey(const Key('open-settings-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('piece-theme-maestro')));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await pumpChessApp(tester, preferences);
    await tester.tap(find.byKey(const Key('open-settings-button')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('piece-theme-maestro')),
        matching: find.byIcon(Icons.radio_button_checked_rounded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('reset restores the game without wiping the selected theme', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await pumpChessApp(tester, preferences);

    await tester.tap(find.byKey(const Key('open-settings-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('piece-theme-maestro')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

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

    final board = tester.widget<Chessboard>(find.byType(Chessboard));
    expect(board.settings.pieceAssets, PieceSet.maestro.assets);
    expect(find.byKey(const Key('chessground-board')), findsOneWidget);
  });
}
