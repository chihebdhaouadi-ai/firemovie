import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../bloc/home_screen_state.dart';
import '../feed_list_screen.dart';
import 'feed_take_card.dart';
import 'section_header.dart';
import 'section_status.dart';

/// Popular takes as one horizontal row of cards. Tapping the title opens
/// them all as a list.
class FeedSection extends StatefulWidget {
  const FeedSection({
    super.key,
    required this.title,
    required this.state,
    required this.onRetry,
    this.reviews,
  });

  final String title;
  final FeedState state;
  final VoidCallback onRetry;
  final ReviewRepository? reviews;

  @override
  State<FeedSection> createState() => _FeedSectionState();
}

class _FeedSectionState extends State<FeedSection> {
  @override
  Widget build(BuildContext context) {
    final FeedSection(:title, :onRetry, :reviews) = widget;
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = widget.state;

    final body = switch (state) {
      FeedLoading() => LinearProgressIndicator(
          color: AppColors.accentGlow,
          backgroundColor: AppColors.surfaceRaised,
        ),
      FeedEmpty() => Text(
          l10n.homeFeedEmpty,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      FeedError() => SectionStatusCard(
          message: l10n.homeSectionErrorTitle,
          actionIcon: BootstrapIcons.arrow_clockwise,
          actionLabel: l10n.homeSectionErrorRetry,
          onAction: onRetry,
        ),
      FeedContent(items: final items) => LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // A little room so the cards' edges aren't clipped.
            padding: const EdgeInsets.only(top: 2, bottom: 14),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in items)
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: tokens.spaceSm),
                      child: SizedBox(
                        width: constraints.maxWidth * 0.8,
                        child: FeedTakeCard(
                          fillHeight: true,
                          key: ValueKey(item.take.id),
                          item: item,
                          heroScope: title,
                          reviews: reviews,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
    };

    final openList = state is FeedContent
        ? () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => FeedListScreen(
                  title: title,
                  items: state.items,
                  reviews: reviews,
                ),
              ),
            )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onTitleTap: openList),
        const SizedBox(height: SectionHeader.contentGap),
        body,
      ],
    );
  }
}
