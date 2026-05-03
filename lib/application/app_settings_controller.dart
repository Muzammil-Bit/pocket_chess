import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/app_settings.dart';
import '../domain/models/piece_theme_option.dart';
import 'piece_theme_catalog.dart';

const pieceThemePreferenceKey = 'piece_theme_id';

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

class AppSettingsController extends Notifier<AppSettings> {
  late final SharedPreferences _preferences;

  @override
  AppSettings build() {
    _preferences = ref.read(sharedPreferencesProvider);
    final savedThemeId =
        _preferences.getString(pieceThemePreferenceKey) ?? defaultPieceThemeId;

    return AppSettings(pieceThemeId: pieceThemeFromId(savedThemeId).id);
  }

  Future<void> setPieceTheme(String pieceThemeId) async {
    final nextTheme = pieceThemeFromId(pieceThemeId);
    state = state.copyWith(pieceThemeId: nextTheme.id);
    await _preferences.setString(pieceThemePreferenceKey, nextTheme.id);
  }
}
