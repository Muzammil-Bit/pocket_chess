import 'package:flutter/material.dart';

import 'presentation/game_screen.dart';
import 'presentation/start_screen.dart';

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0D1023);
    const panel = Color(0xFF171B35);
    const outline = Color(0xFF313767);
    const primary = Color(0xFF4B58FF);
    const text = Color(0xFFF5F7FF);
    const muted = Color(0xFFA8B0D8);

    final base = ThemeData.dark(useMaterial3: true);
    final theme = base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: Color(0xFF7A84FF),
        surface: panel,
        onPrimary: text,
        onSecondary: text,
        onSurface: text,
        error: Color(0xFFFF6D8A),
        onError: text,
      ),
      textTheme: base.textTheme
          .apply(bodyColor: text, displayColor: text)
          .copyWith(
            bodyMedium: base.textTheme.bodyMedium?.copyWith(
              color: muted,
              height: 1.45,
            ),
            titleLarge: base.textTheme.titleLarge?.copyWith(
              color: text,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: panel.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF151935),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      dividerColor: outline.withValues(alpha: 0.5),
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
