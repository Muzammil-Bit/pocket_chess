import 'ai_difficulty.dart';
import 'game_mode.dart';
import 'piece_data.dart';
import 'time_control.dart';

enum AiEngineKind { minimax, stockfish }

extension AiEngineKindX on AiEngineKind {
  String get label {
    switch (this) {
      case AiEngineKind.minimax:
        return 'Minimax';
      case AiEngineKind.stockfish:
        return 'Stockfish';
    }
  }
}

class GameAiConfig {
  const GameAiConfig({
    required this.engine,
    required this.difficulty,
  });

  final AiEngineKind engine;
  final AiDifficulty difficulty;

  GameAiConfig copyWith({
    AiEngineKind? engine,
    AiDifficulty? difficulty,
  }) {
    return GameAiConfig(
      engine: engine ?? this.engine,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toJson() => {
    'engine': engine.name,
    'difficulty': difficulty.storageValue,
  };

  static GameAiConfig fromJson(Map<String, dynamic> json) {
    AiEngineKind engine = AiEngineKind.minimax;
    for (final item in AiEngineKind.values) {
      if (item.name == json['engine']) {
        engine = item;
        break;
      }
    }

    return GameAiConfig(
      engine: engine,
      difficulty: AiDifficultyX.fromStorage(json['difficulty'] as String?),
    );
  }

  String get summary => '${engine.label} ${difficulty.label}';
}

class GameSession {
  const GameSession({
    required this.mode,
    this.whiteAi,
    this.blackAi,
    this.aiMoveDelay = const Duration(milliseconds: 450),
    this.timeControl,
  });

  final GameMode mode;
  final GameAiConfig? whiteAi;
  final GameAiConfig? blackAi;
  final Duration aiMoveDelay;
  final TimeControl? timeControl;

  factory GameSession.defaultSession() {
    return const GameSession(
      mode: GameMode.humanVsAi,
      blackAi: GameAiConfig(
        engine: AiEngineKind.minimax,
        difficulty: AiDifficulty.medium,
      ),
    );
  }

  bool isAiControlled(PieceSide side) => aiFor(side) != null;

  bool isHumanControlled(PieceSide side) => !isAiControlled(side);

  GameAiConfig? aiFor(PieceSide side) {
    return switch (side) {
      PieceSide.white => whiteAi,
      PieceSide.black => blackAi,
    };
  }

  GameSession copyWith({
    GameMode? mode,
    GameAiConfig? whiteAi,
    bool clearWhiteAi = false,
    GameAiConfig? blackAi,
    bool clearBlackAi = false,
    Duration? aiMoveDelay,
    TimeControl? timeControl,
    bool clearTimeControl = false,
  }) {
    return GameSession(
      mode: mode ?? this.mode,
      whiteAi: clearWhiteAi ? null : whiteAi ?? this.whiteAi,
      blackAi: clearBlackAi ? null : blackAi ?? this.blackAi,
      aiMoveDelay: aiMoveDelay ?? this.aiMoveDelay,
      timeControl: clearTimeControl ? null : timeControl ?? this.timeControl,
    );
  }

  GameSession normalized({
    required bool stockfishSupported,
  }) {
    GameAiConfig? normalize(GameAiConfig? config) {
      if (config == null) {
        return null;
      }
      if (config.engine == AiEngineKind.stockfish && !stockfishSupported) {
        return config.copyWith(engine: AiEngineKind.minimax);
      }
      return config;
    }

    switch (mode) {
      case GameMode.humanVsAi:
        return GameSession(
          mode: mode,
          blackAi: normalize(blackAi) ??
              const GameAiConfig(
                engine: AiEngineKind.minimax,
                difficulty: AiDifficulty.medium,
              ),
          aiMoveDelay: aiMoveDelay,
          timeControl: timeControl,
        );
      case GameMode.localTwoPlayer:
        return GameSession(
          mode: mode,
          aiMoveDelay: aiMoveDelay,
          timeControl: timeControl,
        );
      case GameMode.aiVsAi:
        return GameSession(
          mode: mode,
          whiteAi: normalize(whiteAi) ??
              const GameAiConfig(
                engine: AiEngineKind.minimax,
                difficulty: AiDifficulty.medium,
              ),
          blackAi: normalize(blackAi) ??
              const GameAiConfig(
                engine: AiEngineKind.minimax,
                difficulty: AiDifficulty.medium,
              ),
          aiMoveDelay: aiMoveDelay,
          timeControl: timeControl,
        );
    }
  }

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'whiteAi': whiteAi?.toJson(),
    'blackAi': blackAi?.toJson(),
    'aiMoveDelayMs': aiMoveDelay.inMilliseconds,
    'timeControl': timeControl?.toJson(),
  };

  static GameSession fromJson(Map<String, dynamic> json) {
    GameMode mode = GameMode.humanVsAi;
    for (final item in GameMode.values) {
      if (item.name == json['mode']) {
        mode = item;
        break;
      }
    }

    return GameSession(
      mode: mode,
      whiteAi: json['whiteAi'] is Map<String, dynamic>
          ? GameAiConfig.fromJson(json['whiteAi'] as Map<String, dynamic>)
          : null,
      blackAi: json['blackAi'] is Map<String, dynamic>
          ? GameAiConfig.fromJson(json['blackAi'] as Map<String, dynamic>)
          : null,
      aiMoveDelay: Duration(
        milliseconds: (json['aiMoveDelayMs'] as int?) ?? 450,
      ),
      timeControl: json['timeControl'] is Map<String, dynamic>
          ? TimeControl.fromJson(json['timeControl'] as Map<String, dynamic>)
          : null,
    );
  }

  String get summary {
    switch (mode) {
      case GameMode.humanVsAi:
        return 'You vs ${blackAi?.summary ?? 'AI'}';
      case GameMode.localTwoPlayer:
        return 'Local two-player';
      case GameMode.aiVsAi:
        return '${whiteAi?.summary ?? 'AI'} vs ${blackAi?.summary ?? 'AI'}';
    }
  }
}
