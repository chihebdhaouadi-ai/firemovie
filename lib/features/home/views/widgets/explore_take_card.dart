import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../../film_reviews/domain/take.dart';
import '../../../film_reviews/domain/take_tag.dart';
import '../../../film_reviews/domain/topic_vote.dart';
import '../../../film_reviews/domain/vote_kind.dart';
import '../../../film_reviews/presentation/reaction_labels.dart';
import '../../data/home_models.dart';
import 'film_tile.dart';
import 'take_summary_card.dart';

const _cardRadius = 22.0;
const _cardSurface = Color(0xFF1B1D23);
const _cardLine = Color(0xFF2A2D36);
const _fieldSurface = Color(0xFF14151A);
const _text = Color(0xFFE8E9EE);
const _mute = Color(0xFF8D919D);
const _blue = Color(0xFF4A86D8);
const _gold = Color(0xFFE0B15E);
const _agreeGreen = Color(0xFF4AA66D);
const _disagreeRed = Color(0xFFC75050);
const _voteFill = Color(0xFF1F3250);
const _stripConversation = Color(0xFF1F3A5C);
const _stripHotTake = Color(0xFF5C2A2A);
const _stripQuestion = Color(0xFF2D5A45);
const _stripPoll = Color(0xFF4A4020);
const _stripScene = Color(0xFF5A3A24);
const _answerChips = [
  Color(0xFF8A5A8C),
  Color(0xFF2C6F8F),
  Color(0xFFB5762F),
  Color(0xFF4A8A5C),
];

const _stripStyle = TextStyle(
  color: _text,
  fontSize: 11,
  fontWeight: FontWeight.w700,
  letterSpacing: .9,
);

const _muteSmall = TextStyle(color: _mute, fontSize: 12);

/// A card for the explore carousel. Each tag gets the layout from the
/// explore prototype, backed by the real take and its replies.
class ExploreTakeCard extends StatefulWidget {
  const ExploreTakeCard({
    super.key,
    required this.item,
    required this.repository,
    this.threadRevision = 0,
    required this.onSelect,
    required this.onOpenThread,
    this.isActive = true,
  });

  final FeedItem item;
  final ReviewRepository repository;
  final int threadRevision;
  final VoidCallback onSelect;
  final VoidCallback onOpenThread;

  /// False for cards beside the centred one; their taps only move the carousel.
  final bool isActive;

  @override
  State<ExploreTakeCard> createState() => _ExploreTakeCardState();
}

class _ExploreTakeCardState extends State<ExploreTakeCard> {
  late Future<List<TakeComment>> _comments =
      widget.repository.fetchComments(widget.item.take.id);

  /// The take as shown. Poll votes change it here before the server answers.
  late Take _take = widget.item.take;

  /// Spoiler cards hide their body until the reader taps. Not persisted.
  bool _spoilerRevealed = false;

