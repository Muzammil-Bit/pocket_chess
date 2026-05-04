import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'game_screen.dart';
import 'game_win_screen.dart';
import 'history_screen.dart';
import 'routes.dart';
import 'settings_screen.dart';
import 'start_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: Routes.game,
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: Routes.gameWin,
        builder: (context, state) => const GameWinScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/history/:gameId',
        builder: (context, state) => HistoryDetailScreen(
          gameId: state.pathParameters['gameId']!,
        ),
      ),
    ],
  );
});
