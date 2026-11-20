import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../find/data/movie.dart';

class StatusRow extends StatelessWidget {
  const StatusRow({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusChip(
          label: l10n.homeWatchedTitle,
          icon: BootstrapIcons.eye_fill,
          active: movie.isWatched,
        ),
        SizedBox(height: tokens.spaceSm),
        _StatusChip(
          label: l10n.homeWatchlistTitle,
          icon: BootstrapIcons.bookmark_fill,
          active: movie.isWatchlist,
        ),
      ],
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
              horizontal: tokens.spaceMd,
            ),
            child: Row(
              children: [
                Icon(icon, size: tokens.iconSmall, color: color),
                SizedBox(width: tokens.spaceSm),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
