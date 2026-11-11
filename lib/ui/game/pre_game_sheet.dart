import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ai/ai_providers.dart';
import 'game_controller.dart';
import 'game_session_controller.dart';
import '../../models/ai_difficulty.dart';
import '../../models/game_mode.dart';
import '../../models/game_session.dart';
import '../../models/time_control.dart';
import '../../core/app_colors.dart';
import '../../router/routes.dart';

const _defaultAi = GameAiConfig(
  engine: AiEngineKind.minimax,
  difficulty: AiDifficulty.medium,
);

/// Preset picked when the clock is switched on for the first time (5 min).
final _defaultTimeControl = TimeControl.presets[4];

class PreGameScreen extends ConsumerStatefulWidget {
  const PreGameScreen({super.key});

  @override
  ConsumerState<PreGameScreen> createState() => _PreGameScreenState();
}

class _PreGameScreenState extends ConsumerState<PreGameScreen> {
  late GameSession _session;

  /// Remembers the last preset so switching the clock off and on restores it.
  TimeControl? _lastTimeControl;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    final initialSession = ref.read(gameSessionProvider);
    final stockfishSupported = ref.read(stockfishSupportedProvider);
    _session = initialSession.normalized(
      stockfishSupported: stockfishSupported,
    );
  }

  Future<void> _onStartGame() async {
    if (_isStarting) {
      return;
    }
    setState(() => _isStarting = true);
    try {
      await ref.read(gameControllerProvider.notifier).startSession(_session);
    } catch (_) {
      if (mounted) {
        setState(() => _isStarting = false);
      }
      return;
    }
    if (!mounted) {
      return;
    }
    context.pushReplacement(Routes.game);
  }

  void _update(GameSession session) {
    HapticFeedback.selectionClick();
    setState(() => _session = session);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final stockfishSupported = ref.watch(stockfishSupportedProvider);

    return Scaffold(
      backgroundColor: colors.gradientColors.first,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: AbsorbPointer(
            absorbing: _isStarting,
            child: Column(
              children: [
                _Header(onClose: () => context.pop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ModePicker(
                          selected: _session.mode,
                          onChanged: (mode) => _update(_sessionForMode(mode)),
                        ),
                        const SizedBox(height: 28),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            layoutBuilder: (current, previous) => Stack(
                              alignment: Alignment.topCenter,
                              children: [...previous, ?current],
                            ),
                            child: _buildModeContent(stockfishSupported),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _ClockSection(
                          selected: _session.timeControl,
                          onToggle: (enabled) {
                            if (enabled) {
                              _update(
                                _session.copyWith(
                                  timeControl:
                                      _lastTimeControl ?? _defaultTimeControl,
                                ),
                              );
                            } else {
                              _lastTimeControl = _session.timeControl;
                              _update(
                                _session.copyWith(clearTimeControl: true),
                              );
                            }
                          },
                          onSelected: (preset) {
                            _lastTimeControl = preset;
                            _update(_session.copyWith(timeControl: preset));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: _StartButton(
                    isStarting: _isStarting,
                    onPressed: _onStartGame,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeContent(bool stockfishSupported) {
    switch (_session.mode) {
      case GameMode.humanVsAi:
        return _AiSection(
          key: const ValueKey('humanVsAi'),
          title: 'Opponent',
          trailing: 'You play White',
          config: _session.blackAi!,
          stockfishSupported: stockfishSupported,
          onChanged: (config) => _update(_session.copyWith(blackAi: config)),
        );
      case GameMode.localTwoPlayer:
        return const _TwoPlayerNote(key: ValueKey('localTwoPlayer'));
      case GameMode.aiVsAi:
        return Column(
          key: const ValueKey('aiVsAi'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AiSection(
              title: 'White',
              side: _Side.white,
              config: _session.whiteAi!,
              stockfishSupported: stockfishSupported,
              onChanged: (config) =>
                  _update(_session.copyWith(whiteAi: config)),
            ),
            const SizedBox(height: 28),
            _AiSection(
              title: 'Black',
              side: _Side.black,
              config: _session.blackAi!,
              stockfishSupported: stockfishSupported,
              onChanged: (config) =>
                  _update(_session.copyWith(blackAi: config)),
            ),
          ],
        );
    }
  }

  GameSession _sessionForMode(GameMode mode) {
    final stockfishSupported = ref.read(stockfishSupportedProvider);
    switch (mode) {
      case GameMode.humanVsAi:
        return GameSession(
          mode: mode,
          blackAi: _session.blackAi ?? _defaultAi,
          timeControl: _session.timeControl,
        ).normalized(stockfishSupported: stockfishSupported);
      case GameMode.localTwoPlayer:
        return GameSession(
          mode: GameMode.localTwoPlayer,
          timeControl: _session.timeControl,
        );
      case GameMode.aiVsAi:
        return GameSession(
          mode: mode,
          whiteAi: _session.whiteAi ?? _session.blackAi ?? _defaultAi,
          blackAi: _session.blackAi ?? _defaultAi,
          timeControl: _session.timeControl,
        ).normalized(stockfishSupported: stockfishSupported);
    }
  }
}

// Header

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'New match',
              style: TextStyle(
                color: colors.textHeading,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.1,
              ),
            ),
          ),
          IconButton(
            key: const Key('pre-game-close-button'),
            tooltip: 'Close',
            onPressed: onClose,
            style: IconButton.styleFrom(
              backgroundColor: colors.panelBackground.withValues(alpha: 0.8),
              foregroundColor: colors.textHeading,
              fixedSize: const Size(40, 40),
            ),
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

// Shared building blocks

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.side,
    this.trailingText,
    this.trailing,
  });

  final String title;
  final _Side? side;
  final String? trailingText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
      child: Row(
        children: [
          if (side != null) ...[
            _SideDot(side: side!),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colors.textHeading,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText!,
              style: TextStyle(color: colors.textMuted, fontSize: 13),
            ),
          ?trailing,
        ],
      ),
    );
  }
}

enum _Side { white, black }

class _SideDot extends StatelessWidget {
  const _SideDot({required this.side});

  final _Side side;

  @override
  Widget build(BuildContext context) {
    final isWhite = side == _Side.white;

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isWhite ? const Color(0xFFF4F1EA) : const Color(0xFF1A1A1F),
        border: Border.all(
          color: isWhite ? const Color(0x33000000) : const Color(0x55FFFFFF),
        ),
      ),
    );
  }
}