  @override
  void didUpdateWidget(ExploreTakeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _take = widget.item.take;
    }
    if (oldWidget.item.take.id != widget.item.take.id ||
        oldWidget.threadRevision != widget.threadRevision) {
      _comments = widget.repository.fetchComments(widget.item.take.id);
    }
  }

  void _revealSpoiler() {
    if (widget.isActive) {
      setState(() => _spoilerRevealed = true);
    } else {
      widget.onSelect();
    }
  }

  /// Moves the viewer's poll choice to [optionId]. The bars move at once and
  /// go back if the server rejects the vote. Choosing again does nothing.
  Future<void> _votePoll(int optionId) async {
    final current = _take;
    if (current.myPollOptionId == optionId) return;
    final optimistic = current.withPollVote(optionId);
    setState(() => _take = optimistic);
    try {
      final updated = await widget.repository.setPollVote(current.id, optionId);
      // Ignore the answer if the viewer has since picked another option.
      if (!mounted || _take.myPollOptionId != optionId) return;
      setState(() => _take = updated);
    } catch (_) {
      if (!mounted) return;
      if (identical(_take, optimistic)) {
        setState(() => _take = current);
      }
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(context.l10n.reviewVoteFailed)),
      );
    }
  }

  TakeComment? _mostVoted(List<TakeComment> comments, TopicVote vote) {
    TakeComment? best;
    var bestCount = 0;
    for (final comment in comments) {
      final count = comment.votesOf(vote);
      if (count > bestCount) {
        best = comment;
        bestCount = count;
      }
    }
    return best;
  }

  String? _lastReplyTime(BuildContext context, List<TakeComment> comments) {
    DateTime? latest;
    for (final comment in comments) {
      final at = comment.createdAt;
      if (at != null && (latest == null || at.isAfter(latest))) latest = at;
    }
    return latest == null ? null : relativeTakeTime(context, latest);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TakeComment>>(
      future: _comments,
      builder: (context, snapshot) {
        final comments = snapshot.data ?? const <TakeComment>[];
        final take = _take;
        final replyCount =
            snapshot.hasData ? comments.length : take.commentCount;
        return Align(
          alignment: Alignment.center,
          child: _buildCard(context, take, comments, replyCount),
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    Take take,
    List<TakeComment> comments,
    int replyCount,
  ) {
    final topLevel = [
      for (final comment in comments)
        if (comment.parentId == null) comment,
    ];
    final first = topLevel.isEmpty ? null : topLevel.first;
    final replies = first == null
        ? const <TakeComment>[]
        : [
            for (final comment in comments)
              if (comment.parentId == first.id) comment,
          ].take(2).toList();

    return switch (take.tag) {
      TakeTag.review => _reviewCard(context, take, first, replyCount),
      TakeTag.discussion => _conversationCard(
          context,
          take,
          comments,
          first,
          replies,
          replyCount,
        ),
      TakeTag.hotTake => _hotTakeCard(context, take, comments, replyCount),
      TakeTag.question =>
        _questionCard(context, take, topLevel, first, replyCount),
      TakeTag.poll => _pollCard(context, take, first, replyCount),
      TakeTag.scene => _sceneCard(context, take, first, replyCount),
    };
  }

  Widget _reviewCard(
    BuildContext context,
    Take take,
    TakeComment? first,
    int replyCount,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return _CardShell(
      spoiler: take.spoiler && !_spoilerRevealed,
      onReveal: _revealSpoiler,
      onTap: widget.onSelect,
      header: _PosterHeader(
        film: widget.item.film,
        title: widget.item.film.displayTitle,
      ),
      body: [
        _WhoRow(
          name: take.authorName,
          avatarUrl: take.authorAvatarUrl,
          sub: take.createdAt == null
              ? ''
              : relativeTakeTime(context, take.createdAt!),
          trailing: _Pill(label: takeBadgeLabel(l10n, take)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsetsDirectional.only(start: 10),
          decoration: const BoxDecoration(
            border:
                BorderDirectional(start: BorderSide(color: _blue, width: 3)),
          ),
          child: Text(
            take.body,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _text,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Flexible(
              child: _ReactionCount(
                value: take.votesOf(VoteKind.changedMyMind),
                label: l10n.reviewVoteChangedMyMind,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: _ReactionCount(
                value: take.votesOf(VoteKind.disagreeButFair),
                label: l10n.reviewVoteDisagreeFair,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _PeekBox(
          first: first,
          replyCount: replyCount,
          onTap: widget.onOpenThread,
        ),
      ],
    );
  }

  Widget _conversationCard(
    BuildContext context,
    Take take,
    List<TakeComment> comments,
    TakeComment? first,
    List<TakeComment> replies,
    int replyCount,
  ) {
    final l10n = context.l10n;
    final people = {
      take.authorName,
      for (final comment in comments) comment.authorName,
    }.length;
    final last = _lastReplyTime(context, comments);
    final sub = last == null
        ? l10n.explorePeopleTalking(people)
        : '${l10n.explorePeopleTalking(people)} · ${l10n.exploreLastReply(last)}';
    return _CardShell(
      spoiler: take.spoiler && !_spoilerRevealed,
      onReveal: _revealSpoiler,
      onTap: widget.onSelect,
      header: _StripHeader(
        label: l10n.exploreStripConversation,
        trailing: l10n.exploreRepliesShort(replyCount),
        color: _stripConversation,
      ),
      body: [
        _MovieHead(film: widget.item.film, sub: sub),
        _TopicText(text: take.body),
        if (first != null) _ThreadView(comment: first, replies: replies),
        _PeekBox(
          first: first,
          replyCount: replyCount,
          onTap: widget.onOpenThread,
        ),
      ],
    );
  }

  Widget _hotTakeCard(
    BuildContext context,
    Take take,
    List<TakeComment> comments,
    int replyCount,
  ) {
    final l10n = context.l10n;
    final likes = take.topicVotesOf(TopicVote.like);
    final dislikes = take.topicVotesOf(TopicVote.dislike);
    final total = likes + dislikes;
    final fresh = total == 0;
    final agree = fresh ? 50 : (likes * 100 / total).round();
    final topLevel = [
      for (final comment in comments)
        if (comment.parentId == null) comment,
    ];
    final bestLiked = _mostVoted(topLevel, TopicVote.like);
    final bestDisliked = _mostVoted(topLevel, TopicVote.dislike);
    return _CardShell(
      spoiler: take.spoiler && !_spoilerRevealed,
      onReveal: _revealSpoiler,
      onTap: widget.onSelect,
      header: _StripHeader(
        label: l10n.topicTagHotTake,
        trailing: l10n.exploreRepliesShort(replyCount),
        color: _stripHotTake,
      ),
      body: [
        _TopicText(text: take.body),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 10,
            child: Row(
              children: fresh
                  ? const [
                      Expanded(child: ColoredBox(color: _cardLine)),
                    ]
                  : [
                      Expanded(
                        flex: agree.clamp(1, 99).toInt(),
                        child: const ColoredBox(color: _agreeGreen),
                      ),
                      Expanded(
                        flex: (100 - agree).clamp(1, 99).toInt(),
                        child: const ColoredBox(color: _disagreeRed),
                      ),
                    ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: fresh
                ? [Text(l10n.exploreNoVotesYet, style: _muteSmall)]
                : [
                    Text(
                      l10n.exploreAgreePercent(agree),
                      style: _muteSmall,
                    ),
                    Text(
                      l10n.exploreDisagreePercent(100 - agree),
                      style: _muteSmall,
                    ),
                  ],
          ),
        ),
        _SideReply(label: l10n.exploreFor, comment: bestLiked),
        _SideReply(label: l10n.exploreAgainst, comment: bestDisliked),
        _PeekBox(
          first: topLevel.isEmpty ? null : topLevel.first,
          replyCount: replyCount,
          onTap: widget.onOpenThread,
        ),
      ],
    );
  }

  Widget _questionCard(
    BuildContext context,
    Take take,
    List<TakeComment> topLevel,
    TakeComment? first,
    int replyCount,
  ) {
    final l10n = context.l10n;
    final answers = topLevel.take(4).toList();
    return _CardShell(
      spoiler: take.spoiler && !_spoilerRevealed,
      onReveal: _revealSpoiler,
      onTap: widget.onSelect,
      header: _StripHeader(
        label: l10n.topicTagQuestion,
        trailing: l10n.exploreRepliesShort(replyCount),
        color: _stripQuestion,
      ),
      body: [
        _WhoRow(
          name: take.authorName,
          avatarUrl: take.authorAvatarUrl,
          sub: '',
        ),
        const SizedBox(height: 10),
        _TopicText(text: take.body),
        if (answers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < answers.length; i++)
                  _AnswerChip(
                    text: answers[i].body,
                    color: _answerChips[i % _answerChips.length],
                  ),
              ],
            ),
          ),
        _PeekBox(
          first: first,
          replyCount: replyCount,
          onTap: widget.onOpenThread,
        ),
      ],
    );
  }

  Widget _pollCard(
    BuildContext context,
    Take take,
    TakeComment? first,
    int replyCount,
  ) {
    final l10n = context.l10n;
    final total = take.totalPollVotes;
    final voted = take.myPollOptionId != null;
    return _CardShell(
      spoiler: take.spoiler && !_spoilerRevealed,
      onReveal: _revealSpoiler,
      onTap: widget.onSelect,
      header: _StripHeader(
        label: l10n.topicTagPoll,
        trailing: l10n.pollVoteCount(total),
        color: _stripPoll,
      ),
      body: [
        _TopicText(text: take.body),
        for (final option in take.pollOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PollOption(
              label: option.label,
              share: total == 0 ? 0 : option.votes / total,
              showShare: voted,
              selected: take.myPollOptionId == option.id,
              onTap: widget.isActive
                  ? () => _votePoll(option.id)
                  : widget.onSelect,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            voted ? l10n.exploreThanksVoting : l10n.pollVoteHint,
            style: _muteSmall,
          ),
        ),
        _PeekBox(
          first: first,
          replyCount: replyCount,
          onTap: widget.onOpenThread,
        ),
      ],
    );
  }

  Widget _sceneCard(
    BuildContext context,
    Take take,
    TakeComment? first,
    int replyCount,
  ) {
    final l10n = context.l10n;
    return _CardShell(
      spoiler: take.spoiler && !_spoilerRevealed,
      onReveal: _revealSpoiler,
      onTap: widget.onSelect,
      header: _StripHeader(
        label: l10n.topicTagScene,
        trailing: l10n.exploreRepliesShort(replyCount),
        color: _stripScene,
      ),
      body: [
        _MovieHead(
          film: widget.item.film,
          sub: l10n.explorePickedBy(take.authorName),
        ),
        if (take.scene.isNotEmpty || take.timecode.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Wrap(
              children: [
                if (take.scene.isNotEmpty) _OutlineTag(text: take.scene),
                if (take.timecode.isNotEmpty) _OutlineTag(text: take.timecode),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            take.body,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _text, fontSize: 15, height: 1.45),
          ),
        ),
        _PeekBox(
          first: first,
          replyCount: replyCount,
          onTap: widget.onOpenThread,
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.header,
    required this.body,
    required this.spoiler,
    required this.onReveal,
    required this.onTap,
  });

  final Widget header;
  final List<Widget> body;
  final bool spoiler;
  final VoidCallback onReveal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget content = Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: body,
      ),
    );
    if (spoiler) {
      content = Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: content,
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onReveal,
              child: ColoredBox(
                color: const Color(0x991B1D23),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.topicSpoilerLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.exploreSpoilerReveal,
                        textAlign: TextAlign.center,
                        style: _muteSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Material(
      color: _cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: const BorderSide(color: _cardLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Flexible(
              child: SingleChildScrollView(child: content),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterHeader extends StatelessWidget {
  const _PosterHeader({required this.film, required this.title});

  final Film film;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          fit: StackFit.expand,
          children: [
            FilmPoster(
              film: film,
              width: constraints.maxWidth,
              height: 200,
              radius: 0,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xC9000000)],
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripHeader extends StatelessWidget {
  const _StripHeader({
    required this.label,
    required this.trailing,
    required this.color,
  });

  final String label;
  final String trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, _cardSurface]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _stripStyle,
            ),
          ),
          const SizedBox(width: 8),
          Text(trailing.toUpperCase(), style: _stripStyle),
        ],
      ),
    );
  }
}

class _PeekBox extends StatelessWidget {
  const _PeekBox({
    required this.first,
    required this.replyCount,
    required this.onTap,
  });

  final TakeComment? first;
  final int replyCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final comment = first;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _fieldSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (comment == null)
              Text(
                l10n.exploreNoRepliesYet,
                style: const TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              )
            else
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${comment.authorName} ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: comment.body),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _text,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              comment == null
                  ? l10n.exploreBeFirstRespond
                  : l10n.exploreRepliesButton(replyCount),
              style: _muteSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieHead extends StatelessWidget {
  const _MovieHead({required this.film, required this.sub});

  final Film film;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          FilmPoster(film: film, width: 34, height: 48, radius: 6),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  film.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _muteSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhoRow extends StatelessWidget {
  const _WhoRow({
    required this.name,
    required this.sub,
    this.avatarUrl,
    this.trailing,
  });

  final String name;
  final String sub;
  final String? avatarUrl;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;
    return Row(
      children: [
        TakeAvatar(name: name, url: avatarUrl, size: 38),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              if (sub.isNotEmpty)
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _muteSmall,
                ),
            ],
          ),
        ),
        if (trailingWidget != null) ...[
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 122),
            child: trailingWidget,
          ),
        ],
      ],
    );
  }
}

