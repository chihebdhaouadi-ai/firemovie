import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../overview/views/widgets/overview_panel.dart';
import '../../domain/take.dart';
import '../state/movie_reviews_state.dart';
import 'take_card.dart';
import '../../../../core/widgets/game_button.dart';

const _flameCommentThreshold = 5;
const _flameSize = 40.0;

class TakesCard extends StatelessWidget {
  const TakesCard({
    super.key,
    required this.takes,
    required this.onRetry,
    this.highlightTakeId,
  });

  final AsyncView<List<Take>> takes;
  final Future<void> Function() onRetry;
  final int? highlightTakeId;

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
            GameButton(
                label: l10n.reviewRetry,
                style: GameButtonStyle.blue,
                onPressed: onRetry),
          ],
        ),
      AsyncReady(:final value) when value.isEmpty => Text(
          l10n.reviewTakesEmpty,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      AsyncReady(:final value) => _TakesList(
          takes: value,
          highlightTakeId: highlightTakeId,
        ),
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
  const _TakesList({required this.takes, this.highlightTakeId});

  final List<Take> takes;
  final int? highlightTakeId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < takes.length; index++) ...[
          if (index > 0) SizedBox(height: tokens.spaceMd),
          _TakeEntry(
            key: ValueKey(takes[index].id),
            take: takes[index],
            isMostHelpful: index == 0 &&
                takes[index].isMostHelpful &&
                !takes[index].isMine,
            isHighlighted: takes[index].id == highlightTakeId,
          ),
        ],
      ],
    );
  }
}

class _TakeEntry extends StatelessWidget {
  const _TakeEntry({
    super.key,
    required this.take,
    required this.isMostHelpful,
    required this.isHighlighted,
  });

  final Take take;
  final bool isMostHelpful;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final card = Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: TakeCard(
        take: take,
        isMostHelpful: isMostHelpful,
        isHighlighted: isHighlighted,
      ),
    );
    if (take.commentCount <= _flameCommentThreshold) return card;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          card,
          Positioned(
            top: 4,
            right: 4,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Lottie.asset(
                  'assets/flamefire.json',
                  width: _flameSize,
                  height: _flameSize,
                ),
              ),
            ),
          ),
        ],
      ),
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
