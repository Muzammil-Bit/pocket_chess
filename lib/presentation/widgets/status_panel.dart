import 'package:flutter/material.dart';

import '../../domain/models/game_status.dart';
import '../../domain/models/piece_data.dart';
import '../app_colors.dart';

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
    final colors = context.appColors;
    final statusText = _statusText();
    final turnText = turn == PieceSide.white ? 'Your move' : 'Computer move';

    return Container(
      key: const Key('status-panel'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.panelBackground.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.panelBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusText != null)
            _StatusBadge(label: statusText, isThinking: isAiThinking),
          if (statusText != null) const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: turn == PieceSide.white
                      ? colors.activeText
                      : colors.inactiveText,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                turnText,
                key: const Key('turn-label'),
                style: TextStyle(
                  color: colors.textHeading,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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

    return 'Match in progress';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.isThinking});

  final String label;
  final bool isThinking;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      key: const Key('status-badge'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isThinking ? colors.statusBadgeActiveBg : colors.statusBadgeBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isThinking
              ? colors.statusBadgeActiveBorder
              : colors.statusBadgeBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isThinking ? Icons.psychology_alt_outlined : Icons.flag_outlined,
            size: 18,
            color: colors.textHeading,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              key: const Key('status-text'),
              style: TextStyle(
                color: colors.textHeading,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
