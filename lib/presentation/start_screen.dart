import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import 'app_colors.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    return Scaffold(
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
            const _FloatingPieces(),
            Positioned(
              top: -80,
              right: -60,
              child: _GlowOrb(size: 300, color: colors.glowOrbPrimary),
            ),
            Positioned(
              bottom: 40,
              left: -70,
              child: _GlowOrb(size: 240, color: colors.glowOrbSecondary),
            ),
            Positioned(
              bottom: -100,
              right: -40,
              child: _GlowOrb(
                size: 200,
                color: colors.accentPrimary.withValues(alpha: 0.12),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    onSettings: () => Navigator.of(
                      context,
                    ).pushNamed(SettingsScreen.routeName),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: _HeroContent(
                          onPlay: () => _startGame(context, ref),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, WidgetRef ref) {
    ref.read(gameControllerProvider.notifier).resetGame();
    Navigator.of(context).pushNamed(GameScreen.routeName);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
      child: Row(
        children: [
          const Spacer(),
          IconButton(
            key: const Key('open-settings-button'),
            onPressed: onSettings,
            icon: Icon(Icons.tune_rounded, color: colors.textMuted),
            tooltip: 'Settings',
            style: IconButton.styleFrom(
              backgroundColor: colors.cardBackground.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: colors.cardBorder.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroContent extends StatefulWidget {
  const _HeroContent({required this.onPlay});

  final VoidCallback onPlay;

  @override
  State<_HeroContent> createState() => _HeroContentState();
}

class _HeroContentState extends State<_HeroContent>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _buttonScale;
  late final Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _iconScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _iconOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _subtitleSlide = Tween(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.6, curve: Curves.easeOut),
      ),
    );

    _buttonScale = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.85, curve: Curves.elasticOut),
      ),
    );
    _buttonOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) => Column(
        key: const Key('start-screen'),
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _iconOpacity,
            child: ScaleTransition(
              scale: _iconScale,
              child: _HeroKing(pulseAnimation: _pulseController),
            ),
          ),
          const SizedBox(height: 40),
          SlideTransition(
            position: _titleSlide,
            child: FadeTransition(
              opacity: _titleOpacity,
              child: _GradientTitle(colors: colors),
            ),
          ),
          const SizedBox(height: 48),
          FadeTransition(
            opacity: _buttonOpacity,
            child: ScaleTransition(
              scale: _buttonScale,
              child: _PlayButton(
                onPressed: widget.onPlay,
                pulseAnimation: _pulseController,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _buttonOpacity,
            child: _QuickStats(colors: colors),
          ),
        ],
      ),
    );
  }
}

class _GradientTitle extends StatelessWidget {
  const _GradientTitle({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [colors.textHeading, colors.accentPrimary, colors.textHeading],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: const Text(
        'Pocket\nChess',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 52,
          height: 1.05,
          fontWeight: FontWeight.w900,
          letterSpacing: -2,
        ),
      ),
    );
  }
}

class _HeroKing extends StatelessWidget {
  const _HeroKing({required this.pulseAnimation});

  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              final scale = 1.0 + pulseAnimation.value * 0.08;
              final opacity = 0.3 + pulseAnimation.value * 0.3;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.accentPrimary.withValues(alpha: opacity),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              final scale = 1.0 + pulseAnimation.value * 0.04;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.accentPrimary.withValues(alpha: 0.2),
                        colors.accentPrimary.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colors.chessIconGradientStart,
                  colors.chessIconGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: colors.accentPrimary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.accentPrimary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '\u265A',
                style: TextStyle(
                  fontSize: 44,
                  height: 1,
                  color: colors.textHeading,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatefulWidget {
  const _PlayButton({required this.onPressed, required this.pulseAnimation});

  final VoidCallback onPressed;
  final Animation<double> pulseAnimation;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AnimatedBuilder(
      animation: widget.pulseAnimation,
      builder: (context, child) {
        final glowRadius = 20.0 + widget.pulseAnimation.value * 12;
        final glowOpacity = 0.25 + widget.pulseAnimation.value * 0.15;

        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              key: const Key('start-game-button'),
              constraints: const BoxConstraints(maxWidth: 280),
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [colors.accentPrimary, colors.accentBorder],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.accentPrimary.withValues(alpha: glowOpacity),
                    blurRadius: glowRadius,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.white24,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Play Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatChip(
          icon: Icons.smart_toy_rounded,
          label: 'vs Engine',
          colors: colors,
        ),
        const SizedBox(width: 12),
        _StatChip(
          icon: Icons.bolt_rounded,
          label: 'Quick Match',
          colors: colors,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.cardBackground.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.accentPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingPieces extends StatefulWidget {
  const _FloatingPieces();

  @override
  State<_FloatingPieces> createState() => _FloatingPiecesState();
}

class _FloatingPiecesState extends State<_FloatingPieces>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _pieces = [
    '\u2656', // white rook
    '\u2658', // white knight
    '\u2657', // white bishop
    '\u265B', // black queen
    '\u265E', // black knight
    '\u265F', // black pawn
    '\u2655', // white queen
    '\u265C', // black rook
  ];

  late final List<_FloatingPieceData> _pieceData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    final random = Random(42);
    _pieceData = List.generate(_pieces.length, (i) {
      return _FloatingPieceData(
        piece: _pieces[i],
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 22.0 + random.nextDouble() * 18,
        speed: 0.3 + random.nextDouble() * 0.7,
        phase: random.nextDouble() * 2 * pi,
        opacity: 0.04 + random.nextDouble() * 0.06,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            for (final p in _pieceData)
              Positioned(
                left: _lerpX(p, context),
                top: _lerpY(p, context),
                child: Transform.rotate(
                  angle:
                      sin(_controller.value * 2 * pi * p.speed + p.phase) *
                      0.15,
                  child: Text(
                    p.piece,
                    style: TextStyle(
                      fontSize: p.size,
                      color: colors.textHeading.withValues(alpha: p.opacity),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  double _lerpX(_FloatingPieceData p, BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final drift = sin(_controller.value * 2 * pi * p.speed + p.phase) * 20;
    return p.x * width + drift;
  }

  double _lerpY(_FloatingPieceData p, BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final drift =
        cos(_controller.value * 2 * pi * p.speed * 0.7 + p.phase) * 15;
    return p.y * height + drift;
  }
}

class _FloatingPieceData {
  const _FloatingPieceData({
    required this.piece,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
  });

  final String piece;
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
  final double opacity;
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