class _TopicText extends StatelessWidget {
  const _TopicText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _fieldSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _cardLine),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OutlineTag extends StatelessWidget {
  const _OutlineTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 6, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _cardLine),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: _text, fontSize: 12),
      ),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  const _AnswerChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _ThreadView extends StatelessWidget {
  const _ThreadView({required this.comment, required this.replies});

  final TakeComment comment;
  final List<TakeComment> replies;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThreadLine(comment: comment, emphasis: true),
          for (final reply in replies)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 14),
              child: _ThreadLine(comment: reply, emphasis: false),
            ),
        ],
      ),
    );
  }
}

class _ThreadLine extends StatelessWidget {
  const _ThreadLine({required this.comment, required this.emphasis});

  final TakeComment comment;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsetsDirectional.only(start: 8),
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(
            color: emphasis ? _blue : _cardLine,
            width: emphasis ? 3 : 2,
          ),
        ),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${comment.authorName} ',
              style: const TextStyle(
                color: _text,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: comment.body),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFFD9D9D9),
          fontSize: 13,
          height: 1.35,
        ),
      ),
    );
  }
}

class _SideReply extends StatelessWidget {
  const _SideReply({required this.label, required this.comment});

  final String label;
  final TakeComment? comment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reply = comment;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _fieldSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            reply == null
                ? l10n.exploreNoRepliesYet
                : '$label · ${reply.authorName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _text,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          Text(
            reply?.body ?? l10n.exploreBeFirstArgue(label),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: reply == null ? _mute : _text,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionCount extends StatelessWidget {
  const _ReactionCount({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$value ',
            style: const TextStyle(color: _blue, fontWeight: FontWeight.w700),
          ),
          TextSpan(text: label),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: _mute, fontSize: 12),
    );
  }
}

class _PollOption extends StatelessWidget {
  const _PollOption({
    required this.label,
    required this.share,
    required this.showShare,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double share;
  final bool showShare;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (share * 100).round();
    return Material(
      color: _fieldSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: selected ? _blue : _cardLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 500),
                alignment: AlignmentDirectional.centerStart,
                widthFactor: showShare ? share.clamp(0.0, 1.0) : 0,
                child: const ColoredBox(color: _voteFill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _text, fontSize: 14),
                    ),
                  ),
                  if (showShare) ...[
                    const SizedBox(width: 8),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: _gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
