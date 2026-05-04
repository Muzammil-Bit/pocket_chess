import 'dart:math' as math;

import 'package:chessground/chessground.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_settings_controller.dart';
import 'game_controller.dart';
import '../../models/game_status.dart';
import '../../core/app_colors.dart';
import '../../router/routes.dart';
import '../widgets/chess_board.dart';
import 'widgets/game_board_shell.dart';
import 'widgets/game_players_header.dart';

class GameWinScreen extends ConsumerStatefulWidget {
  const GameWinScreen({super.key});

  @override
  ConsumerState<GameWinScreen> createState() => _GameWinScreenState();
}

class _GameWinScreenState extends ConsumerState<GameWinScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _shimmerController;
  late final ConfettiController _confettiCenter;

  late final Animation<double> _crownScale;
  late final Animation<double> _crownOpacity;
  late final Animation<double> _headlineSlide;
  late final Animation<double> _headlineOpacity;
  late final Animation<double> _statsOpacity;
  late final Animation<double> _statsSlide;
  late final Animation<double> _boardOpacity;
  late final Animation<double> _boardSlide;
  late final Animation<double> _buttonsOpacity;
  late final Animation<double> _buttonsSlide;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _confettiCenter = ConfettiController(duration: const Duration(seconds: 5));

    _crownScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
      ),
    );
    _crownOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _headlineSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _headlineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
      ),
    );

    _statsSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _statsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
      ),
    );

    _boardSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _boardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.65, curve: Curves.easeOut),
      ),
    );

    _buttonsSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entranceController.forward();
      _confettiCenter.play();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _confettiCenter.dispose();
    super.dispose();
  }

  int _moveCountFromFen(String fen) {
    final parts = fen.split(' ');
    if (parts.length >= 6) {
      return int.tryParse(parts[5]) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final state = ref.watch(gameControllerProvider);
    final winner = state.status.winner;

    if (state.status.phase != GamePhase.checkmate || winner == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.canPop()) context.pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final pieceTheme = ref.watch(selectedPieceThemeProvider);
    final session = state.session;
    final label = GamePlayersHeader.participantLabel(session, winner);
    final winPhrase = label == 'You' ? '$label win!' : '$label wins!';
    final totalMoves = _moveCountFromFen(state.fen);
    final totalCaptures =
        state.whiteCaptured.length + state.blackCaptured.length;

    final accentColor = colors.accentPrimary;

    final confettiColors = [
      const Color(0xFFFFD54F),
      const Color(0xFFFF7043),
      const Color(0xFF42A5F5),
      const Color(0xFF66BB6A),
      const Color(0xFFAB47BC),
      colors.activeIndicator,
    ];

    return PopScope<void>(
      canPop: true,
      child: Scaffold(
        backgroundColor: colors.gradientColors.first,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.textHeading,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              if (context.canPop()) context.pop();
            },
          ),
        ),
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors.gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Background glow behind crown
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _crownOpacity,
                    builder: (context, _) => Opacity(
                      opacity: _crownOpacity.value * 0.6,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              accentColor.withValues(alpha: 0.3),
                              accentColor.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const padding = 20.0;
                    const boardFrameAllowance = 50.0;
                    final boardSize = math.min(
                      (constraints.maxWidth -
                              (padding * 2) -
                              boardFrameAllowance)
                          .clamp(200.0, 400.0),
                      (constraints.maxHeight * 0.38 - boardFrameAllowance)
                          .clamp(200.0, 400.0),
                    );

                    return AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, _) => SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: padding,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 520,
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 4),

                                // Crown
                                Opacity(
                                  opacity: _crownOpacity.value,
                                  child: Transform.scale(
                                    scale: _crownScale.value,
                                    child: _AnimatedCrown(
                                      shimmer: _shimmerController,
                                      accentColor: accentColor,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Headline
                                Transform.translate(
                                  offset: Offset(0, _headlineSlide.value),
                                  child: Opacity(
                                    opacity: _headlineOpacity.value,
                                    child: _VictoryHeadline(
                                      winPhrase: winPhrase,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Stats
                                Transform.translate(
                                  offset: Offset(0, _statsSlide.value),
                                  child: Opacity(
                                    opacity: _statsOpacity.value,
                                    child: _GameStatsStrip(
                                      moves: totalMoves,
                                      captures: totalCaptures,
                                      winnerLabel: label,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Board
                                Transform.translate(
                                  offset: Offset(0, _boardSlide.value),
                                  child: Opacity(
                                    opacity: _boardOpacity.value,
                                    child: ChessBoardStage(
                                      boardSize: boardSize,
                                      topStrip: ChessBoardCapturedStrip(
                                        pieces: state.blackCaptured,
                                        alignment: Alignment.centerRight,
                                        theme: pieceTheme,
                                      ),
                                      board: ChessBoardFrame(
                                        boardSize: boardSize,
                                        child: IgnorePointer(
                                          child: ChessBoard(
                                            fen: state.fen,
                                            boardSize: boardSize,
                                            pieceAssets: pieceTheme.boardAssets,
                                            validMovesByOrigin: const {},
                                            playerSide: PlayerSide.none,
                                            sideToMove: state.turn,
                                            isCheck: state.status.inCheck,
                                            lastMove: state.lastMove,
                                            onMove: (_) {},
                                            lightSquareColor:
                                                colors.boardLightSquare,
                                            darkSquareColor:
                                                colors.boardDarkSquare,
                                            lastMoveHighlight:
                                                colors.boardLastMoveHighlight,
                                            selectedHighlight:
                                                colors.boardSelectedHighlight,
                                            validMovesColor:
                                                colors.boardValidMoveDot,
                                          ),
                                        ),
                                      ),
                                      bottomStrip: ChessBoardCapturedStrip(
                                        pieces: state.whiteCaptured,
                                        alignment: Alignment.centerRight,
                                        theme: pieceTheme,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Buttons
                                Transform.translate(
                                  offset: Offset(0, _buttonsSlide.value),
                                  child: Opacity(
                                    opacity: _buttonsOpacity.value,
                                    child: _ActionButtons(
                                      onPlayAgain: () {
                                        context.pop();
                                        ref
                                            .read(
                                              gameControllerProvider.notifier,
                                            )
                                            .resetGame();
                                      },
                                      onBackToMenu: () {
                                        context.go(Routes.home);
                                      },
                                      accentColor: accentColor,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Confetti overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiCenter,
                      blastDirectionality: BlastDirectionality.explosive,
                      emissionFrequency: 0.03,
                      numberOfParticles: 20,
                      maxBlastForce: 60,
                      minBlastForce: 20,
                      gravity: 0.15,
                      shouldLoop: false,
                      colors: confettiColors,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Crown
// ---------------------------------------------------------------------------

class _AnimatedCrown extends StatelessWidget {
  const _AnimatedCrown({required this.shimmer, required this.accentColor});

  final Animation<double> shimmer;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: shimmer,
            builder: (context, _) => CustomPaint(
              size: const Size(88, 88),
              painter: _ShimmerRingPainter(
                progress: shimmer.value,
                color: accentColor,
              ),
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withValues(alpha: 0.25),
                  accentColor.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: CustomPaint(painter: _CrownPainter(color: accentColor)),
          ),
        ],
      ),
    );
  }
}

class _ShimmerRingPainter extends CustomPainter {
  _ShimmerRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final sweepGradient = SweepGradient(
      startAngle: progress * 2 * math.pi,
      endAngle: progress * 2 * math.pi + 2 * math.pi,
      colors: [
        Colors.transparent,
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.5),
        color.withValues(alpha: 0.8),
        color.withValues(alpha: 0.5),
        color.withValues(alpha: 0.0),
        Colors.transparent,
      ],
      stops: const [0.0, 0.15, 0.35, 0.5, 0.65, 0.85, 1.0],
      tileMode: TileMode.clamp,
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CrownPainter extends CustomPainter {
  _CrownPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final crownW = w * 0.48;
    final crownH = h * 0.32;
    final top = cy - crownH * 0.55;
    final bottom = cy + crownH * 0.45;
    final left = cx - crownW / 2;
    final right = cx + crownW / 2;

    final path = Path()
      ..moveTo(left, bottom)
      ..lineTo(left, top + crownH * 0.4)
      ..lineTo(left + crownW * 0.2, top + crownH * 0.55)
      ..lineTo(left + crownW * 0.35, top)
      ..lineTo(cx, top + crownH * 0.35)
      ..lineTo(right - crownW * 0.35, top)
      ..lineTo(right - crownW * 0.2, top + crownH * 0.55)
      ..lineTo(right, top + crownH * 0.4)
      ..lineTo(right, bottom)
      ..close();

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Jewel dots on the crown peaks
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    const dotR = 2.0;
    canvas.drawCircle(Offset(left + crownW * 0.35, top + 1), dotR, dotPaint);
    canvas.drawCircle(Offset(cx, top + crownH * 0.35 + 1), dotR, dotPaint);
    canvas.drawCircle(Offset(right - crownW * 0.35, top + 1), dotR, dotPaint);

    // Base band
    final bandRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(left + 1, bottom - crownH * 0.18, right - 1, bottom - 1),
      const Radius.circular(1),
    );
    final bandPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(bandRect, bandPaint);
  }

  @override
  bool shouldRepaint(covariant _CrownPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ---------------------------------------------------------------------------
// Headline
// ---------------------------------------------------------------------------

class _VictoryHeadline extends StatelessWidget {
  const _VictoryHeadline({required this.winPhrase});

  final String winPhrase;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Text(
      winPhrase,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
        height: 1.1,
        color: colors.textHeading,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats Row
// ---------------------------------------------------------------------------

class _GameStatsStrip extends StatelessWidget {
  const _GameStatsStrip({
    required this.moves,
    required this.captures,
    required this.winnerLabel,
  });

  final int moves;
  final int captures;
  final String winnerLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        _StatChip(
          icon: Icons.swap_vert_rounded,
          text: '$moves moves',
          colors: colors,
        ),
        _StatChip(
          icon: Icons.shield_outlined,
          text: '$captures captures',
          colors: colors,
        ),
        _StatChip(
          icon: Icons.emoji_events_rounded,
          text: winnerLabel,
          colors: colors,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.text,
    required this.colors,
  });

  final IconData icon;
  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colors.panelBackground.withValues(alpha: 0.5),
        border: Border.all(color: colors.panelBorder.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colors.accentPrimary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: colors.textHeading,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action Buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onPlayAgain,
    required this.onBackToMenu,
    required this.accentColor,
  });

  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMenu;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onBackToMenu,
            icon: Icon(Icons.home_rounded, size: 18, color: colors.textMuted),
            label: Text(
              'Menu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(
                color: colors.panelBorder.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: onPlayAgain,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(
              'Play Again',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
