import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../film_reviews/data/api_review_repository.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../../film_reviews/domain/take.dart';
import '../../../film_reviews/domain/take_tag.dart';
import '../../../film_reviews/presentation/topic_detail_screen.dart';
import '../../../film_reviews/presentation/widgets/take_heart.dart';
import '../../data/home_models.dart';
import '../home_navigation.dart' show openOverview;
import 'section_header.dart';
import 'section_status.dart';

/// This week's most discussed questions and discussions, across all films.
class TrendingTopicsSection extends StatefulWidget {
  const TrendingTopicsSection({super.key, this.reviews});

  final ReviewRepository? reviews;

  @override
  State<TrendingTopicsSection> createState() => _TrendingTopicsSectionState();
}

class _TrendingTopicsSectionState extends State<TrendingTopicsSection> {
  late Future<List<FeedItem>> _topics = _load();

  Future<List<FeedItem>> _load() =>
      (widget.reviews ?? ApiReviewRepository()).fetchTrendingTopics();

  void _retry() => setState(() => _topics = _load());

  /// Latest version of each topic changed on its page (say, a new reply),
  /// so the card shows it on the way back.
  final Map<int, Take> _changed = {};

  void _remember(Take take) => setState(() => _changed[take.id] = take);

  FeedItem _latest(FeedItem item) {
    final saved = _changed[item.take.id];
    return saved == null ? item : FeedItem(film: item.film, take: saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.homeTrendingTopicsTitle),
        const SizedBox(height: SectionHeader.contentGap),
        FutureBuilder<List<FeedItem>>(
          future: _topics,
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
                message: l10n.homeTrendingEmpty,
                actionIcon: BootstrapIcons.chat_square_text,
              );
            }
            return LayoutBuilder(
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
                          padding:
                              EdgeInsetsDirectional.only(end: tokens.spaceSm),
                          child: SizedBox(
                            width: constraints.maxWidth * 0.8,
                            child: _TopicCard(
                              key: ValueKey(item.take.id),
                              width: constraints.maxWidth * 0.8,
                              item: _latest(item),
                              reviews: widget.reviews,
                              onTakeChanged: _remember,
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

/// One trending topic: its type as a coloured dot and a plain label, the
/// question (and its title), and below a hairline how many replies it has,
/// its heart and a Reply button.
/// Lines of title or body a topic card shows before "See more".
const _maxLines = 2;

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    super.key,
    required this.item,
    required this.width,
    this.reviews,
    this.onTakeChanged,
  });

  final FeedItem item;

  /// The card's width, to tell whether the title or body runs past two
  /// lines (the row sizes cards by their content, so this can't come from a
  /// LayoutBuilder).
  final double width;
  final ReviewRepository? reviews;
  final ValueChanged<Take>? onTakeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final take = item.take;
    final question = take.tag == TakeTag.question;

    // Every topic opens its own page, with or without a movie or photo.
    void open() => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => TopicDetailScreen(
              item: item,
              repository: reviews,
              onTakeChanged: onTakeChanged,
            ),
          ),
        );

    final muted = TextStyle(color: LuxeColors.muted, fontSize: 13);
    final titleStyle = TextStyle(
      color: LuxeColors.text,
      fontSize: 14,
      height: 1.3,
      fontWeight: take.title.isNotEmpty ? FontWeight.w500 : FontWeight.w400,
    );
    final bodyStyle = TextStyle(
      color: LuxeColors.muted,
      fontSize: 12,
      height: 1.35,
    );
    // The text area: the card minus its side padding.
    final textWidth = width - 36;
    bool overflows(String text, TextStyle style) {
      if (text.isEmpty || textWidth <= 0) return false;
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: _maxLines,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: textWidth);
      final over = painter.didExceedMaxLines;
      painter.dispose();
      return over;
    }

    final clipped = take.title.isNotEmpty
        ? overflows(take.title, titleStyle) || overflows(take.body, bodyStyle)
        : overflows(take.body, titleStyle);
    return Material(
      color: LuxeColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: open,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: question
                            ? const Color(0xFFB8862F)
                            : const Color(0xFF4E8A5C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        question
                            ? l10n.topicTagQuestion
                            : l10n.topicTagDiscussion,
                        style: muted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // With a title, it leads and the body follows in a quieter
              // style; without one, the body is the question itself. Either
              // shows two lines at most, with "See more" opening the topic.
              if (take.title.isNotEmpty) ...[
                Text(
                  take.title,
                  maxLines: _maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  take.body,
                  maxLines: _maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: bodyStyle,
                ),
              ] else
                Text(
                  take.body,
                  maxLines: _maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              if (clipped)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    key: ValueKey('topic-see-more-${take.id}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: open,
                    child: Text(
                      l10n.topicSeeMore,
                      style: TextStyle(
                        color: LuxeColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: LuxeColors.hair,
                      ),
                    ),
                  ),
                ),
              if (item.film.title case final title? when title.isNotEmpty) ...[
                const SizedBox(height: 12),
                TopicFilmBlock(
                  compact: true,
                  film: item.film,
                  onTap: () => openOverview(context, item.film),
                ),
              ],
              const Spacer(),
              const SizedBox(height: 12),
              Divider(height: 1, thickness: 1, color: LuxeColors.hair),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      take.commentCount > 0
                          ? l10n.exploreRepliesShort(take.commentCount)
                          : l10n.homeTopicFirstReply,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: take.commentCount > 0
                          ? TextStyle(
                              color: LuxeColors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )
                          : muted,
                    ),
                  ),
                  TakeHeart(
                    take: take,
                    reviews: reviews,
                    onChanged: onTakeChanged,
                    size: 15,
                  ),
                  TextButton.icon(
                    key: ValueKey('topic-reply-${take.id}'),
                    onPressed: open,
                    style: TextButton.styleFrom(
                      foregroundColor: LuxeColors.muted,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(BootstrapIcons.chat_square, size: 14),
                    label: Text(l10n.reviewReply,
                        style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
