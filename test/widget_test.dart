import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pocket_chess/app.dart';
import 'package:pocket_chess/application/app_settings_controller.dart';
import 'package:pocket_chess/application/game_history_repository.dart';
import 'package:pocket_chess/application/piece_theme_catalog.dart';
import 'package:pocket_chess/application/providers.dart';
import 'package:pocket_chess/domain/models/game_session.dart';
import 'package:pocket_chess/domain/models/piece_data.dart';
import 'package:pocket_chess/domain/models/piece_theme_option.dart';
import 'package:pocket_chess/domain/models/saved_game.dart';

class _MemoryGameHistoryRepository implements GameHistoryRepository {
  @override
  Future<void> appendMove({
    required String gameId,
    required RecordedMove move,
  }) async {}

  @override
  Future<SavedGameDetail> createGame({
    required GameSession session,
    required String initialFen,
    required DateTime startedAt,
  }) async {
    return SavedGameDetail(
      header: SavedGameHeader(
        id: 'game-1',
        startedAt: startedAt,
        completedAt: null,
        mode: session.mode,
        session: session,
        configSummary: session.summary,
        result: SavedGameResultKind.abandoned,
        winner: null,
        moveCount: 0,
      ),
      moves: const [],
      finalFen: initialFen,
    );
  }

  @override
  Future<void> finalizeGame({
    required String gameId,
    required SavedGameResultKind result,
    required DateTime completedAt,
    PieceSide? winner,
    String? finalFen,
  }) async {}

  @override
  Future<SavedGameDetail?> loadGame(String id) async => null;

  @override
  Future<List<SavedGameHeader>> loadHeaders() async => const [];

  @override
  Future<void> deleteGame(String gameId) async {}
}

void main() {
  Future<void> pumpUi(WidgetTester tester, [Duration? duration]) {
    return tester.pump(duration ?? const Duration(milliseconds: 700));
  }

  Future<void> tapAndPump(
    WidgetTester tester,
    Finder finder, {
    Duration duration = const Duration(seconds: 1),
  }) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(duration);
  }

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
          gameHistoryRepositoryProvider.overrideWithValue(
            _MemoryGameHistoryRepository(),
          ),
          availablePieceThemesProvider.overrideWith(
            (ref) async => availableThemes,
          ),
        ],
        child: const ChessApp(),
      ),
    );
    await pumpUi(tester, const Duration(milliseconds: 1200));
  }

  Future<void> startDefaultGame(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('start-game-button')));
    await tapAndPump(tester, find.byKey(const Key('start-game-button')));
    expect(find.text('New match'), findsOneWidget);
    await tapAndPump(tester, find.text('Start game'));
  }

  testWidgets('landing page opens the setup sheet before the game page', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await pumpChessApp(tester, preferences);

    expect(find.byKey(const Key('start-screen')), findsOneWidget);
    expect(find.byKey(const Key('start-game-button')), findsOneWidget);
    expect(find.text('Pocket\nChess'), findsOneWidget);

    await tapAndPump(tester, find.byKey(const Key('start-game-button')));

    expect(find.text('New match'), findsOneWidget);
    expect(find.text('Start game'), findsOneWidget);

    await tapAndPump(tester, find.text('Start game'));

    expect(find.byKey(const Key('chessground-board')), findsOneWidget);
    expect(find.byType(Chessboard), findsOneWidget);
  });

  testWidgets('settings screen opens from the landing page', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await pumpChessApp(tester, preferences);

    await tapAndPump(tester, find.byKey(const Key('open-settings-button')));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byKey(const Key('piece-theme-cburnett')), findsOneWidget);
    expect(find.byKey(const Key('piece-theme-maestro')), findsOneWidget);
  });

  testWidgets('history screen opens from the landing page', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await pumpChessApp(tester, preferences);

    await tapAndPump(tester, find.byKey(const Key('open-history-button')));

    expect(find.text('Game History'), findsOneWidget);
  });

  testWidgets('selecting a theme updates the board piece set', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await pumpChessApp(tester, preferences);

    await tapAndPump(tester, find.byKey(const Key('open-settings-button')));
    await tapAndPump(tester, find.byKey(const Key('piece-theme-maestro')));
    await tester.pageBack();
    await tester.pump();
    await pumpUi(tester);

    await startDefaultGame(tester);

    final board = tester.widget<Chessboard>(find.byType(Chessboard));
    expect(board.settings.pieceAssets, PieceSet.maestro.assets);
  });

  testWidgets('selected theme persists after rebuilding the app', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await pumpChessApp(tester, preferences);

    await tapAndPump(tester, find.byKey(const Key('open-settings-button')));
    await tapAndPump(tester, find.byKey(const Key('piece-theme-maestro')));

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpUi(tester);

    await pumpChessApp(tester, preferences);
    await tapAndPump(tester, find.byKey(const Key('open-settings-button')));

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

    await tapAndPump(tester, find.byKey(const Key('open-settings-button')));
    await tapAndPump(tester, find.byKey(const Key('piece-theme-maestro')));
    await tester.pageBack();
    await tester.pump();
    await pumpUi(tester);

    await startDefaultGame(tester);

    final boardFinder = find.byKey(const Key('chessground-board'));
    final boardRect = tester.getRect(boardFinder);
    await tester.tapAt(squareCenter(boardRect, 'e2'));
    await tester.pump();
    await tester.tapAt(squareCenter(boardRect, 'e4'));
    await pumpUi(tester, const Duration(seconds: 1));

    await tapAndPump(tester, find.text('Restart'));

    final board = tester.widget<Chessboard>(find.byType(Chessboard));
    expect(board.settings.pieceAssets, PieceSet.maestro.assets);
    expect(find.byKey(const Key('chessground-board')), findsOneWidget);
  });
}
