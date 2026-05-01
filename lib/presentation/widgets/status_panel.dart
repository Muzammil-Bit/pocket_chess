import 'package:flutter/material.dart';

import '../../domain/models/game_status.dart';
import '../../domain/models/piece_data.dart';

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.status,
    required this.turn,
    required this.isAiThinking,
  });

  final GameStatus status;
  final PieceSide turn;
  final bool isAiThinking;

  @override
  Widget build(BuildContext context) {
    final statusText = _statusText();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: statusText != null,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: _StatusBadge(
              label: statusText ?? ' ',
              isThinking: isAiThinking,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Turn: ${turn == PieceSide.white ? 'White' : 'Black'}',
            key: const Key('turn-label'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String? _statusText() {
    if (isAiThinking) {
      return 'Black is thinking...';
    }

    if (status.phase == GamePhase.checkmate) {
      return '${status.winner == PieceSide.white ? 'White' : 'Black'} wins by checkmate';
    }

    if (status.phase == GamePhase.stalemate) {
      return 'Stalemate';
    }

    if (status.phase == GamePhase.draw) {
      return 'Draw';
    }

    if (status.inCheck) {
      return '${turn == PieceSide.white ? 'White' : 'Black'} is in check';
    }

    return null;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.isThinking});

  final String label;
  final bool isThinking;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('status-badge'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isThinking ? const Color(0xFFDDECE7) : const Color(0xFFF0E4C6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isThinking ? Icons.psychology_alt_outlined : Icons.flag_outlined,
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              key: const Key('status-text'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
