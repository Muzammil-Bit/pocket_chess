import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/chess_engine.dart';
import '../../models/game_mode.dart';
import '../../models/game_session.dart';
import '../../models/game_snapshot.dart';
import '../../models/game_status.dart';
import '../../models/move_option.dart';
import '../../models/move_result.dart';
import '../../models/piece_data.dart';
import '../../models/promotion_choice.dart';
import '../../models/saved_game.dart';
import '../../models/square_position.dart';
import '../../engine/package_chess_engine.dart';
import '../../ai/ai_move.dart';
import '../../ai/ai_providers.dart';
import '../../repositories/history_providers.dart';
import 'game_recorder.dart';
import 'game_session_controller.dart';
import 'game_state.dart';

final chessEngineProvider = Provider<ChessEngine>(
  (ref) => PackageChessEngine(),
);

final gameControllerProvider = NotifierProvider<GameController, GameState>(
  GameController.new,
);

class GameController extends Notifier<GameState> {
  late final ChessEngine _engine;
  late final AiStrategyFactory _aiStrategies;
  late final GameRecorder _recorder;
  int _sessionToken = 0;
  Timer? _clockTimer;

  @override
  GameState build() {
    _engine = ref.read(chessEngineProvider);
    _aiStrategies = ref.read(aiStrategyFactoryProvider);
    _recorder = GameRecorder(ref.read(gameHistoryRepositoryProvider));

    final session = ref.read(gameSessionProvider);
    final snapshot = _engine.newGame();
    return _stateFromSnapshot(snapshot, session: session);
  }

  Future<void> startSession(GameSession session) async {
    await ref.read(gameSessionProvider.notifier).setSession(session);
    await _beginNewGame(session);
  }

  Future<void> handleSquareTap(SquarePosition square) async {
    if (!_canAcceptInput()) {
      return;
    }

    final selectedSquare = state.selectedSquare;
    if (selectedSquare != null) {
      MoveOption? chosenMove;
      for (final move in state.legalMoves) {
        if (move.to == square) {
          chosenMove = move;
          break;
        }
      }
      if (chosenMove != null) {
        await _playMove(chosenMove);
        return;
      }
    }

    final piece = state.board.pieceAt(square);
    final isPlayersPiece =
        piece != null &&
        piece.side == state.turn &&
        state.session.isHumanControlled(piece.side);
    if (!isPlayersPiece) {
      state = state.copyWith(clearSelectedSquare: true, legalMoves: const []);
      return;
    }

    state = state.copyWith(
      selectedSquare: square,
      legalMoves: _engine.legalMoves(state.fen, from: square),
    );
  }

  Future<void> handleMove(MoveOption move) async {
    if (!_canAcceptInput()) {
      return;
    }

    await _playMove(move);
  }

  Future<void> choosePromotion(PromotionChoice choice) async {
    final pendingMove = state.pendingPromotionMove;
    if (pendingMove == null) {
      return;
    }

    await _commitMove(pendingMove, promotion: choice);
  }

  void cancelPromotion() {
    state = state.copyWith(clearPendingPromotion: true);
  }

  Future<void> resetGame() async {
    await _beginNewGame(state.session);
  }

  Future<void> abandonGame({bool saveToHistory = true}) async {
    _sessionToken++;
    _stopClock();
    state = state.copyWith(
      isAiThinking: false,
      clearPendingPromotion: true,
      clearSelectedSquare: true,
      legalMoves: const [],
    );
    final fen = state.fen;
    if (saveToHistory) {
      await _recorder.abandonIfActive(finalFen: fen);
    } else {
      await _recorder.discardActiveRecording();
    }
    _refreshHistory();
  }

  bool canHumanInteract() {
    return !state.status.isGameOver &&
        !state.isAiThinking &&
        state.pendingPromotionMove == null &&
        state.session.isHumanControlled(state.turn);
  }

  Future<void> _beginNewGame(GameSession session) async {
    _sessionToken++;
    _stopClock();
    final snapshot = _engine.newGame();
    state = _stateFromSnapshot(snapshot, session: session);
    await _recorder.startRecording(session: session, initialFen: snapshot.fen);
    _refreshHistory();
    if (state.isTimed) _startClock();
    final token = _sessionToken;
    if (session.mode == GameMode.aiVsAi) {
      Future<void>.microtask(() => _maybeRunAiTurns(expectedToken: token));
    } else {
      await _maybeRunAiTurns(expectedToken: token);
    }
  }

