import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_controller.dart';
import 'game_state.dart';

final gameControllerProvider = NotifierProvider<GameController, GameState>(
  GameController.new,
);
