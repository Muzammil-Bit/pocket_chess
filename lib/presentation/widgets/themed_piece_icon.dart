import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/models/piece_data.dart';
import '../../domain/models/piece_theme_option.dart';

class ThemedPieceIcon extends StatelessWidget {
  const ThemedPieceIcon({
    super.key,
    required this.piece,
    required this.theme,
    this.size = 32,
  });

  final PieceData piece;
  final PieceThemeOption theme;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      theme.assetPathForPiece(piece),
      width: size,
      height: size,
    );
  }
}
