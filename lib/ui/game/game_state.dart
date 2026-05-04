import '../../models/board_state.dart';
import '../../models/game_mode.dart';
import '../../models/game_status.dart';
import '../../models/game_session.dart';
import '../../models/move_option.dart';
import '../../models/piece_data.dart';
import '../../models/square_position.dart';

class GameState {
  const GameState({
    required this.fen,
    required this.board,
    required this.turn,
    required this.status,
    required this.session,
    this.legalMovesByOrigin = const {},
    this.selectedSquare,
    this.legalMoves = const [],
    this.whiteCaptured = const [],
    this.blackCaptured = const [],
    this.pendingPromotionMove,
    this.isAiThinking = false,
    this.lastMove,
    this.whiteTime,
    this.blackTime,
  });

  final String fen;
  final BoardState board;
  final PieceSide turn;
  final GameStatus status;
  final GameSession session;
  final Map<SquarePosition, List<MoveOption>> legalMovesByOrigin;
  final SquarePosition? selectedSquare;
  final List<MoveOption> legalMoves;
  final List<PieceData> whiteCaptured;
  final List<PieceData> blackCaptured;
  final MoveOption? pendingPromotionMove;
  final bool isAiThinking;
  final MoveOption? lastMove;
  final Duration? whiteTime;
  final Duration? blackTime;

  bool get isTimed => session.timeControl != null;

  Duration? timeFor(PieceSide side) =>
      side == PieceSide.white ? whiteTime : blackTime;

  GameState copyWith({
    String? fen,
    BoardState? board,
    PieceSide? turn,
    GameStatus? status,
    GameSession? session,
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
    Duration? whiteTime,
    Duration? blackTime,
  }) {
    return GameState(
      fen: fen ?? this.fen,
      board: board ?? this.board,
      turn: turn ?? this.turn,
      status: status ?? this.status,
      session: session ?? this.session,
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
      whiteTime: whiteTime ?? this.whiteTime,
      blackTime: blackTime ?? this.blackTime,
    );
  }

  GameMode get mode => session.mode;
}
