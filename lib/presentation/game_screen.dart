import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/app_settings_controller.dart';
import '../application/providers.dart';
import '../domain/models/piece_data.dart';
import '../domain/models/piece_theme_option.dart';
import 'widgets/chess_board.dart';
import 'widgets/promotion_dialog.dart';
import 'widgets/themed_piece_icon.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  static const routeName = '/game';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      gameControllerProvider.select((value) => value.pendingPromotionMove),
      (previous, next) async {
        if (next == null || previous == next) {
          return;
        }

        final controller = ref.read(gameControllerProvider.notifier);
        final choice = await showPromotionDialog(context);
        if (!context.mounted) {
          return;
        }

        if (choice == null) {
          controller.cancelPromotion();
        } else {
          await controller.choosePromotion(choice);
        }
      },
    );

    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final pieceTheme = ref.watch(selectedPieceThemeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFF5F7FF),
        elevation: 0,
        title: const Text(
          'Pocket Chess',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF090B18), Color(0xFF121735), Color(0xFF1B2350)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -40,
              right: -10,
              child: _GlowOrb(size: 240, color: Color(0x70505FFF)),
            ),
            const Positioned(
              bottom: 100,
              left: -30,
              child: _GlowOrb(size: 220, color: Color(0x403B4275)),
            ),
            const Positioned.fill(child: _BoardBackdrop()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final boardSize = math.min(
                    (constraints.maxWidth - 32).clamp(280.0, 520.0),
                    (constraints.maxHeight - 280).clamp(280.0, 520.0),
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 620,
                          minHeight: constraints.maxHeight - 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _PlayersRow(
                                  isWhiteTurn: state.turn == PieceSide.white,
                                ),
                                const SizedBox(height: 20),
                                _PieceStrip(
                                  pieces: state.blackCaptured,
                                  alignment: Alignment.centerRight,
                                  theme: pieceTheme,
                                ),
                                const SizedBox(height: 16),
                                _BoardFrame(
                                  boardSize: boardSize,
                                  child: ChessBoard(
                                    fen: state.fen,
                                    boardSize: boardSize,
                                    pieceAssets: pieceTheme.boardAssets,
                                    validMovesByOrigin:
                                        state.legalMovesByOrigin,
                                    isInteractive:
                                        !state.isAiThinking &&
                                        state.pendingPromotionMove == null &&
                                        !state.status.isGameOver &&
                                        state.turn == PieceSide.white,
                                    isCheck: state.status.inCheck,
                                    lastMove: state.lastMove,
                                    onMove: (move) =>
                                        controller.handleMove(move),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _PieceStrip(
                                  pieces: state.whiteCaptured,
                                  alignment: Alignment.centerRight,
                                  theme: pieceTheme,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _ActionRow(onRestart: controller.resetGame),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayersRow extends StatelessWidget {
  const _PlayersRow({required this.isWhiteTurn});

  final bool isWhiteTurn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlayerAvatar(
            label: 'You',
            initials: 'YU',
            accent: const Color(0xFFD8E1FF),
            isActive: isWhiteTurn,
            alignment: CrossAxisAlignment.start,
          ),
        ),
        const SizedBox(width: 12),
        const _TimerPill(time: '05:00'),
        const SizedBox(width: 12),
        Expanded(
          child: _PlayerAvatar(
            label: 'Computer',
            initials: 'AI',
            accent: const Color(0xFFFFD7E1),
            isActive: !isWhiteTurn,
            alignment: CrossAxisAlignment.end,
          ),
        ),
      ],
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({
    required this.label,
    required this.initials,
    required this.accent,
    required this.isActive,
    required this.alignment,
  });

  final String label;
  final String initials;
  final Color accent;
  final bool isActive;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        SizedBox(
          width: 88,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [accent, accent.withValues(alpha: 0.82)],
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.38),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Color(0xFF0F1430),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFFF5F7FF)
                      : const Color(0xFFB8C2EF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedOpacity(
                opacity: isActive ? 1 : 0.25,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  width: 56,
                  height: 2,
                  color: isActive
                      ? const Color(0xFF6C7BFF)
                      : const Color(0xFF3A426E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(
            color: Color(0xFFF5F7FF),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Timer',
          style: TextStyle(color: Color(0xFF93A0D6), fontSize: 12),
        ),
      ],
    );
  }
}

class _PieceStrip extends StatelessWidget {
  const _PieceStrip({
    required this.pieces,
    required this.alignment,
    required this.theme,
  });

  final List<PieceData> pieces;
  final Alignment alignment;
  final PieceThemeOption theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Align(
        alignment: alignment,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final piece in pieces)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ThemedPieceIcon(piece: piece, theme: theme, size: 30),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardFrame extends StatelessWidget {
  const _BoardFrame({required this.boardSize, required this.child});

  final double boardSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(width: boardSize, height: boardSize, child: child),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: _ActionButton(label: 'Resign', icon: Icons.flag_outlined),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _ActionButton(label: 'Draw', icon: Icons.handshake_outlined),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Restart',
            icon: Icons.refresh_rounded,
            highlight: true,
            onPressed: onRestart,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.highlight = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final foreground = highlight
        ? const Color(0xFFF6F7FF)
        : const Color(0xFFD7DEFF);

    return FilledButton.tonalIcon(
      onPressed: onPressed ?? () {},
      style: FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: foreground,
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: const RoundedRectangleBorder(),
      ),
      icon: Icon(icon),
      label: Text(
        label,
        style: TextStyle(
          decoration: highlight
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationColor: foreground,
        ),
      ),
    );
  }
}

class _BoardBackdrop extends StatelessWidget {
  const _BoardBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _BoardBackdropPainter()));
  }
}

class _BoardBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x12FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final rect = Rect.fromLTWH(
        size.width * (0.08 + i * 0.16),
        size.height * 0.12,
        size.width * 0.28,
        size.height * 0.76,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(120)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
