import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/app_settings_controller.dart';
import 'presentation/app_colors.dart';
import 'presentation/router.dart';

class ChessApp extends ConsumerWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appSettingsProvider.select((s) => s.themeMode));
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Pocket Chess',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      routerConfig: router,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final appColors = isDark ? AppColors.dark : AppColors.light;

    const darkBackground = Color(0xFF0D1023);
    const darkPanel = Color(0xFF171B35);
    const darkOutline = Color(0xFF313767);
    const darkPrimary = Color(0xFF4B58FF);
    const darkText = Color(0xFFF5F7FF);
    const darkMuted = Color(0xFFA8B0D8);

    const lightBackground = Color(0xFFF2F4FB);
    const lightPanel = Color(0xFFFFFFFF);
    const lightOutline = Color(0xFFD0D5E8);
    const lightPrimary = Color(0xFF4B58FF);
    const lightText = Color(0xFF1A1D2E);
    const lightMuted = Color(0xFF6B7194);

    final background = isDark ? darkBackground : lightBackground;
    final panel = isDark ? darkPanel : lightPanel;
    final outline = isDark ? darkOutline : lightOutline;
    final text = isDark ? darkText : lightText;
    final muted = isDark ? darkMuted : lightMuted;

    final base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: darkPrimary,
              secondary: Color(0xFF7A84FF),
              surface: darkPanel,
              onPrimary: darkText,
              onSecondary: darkText,
              onSurface: darkText,
              error: Color(0xFFFF6D8A),
              onError: darkText,
            )
          : const ColorScheme.light(
              primary: lightPrimary,
              secondary: Color(0xFF7A84FF),
              surface: lightPanel,
              onPrimary: Color(0xFFFFFFFF),
              onSecondary: Color(0xFFFFFFFF),
              onSurface: lightText,
              error: Color(0xFFD32F2F),
              onError: Color(0xFFFFFFFF),
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
        backgroundColor: isDark
            ? const Color(0xFF151935)
            : const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      dividerColor: outline.withValues(alpha: 0.5),
      extensions: [appColors],
    );
  }
}
