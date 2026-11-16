import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/game_parts.dart';
import '../../../../core/widgets/luxe_chip.dart';
import '../../../film_reviews/data/api_review_repository.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../../film_reviews/domain/take.dart';
import '../../../film_reviews/domain/take_tag.dart';
import '../../../film_reviews/presentation/topic_detail_screen.dart';
import '../../../film_reviews/presentation/widgets/topic_vote_row.dart';
import '../../data/home_models.dart';
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

  /// Latest saved take per topic id, so a vote made on a card or on the
  /// topic page is still there when the other one is shown.
  final Map<int, Take> _votedTakes = {};

  void _rememberVote(Take take) => setState(() => _votedTakes[take.id] = take);

  FeedItem _withSavedVote(FeedItem item) {
    final saved = _votedTakes[item.take.id];
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
        SizedBox(height: tokens.spaceSm),
        FutureBuilder<List<FeedItem>>(
          future: _topics,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SectionStatusCard(
                message: l10n.homeSectionErrorTitle,
                actionIcon: Icons.refresh,
                actionLabel: l10n.homeSectionErrorRetry,
                onAction: _retry,
              );
            }
            final items = snapshot.data;
            if (items == null) {
              return const LinearProgressIndicator(
                color: AppColors.accentGlow,
                backgroundColor: AppColors.surfaceRaised,
              );
            }
            if (items.isEmpty) {
              return SectionStatusCard(
                message: l10n.homeTrendingEmpty,
                actionIcon: Icons.forum_outlined,
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // Room for the card's 3D lip and shadow so they aren't clipped.
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
                              item: _withSavedVote(item),
                              reviews: widget.reviews,
                              onVoteChanged: _rememberVote,
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

/// Topics with more comments than this get the animated evil frame.
const _evilFrameAboveComments = 7;
const _evilFrameAsset = 'assets/lottie/evil_frame.json';

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    super.key,
    required this.item,
    this.reviews,
    this.onVoteChanged,
  });

  final FeedItem item;
  final ReviewRepository? reviews;
  final ValueChanged<Take>? onVoteChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final take = item.take;
    final film = item.film;
    final filmTitle = film.title;
    final tagLabel = take.tag == TakeTag.question
        ? l10n.topicTagQuestion
        : l10n.topicTagDiscussion;

    // Every topic opens its own page, with or without a movie or photo.
    void onTap() => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => TopicDetailScreen(
              item: item,
              repository: reviews,
              onTakeChanged: onVoteChanged,
            ),
          ),
        );

    final framed = take.commentCount > _evilFrameAboveComments;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GameCard(
          onTap: onTap,
          // The frame's horns and border need more room than the plain card.
          padding: framed
              ? const EdgeInsets.fromLTRB(22, 28, 22, 22)
              : const EdgeInsets.all(14),
          child: _buildContent(context, tagLabel, filmTitle, theme, tokens),
        ),
        if (framed)
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Lottie.asset(
                  _evilFrameAsset,
                  fit: BoxFit.fill,
                  repeat: true,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    String tagLabel,
    String? filmTitle,
    ThemeData theme,
    AppTokens tokens,
  ) {
    final take = item.take;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GameTag(
          tagLabel.toUpperCase(),
          tone: take.tag == TakeTag.question
              ? GameTagTone.orange
              : GameTagTone.green,
        ),
        const SizedBox(height: 10),
        Text(
          take.body,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            height: 1.9,
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(214, 255, 255, 255),
          ),
        ),
        SizedBox(height: tokens.spaceSm),
        if (filmTitle != null && filmTitle.isNotEmpty)
          Text(
            filmTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: GameColors.muted,
            ),
          ),
        const Spacer(),
        const SizedBox(height: 10),
        Row(
          children: [
           
            const SizedBox(width: 8),
            TopicVoteRow(
              take: take,
              reviews: reviews,
              onChanged: onVoteChanged,
              luxe: true,
            ),
             LuxeCounter(
              icon: Icons.chat_bubble_outline_rounded,
              count: take.commentCount,
            ),
          ],
        ),
      ],
    );
  }
}
