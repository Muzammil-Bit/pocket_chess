import 'package:flutter/foundation.dart';

import 'ai_worker.dart';

class AiMove {
  const AiMove({required this.from, required this.to, this.promotion});

  final String from;
  final String to;
  final String? promotion;
}

Future<AiMove?> chooseAiMove({required String fen, int depth = 2}) async {
  final payload = <String, Object?>{'fen': fen, 'depth': depth};
  final result = await compute(computeBestMove, payload);
  if (result == null) {
    return null;
  }

  return AiMove(
    from: result['from']!,
    to: result['to']!,
    promotion: result['promotion'],
  );
}
