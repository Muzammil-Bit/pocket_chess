import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_controller.dart';
import 'game_state.dart';
export 'service_providers.dart';

final gameControllerProvider = NotifierProvider<GameController, GameState>(
  GameController.new,
);
