import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_chess/application/piece_theme_catalog.dart';

void main() {
  test('catalog keeps complete standard sets and rejects special cases', () {
    final assetKeys = <String>[
      for (final code in const [
        'wb',
        'wk',
        'wn',
        'wp',
        'wq',
        'wr',
        'bb',
        'bk',
        'bn',
        'bp',
        'bq',
        'br',
      ])
        'assets/pieces/cburnett/$code.svg',
      'assets/pieces/fantasy/fantasy.svg',
      'assets/pieces/merida/wb.svg',
      'assets/pieces/merida/bb.svg',
      'assets/pieces/merida/we.svg',
      'assets/pieces/merida/be.svg',
    ];

    final themes = buildAvailablePieceThemes(assetKeys);

    expect(themes.map((theme) => theme.id), ['cburnett']);
  });

  test('unknown theme ids fall back to the default theme', () {
    expect(pieceThemeFromId('missing-theme').id, defaultPieceThemeId);
  });
}
