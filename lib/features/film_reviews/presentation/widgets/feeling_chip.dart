import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../domain/film_reaction.dart';
import '../../domain/movie_review_summary.dart';
import '../reaction_labels.dart';

/// One feeling as a pill. Picked feelings fill with their own gradient and
/// glow; the rest stay matte with the feeling's colour on the icon.
class FeelingChip extends StatelessWidget {
  const FeelingChip({
    super.key,
    required this.feeling,
    this.selected = false,
    this.dimmed = false,
    this.onTap,
  });

  final FilmReaction feeling;
  final bool selected;

  /// Faded when the viewer already has the maximum number of feelings.
  final bool dimmed;
  final VoidCallback? onTap;

  static const _height = 44.0;
  static const _radius = BorderRadius.all(Radius.circular(_height / 2));

  @override
  Widget build(BuildContext context) {
    final label = reactionLabel(context.l10n, feeling);
    final (icon, color) = reactionLook(feeling);
    final (_, deep) = reactionColors(feeling);
    final foreground = selected ? Colors.white : LuxeColors.text;

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: dimmed && !selected ? .45 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: _height),
          decoration: BoxDecoration(
            color: selected ? null : LuxeColors.surface2,
            gradient: selected ? reactionGradient(feeling) : null,
            borderRadius: _radius,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: deep.withValues(alpha: .35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: _radius,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: selected ? foreground : color),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 15,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A static bar of how the audience felt: one segment per feeling, in its
/// gradient, sized by its share, with a small legend underneath.
class AudienceBar extends StatelessWidget {
  const AudienceBar({super.key, required this.counts});

  final List<ReactionCount> counts;

  static const _barHeight = 14.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      for (final item in counts)
        if (item.count > 0) item,
    ]..sort((a, b) => b.count.compareTo(a.count));
    if (items.isEmpty) return const SizedBox.shrink();
    final total = items.fold<int>(0, (sum, item) => sum + item.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: items
              .map((item) => '${reactionLabel(l10n, item.reaction)} '
                  '${(item.count * 100 / total).round()}%')
              .join(', '),
          excludeSemantics: true,
          child: Container(
            height: _barHeight,
            decoration: const BoxDecoration(
              color: LuxeColors.surface2,
              borderRadius: BorderRadius.all(Radius.circular(_barHeight / 2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    flex: items[i].count,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: reactionGradient(
                          items[i].reaction,
                          begin: AlignmentDirectional.centerStart,
                          end: AlignmentDirectional.centerEnd,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(_barHeight / 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ExcludeSemantics(
          child: Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              for (final item in items)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: reactionGradient(item.reaction),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        reactionLabel(l10n, item.reaction),
                        style: const TextStyle(
                          color: LuxeColors.text,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(item.count * 100 / total).round()}%',
                      style: const TextStyle(
                        color: LuxeColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Every feeling as a chip; the viewer's picks are lit. At the limit the
/// others fade, and tapping a picked one removes it.
class FeelingPicker extends StatelessWidget {
  const FeelingPicker({
    super.key,
    required this.picked,
    required this.onToggle,
  });

  final List<FilmReaction> picked;
  final ValueChanged<FilmReaction>? onToggle;

  @override
  Widget build(BuildContext context) {
    final full = picked.length >= MovieReviewSummary.maxFeelings;
    final onToggle = this.onToggle;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final feeling in FilmReaction.values)
          FeelingChip(
            feeling: feeling,
            selected: picked.contains(feeling),
            dimmed: full,
            onTap: onToggle == null ? null : () => onToggle(feeling),
          ),
      ],
    );
  }
}
