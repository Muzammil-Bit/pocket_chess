import 'package:flutter/material.dart';

import '../../domain/models/piece_data.dart';
import '../../domain/models/piece_glyphs.dart';
import '../../domain/models/promotion_choice.dart';

Future<PromotionChoice?> showPromotionDialog(BuildContext context) {
  return showDialog<PromotionChoice>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _PromotionDialog(),
  );
}

class _PromotionDialog extends StatelessWidget {
  const _PromotionDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose a promotion'),
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
                  color: const Color(0xFFF4EFE7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _pieceGlyph(choice),
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _pieceGlyph(PromotionChoice choice) {
    return switch (choice) {
      PromotionChoice.queen => const PieceData(
        side: PieceSide.white,
        kind: PieceKind.queen,
      ).glyph,
      PromotionChoice.rook => const PieceData(
        side: PieceSide.white,
        kind: PieceKind.rook,
      ).glyph,
      PromotionChoice.bishop => const PieceData(
        side: PieceSide.white,
        kind: PieceKind.bishop,
      ).glyph,
      PromotionChoice.knight => const PieceData(
        side: PieceSide.white,
        kind: PieceKind.knight,
      ).glyph,
    };
  }
}
