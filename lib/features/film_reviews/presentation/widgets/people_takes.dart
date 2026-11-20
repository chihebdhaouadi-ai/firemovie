import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../angel_bird/angel_bird_host.dart';
import '../../../angel_bird/hold_gesture.dart';
import '../../../debate/presentation/debate_waiting_page.dart';
import '../../../../core/widgets/avatar_frame.dart';
import '../../../home/views/widgets/take_summary_card.dart'
    show absoluteApiUrl, relativeTakeTime;
import '../../data/review_repository.dart';
import '../../domain/film_reaction.dart';
import '../../domain/movie_review_summary.dart';
import '../../domain/take.dart';
import '../reaction_labels.dart';
import '../../../home/data/home_models.dart';
import '../topic_detail_screen.dart';
import '../state/movie_reviews_cubit.dart';
import 'take_photo.dart';
import 'take_heart.dart';
import 'take_film_cover.dart';
import 'spoiler_shield.dart';
import 'take_skin_background.dart';
import 'translatable_text.dart';

/// "What people said" on the film page: takes grouped per person, each
/// person's takes on a thread, two at a time with a "show more" toggle.
class PeopleTakes extends StatelessWidget {
  const PeopleTakes({
    super.key,
    required this.takes,
    required this.movieId,
    this.repository,
    this.cover,
  });

  final List<Take> takes;
  final String movieId;

  /// The film's cover for the take page opened from a card.
  final TakeCoverInfo? cover;

  /// Passed on to the take page opened from the comment button.
  final ReviewRepository? repository;

  /// Groups [takes] by author, keeping the order people first appear in.
  static List<List<Take>> groupByPerson(List<Take> takes) {
    final groups = <int, List<Take>>{};
    for (final take in takes) {
      groups.putIfAbsent(take.authorId, () => []).add(take);
    }
    return groups.values.toList(growable: false);
  }

  /// A person's feelings for the film (up to three): what the server says
  /// they feel now, or else the feelings stored on their takes.
  static List<FilmReaction> personFeelings(List<Take> takes) {
    for (final take in takes) {
      if (take.authorReactions.isNotEmpty) {
        return take.authorReactions
            .take(MovieReviewSummary.maxFeelings)
            .toList(growable: false);
      }
    }
    return {
      for (final take in takes)
        if (take.reaction case final reaction?) reaction,
    }.take(MovieReviewSummary.maxFeelings).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final people = groupByPerson(takes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < people.length; i++) ...[
          if (i > 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 1, color: LuxeColors.hair),
            ),
          _PersonTakes(
            cover: cover,
            key: ValueKey(people[i].first.authorId),
            takes: people[i],
            movieId: movieId,
            repository: repository,
          ),
        ],
      ],
    );
  }
}

class _PersonTakes extends StatefulWidget {
  const _PersonTakes({
    super.key,
    required this.takes,
    required this.movieId,
    this.repository,
    this.cover,
  });

  final List<Take> takes;
  final String movieId;
  final ReviewRepository? repository;
  final TakeCoverInfo? cover;

  @override
  State<_PersonTakes> createState() => _PersonTakesState();
}

class _PersonTakesState extends State<_PersonTakes> {
  static const _visible = 2;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final takes = widget.takes;
    final first = takes.first;
    final feelings = PeopleTakes.personFeelings(takes);
    final hidden = takes.length - _visible;
    final shown = _expanded ? takes : takes.take(_visible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Who and when: framed photo, name with the time under it, and how
        // they felt on the right.
        Row(
          children: [
            SizedBox.square(
              dimension: 48,
              child: Center(
                child: AvatarFrame(
                  size: 34,
                  frame: first.authorFrame,
                  avatarUrl: absoluteApiUrl(first.authorAvatarUrl),
                  initial: first.authorName,
                  backgroundColor: LuxeColors.accentLo,
                  ringWidth: 0,
                  animate: false,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    first.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: LuxeColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _TakeMeta(take: shown.first),
                ],
              ),
            ),
            if (feelings.isNotEmpty) ...[
              const SizedBox(width: 8),
              Semantics(
                label: l10n.filmPersonFeelings(
                  feelings.map((f) => reactionLabel(l10n, f)).join(', '),
                ),
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < feelings.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      _FeelingDot(feeling: feelings[i]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, thickness: 1, color: LuxeColors.hair),
            ),
          _ThreadTake(
            cover: widget.cover,
            key: ValueKey(shown[i].id),
            take: shown[i],
            movieId: widget.movieId,
            repository: widget.repository,
            // The first take's time sits under the name already.
            showMeta: i > 0,
          ),
        ],
        if (hidden > 0)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              style: TextButton.styleFrom(
                foregroundColor: LuxeColors.accent,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: Icon(
                _expanded
                    ? BootstrapIcons.chevron_up
                    : BootstrapIcons.chevron_down,
                size: 18,
              ),
              label: Text(
                _expanded
                    ? l10n.filmShowLessTakes
                    : l10n.filmShowMoreTakes(hidden),
              ),
            ),
          ),
      ],
    );
  }
}

const _cardRadius = BorderRadius.all(Radius.circular(12));