/// Rounded surface that groups related controls.
class _Group extends StatelessWidget {
  const _Group({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.panelBackground.withValues(alpha: isDark ? 0.55 : 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.panelBorder.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: context.appColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Segment<T> {
  const _Segment(this.value, this.label, {this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Segmented control with a thumb that slides to the selected option.
class _SegmentedPicker<T> extends StatelessWidget {
  const _SegmentedPicker({
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<_Segment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final index = segments.indexWhere((s) => s.value == selected);
    final count = segments.length;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.textHeading.withValues(alpha: isDark ? 0.06 : 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              count == 1 ? 0 : -1 + 2 * index / (count - 1),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / count,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark ? colors.statusBadgeActiveBg : Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final segment in segments)
                Expanded(
                  child: _SegmentLabel(
                    segment: segment,
                    isSelected: segment.value == selected,
                    onTap: () => onChanged(segment.value),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentLabel<T> extends StatelessWidget {
  const _SegmentLabel({
    required this.segment,
    required this.isSelected,
    required this.onTap,
  });

  final _Segment<T> segment;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = isSelected ? colors.textHeading : colors.textMuted;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (segment.icon != null) ...[
                Icon(segment.icon, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(segment.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Mode picker

class _ModePicker extends StatelessWidget {
  const _ModePicker({required this.selected, required this.onChanged});

  final GameMode selected;
  final ValueChanged<GameMode> onChanged;

  static const _modes = [
    (GameMode.humanVsAi, Icons.person_rounded, 'vs AI', 'Solo play'),
    (GameMode.localTwoPlayer, Icons.people_rounded, '2 Players', 'Pass & play'),
    (GameMode.aiVsAi, Icons.smart_toy_rounded, 'AI vs AI', 'Watch a duel'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, (mode, icon, label, caption)) in _modes.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _ModeTile(
              icon: icon,
              label: label,
              caption: caption,
              isSelected: selected == mode,
              onTap: () => onChanged(mode),
            ),
          ),
        ],
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.label,
    required this.caption,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String caption;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isSelected ? Colors.white : colors.textHeading;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          height: 112,
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: isSelected
                ? null
                : colors.panelBackground.withValues(alpha: isDark ? 0.55 : 0.9),
            gradient: isSelected
                ? LinearGradient(
                    colors: [colors.accentPrimary, colors.accentBorder],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.18)
                  : colors.panelBorder.withValues(alpha: 0.35),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.accentPrimary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : colors.accentPrimary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : colors.accentBorder,
                ),
              ),
              const Spacer(),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.75)
                      : colors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AI configuration

class _AiSection extends StatelessWidget {
  const _AiSection({
    super.key,
    required this.title,
    required this.config,
    required this.stockfishSupported,
    required this.onChanged,
    this.side,
    this.trailing,
  });

  final String title;
  final _Side? side;
  final String? trailing;
  final GameAiConfig config;
  final bool stockfishSupported;
  final ValueChanged<GameAiConfig> onChanged;

  String get _strengthHint {
    switch (config.engine) {
      case AiEngineKind.minimax:
        final depth = config.difficulty.minimaxDepth;
        return 'Looks $depth ${depth == 1 ? 'move' : 'moves'} ahead';
      case AiEngineKind.stockfish:
        return 'Skill level ${config.difficulty.stockfishSkillLevel} of 20';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: title, side: side, trailingText: trailing),
        _Group(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _FieldLabel('Engine'),
              if (stockfishSupported)
                _SegmentedPicker<AiEngineKind>(
                  segments: const [
                    _Segment(
                      AiEngineKind.minimax,
                      'Minimax',
                      icon: Icons.account_tree_outlined,
                    ),
                    _Segment(
                      AiEngineKind.stockfish,
                      'Stockfish',
                      icon: Icons.memory_rounded,
                    ),
                  ],
                  selected: config.engine,
                  onChanged: (engine) =>
                      onChanged(config.copyWith(engine: engine)),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    'Minimax. Stockfish runs on Android and iOS only.',
                    style: TextStyle(
                      color: colors.textHeading,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              const _FieldLabel('Difficulty'),
              _SegmentedPicker<AiDifficulty>(
                segments: [
                  for (final difficulty in AiDifficulty.values)
                    _Segment(difficulty, difficulty.label),
                ],
                selected: config.difficulty,
                onChanged: (difficulty) =>
                    onChanged(config.copyWith(difficulty: difficulty)),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  _strengthHint,
                  key: ValueKey(_strengthHint),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TwoPlayerNote extends StatelessWidget {
  const _TwoPlayerNote({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(title: 'Players'),
        _Group(
          child: Row(
            children: [
              const _SideDot(side: _Side.white),
              const SizedBox(width: 4),
              const _SideDot(side: _Side.black),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Both sides play on this device. '
                  'Pass it over after each move.',
                  style: TextStyle(
                    color: colors.textHeading,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Clock

class _ClockSection extends StatelessWidget {
  const _ClockSection({
    required this.selected,
    required this.onToggle,
    required this.onSelected,
  });

  final TimeControl? selected;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeControl> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = selected != null;
    const presets = TimeControl.presets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'Clock',
          trailing: Switch.adaptive(
            key: const Key('clock-switch'),
            value: enabled,
            activeTrackColor: colors.accentPrimary,
            inactiveTrackColor: colors.textHeading.withValues(alpha: 0.14),
            onChanged: onToggle,
          ),
        ),
        _Group(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: enabled
                ? Column(
                    children: [
                      for (var row = 0; row < presets.length; row += 3) ...[
                        if (row > 0) const SizedBox(height: 8),
                        Row(
                          children: [
                            for (var i = row; i < row + 3; i++) ...[
                              if (i > row) const SizedBox(width: 8),
                              Expanded(
                                child: i < presets.length
                                    ? _TimeTile(
                                        preset: presets[i],
                                        isSelected: presets[i] == selected,
                                        onTap: () => onSelected(presets[i]),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.all_inclusive_rounded,
                        size: 18,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No time limit. Turn the clock on for '
                          'bullet, blitz or rapid.',
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final TimeControl preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 62,
          decoration: BoxDecoration(
            color: isSelected
                ? colors.accentPrimary
                : colors.textHeading.withValues(alpha: isDark ? 0.05 : 0.04),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                preset.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : colors.textHeading,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                preset.category,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.75)
                      : colors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Start button

class _StartButton extends StatelessWidget {
  const _StartButton({required this.isStarting, required this.onPressed});

  final bool isStarting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.accentPrimary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.accentPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
        icon: isStarting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.25,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.play_arrow_rounded, size: 22),
        label: Text(isStarting ? 'Starting...' : 'Start game'),
      ),
    );
  }
}
