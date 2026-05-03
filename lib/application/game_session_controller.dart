import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/game_session.dart';
import 'ai/stockfish_client.dart';
import 'app_settings_controller.dart';

const gameSessionPreferenceKey = 'last_game_session';

class GameSessionController extends Notifier<GameSession> {
  late final SharedPreferences _preferences;

  @override
  GameSession build() {
    _preferences = ref.read(sharedPreferencesProvider);
    final stockfishSupported = createStockfishClient().isSupported;
    final rawValue = _preferences.getString(gameSessionPreferenceKey);
    if (rawValue == null) {
      return GameSession.defaultSession().normalized(
        stockfishSupported: stockfishSupported,
      );
    }

    try {
      final decoded = jsonDecode(rawValue) as Map<String, dynamic>;
      return GameSession.fromJson(decoded).normalized(
        stockfishSupported: stockfishSupported,
      );
    } catch (_) {
      return GameSession.defaultSession().normalized(
        stockfishSupported: stockfishSupported,
      );
    }
  }

  Future<void> setSession(GameSession session) async {
    final normalized = session.normalized(
      stockfishSupported: createStockfishClient().isSupported,
    );
    state = normalized;
    await _preferences.setString(
      gameSessionPreferenceKey,
      jsonEncode(normalized.toJson()),
    );
  }
}
