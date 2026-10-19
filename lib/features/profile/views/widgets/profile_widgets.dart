import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../overview/views/widgets/overview_panel.dart';
import '../../data/profile_models.dart';
import '../../data/profile_placeholders.dart';

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key, required this.watched});

  final int? watched;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final achievements = ProfilePlaceholders.achievements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileAchievementsTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: tokens.spaceMd),
        Row(
          children: [
            for (var i = 0; i < achievements.length; i++) ...[
              if (i > 0) SizedBox(width: tokens.spaceSm),
              Expanded(
                child: _AchievementCard(
                  achievement: achievements[i],
                  unlocked:
                      watched != null && watched! >= achievements[i].films,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, required this.unlocked});

  final ProfileAchievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final title = switch (achievement.level) {
      AchievementLevel.rookie => l10n.profileAchievementRookie,
      AchievementLevel.master => l10n.profileAchievementMaster,
      AchievementLevel.legend => l10n.profileAchievementLegend,
    };

    return OverviewPanel(
      borderColor: unlocked ? AppColors.panelBorder : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            unlocked ? Icons.emoji_events_outlined : Icons.lock_outline,
            size: tokens.iconLarge,
            color: unlocked ? AppColors.star : AppColors.textMuted,
          ),
          SizedBox(height: tokens.spaceXs),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: tokens.spaceXs),
          Text(
            l10n.profileAchievementFilms(achievement.films),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: tokens.spaceSm),
          if (unlocked)
            OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, tokens.minTouchTarget),
              ),
              child: Text(l10n.profileClaim),
            ),
        ],
      ),
    );
  }
}

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key, required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final loaded = profile;

    String value(int? n) => n == null ? '—' : '$n';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileStatisticsTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: tokens.spaceMd),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: value(loaded?.watched),
                label: l10n.profileStatWatched,
              ),
            ),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: _StatTile(
                value: value(loaded?.watchlist),
                label: l10n.profileStatWatchlist,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spaceSm),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: value(loaded?.reviews),
                label: l10n.profileStatReviews,
              ),
            ),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: _StatTile(
                value: '${ProfilePlaceholders.rewards}',
                label: l10n.profileStatRewards,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.accentGlow,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showProfileBlockDialog(BuildContext context) {
  final l10n = context.l10n;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(l10n.profileBlockTitle),
      content: TextField(
        maxLines: 3,
        decoration: InputDecoration(hintText: l10n.profileBlockReasonHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.profileBlockNo),
        ),
        FilledButton(
          onPressed: null,
          child: Text(l10n.profileBlockYes),
        ),
      ],
    ),
  );
}
