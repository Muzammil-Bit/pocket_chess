import '../domain/models/board_state.dart';
import '../domain/models/game_mode.dart';
import '../domain/models/game_status.dart';
import '../domain/models/move_option.dart';
import '../domain/models/piece_data.dart';
import '../domain/models/square_position.dart';

class GameState {
  const GameState({
    required this.fen,
    required this.board,
    required this.turn,
    required this.status,
    required this.mode,
    this.legalMovesByOrigin = const {},
    this.selectedSquare,
    this.legalMoves = const [],
    this.whiteCaptured = const [],
    this.blackCaptured = const [],
    this.pendingPromotionMove,
    this.isAiThinking = false,
    this.lastMove,
  });

  final String fen;
  final BoardState board;
  final PieceSide turn;
  final GameStatus status;
  final GameMode mode;
  final Map<SquarePosition, List<MoveOption>> legalMovesByOrigin;
  final SquarePosition? selectedSquare;
  final List<MoveOption> legalMoves;
  final List<PieceData> whiteCaptured;
  final List<PieceData> blackCaptured;
  final MoveOption? pendingPromotionMove;
  final bool isAiThinking;
  final MoveOption? lastMove;

  GameState copyWith({
    String? fen,
    BoardState? board,
    PieceSide? turn,
    GameStatus? status,
    GameMode? mode,
    Map<SquarePosition, List<MoveOption>>? legalMovesByOrigin,
    SquarePosition? selectedSquare,
    bool clearSelectedSquare = false,
    List<MoveOption>? legalMoves,
    List<PieceData>? whiteCaptured,
    List<PieceData>? blackCaptured,
    MoveOption? pendingPromotionMove,
    bool clearPendingPromotion = false,
    bool? isAiThinking,
    MoveOption? lastMove,
    bool clearLastMove = false,
  }) {
    return GameState(
      fen: fen ?? this.fen,
      board: board ?? this.board,
      turn: turn ?? this.turn,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      legalMovesByOrigin: legalMovesByOrigin ?? this.legalMovesByOrigin,
      selectedSquare: clearSelectedSquare
          ? null
          : selectedSquare ?? this.selectedSquare,
      legalMoves: legalMoves ?? this.legalMoves,
      whiteCaptured: whiteCaptured ?? this.whiteCaptured,
      blackCaptured: blackCaptured ?? this.blackCaptured,
      pendingPromotionMove: clearPendingPromotion
          ? null
          : pendingPromotionMove ?? this.pendingPromotionMove,
      isAiThinking: isAiThinking ?? this.isAiThinking,
      lastMove: clearLastMove ? null : lastMove ?? this.lastMove,
    );
  }
}
