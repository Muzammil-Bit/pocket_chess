import 'game_mode.dart';
import 'game_session.dart';
import 'piece_data.dart';

enum SavedGameResultKind { checkmate, stalemate, draw, abandoned, timeout }

class RecordedMove {
  const RecordedMove({
    required this.ply,
    required this.side,
    required this.san,
    required this.uci,
    required this.fenAfter,
  });

  final int ply;
  final PieceSide side;
  final String san;
  final String uci;
  final String fenAfter;

  Map<String, dynamic> toJson() => {
    'ply': ply,
    'side': side.name,
    'san': san,
    'uci': uci,
    'fenAfter': fenAfter,
  };

  static RecordedMove fromJson(Map<String, dynamic> json) {
    return RecordedMove(
      ply: json['ply'] as int,
      side: (json['side'] as String?) == PieceSide.black.name
          ? PieceSide.black
          : PieceSide.white,
      san: json['san'] as String,
      uci: json['uci'] as String,
      fenAfter: json['fenAfter'] as String,
    );
  }
}

class SavedGameHeader {
  const SavedGameHeader({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.mode,
    required this.session,
    required this.configSummary,
    required this.result,
    required this.winner,
    required this.moveCount,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final GameMode mode;
  final GameSession session;
  final String configSummary;
  final SavedGameResultKind result;
  final PieceSide? winner;
  final int moveCount;

  SavedGameHeader copyWith({
    DateTime? completedAt,
    SavedGameResultKind? result,
    PieceSide? winner,
    bool clearWinner = false,
    int? moveCount,
  }) {
    return SavedGameHeader(
      id: id,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      mode: mode,
      session: session,
      configSummary: configSummary,
      result: result ?? this.result,
      winner: clearWinner ? null : winner ?? this.winner,
      moveCount: moveCount ?? this.moveCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'mode': mode.name,
    'session': session.toJson(),
    'configSummary': configSummary,
    'result': result.name,
    'winner': winner?.name,
    'moveCount': moveCount,
  };

  static SavedGameHeader fromJson(Map<String, dynamic> json) {
    GameMode mode = GameMode.humanVsAi;
    for (final item in GameMode.values) {
      if (item.name == json['mode']) {
        mode = item;
        break;
      }
    }

    SavedGameResultKind result = SavedGameResultKind.abandoned;
    for (final item in SavedGameResultKind.values) {
      if (item.name == json['result']) {
        result = item;
        break;
      }
    }

    return SavedGameHeader(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      mode: mode,
      session: GameSession.fromJson(json['session'] as Map<String, dynamic>),
      configSummary: json['configSummary'] as String,
      result: result,
      winner: switch (json['winner'] as String?) {
        'black' => PieceSide.black,
        'white' => PieceSide.white,
        _ => null,
      },
      moveCount: json['moveCount'] as int? ?? 0,
    );
  }
}

class SavedGameDetail {
  const SavedGameDetail({
    required this.header,
    required this.moves,
    this.finalFen,
  });

  final SavedGameHeader header;
  final List<RecordedMove> moves;
  final String? finalFen;

  SavedGameDetail copyWith({
    SavedGameHeader? header,
    List<RecordedMove>? moves,
    String? finalFen,
    bool clearFinalFen = false,
  }) {
    return SavedGameDetail(
      header: header ?? this.header,
      moves: moves ?? this.moves,
      finalFen: clearFinalFen ? null : finalFen ?? this.finalFen,
    );
  }

  Map<String, dynamic> toJson() => {
    'header': header.toJson(),
    'moves': moves.map((move) => move.toJson()).toList(growable: false),
    'finalFen': finalFen,
  };

  static SavedGameDetail fromJson(Map<String, dynamic> json) {
    return SavedGameDetail(
      header: SavedGameHeader.fromJson(json['header'] as Map<String, dynamic>),
      moves: (json['moves'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(RecordedMove.fromJson)
          .toList(growable: false),
      finalFen: json['finalFen'] as String?,
    );
  }
}

extension SavedGameResultKindX on SavedGameResultKind {
  String label(PieceSide? winner) {
    switch (this) {
      case SavedGameResultKind.checkmate:
        if (winner == PieceSide.white) {
          return 'White won by checkmate';
        }
        if (winner == PieceSide.black) {
          return 'Black won by checkmate';
        }
        return 'Checkmate';
      case SavedGameResultKind.stalemate:
        return 'Stalemate';
      case SavedGameResultKind.draw:
        return 'Draw';
      case SavedGameResultKind.abandoned:
        return 'Abandoned';
      case SavedGameResultKind.timeout:
        if (winner == PieceSide.white) {
          return 'White won on time';
        }
        if (winner == PieceSide.black) {
          return 'Black won on time';
        }
        return 'Timeout';
    }
  }
}
