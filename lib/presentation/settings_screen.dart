import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/app_settings_controller.dart';
import '../domain/models/piece_data.dart';
import '../domain/models/piece_theme_option.dart';
import 'widgets/themed_piece_icon.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedThemeId = ref.watch(
      appSettingsProvider.select((value) => value.pieceThemeId),
    );
    final availableThemes = ref.watch(availablePieceThemesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFF5F7FF),
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF090B18), Color(0xFF121735), Color(0xFF1B2350)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Piece icons',
                  style: TextStyle(
                    color: Color(0xFFF5F7FF),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choose the set used on the board, in captures, and during promotion.',
                  style: TextStyle(
                    color: Color(0xFFAEB7E5),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: availableThemes.when(
                    data: (themes) => ListView.separated(
                      itemCount: themes.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: const Color(0xFF313767).withValues(alpha: 0.55),
                      ),
                      itemBuilder: (context, index) {
                        final theme = themes[index];
                        return _ThemeRow(
                          key: ValueKey('piece-theme-${theme.id}'),
                          theme: theme,
                          isSelected: theme.id == selectedThemeId,
                          onTap: () => ref
                              .read(appSettingsProvider.notifier)
                              .setPieceTheme(theme.id),
                        );
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
                      child: Text(
                        'Unable to load piece themes.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final PieceThemeOption theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: isSelected ? const Color(0x124D5BFF) : Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.label,
                      style: TextStyle(
                        color: const Color(0xFFF5F7FF),
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final piece in _previewPieces)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ThemedPieceIcon(
                              piece: piece,
                              theme: theme,
                              size: 28,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected
                    ? const Color(0xFF6C7BFF)
                    : const Color(0xFF7F89B9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _previewPieces = [
  PieceData(side: PieceSide.white, kind: PieceKind.king),
  PieceData(side: PieceSide.white, kind: PieceKind.queen),
  PieceData(side: PieceSide.black, kind: PieceKind.knight),
  PieceData(side: PieceSide.black, kind: PieceKind.pawn),
];
