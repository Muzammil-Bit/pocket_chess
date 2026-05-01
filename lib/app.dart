import 'package:flutter/material.dart';

import 'presentation/game_screen.dart';
import 'presentation/start_screen.dart';

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF234E52),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF4EFE7),
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: const Color(0xFF1E2A2F),
        displayColor: const Color(0xFF1E2A2F),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );

    return MaterialApp(
      title: 'Pocket Chess',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const StartScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == GameScreen.routeName) {
          return MaterialPageRoute<void>(
            builder: (_) => const GameScreen(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
