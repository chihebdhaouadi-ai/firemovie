import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/home_models.dart';
import 'film_tile.dart';

class RecommendSection extends StatelessWidget {
  const RecommendSection({
    super.key,
    required this.picks,
    required this.onRemovePick,
    this.onAddPick,
  });

  final List<Film> picks;
  final ValueChanged<Film> onRemovePick;

  /// Invoked with the empty pick slot index (0..2) when tapped.
  final ValueChanged<int>? onAddPick;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeRecommendHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        SizedBox(height: tokens.spaceSm),
        Row(
          children: [
            for (var index = 0; index < HomeLimits.recommendPicks; index++) ...[
              if (index > 0) SizedBox(width: tokens.spaceSm),
              if (index < picks.length)
                FilmTile(
                  film: picks[index],
                  width: tokens.recommendCardWidth,
                  semanticsLabel: l10n.homeFilmTileSemantics(
                    picks[index].displayTitle,
                    l10n.homeRecommendTitle,
                  ),
                  removeLabel: l10n.homeRemoveFilm(picks[index].displayTitle),
                  selected: true,
                  onTap: () => onRemovePick(picks[index]),
                )
              else
                _EmptyPickSlot(
                  index: index + 1,
                  width: tokens.recommendCardWidth,
                  onAdd: onAddPick == null ? null : () => onAddPick!(index),
                ),
            ],
          ],
        ),
      ],
    );
  }
}

class _EmptyPickSlot extends StatelessWidget {
  const _EmptyPickSlot({
    required this.index,
    required this.width,
    this.onAdd,
  });

  final int index;
  final double width;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final add = onAdd;

    return Semantics(
      button: add != null,
      label: context.l10n.homePickSlotEmpty(index),
      child: SizedBox(
        width: width,
        height: tokens.posterHeight(width),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(
              color: AppColors.outline,
              width: tokens.borderWidth,
            ),
          ),
          child: Material(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              onTap: add,
              child: ExcludeSemantics(
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: AppColors.textMuted,
                    size: tokens.iconSmall,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