/// One take under a person: quote, translate / more, and the three vote
/// options (plus its own time line when it is not the person's first). Tapping the card opens the take's
/// detail page; holding it summons the angel bird to debate someone.
class _ThreadTake extends StatelessWidget {
  const _ThreadTake({
    super.key,
    required this.take,
    required this.movieId,
    this.repository,
    this.showMeta = true,
    this.cover,
  });

  final Take take;
  final String movieId;
  final ReviewRepository? repository;
  final TakeCoverInfo? cover;

  /// Whether to show this take's own time line (the first take's is in the
  /// person header).
  final bool showMeta;

  // Takes open on the same page as topics.
  void _openDetail(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TopicDetailScreen(
          item: FeedItem(
            film: cover?.film ?? Film(imdbId: movieId),
            take: take,
          ),
          repository: repository,
        ),
      ),
    );
  }

  void _summonBird(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<MovieReviewsCubit>();
    AngelBirdHost.summon(
      context,
      BirdRequest(
        question: l10n.angelBirdReviewQuestion,
        pickPrompt: l10n.angelBirdPickPerson,
        emptyMessage: l10n.angelBirdNoPeople,
        failedMessage: l10n.angelBirdPeopleFailed,
        load: () => _participants(cubit),
      ),
    );
  }

  Future<List<BirdOption>> _participants(MovieReviewsCubit cubit) async {
    final comments = await cubit.loadComments(take.id);
    if (comments == null) throw StateError('Comments unavailable');
    final seen = <int>{};
    final options = <BirdOption>[];
    void add(int userId, String name) {
      if (!seen.add(userId)) return;
      options.add(
        BirdOption(
          label: name,
          page: (_) =>
              DebateWaitingPage(opponentId: userId, opponentName: name),
        ),
      );
    }

    if (!take.isMine) add(take.authorId, take.authorName);
    for (final comment in comments) {
      add(comment.authorId, comment.authorName);
    }
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BirdHoldRegion(
      onHold: () => _summonBird(context),
      // Normal takes sit flat inside the section card (no card in a card):
      // more room for text. Other skins draw their own background.
      child: TakeSkinBackground(
        skin: take.skin,
        padding: const EdgeInsets.all(10),
        borderRadius: _cardRadius,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => _openDetail(context),
            borderRadius: _cardRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showMeta) ...[
                    _TakeMeta(take: take),
                    const SizedBox(height: 6),
                  ],
                  SpoilerShield(
                    hidden: take.spoiler,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (take.imageUrl != null) ...[
                          TakePhoto(url: take.imageUrl!),
                          const SizedBox(height: 8),
                        ],
                        ConstrainedBox(
                          // Room for the spoiler veil on one-line takes.
                          constraints: BoxConstraints(
                            minHeight: take.spoiler ? 72 : 0,
                          ),
                          child: TranslatableText(
                            text: take.body,
                            format: l10n.reviewQuote,
                            style: TextStyle(
                              color: LuxeColors.text,
                              fontSize: 15,
                              height: 1.5,
                            ),
                            // Long takes (up to 1500 characters) fold to 8
                            // lines.
                            collapsedMaxLines: 8,
                            linkStyle: TextStyle(
                              color: LuxeColors.muted,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // The one reaction on takes: a heart.
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Builder(builder: (context) {
                      // The film page's state, when this list sits on it.
                      final cubit = context.read<MovieReviewsCubit?>();
                      return TakeHeart(
                        take: take,
                        reviews: repository ?? cubit?.repository,
                        onChanged: cubit?.takeChanged,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A take's quiet details on one line: when it was posted, how many
/// comments it has, and the TOP TAKE mark.
class _TakeMeta extends StatelessWidget {
  const _TakeMeta({required this.take});

  final Take take;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final createdAt = take.createdAt;
    final isTop = take.isMostHelpful && !take.isMine;
    final muted = TextStyle(color: LuxeColors.muted, fontSize: 12.5);
    final dot = Text(' · ', style: muted);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (createdAt != null)
          Text(relativeTakeTime(context, createdAt), style: muted),
        if (take.commentCount > 0) ...[
          if (createdAt != null) dot,
          Semantics(
            label: l10n.filmTakeComments(take.commentCount),
            excludeSemantics: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  BootstrapIcons.chat,
                  size: 13,
                  color: LuxeColors.muted,
                ),
                const SizedBox(width: 3),
                Text('${take.commentCount}', style: muted),
              ],
            ),
          ),
        ],
        if (isTop) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: LuxeColors.accent.withValues(alpha: .16),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            child: Text(
              l10n.filmTopTake,
              style: TextStyle(
                color: LuxeColors.accentHi,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: .6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// One of a person's feelings as a small gradient circle with its icon.
class _FeelingDot extends StatelessWidget {
  const _FeelingDot({required this.feeling});

  final FilmReaction feeling;

  @override
  Widget build(BuildContext context) {
    final (_, deep) = reactionColors(feeling);
    return Tooltip(
      message: reactionLabel(context.l10n, feeling),
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: reactionGradient(feeling),
          boxShadow: [
            BoxShadow(color: deep.withValues(alpha: .35), blurRadius: 6),
          ],
        ),
        child: Icon(reactionLook(feeling).$1, size: 13, color: Colors.white),
      ),
    );
  }
}
