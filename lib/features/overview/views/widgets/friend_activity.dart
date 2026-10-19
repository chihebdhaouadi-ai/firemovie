import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/overview_placeholders.dart';
import 'overview_panel.dart';

class FriendActivity extends StatelessWidget {
  const FriendActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return OverviewPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.overviewActivityTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          for (final name in OverviewPlaceholders.friends) ...[
            _FriendRow(name: name, subtitle: l10n.overviewWantsToWatch),
            if (name != OverviewPlaceholders.friends.last)
              SizedBox(height: tokens.spaceSm),
          ],
        ],
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: tokens.minTouchTarget / 2,
          backgroundColor: AppColors.surfaceRaised,
          child: Text(
            name.substring(0, 1),
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.accentGlow,
            ),
          ),
        ),
        SizedBox(width: tokens.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
