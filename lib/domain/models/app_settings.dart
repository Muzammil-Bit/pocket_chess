import 'package:flutter/foundation.dart';

@immutable
class AppSettings {
  const AppSettings({required this.pieceThemeId});

  final String pieceThemeId;

  AppSettings copyWith({String? pieceThemeId}) {
    return AppSettings(pieceThemeId: pieceThemeId ?? this.pieceThemeId);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppSettings && other.pieceThemeId == pieceThemeId;
  }

  @override
  int get hashCode => pieceThemeId.hashCode;
}
