import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../bloc/home_screen_state.dart';
import '../feed_list_screen.dart';
import 'feed_take_card.dart';
import 'section_header.dart';
import 'section_status.dart';

enum _FeedLayout { row, column }

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
  _FeedLayout _layout = _FeedLayout.row;

  void _toggleLayout() => setState(() {
        _layout =
            _layout == _FeedLayout.row ? _FeedLayout.column : _FeedLayout.row;
      });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = widget.state;

    final body = switch (state) {
      FeedLoading() => const LinearProgressIndicator(
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
          actionIcon: Icons.refresh,
          actionLabel: l10n.homeSectionErrorRetry,
          onAction: widget.onRetry,
        ),
      FeedContent(items: final items) => _layout == _FeedLayout.row
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // Room for the cards' 3D lip and shadow so they aren't clipped.
                padding: const EdgeInsets.only(top: 2, bottom: 14),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in items)
                        Padding(
                          padding:
                              EdgeInsetsDirectional.only(end: tokens.spaceSm),
                          child: SizedBox(
                            width: constraints.maxWidth * 0.8,
                            child: FeedTakeCard(
                              key: ValueKey(item.take.id),
                              item: item,
                              heroScope: widget.title,
                              reviews: widget.reviews,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) SizedBox(height: tokens.spaceSm),
                  FeedTakeCard(
                    key: ValueKey(items[i].take.id),
                    item: items[i],
                    heroScope: widget.title,
                    reviews: widget.reviews,
                  ),
                ],
              ],
            ),
    };

    final toggle = state is FeedContent
        ? IconButton(
            tooltip: _layout == _FeedLayout.row
                ? l10n.homeFeedShowAsColumn
                : l10n.homeFeedShowAsRow,
            icon: Icon(
              _layout == _FeedLayout.row
                  ? Icons.view_agenda_outlined
                  : Icons.view_carousel_outlined,
            ),
            color: AppColors.textSecondary,
            onPressed: _toggleLayout,
          )
        : null;

    final openList = state is FeedContent
        ? () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => FeedListScreen(
                  title: widget.title,
                  items: state.items,
                  reviews: widget.reviews,
                ),
              ),
            )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: widget.title,
          action: toggle,
          onTitleTap: openList,
        ),
        SizedBox(height: tokens.spaceSm),
        body,
      ],
    );
  }
}
