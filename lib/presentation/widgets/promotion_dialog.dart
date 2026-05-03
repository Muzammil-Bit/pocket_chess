import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/app_settings_controller.dart';
import '../../domain/models/piece_data.dart';
import '../../domain/models/piece_theme_option.dart';
import '../../domain/models/promotion_choice.dart';
import '../app_colors.dart';
import 'themed_piece_icon.dart';

Future<PromotionChoice?> showPromotionDialog(BuildContext context) {
  return showDialog<PromotionChoice>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _PromotionDialog(),
  );
}

class _PromotionDialog extends ConsumerWidget {
  const _PromotionDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final pieceTheme = ref.watch(selectedPieceThemeProvider);

    return AlertDialog(
      title: Text(
        'Choose a promotion',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: colors.textHeading,
        ),
      ),
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final choice in PromotionChoice.values)
            InkWell(
              onTap: () => Navigator.of(context).pop(choice),
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                width: 64,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.promotionItemBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.promotionItemBorder),
                ),
                child: Center(
                  child: ThemedPieceIcon(
                    piece: PieceData(
                      side: PieceSide.white,
                      kind: choice.pieceKind,
                    ),
                    theme: pieceTheme,
                    size: 42,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
