import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/ai_providers.dart';
import 'game_controller.dart';
import 'game_session_controller.dart';
import '../../models/ai_difficulty.dart';
import '../../models/game_mode.dart';
import '../../models/game_session.dart';
import '../../models/time_control.dart';
import '../../core/app_colors.dart';

Future<GameSession?> showPreGameSheet(
  BuildContext context, {
  required WidgetRef ref,
}) {
  return showModalBottomSheet<GameSession>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _PreGameSheetBody(
        initialSession: ref.read(gameSessionProvider),
        stockfishSupported: ref.read(stockfishSupportedProvider),
      );
    },
  );
}

class _PreGameSheetBody extends ConsumerStatefulWidget {
  const _PreGameSheetBody({
    required this.initialSession,
    required this.stockfishSupported,
  });

  final GameSession initialSession;
  final bool stockfishSupported;

  @override
  ConsumerState<_PreGameSheetBody> createState() => _PreGameSheetBodyState();
}

class _PreGameSheetBodyState extends ConsumerState<_PreGameSheetBody> {
  late GameSession _session;
  bool _isStarting = false;

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
    Navigator.of(context).pop(_session);
  }

  @override
  void initState() {
    super.initState();
    _session = widget.initialSession.normalized(
      stockfishSupported: widget.stockfishSupported,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: AbsorbPointer(
          absorbing: _isStarting,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.textMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'New match',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your game mode and configure the engine.',
                    style: TextStyle(color: colors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  _ModeSelector(
                    selected: _session.mode,
                    onChanged: (mode) {
                      setState(() {
                        _session = _sessionForMode(mode);
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            ...previousChildren,
                            ?currentChild,
                          ],
                        );
                      },
                      child: _buildModeContent(),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _TimeControlSelector(
                    selected: _session.timeControl,
                    onChanged: (tc) {
                      setState(() {
                        if (tc == null) {
                          _session = _session.copyWith(clearTimeControl: true);
                        } else {
                          _session = _session.copyWith(timeControl: tc);
                        }
                      });
                    },
                  ),

                  if (!widget.stockfishSupported) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Colors.amber.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Stockfish is only available on Android & iOS. '
                              'This device will use minimax.',
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isStarting
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.textMuted,
                            side: BorderSide(color: colors.panelBorder),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _onStartGame,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.accentPrimary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: _isStarting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.25,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.play_arrow_rounded, size: 20),
                          label: Text(
                            _isStarting ? 'Starting...' : 'Start game',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeContent() {
    switch (_session.mode) {
      case GameMode.humanVsAi:
        return _AiConfigCard(
          key: const ValueKey('humanVsAi'),
          icon: Icons.smart_toy_outlined,
          title: 'Opponent AI',
          subtitle: 'You play White — the engine replies as Black.',
          config: _session.blackAi!,
          stockfishSupported: widget.stockfishSupported,
          onChanged: (config) {
            setState(() {
              _session = _session.copyWith(blackAi: config);
            });
          },
        );
      case GameMode.localTwoPlayer:
        return _InfoCard(
          key: const ValueKey('localTwoPlayer'),
          icon: Icons.people_outline_rounded,
          text:
              'Both sides are controlled locally — '
              'pass the device between turns.',
        );
      case GameMode.aiVsAi:
        return Column(
          key: const ValueKey('aiVsAi'),
          children: [
            _AiConfigCard(
              icon: Icons.smart_toy_outlined,
              title: 'White AI',
              subtitle: 'Configure the White engine and strength.',
              config: _session.whiteAi!,
              stockfishSupported: widget.stockfishSupported,
              onChanged: (config) {
                setState(() {
                  _session = _session.copyWith(whiteAi: config);
                });
              },
            ),
            const SizedBox(height: 12),
            _AiConfigCard(
              icon: Icons.smart_toy_outlined,
              title: 'Black AI',
              subtitle: 'Configure the Black engine and strength.',
              config: _session.blackAi!,
              stockfishSupported: widget.stockfishSupported,
              onChanged: (config) {
                setState(() {
                  _session = _session.copyWith(blackAi: config);
                });
              },
            ),
          ],
        );
    }
  }

  GameSession _sessionForMode(GameMode mode) {
    switch (mode) {
      case GameMode.humanVsAi:
        return GameSession(
          mode: mode,
          blackAi:
              _session.blackAi ??
              const GameAiConfig(
                engine: AiEngineKind.minimax,
                difficulty: AiDifficulty.medium,
              ),
          timeControl: _session.timeControl,
        ).normalized(stockfishSupported: widget.stockfishSupported);
      case GameMode.localTwoPlayer:
        return GameSession(
          mode: GameMode.localTwoPlayer,
          timeControl: _session.timeControl,
        );
      case GameMode.aiVsAi:
        return GameSession(
          mode: mode,
          whiteAi:
              _session.whiteAi ??
              _session.blackAi ??
              const GameAiConfig(
                engine: AiEngineKind.minimax,
                difficulty: AiDifficulty.medium,
              ),
          blackAi:
              _session.blackAi ??
              const GameAiConfig(
                engine: AiEngineKind.minimax,
                difficulty: AiDifficulty.medium,
              ),
          timeControl: _session.timeControl,
        ).normalized(stockfishSupported: widget.stockfishSupported);
    }
  }
}

// ---------------------------------------------------------------------------
// Mode selector
// ---------------------------------------------------------------------------

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.selected, required this.onChanged});

  final GameMode selected;
  final ValueChanged<GameMode> onChanged;

  static const _modes = [
    (GameMode.humanVsAi, Icons.person_outline_rounded, 'vs AI'),
    (GameMode.localTwoPlayer, Icons.people_outline_rounded, '2 Players'),
    (GameMode.aiVsAi, Icons.smart_toy_outlined, 'AI vs AI'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.panelBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.panelBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          for (final (mode, icon, label) in _modes)
            Expanded(
              child: _ModeOption(
                icon: icon,
                label: label,
                isSelected: selected == mode,
                onTap: () => onChanged(mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accentPrimary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors.accentPrimary.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? colors.accentPrimary : colors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colors.accentPrimary : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AI configuration card
// ---------------------------------------------------------------------------

class _AiConfigCard extends StatelessWidget {
  const _AiConfigCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.config,
    required this.stockfishSupported,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final GameAiConfig config;
  final bool stockfishSupported;
  final ValueChanged<GameAiConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.panelBackground.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.panelBorder.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.accentPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: colors.accentPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: colors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'ENGINE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: colors.textMuted.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _EngineChip(
                label: 'Minimax',
                icon: Icons.account_tree_outlined,
                isSelected: config.engine == AiEngineKind.minimax,
                onTap: () =>
                    onChanged(config.copyWith(engine: AiEngineKind.minimax)),
              ),
              if (stockfishSupported) ...[
                const SizedBox(width: 8),
                _EngineChip(
                  label: 'Stockfish',
                  icon: Icons.memory_rounded,
                  isSelected: config.engine == AiEngineKind.stockfish,
                  onTap: () => onChanged(
                    config.copyWith(engine: AiEngineKind.stockfish),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'DIFFICULTY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: colors.textMuted.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final (i, difficulty) in AiDifficulty.values.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DifficultyChip(
                    difficulty: difficulty,
                    isSelected: difficulty == config.difficulty,
                    onTap: () =>
                        onChanged(config.copyWith(difficulty: difficulty)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EngineChip extends StatelessWidget {
  const _EngineChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accentPrimary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colors.accentPrimary.withValues(alpha: 0.5)
                : colors.panelBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? colors.accentPrimary : colors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? colors.accentPrimary : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  final AiDifficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon {
    switch (difficulty) {
      case AiDifficulty.easy:
        return Icons.sentiment_satisfied_alt_rounded;
      case AiDifficulty.medium:
        return Icons.local_fire_department_rounded;
      case AiDifficulty.hard:
        return Icons.whatshot_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accentPrimary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colors.accentPrimary.withValues(alpha: 0.5)
                : colors.panelBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(
              _icon,
              size: 18,
              color: isSelected ? colors.accentPrimary : colors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              difficulty.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colors.accentPrimary : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info card (for 2-player mode)
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  const _InfoCard({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.panelBackground.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.panelBorder.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.accentPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: colors.accentPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Time control selector
// ---------------------------------------------------------------------------

class _TimeControlSelector extends StatelessWidget {
  const _TimeControlSelector({
    required this.selected,
    required this.onChanged,
  });

  final TimeControl? selected;
  final ValueChanged<TimeControl?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.panelBackground.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.panelBorder.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.accentPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: colors.accentPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time control',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Optional — leave off for a free-play game.',
                      style: TextStyle(color: colors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TimeChip(
                label: 'None',
                isSelected: selected == null,
                onTap: () => onChanged(null),
              ),
              for (final preset in TimeControl.presets)
                _TimeChip(
                  label: preset.label,
                  subtitle: preset.category,
                  isSelected: selected == preset,
                  onTap: () => onChanged(preset),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accentPrimary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colors.accentPrimary.withValues(alpha: 0.5)
                : colors.panelBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colors.accentPrimary : colors.textMuted,
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? colors.accentPrimary.withValues(alpha: 0.7)
                        : colors.textMuted.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
