import 'package:chessground/chessground.dart';
import 'package:flutter/services.dart';

import '../models/piece_theme_option.dart';

const defaultPieceThemeId = 'cburnett';
const Set<String> _fallbackSupportedThemeIds = {
  'alpha',
  'california',
  'cardinal',
  'cburnett',
  'celtic',
  'chess7',
  'chessnut',
  'companion',
  'dubrovny',
  'fresca',
  'gioco',
  'governor',
  'horsey',
  'icpieces',
  'kosal',
  'leipzig',
  'letter',
  'maestro',
  'pirouetti',
  'pixel',
  'reillycraig',
  'riohacha',
  'shapes',
  'staunty',
  'tatiana',
};

const Set<String> _requiredPieceFiles = {
  'wb.svg',
  'wk.svg',
  'wn.svg',
  'wp.svg',
  'wq.svg',
  'wr.svg',
  'bb.svg',
  'bk.svg',
  'bn.svg',
  'bp.svg',
  'bq.svg',
  'br.svg',
};

final PieceThemeOption defaultPieceTheme = pieceThemeFromId(
  defaultPieceThemeId,
);

Future<List<PieceThemeOption>> loadAvailablePieceThemes(
  AssetBundle assetBundle,
) async {
  final manifest = await AssetManifest.loadFromAssetBundle(assetBundle);
  final discoveredThemes = buildAvailablePieceThemes(manifest.listAssets());
  return discoveredThemes.isEmpty
      ? _fallbackSupportedThemes()
      : discoveredThemes;
}

List<PieceThemeOption> buildAvailablePieceThemes(Iterable<String> assetKeys) {
  final assetFilesByTheme = <String, Set<String>>{};

  for (final assetKey in assetKeys) {
    if (!assetKey.startsWith('assets/pieces/') || !assetKey.endsWith('.svg')) {
      continue;
    }

    final segments = assetKey.split('/');
    if (segments.length != 4) {
      continue;
    }

    assetFilesByTheme
        .putIfAbsent(segments[2], () => <String>{})
        .add(segments[3]);
  }

  final completeThemeIds = assetFilesByTheme.entries
      .where((entry) => entry.value.containsAll(_requiredPieceFiles))
      .map((entry) => entry.key)
      .toSet();

  final options = PieceSet.values
      .where((pieceSet) => completeThemeIds.contains(pieceSet.name))
      .map(
        (pieceSet) => PieceThemeOption(
          id: pieceSet.name,
          label: pieceSet.label,
          boardAssets: pieceSet.assets,
        ),
      )
      .toList();

  options.sort((a, b) {
    if (a.id == defaultPieceThemeId) {
      return -1;
    }
    if (b.id == defaultPieceThemeId) {
      return 1;
    }
    return a.label.compareTo(b.label);
  });

  return options;
}

PieceThemeOption pieceThemeFromId(String id) {
  final pieceSet = PieceSet.values.where((set) => set.name == id).firstOrNull;
  if (pieceSet == null) {
    return PieceThemeOption(
      id: PieceSet.cburnett.name,
      label: PieceSet.cburnett.label,
      boardAssets: PieceSet.cburnett.assets,
    );
  }

  return PieceThemeOption(
    id: pieceSet.name,
    label: pieceSet.label,
    boardAssets: pieceSet.assets,
  );
}

List<PieceThemeOption> _fallbackSupportedThemes() {
  final options = PieceSet.values
      .where((pieceSet) => _fallbackSupportedThemeIds.contains(pieceSet.name))
      .map(
        (pieceSet) => PieceThemeOption(
          id: pieceSet.name,
          label: pieceSet.label,
          boardAssets: pieceSet.assets,
        ),
      )
      .toList();

  options.sort((a, b) {
    if (a.id == defaultPieceThemeId) {
      return -1;
    }
    if (b.id == defaultPieceThemeId) {
      return 1;
    }
    return a.label.compareTo(b.label);
  });

  return options;
}
