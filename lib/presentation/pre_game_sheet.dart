import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import '../domain/models/ai_difficulty.dart';
import '../domain/models/game_mode.dart';
import '../domain/models/game_session.dart';
import 'app_colors.dart';
import 'history_screen.dart';

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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'New match',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(HistoryScreen.routeName);
                      },
                      icon: const Icon(Icons.history_rounded),
                      label: const Text('Previous games'),
                    ),
                  ],
                ),
                Text(
                  'Choose mode, engine, and difficulty before you jump in.',
                  style: TextStyle(color: colors.textMuted),
                ),
                const SizedBox(height: 20),
                _SectionLabel(label: 'Mode'),
                const SizedBox(height: 10),
                SegmentedButton<GameMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: GameMode.humanVsAi,
                      label: Text('vs AI'),
                    ),
                    ButtonSegment(
                      value: GameMode.localTwoPlayer,
                      label: Text('2 players'),
                    ),
                    ButtonSegment(
                      value: GameMode.aiVsAi,
                      label: Text('AI vs AI'),
                    ),
                  ],
                  selected: {_session.mode},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _session = _sessionForMode(selection.first);
                    });
                  },
                ),
                const SizedBox(height: 22),
                if (_session.mode == GameMode.humanVsAi) ...[
                  _AiSideEditor(
                    title: 'Black AI',
                    subtitle: 'You play White. The engine replies as Black.',
                    config: _session.blackAi!,
                    stockfishSupported: widget.stockfishSupported,
                    onChanged: (config) {
                      setState(() {
                        _session = _session.copyWith(blackAi: config);
                      });
                    },
                  ),
                ] else if (_session.mode == GameMode.aiVsAi) ...[
                  _AiSideEditor(
                    title: 'White AI',
                    subtitle: 'Configure White engine and strength.',
                    config: _session.whiteAi!,
                    stockfishSupported: widget.stockfishSupported,
                    onChanged: (config) {
                      setState(() {
                        _session = _session.copyWith(whiteAi: config);
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  _AiSideEditor(
                    title: 'Black AI',
                    subtitle: 'Configure Black engine and strength.',
                    config: _session.blackAi!,
                    stockfishSupported: widget.stockfishSupported,
                    onChanged: (config) {
                      setState(() {
                        _session = _session.copyWith(blackAi: config);
                      });
                    },
                  ),
                ] else ...[
                  Divider(color: Theme.of(context).dividerColor, height: 1),
                  const SizedBox(height: 14),
                  Text(
                    'Both sides stay local and fully manual.',
                    style: TextStyle(color: colors.textMuted),
                  ),
                ],
                if (!widget.stockfishSupported) ...[
                  const SizedBox(height: 20),
                  Divider(color: Theme.of(context).dividerColor, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'Stockfish is available on Android and iOS only. This device will use minimax.',
                    style: TextStyle(color: colors.textMuted),
                  ),
                ],
                const SizedBox(height: 26),
                Divider(color: Theme.of(context).dividerColor, height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(_session),
                      child: const Text('Start game'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GameSession _sessionForMode(GameMode mode) {
    switch (mode) {
      case GameMode.humanVsAi:
        return GameSession(
          mode: mode,
          blackAi: _session.blackAi ??
              const GameAiConfig(
                engine: AiEngineKind.minimax,
                difficulty: AiDifficulty.medium,
              ),
        ).normalized(stockfishSupported: widget.stockfishSupported);
      case GameMode.localTwoPlayer:
        return const GameSession(mode: GameMode.localTwoPlayer);
      case GameMode.aiVsAi:
        return GameSession(
          mode: mode,
          whiteAi: _session.whiteAi ??
              _session.blackAi ??
              const GameAiConfig(
                engine: AiEngineKind.minimax,
                difficulty: AiDifficulty.medium,
              ),
          blackAi: _session.blackAi ??
              const GameAiConfig(
                engine: AiEngineKind.minimax,
                difficulty: AiDifficulty.medium,
              ),
        ).normalized(stockfishSupported: widget.stockfishSupported);
    }
  }
}

class _AiSideEditor extends StatelessWidget {
  const _AiSideEditor({
    required this.title,
    required this.subtitle,
    required this.config,
    required this.stockfishSupported,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final GameAiConfig config;
  final bool stockfishSupported;
  final ValueChanged<GameAiConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(label: title),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(color: context.appColors.textMuted)),
        const SizedBox(height: 14),
        Text('Engine', style: theme.textTheme.titleSmall),
        const SizedBox(height: 10),
        SegmentedButton<AiEngineKind>(
          showSelectedIcon: false,
          segments: [
            const ButtonSegment(
              value: AiEngineKind.minimax,
              label: Text('Minimax'),
            ),
            if (stockfishSupported)
              const ButtonSegment(
                value: AiEngineKind.stockfish,
                label: Text('Stockfish'),
              ),
          ],
          selected: {config.engine},
          onSelectionChanged: (selection) {
            onChanged(config.copyWith(engine: selection.first));
          },
        ),
        const SizedBox(height: 16),
        Text('Difficulty', style: theme.textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final difficulty in AiDifficulty.values)
              ChoiceChip(
                label: Text(difficulty.label),
                selected: difficulty == config.difficulty,
                onSelected: (_) {
                  onChanged(config.copyWith(difficulty: difficulty));
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
