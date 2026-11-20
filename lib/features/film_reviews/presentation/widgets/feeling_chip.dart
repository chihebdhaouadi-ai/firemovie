import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../domain/film_reaction.dart';
import '../../domain/movie_review_summary.dart';
import 'feeling_motion.dart';
import '../reaction_labels.dart';

/// One feeling as a pill. Picked feelings fill with their own gradient and
/// glow; the rest stay matte with the feeling's colour on the icon.
class FeelingChip extends StatelessWidget {
  const FeelingChip({
    super.key,
    required this.feeling,
    this.selected = false,
    this.dimmed = false,
    this.animate = false,
    this.fill = false,
    this.compact = false,
    this.tag = false,
    this.onTap,
  });

  final FilmReaction feeling;
  final bool selected;

  /// Faded when the viewer already has the maximum number of feelings.
  final bool dimmed;

  /// Loops the icon's motion while picked.
  final bool animate;

  /// Takes the width it is given and centres its content (the film page
  /// splits the row between the picked feelings).
  final bool fill;

  /// Smaller icon and text, for three feelings sharing a phone-width row.
  final bool compact;

  /// A small read-only label (about 70% of [compact]), for showing an
  /// author's feelings above their take. Not tappable, so it can sit below
  /// the 44 pt touch target.
  final bool tag;
  final VoidCallback? onTap;

  static const _height = 44.0;
  static const _tagHeight = 30.0;
  static const _radius = BorderRadius.all(Radius.circular(_height / 2));

  @override
  Widget build(BuildContext context) {
    final label = reactionLabel(context.l10n, feeling);
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
          constraints: BoxConstraints(minHeight: tag ? _tagHeight : _height),
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
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: tag ? 10 : (fill ? 10 : 16),
                  vertical: tag ? 5 : 10,
                ),
                child: Row(
                  mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FeelingIcon(
                      feeling: feeling,
                      size: tag ? 13 : (compact ? 18 : 22),
                      animate: selected && animate,
                      color: selected ? foreground : null,
                    ),
                    SizedBox(width: tag ? 4 : (compact ? 6 : 8)),
                    Flexible(
                      child: Text(
                        label,
                        textAlign: fill ? TextAlign.center : TextAlign.start,
                        maxLines: fill ? 2 : null,
                        style: TextStyle(
                          color: foreground,
                          // Text stops at 11.5 so the label stays readable.
                          fontSize: tag ? 11.5 : (compact ? 13 : 15),
                          height: 1.2,
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
/// gradient, sized by its share. Screen readers hear each feeling's share.
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
            decoration: BoxDecoration(
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
      ],
    );
  }
}
