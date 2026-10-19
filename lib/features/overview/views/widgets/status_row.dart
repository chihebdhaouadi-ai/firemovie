import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../find/data/movie.dart';
import '../../data/overview_placeholders.dart';

class StatusRow extends StatelessWidget {
  const StatusRow({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final rating = movie.voteAverage;

    return Row(
      children: [
        Expanded(
          child: _StatusChip(
            label: l10n.homeWatchedTitle,
            icon: Icons.visibility,
            active: movie.isWatched,
          ),
        ),
        SizedBox(width: tokens.spaceSm),
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: tokens.iconSmall,
                    color: AppColors.star,
                  ),
                  SizedBox(width: tokens.spaceXs),
                  Flexible(
                    child: Text(
                      rating == null
                          ? l10n.overviewNoRating
                          : l10n.overviewRating(rating.toStringAsFixed(1)),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              if (rating != null)
                Text(
                  l10n.overviewRatingsCount(OverviewPlaceholders.ratingsCount),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: tokens.spaceSm),
        Expanded(
          child: _StatusChip(
            label: l10n.homeWatchlistTitle,
            icon: Icons.bookmark,
            active: movie.isWatchlist,
          ),
        ),
      ],
    );
  }
}

class UserStarsRow extends StatelessWidget {
  const UserStarsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    const filled = OverviewPlaceholders.userStars;

    return Semantics(
      label: l10n.overviewStarsValue('$filled'),
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              Icon(
                i <= filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: tokens.iconSmall * 1.5,
                color: AppColors.star,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.icon,
    required this.active,
  });

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final color = active ? AppColors.accentGlow : AppColors.textMuted;

    return Semantics(
      label: label,
      selected: active,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: active ? AppColors.surfaceRaised : AppColors.surface,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(
              color: active ? AppColors.accentGlow : AppColors.outline,
              width: tokens.borderWidth,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: tokens.spaceSm,
              horizontal: tokens.spaceXs,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: tokens.iconSmall, color: color),
                SizedBox(height: tokens.spaceXs),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
