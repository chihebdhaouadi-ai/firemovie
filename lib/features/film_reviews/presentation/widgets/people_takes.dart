import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../angel_bird/angel_bird_host.dart';
import '../../../angel_bird/hold_gesture.dart';
import '../../../debate/presentation/debate_waiting_page.dart';
import '../../../home/views/widgets/take_summary_card.dart'
    show relativeTakeTime;
import '../../data/review_repository.dart';
import '../../domain/take.dart';
import '../../domain/vote_kind.dart';
import '../reaction_labels.dart';
import '../review_detail_screen.dart';
import '../state/movie_reviews_cubit.dart';
import 'take_photo.dart';
import 'translatable_text.dart';

/// "What people said" on the film page: takes grouped per person, each
/// person's takes on a thread, two at a time with a "show more" toggle.
class PeopleTakes extends StatelessWidget {
  const PeopleTakes({
    super.key,
    required this.takes,
    required this.movieId,
    this.repository,
  });

  final List<Take> takes;
  final String movieId;

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

  @override
  Widget build(BuildContext context) {
    final people = groupByPerson(takes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < people.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 1, color: LuxeColors.hair),
            ),
          _PersonTakes(
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
  });

  final List<Take> takes;
  final String movieId;
  final ReviewRepository? repository;

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
    final reaction = takes
        .map((take) => take.reaction)
        .firstWhere((reaction) => reaction != null, orElse: () => null);
    final hidden = takes.length - _visible;
    final shown = _expanded ? takes : takes.take(_visible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              _Avatar(name: first.authorName),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      first.authorName,
                      style: const TextStyle(
                        color: LuxeColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.filmTakeCount(takes.length),
                      style: const TextStyle(
                        color: LuxeColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (reaction != null) ...[
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * .5,
                  ),
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: const BoxDecoration(
                      color: LuxeColors.surface2,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        reactionIcon(reaction, size: 15),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            reactionLabel(l10n, reaction),
                            style: TextStyle(
                              color: reactionLook(reaction).$2,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 18, top: 12),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(color: _threadLine, width: 2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final take in shown)
                    _ThreadTake(
                      key: ValueKey(take.id),
                      take: take,
                      movieId: widget.movieId,
                      repository: widget.repository,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hidden > 0)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
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
                _expanded ? Icons.expand_less : Icons.expand_more,
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

const _threadLine = Color(0xFF262A34);

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return ExcludeSemantics(
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LuxeColors.accentGradient,
        ),
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// One take on a person's thread: dot, time, quote, translate, votes and
/// comments. Hold it to summon the angel bird and debate someone.
class _ThreadTake extends StatelessWidget {
  const _ThreadTake({
    super.key,
    required this.take,
    required this.movieId,
    this.repository,
  });

  final Take take;
  final String movieId;
  final ReviewRepository? repository;

  bool get _isTop => take.isMostHelpful && !take.isMine;

  Future<void> _vote(BuildContext context, VoteKind kind) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final failed = context.l10n.reviewVoteFailed;
    final ok = await context.read<MovieReviewsCubit>().setVote(take.id, kind);
    if (!ok) messenger?.showSnackBar(SnackBar(content: Text(failed)));
  }

  void _openComments(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReviewDetailScreen(
          movieId: movieId,
          takeId: take.id,
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
    final createdAt = take.createdAt;

    return BirdHoldRegion(
      onHold: () => _summonBird(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            start: -25,
            top: 4,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isTop ? LuxeColors.accent : LuxeColors.surface,
                border: Border.all(
                  color: _isTop ? LuxeColors.accent : _threadLine,
                  width: 2,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    if (createdAt != null)
                      Text(
                        relativeTakeTime(context, createdAt),
                        style: const TextStyle(
                          color: LuxeColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    if (_isTop)
                      Text(
                        l10n.filmTopTake,
                        style: const TextStyle(
                          color: LuxeColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (take.imageUrl != null) ...[
                  TakePhoto(url: take.imageUrl!),
                  const SizedBox(height: 8),
                ],
                TranslatableText(
                  text: take.body,
                  format: l10n.reviewQuote,
                  style: const TextStyle(
                    color: LuxeColors.text,
                    fontSize: 18,
                    height: 1.4,
                  ),
                  linkStyle: const TextStyle(
                    color: LuxeColors.muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final kind in VoteKind.values) ...[
                              _VoteChip(
                                label: voteLabel(l10n, kind),
                                count: take.votesOf(kind),
                                selected: take.hasVoted(kind),
                                onTap: take.isMine
                                    ? null
                                    : () => _vote(context, kind),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: l10n.reviewCommentsButton(take.commentCount),
                      excludeSemantics: true,
                      child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(18)),
                        onTap: () => _openComments(context),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 44,
                            minWidth: 44,
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: 6,
                              end: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 18,
                                  color: LuxeColors.muted,
                                ),
                                if (take.commentCount > 0) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '${take.commentCount}',
                                    style: const TextStyle(
                                      color: LuxeColors.muted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteChip extends StatelessWidget {
  const _VoteChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback? onTap;

  static const _radius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: selected,
      label: count > 0 ? '$label, $count' : label,
      excludeSemantics: true,
      child: Material(
        color: LuxeColors.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(
            color: selected ? LuxeColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: _radius,
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 13),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? LuxeColors.text : LuxeColors.muted,
                    fontSize: 14,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: TextStyle(
                      color: selected ? LuxeColors.accent : LuxeColors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
