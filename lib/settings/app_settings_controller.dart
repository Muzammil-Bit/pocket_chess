import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/piece_theme_option.dart';
import 'piece_theme_catalog.dart';

const pieceThemePreferenceKey = 'piece_theme_id';
const themeModePreferenceKey = 'theme_mode';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden.');
});

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

final availablePieceThemesProvider = FutureProvider<List<PieceThemeOption>>((
  ref,
) async {
  return loadAvailablePieceThemes(rootBundle);
});

final selectedPieceThemeProvider = Provider<PieceThemeOption>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return pieceThemeFromId(settings.pieceThemeId);
});

ThemeMode _themeModeFromString(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

class AppSettingsController extends Notifier<AppSettings> {
  late final SharedPreferences _preferences;

  @override
  AppSettings build() {
    _preferences = ref.read(sharedPreferencesProvider);
    final savedThemeId =
        _preferences.getString(pieceThemePreferenceKey) ?? defaultPieceThemeId;
    final savedThemeMode = _themeModeFromString(
      _preferences.getString(themeModePreferenceKey),
    );

    return AppSettings(
      pieceThemeId: pieceThemeFromId(savedThemeId).id,
      themeMode: savedThemeMode,
    );
  }

  Future<void> setPieceTheme(String pieceThemeId) async {
    final nextTheme = pieceThemeFromId(pieceThemeId);
    state = state.copyWith(pieceThemeId: nextTheme.id);
    await _preferences.setString(pieceThemePreferenceKey, nextTheme.id);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _preferences.setString(
      themeModePreferenceKey,
      _themeModeToString(mode),
    );
  }
}
