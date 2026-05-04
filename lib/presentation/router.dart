import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'game_screen.dart';
import 'game_win_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'start_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: '/game/win',
        builder: (context, state) => const GameWinScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/history',
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
