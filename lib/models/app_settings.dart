import 'package:flutter/material.dart';

@immutable
class AppSettings {
  const AppSettings({required this.pieceThemeId, required this.themeMode});

  final String pieceThemeId;
  final ThemeMode themeMode;

  AppSettings copyWith({String? pieceThemeId, ThemeMode? themeMode}) {
    return AppSettings(
      pieceThemeId: pieceThemeId ?? this.pieceThemeId,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppSettings &&
            other.pieceThemeId == pieceThemeId &&
            other.themeMode == themeMode;
  }

  @override
  int get hashCode => Object.hash(pieceThemeId, themeMode);
}
