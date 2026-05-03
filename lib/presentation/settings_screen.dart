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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFF5F7FF),
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
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
        child: Stack(
          children: [
            const Positioned(
              top: -60,
              right: -40,
              child: _GlowOrb(size: 220, color: Color(0x554D5BFF)),
            ),
            SafeArea(
              child: availableThemes.when(
                data: (themes) => _ThemesGrid(
                  themes: themes,
                  selectedThemeId: selectedThemeId,
                  onSelect: (id) =>
                      ref.read(appSettingsProvider.notifier).setPieceTheme(id),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
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
    );
  }
}

class _ThemesGrid extends StatelessWidget {
  const _ThemesGrid({
    required this.themes,
    required this.selectedThemeId,
    required this.onSelect,
  });

  final List<PieceThemeOption> themes;
  final String selectedThemeId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 18),
          sliver: SliverToBoxAdapter(child: _SectionHeader()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.95,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final theme = themes[index];
              return _ThemeCard(
                key: ValueKey('piece-theme-${theme.id}'),
                theme: theme,
                isSelected: theme.id == selectedThemeId,
                onTap: () => onSelect(theme.id),
              );
            }, childCount: themes.length),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Piece set',
      style: TextStyle(
        color: Color(0xFFAEB7E5),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
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
    final borderColor = isSelected
        ? const Color(0xFF6C7BFF)
        : const Color(0xFF262E57);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1128),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: isSelected ? 1.6 : 1),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x444D5BFF),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final piece in _previewPieces)
                        ThemedPieceIcon(piece: piece, theme: theme, size: 38),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      theme.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFF5F7FF),
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.radio_button_checked_rounded,
                      size: 18,
                      color: Color(0xFF6C7BFF),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
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

const _previewPieces = [
  PieceData(side: PieceSide.white, kind: PieceKind.king),
  PieceData(side: PieceSide.white, kind: PieceKind.queen),
  PieceData(side: PieceSide.black, kind: PieceKind.knight),
  PieceData(side: PieceSide.black, kind: PieceKind.pawn),
];
