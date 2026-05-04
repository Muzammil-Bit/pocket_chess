import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stockfish/stockfish.dart';

import '../models/ai_difficulty.dart';
import 'stockfish_client_base.dart';

class PlatformStockfishClient implements StockfishClient {
  PlatformStockfishClient();

  Stockfish? _engine;
  Future<Stockfish>? _startingEngine;
  StreamSubscription<String>? _stdoutSubscription;
  Future<String?> _requestChain = Future<String?>.value();
  Completer<String?>? _bestMoveCompleter;
  Completer<void>? _readyCompleter;

  @override
  bool get isSupported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<String?> bestMove({
    required String fen,
    required AiDifficulty difficulty,
  }) {
    _requestChain = _requestChain.then((_) {
      return _bestMoveInternal(fen: fen, difficulty: difficulty);
    });
    return _requestChain;
  }

  Future<String?> _bestMoveInternal({
    required String fen,
    required AiDifficulty difficulty,
  }) async {
    if (!isSupported) {
      return null;
    }

    final engine = await _ensureReady();
    await _sendAndWaitReady(engine, 'ucinewgame');
    engine.stdin =
        'setoption name Skill Level value ${difficulty.stockfishSkillLevel}';
    await _sendAndWaitReady(engine, 'isready');
    engine.stdin = 'position fen $fen';

    final bestMoveCompleter = Completer<String?>();
    _bestMoveCompleter = bestMoveCompleter;
    engine.stdin = 'go movetime ${difficulty.stockfishMoveTimeMs}';
    return bestMoveCompleter.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
  }

  Future<Stockfish> _ensureReady() async {
    if (_engine != null) {
      return _engine!;
    }
    if (_startingEngine != null) {
      return _startingEngine!;
    }

    final future = stockfishAsync();
    _startingEngine = future;
    final engine = await future;
    _engine = engine;
    _stdoutSubscription ??= engine.stdout.listen(_handleLine);
    _startingEngine = null;
    return engine;
  }

  Future<void> _sendAndWaitReady(Stockfish engine, String command) async {
    final completer = Completer<void>();
    _readyCompleter = completer;
    engine.stdin = command;
    if (command != 'isready') {
      engine.stdin = 'isready';
    }
    await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {},
    );
  }

  void _handleLine(String line) {
    if (line == 'readyok') {
      _readyCompleter?.complete();
      _readyCompleter = null;
      return;
    }

    if (!line.startsWith('bestmove ')) {
      return;
    }

    final segments = line.split(' ');
    final move = segments.length > 1 ? segments[1] : '(none)';
    _bestMoveCompleter?.complete(move == '(none)' ? null : move);
    _bestMoveCompleter = null;
  }

  @override
  Future<void> dispose() async {
    _bestMoveCompleter?.complete(null);
    _bestMoveCompleter = null;
    _readyCompleter?.complete();
    _readyCompleter = null;
    await _stdoutSubscription?.cancel();
    _stdoutSubscription = null;
    if (_engine != null &&
        _engine!.state.value == StockfishState.ready) {
      _engine!.dispose();
    }
    _engine = null;
    _startingEngine = null;
  }
}

StockfishClient createPlatformStockfishClient() {
  return PlatformStockfishClient();
}