  bool _canAcceptInput() {
    return canHumanInteract();
  }

  Future<void> _commitMove(
    MoveOption move, {
    PromotionChoice? promotion,
  }) async {
    final movingSide = state.turn;
    final result = _engine.applyMove(state.fen, move, promotion: promotion);
    if (result == null) {
      return;
    }

    await _applyMoveResult(result, movingSide: movingSide);
  }

  Future<void> _applyMoveResult(
    MoveResult result, {
    required PieceSide movingSide,
    bool isAiMove = false,
  }) async {
    final nextWhiteCaptured = List<PieceData>.from(state.whiteCaptured);
    final nextBlackCaptured = List<PieceData>.from(state.blackCaptured);
    final capturedPiece = result.capturedPiece;
    if (capturedPiece != null) {
      if (capturedPiece.side == PieceSide.white) {
        nextWhiteCaptured.add(capturedPiece);
      } else {
        nextBlackCaptured.add(capturedPiece);
      }
    }

    state = state.copyWith(
      fen: result.snapshot.fen,
      board: result.snapshot.board,
      turn: result.snapshot.turn,
      status: result.snapshot.status,
      legalMovesByOrigin: _groupLegalMoves(result.snapshot.fen),
      whiteCaptured: nextWhiteCaptured,
      blackCaptured: nextBlackCaptured,
      clearSelectedSquare: true,
      legalMoves: const [],
      clearPendingPromotion: true,
      isAiThinking: false,
      lastMove: result.move,
    );

    if (state.isTimed) _addIncrement(movingSide);

    await _recorder.onMoveApplied(
      RecordedMove(
        ply: _plyCountFromFen(result.snapshot.fen),
        side: movingSide,
        san: result.san,
        uci: result.uci,
        fenAfter: result.snapshot.fen,
      ),
    );
    _refreshHistory();

    if (state.status.isGameOver) {
      _stopClock();
      await _finalizeGameFromStatus();
      return;
    }

    await _maybeRunAiTurns(expectedToken: _sessionToken);
  }

  Future<void> _finalizeGameFromStatus() async {
    final outcome = switch (state.status.phase) {
      GamePhase.checkmate => SavedGameResultKind.checkmate,
      GamePhase.stalemate => SavedGameResultKind.stalemate,
      GamePhase.draw => SavedGameResultKind.draw,
      GamePhase.timeout => SavedGameResultKind.timeout,
      GamePhase.active => SavedGameResultKind.abandoned,
    };
    await _recorder.finalize(
      result: outcome,
      winner: state.status.winner,
      finalFen: state.fen,
    );
    _refreshHistory();
  }

  Future<void> _maybeRunAiTurns({required int expectedToken}) async {
    while (expectedToken == _sessionToken &&
        !state.status.isGameOver &&
        state.session.isAiControlled(state.turn)) {
      final aiConfig = state.session.aiFor(state.turn);
      if (aiConfig == null) {
        return;
      }

      state = state.copyWith(
        isAiThinking: true,
        clearSelectedSquare: true,
        legalMoves: const [],
      );

      if (state.session.aiMoveDelay > Duration.zero) {
        await Future<void>.delayed(state.session.aiMoveDelay);
        if (expectedToken != _sessionToken) {
          return;
        }
      }

      final aiMove = await _aiStrategies
          .forConfig(aiConfig)
          .chooseMove(fen: state.fen, config: aiConfig);
      if (expectedToken != _sessionToken) {
        return;
      }

      if (aiMove == null) {
        final refreshed = _engine.snapshotFromFen(state.fen);
        state = state.copyWith(isAiThinking: false, status: refreshed.status);
        if (state.status.isGameOver) {
          await _finalizeGameFromStatus();
        }
        return;
      }

      final matchingMove = _matchingMoveFor(aiMove);
      if (matchingMove == null) {
        state = state.copyWith(isAiThinking: false);
        return;
      }

      final promotion = matchingMove.promotion ?? PromotionChoice.queen;
      final movingSide = state.turn;
      final result = _engine.applyMove(
        state.fen,
        matchingMove,
        promotion: matchingMove.isPromotion ? promotion : null,
      );
      if (result == null) {
        state = state.copyWith(isAiThinking: false);
        return;
      }

      await _applyMoveResult(result, movingSide: movingSide, isAiMove: true);
    }
  }

