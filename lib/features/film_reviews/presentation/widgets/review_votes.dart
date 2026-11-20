import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../domain/take.dart';
import '../../domain/vote_kind.dart';
import '../reaction_labels.dart';

/// The icon that stands for [kind]; the vote row shows no text labels.
IconData voteIcon(VoteKind kind) => switch (kind) {
      VoteKind.up => BootstrapIcons.hand_thumbs_up_fill,
      VoteKind.draw => BootstrapIcons.hand_thumbs_up_fill,
      VoteKind.down => BootstrapIcons.hand_thumbs_down_fill,
    };

/// The colour of [kind] on its button and in the split bar.
Color voteColor(VoteKind kind) => switch (kind) {
      VoteKind.up => themed(const Color(0xFF4ADE80), const Color(0xFF1F7A45)),
      VoteKind.draw => themed(const Color(0xFFFFC53D), const Color(0xFF8A6200)),
      VoteKind.down => themed(const Color(0xFFFF5C7A), const Color(0xFFB8304C)),
    };

/// Up / draw / down on a review: three icon buttons with their counts, and a
/// bar that splits the votes by kind. The author sees the numbers but cannot
/// vote ([onVote] is then null).
class ReviewVoteBar extends StatelessWidget {
  const ReviewVoteBar({super.key, required this.take, required this.onVote});

  final Take take;
  final ValueChanged<VoteKind>? onVote;

  @override
  Widget build(BuildContext context) {
    final total =
        VoteKind.values.fold<int>(0, (sum, kind) => sum + take.votesOf(kind));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (final kind in VoteKind.values) ...[
              if (kind != VoteKind.values.first) const SizedBox(width: 8),
              Expanded(
                child: _VoteButton(
                  kind: kind,
                  count: take.votesOf(kind),
                  selected: take.hasVoted(kind),
                  onTap: onVote == null ? null : () => onVote!(kind),
                ),
              ),
            ],
          ],
        ),
        if (total > 0) ...[
          const SizedBox(height: 10),
          VoteSplitBar(take: take, total: total),
        ],
      ],
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.kind,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final VoteKind kind;
  final int count;
  final bool selected;
  final VoidCallback? onTap;

  static const _radius = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    final label = voteLabel(context.l10n, kind);
    final tint = voteColor(kind);
    final color = selected ? tint : LuxeColors.muted;

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        enabled: onTap != null,
        selected: selected,
        label: '$label, $count',
        onTap: onTap,
        excludeSemantics: true,
        child: Material(
          color: selected ? tint.withValues(alpha: .14) : LuxeColors.surface2,
          shape: RoundedRectangleBorder(
            borderRadius: _radius,
            side: BorderSide(color: selected ? tint : Colors.transparent),
          ),
          child: InkWell(
            key: Key('vote-${kind.apiValue}'),
            borderRadius: _radius,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(voteIcon(kind), size: 20, color: color),
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: TextStyle(
                      color: selected ? tint : LuxeColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// How the votes split between up, draw and down: one segment per kind,
/// each as wide as its share, with the up share written beside it.
class VoteSplitBar extends StatelessWidget {
  const VoteSplitBar({super.key, required this.take, required this.total});

  final Take take;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shares = {
      for (final kind in VoteKind.values)
        kind: (100 * take.votesOf(kind) / total).round(),
    };
    final summary = [
      for (final kind in VoteKind.values)
        '${voteLabel(l10n, kind)} ${shares[kind]}%',
    ].join(', ');

    return Semantics(
      label: summary,
      excludeSemantics: true,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    for (final kind in VoteKind.values)
                      if (take.votesOf(kind) > 0)
                        Expanded(
                          flex: take.votesOf(kind),
                          child: Padding(
                            // Thin gaps keep the colours apart.
                            padding: const EdgeInsetsDirectional.only(end: 2),
                            child: ColoredBox(color: voteColor(kind)),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          for (final kind in VoteKind.values)
            if (take.votesOf(kind) > 0) ...[
              Icon(voteIcon(kind), size: 13, color: voteColor(kind)),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Text(
                  '${shares[kind]}%',
                  style: TextStyle(
                    color: LuxeColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}
