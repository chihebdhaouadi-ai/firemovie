import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../film_reviews/data/api_review_repository.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../data/home_models.dart';
import 'feed_take_card.dart';
import 'section_header.dart';
import 'section_status.dart';

/// A horizontal row of take cards that loads its own data, so a tab can show
/// it without the home bloc knowing about it.
class TakeListSection extends StatefulWidget {
  const TakeListSection({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.load,
    this.reviews,
  });

  final String title;
  final String emptyMessage;
  final Future<List<FeedItem>> Function(ReviewRepository repository) load;
  final ReviewRepository? reviews;

  @override
  State<TakeListSection> createState() => _TakeListSectionState();
}

class _TakeListSectionState extends State<TakeListSection> {
  late Future<List<FeedItem>> _items = _load();

  Future<List<FeedItem>> _load() =>
      widget.load(widget.reviews ?? ApiReviewRepository());

  void _retry() => setState(() => _items = _load());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: widget.title),
        const SizedBox(height: SectionHeader.contentGap),
        FutureBuilder<List<FeedItem>>(
          future: _items,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SectionStatusCard(
                message: l10n.homeSectionErrorTitle,
                actionIcon: BootstrapIcons.arrow_clockwise,
                actionLabel: l10n.homeSectionErrorRetry,
                onAction: _retry,
              );
            }
            final items = snapshot.data;
            if (items == null) {
              return LinearProgressIndicator(
                color: AppColors.accentGlow,
                backgroundColor: AppColors.surfaceRaised,
              );
            }
            if (items.isEmpty) {
              return SectionStatusCard(
                message: widget.emptyMessage,
                actionIcon: BootstrapIcons.pencil_square,
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                              fillHeight: true,
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
            );
          },
        ),
      ],
    );
  }
}
