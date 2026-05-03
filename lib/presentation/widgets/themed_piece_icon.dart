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
    if (_requiresSanitizedSvg(theme.id)) {
      return FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(
          theme.assetPathForPiece(piece),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SvgPicture.string(
              _sanitizeSvg(theme.id, snapshot.data!),
              width: size,
              height: size,
            );
          }

          if (snapshot.hasError) {
            return _FallbackPieceIcon(size: size);
          }

          return SizedBox(width: size, height: size);
        },
      );
    }

    return SvgPicture.asset(
      theme.assetPathForPiece(piece),
      width: size,
      height: size,
    );
  }

  bool _requiresSanitizedSvg(String themeId) {
    return themeId == 'kosal' || themeId == 'reillycraig';
  }

  String _sanitizeSvg(String themeId, String svg) {
    if (themeId == 'reillycraig') {
      return svg.replaceAll('<switch>', '').replaceAll('</switch>', '');
    }

    if (themeId == 'kosal') {
      return svg
          .replaceFirst(
            RegExp(r'<style[^>]*>[\s\S]*?</style>'),
            '',
          )
          .replaceAll('class="st0"', 'fill="none"')
          .replaceAll('class="st1"', 'fill="#FFFFFF"')
          .replaceAll('class="st2"', 'fill="#CFCECF"')
          .replaceAll('class="st3"', 'display="none"')
          .replaceAll('class="st4"', 'display="inline" fill="none"')
          .replaceAll('class="st5"', 'display="inline" fill="#FFFFFF"')
          .replaceAll('class="st6"', 'display="inline" fill="#CFCECF"')
          .replaceAll(
            'class="st7"',
            'display="inline" fill="#231F20" stroke="#000000" stroke-width="0.5" stroke-miterlimit="10"',
          )
          .replaceAll(
            'class="st8"',
            'display="inline" stroke="#000000" stroke-width="0.5" stroke-miterlimit="10"',
          )
          .replaceAll('class="st9"', 'display="inline"');
    }

    return svg;
  }
}

class _FallbackPieceIcon extends StatelessWidget {
  const _FallbackPieceIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Icon(
        Icons.hide_image_outlined,
        size: size * 0.7,
        color: const Color(0x80FFFFFF),
      ),
    );
  }
}
