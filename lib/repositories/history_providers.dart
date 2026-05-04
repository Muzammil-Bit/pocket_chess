import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_history_repository.dart';
import '../models/saved_game.dart';
import 'json_game_history_repository.dart';

final gameHistoryRepositoryProvider = Provider<GameHistoryRepository>((ref) {
  return JsonGameHistoryRepository();
});

final savedGameHeadersProvider = FutureProvider<List<SavedGameHeader>>((ref) {
  return ref.watch(gameHistoryRepositoryProvider).loadHeaders();
});

final savedGameDetailProvider = FutureProvider.family<SavedGameDetail?, String>((
  ref,
  id,
) {
  return ref.watch(gameHistoryRepositoryProvider).loadGame(id);
});