  MoveOption? _matchingMoveFor(AiMove aiMove) {
    for (final move in _engine.legalMoves(state.fen)) {
      if (move.from.algebraic != aiMove.from ||
          move.to.algebraic != aiMove.to) {
        continue;
      }
      if (_promotionCode(move.promotion) != aiMove.promotion &&
          !(aiMove.promotion == null &&
              move.isPromotion &&
              move.promotion == PromotionChoice.queen)) {
        continue;
      }
      return move;
    }
    return null;
  }

  Future<void> _playMove(MoveOption move) async {
    if (move.isPromotion) {
      state = state.copyWith(pendingPromotionMove: move);
      return;
    }

    await _commitMove(move);
  }

  int _plyCountFromFen(String fen) {
    final parts = fen.split(' ');
    if (parts.length < 6) {
      return 0;
    }

    final fullMove = int.tryParse(parts[5]) ?? 1;
    final sideToMove = parts[1];
    return sideToMove == 'w'
        ? ((fullMove - 1) * 2)
        : (((fullMove - 1) * 2) + 1);
  }

  String? _promotionCode(PromotionChoice? promotion) {
    switch (promotion) {
      case PromotionChoice.queen:
        return 'q';
      case PromotionChoice.rook:
        return 'r';
      case PromotionChoice.bishop:
        return 'b';
      case PromotionChoice.knight:
        return 'n';
      case null:
        return null;
    }
  }

  GameState _stateFromSnapshot(
    GameSnapshot snapshot, {
    required GameSession session,
  }) {
    final tc = session.timeControl;
    return GameState(
      fen: snapshot.fen,
      board: snapshot.board,
      turn: snapshot.turn,
      status: snapshot.status,
      session: session,
      legalMovesByOrigin: _groupLegalMoves(snapshot.fen),
      whiteTime: tc?.initialTime,
      blackTime: tc?.initialTime,
    );
  }

  void _startClock() {
    _stopClock();
    if (!state.isTimed || state.status.isGameOver) return;
    _clockTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _tickClock();
    });
  }

  void _stopClock() {
    _clockTimer?.cancel();
    _clockTimer = null;
  }

  void _tickClock() {
    if (state.status.isGameOver) {
      _stopClock();
      return;
    }

    const tick = Duration(milliseconds: 100);
    final isWhiteTurn = state.turn == PieceSide.white;
    final current = isWhiteTurn ? state.whiteTime! : state.blackTime!;
    final updated = current - tick;

    if (updated <= Duration.zero) {
      _stopClock();
      final loser = state.turn;
      final winner =
          loser == PieceSide.white ? PieceSide.black : PieceSide.white;
      state = state.copyWith(
        whiteTime: isWhiteTurn ? Duration.zero : state.whiteTime,
        blackTime: isWhiteTurn ? state.blackTime : Duration.zero,
        status: GameStatus(
          phase: GamePhase.timeout,
          inCheck: false,
          winner: winner,
        ),
      );
      _finalizeGameFromStatus();
      return;
    }

    state = state.copyWith(
      whiteTime: isWhiteTurn ? updated : state.whiteTime,
      blackTime: isWhiteTurn ? state.blackTime : updated,
    );
  }

  void _addIncrement(PieceSide side) {
    final tc = state.session.timeControl;
    if (tc == null || tc.increment <= Duration.zero) return;
    final current = state.timeFor(side)!;
    if (side == PieceSide.white) {
      state = state.copyWith(whiteTime: current + tc.increment);
    } else {
      state = state.copyWith(blackTime: current + tc.increment);
    }
  }

  Map<SquarePosition, List<MoveOption>> _groupLegalMoves(String fen) {
    final grouped = <SquarePosition, List<MoveOption>>{};

    for (final move in _engine.legalMoves(fen)) {
      grouped.putIfAbsent(move.from, () => <MoveOption>[]).add(move);
    }

    return {
      for (final entry in grouped.entries)
        entry.key: List<MoveOption>.unmodifiable(entry.value),
    };
  }

  void _refreshHistory() {
    ref.invalidate(savedGameHeadersProvider);
  }
}
