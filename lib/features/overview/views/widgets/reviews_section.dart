import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/overview_placeholders.dart';
import 'overview_panel.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

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
            l10n.overviewReviewsTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          _YourReview(),
          SizedBox(height: tokens.spaceLg),
          _ReviewGroup(
            title: l10n.overviewFriendsReviews,
            reviews: OverviewPlaceholders.friendReviews,
          ),
          SizedBox(height: tokens.spaceLg),
          _ReviewGroup(
            title: l10n.overviewPopularReviews,
            reviews: OverviewPlaceholders.popularReviews,
          ),
        ],
      ),
    );
  }
}

class _YourReview extends StatelessWidget {
  const _YourReview();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.overviewYourReview,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: tokens.spaceXs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(
              color: AppColors.outline,
              width: tokens.borderWidth,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spaceMd,
              vertical: tokens.spaceSm,
            ),
            child: Text(
              l10n.overviewAddReviewHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewGroup extends StatelessWidget {
  const _ReviewGroup({required this.title, required this.reviews});

  final String title;
  final List<OverviewReview> reviews;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: null,
              style: TextButton.styleFrom(
                minimumSize: Size(0, tokens.minTouchTarget),
              ),
              child: Text(l10n.overviewSeeAll),
            ),
          ],
        ),
        for (final review in reviews) ...[
          SizedBox(height: tokens.spaceXs),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: tokens.spaceXs),
                  Text(
                    l10n.overviewReviewBy(review.author, review.date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
