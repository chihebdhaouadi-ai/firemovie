import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../overview/views/widgets/overview_panel.dart';
import '../../domain/take.dart';
import '../state/movie_reviews_state.dart';
import 'take_card.dart';

class TakesCard extends StatelessWidget {
  const TakesCard({super.key, required this.takes, required this.onRetry});

  final AsyncView<List<Take>> takes;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    final body = switch (takes) {
      AsyncLoading() => const _TakesSkeleton(),
      AsyncFailed() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reviewTakesFailed,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            FilledButton(onPressed: onRetry, child: Text(l10n.reviewRetry)),
          ],
        ),
      AsyncReady(:final value) when value.isEmpty => Text(
          l10n.reviewTakesEmpty,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      AsyncReady(:final value) => _TakesList(takes: value),
    };

    return OverviewPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reviewTakesTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spaceXs),
          Text(
            l10n.reviewTakesHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          body,
        ],
      ),
    );
  }
}

class _TakesList extends StatelessWidget {
  const _TakesList({required this.takes});

  final List<Take> takes;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < takes.length; index++) ...[
          if (index > 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
              child: const Divider(height: 1, color: AppColors.panelBorder),
            ),
          TakeCard(
            key: ValueKey(takes[index].id),
            take: takes[index],
            isMostHelpful:
                index == 0 && takes[index].isMostHelpful && !takes[index].isMine,
          ),
        ],
      ],
    );
  }
}

class _TakesSkeleton extends StatelessWidget {
  const _TakesSkeleton();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
    );
  }
}
