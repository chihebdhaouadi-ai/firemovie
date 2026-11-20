import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/game_parts.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/data/home_models.dart';
import '../../home/views/widgets/take_summary_card.dart';
import '../data/api_review_repository.dart';
import '../../social/data/social_repository.dart';
import '../data/review_repository.dart';
import '../data/take_actions_repository.dart';
import '../domain/take.dart';
import '../domain/take_skin.dart';
import '../domain/topic_vote.dart';
import 'reaction_labels.dart';
import 'state/movie_reviews_cubit.dart';
import 'state/movie_reviews_state.dart';
import 'take_hero.dart';
import 'widgets/comment_thread.dart';
import 'widgets/feeling_chip.dart';
import 'widgets/mention_suggestions.dart';
import '../../social/data/social_models.dart';
import 'widgets/take_photo.dart';
import 'widgets/take_heart.dart';
import 'widgets/spoiler_shield.dart';
import 'widgets/take_actions.dart';
import 'widgets/take_film_cover.dart';
import 'widgets/take_skin_background.dart';
import 'widgets/translatable_text.dart';

/// A review on its own page, laid out like a topic: the review leads in a
/// card (author, feelings, the take on its skin, the film and the three
/// reactions), then the threaded comments with like, dislike and reply, and
/// a composer pinned at the bottom.
class ReviewDetailScreen extends StatelessWidget {
  const ReviewDetailScreen({
    super.key,
    required this.movieId,
    required this.takeId,
    this.initialItem,
    this.heroTag,
    this.repository,
    this.replyToCommentId,
    this.actions,
    this.social,
    this.film,
    this.backdropUrl,
    this.filmYear,
  });

  final String movieId;
  final int takeId;
  final FeedItem? initialItem;

  /// The film, for its cover; falls back to [initialItem]'s film.
  final Film? film;

  /// A wide image of the film for the cover (the poster is used blurred
  /// when missing).
  final String? backdropUrl;
  final int? filmYear;
  final Object? heroTag;
  final ReviewRepository? repository;

  /// Opens with the composer replying to this comment (from a mention).
  final int? replyToCommentId;
  final TakeActionsRepository? actions;
  final SocialRepository? social;

  @override
  Widget build(BuildContext context) {
    final repository = this.repository ?? ApiReviewRepository();
    return BlocProvider(
      create: (_) => MovieReviewsCubit(
        filmId: movieId,
        repository: repository,
      )..load(),
      child: _ReviewDetailView(
        takeId: takeId,
        initialItem: initialItem,
        heroTag: heroTag,
        repository: repository,
        replyToCommentId: replyToCommentId,
        actions: actions,
        social: social,
        film: film,
        backdropUrl: backdropUrl,
        filmYear: filmYear,
      ),
    );
  }
}

class _ReviewDetailView extends StatefulWidget {
  const _ReviewDetailView({
    required this.takeId,
    required this.initialItem,
    required this.heroTag,
    required this.repository,
    required this.replyToCommentId,
    required this.actions,
    required this.social,
    required this.film,
    required this.backdropUrl,
    required this.filmYear,
  });

  final int takeId;
  final FeedItem? initialItem;
  final Object? heroTag;
  final ReviewRepository repository;
  final int? replyToCommentId;
  final TakeActionsRepository? actions;
  final SocialRepository? social;
  final Film? film;
  final String? backdropUrl;
  final int? filmYear;

  @override
  State<_ReviewDetailView> createState() => _ReviewDetailViewState();
}

class _ReviewDetailViewState extends State<_ReviewDetailView> {
  /// Friends offered while typing `@name` in the composer.
  List<SocialUser> _mentionFriends = const [];

  final _input = TextEditingController();
  final _inputFocus = FocusNode();

  List<TakeComment>? _comments;
  bool _loading = true;
  bool _sending = false;
  bool _sendFailed = false;
  TakeComment? _replyTo;

  @override
  void initState() {
    super.initState();
    MentionFriends.load(widget.social).then((friends) {
      if (mounted) setState(() => _mentionFriends = friends);
    });
    _loadComments();
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final comments =
        await context.read<MovieReviewsCubit>().loadComments(widget.takeId);
    if (!mounted) return;
    setState(() {
      _comments = comments;
      _loading = false;
      // From a mention: answer the comment that tagged the viewer.
      final target = widget.replyToCommentId;
      if (target != null && _replyTo == null) _replyTo = _findComment(target);
    });
  }

  void _retryComments() {
    setState(() => _loading = true);
    _loadComments();
  }

  TakeComment? _findComment(int id) {
    for (final comment in _comments ?? const <TakeComment>[]) {
      if (comment.id == id) return comment;
    }
    return null;
  }

  void _replaceComment(TakeComment updated) {
    final comments = _comments;
    if (comments == null) return;
    setState(() {
      _comments = [
        for (final comment in comments)
          comment.id == updated.id ? updated : comment,
      ];
    });
  }

  /// Moves the viewer's vote to [kind]; tapping the same vote again clears
  /// it. The count changes at once and is reverted if the server refuses.
  Future<void> _voteComment(TakeComment tapped, TopicVote kind) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final failed = context.l10n.reviewVoteFailed;
    final current = _findComment(tapped.id) ?? tapped;
    final vote = current.myVote == kind ? null : kind;
    _replaceComment(current.withMyVote(vote));
    try {
      final updated = await widget.repository.setCommentVote(
        current.id,
        kind,
        active: vote != null,
      );
      if (!mounted) return;
      _replaceComment(updated);
    } catch (_) {
      if (!mounted) return;
      _replaceComment(current);
      messenger?.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  void _startReply(TakeComment comment) {
    setState(() => _replyTo = comment);
    _inputFocus.requestFocus();
  }

  void _cancelReply() => setState(() => _replyTo = null);

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty) {
      _inputFocus.requestFocus();
      return;
    }
    if (_sending) return;
    setState(() {
      _sending = true;
      _sendFailed = false;
    });
    final comment = await context.read<MovieReviewsCubit>().postComment(
          widget.takeId,
          body,
          parentId: _replyTo?.id,
        );
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (comment == null) {
        _sendFailed = true;
        return;
      }
      _comments = [...?_comments, comment];
      _replyTo = null;
      _input.clear();
    });
  }

  Take? _resolveTake(AsyncView<List<Take>> takes) {
    if (takes is! AsyncReady<List<Take>>) return null;
    for (final take in takes.value) {
      if (take.id == widget.takeId) return take;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<MovieReviewsCubit, MovieReviewsState>(
      builder: (context, state) {
        final takes = state.takes;
        final take = _resolveTake(takes) ?? widget.initialItem?.take;

        return Scaffold(
          backgroundColor: LuxeColors.bg,
          appBar: AppBar(
            backgroundColor: LuxeColors.bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(l10n.reviewDetailTitle),
          ),
          body: take == null
              ? _Missing(
                  loading: takes is AsyncLoading<List<Take>>,
                  failed: takes is AsyncFailed<List<Take>>,
                )
              : _body(l10n, take),
          bottomNavigationBar: take == null ? null : _composerBar(l10n, take),
        );
      },
    );
  }

  /// Puts the film's cover behind the top of the page, with its poster and
  /// title above the take card. Without a film, the card stands alone.
  Widget _withCover(Film? film, Widget card) {
    if (film == null) return card;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          // Bleeds past the page padding to the screen edges.
          top: -4,
          left: -14,
          right: -14,
          child: TakeCoverBackdrop(film: film, backdropUrl: widget.backdropUrl),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 96),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TakeCoverTitle(film: film, year: widget.filmYear),
            ),
            const SizedBox(height: 18),
            card,
          ],
        ),
      ],
    );
  }

  Widget _body(AppLocalizations l10n, Take take) {
    final candidate = widget.film ?? widget.initialItem?.film;
    final film =
        candidate == null || candidate.imdbId.isEmpty ? null : candidate;
    final header = _ReviewHeader(
      take: take,
      menu: TakeMenuButton(
        take: take,
        actions: widget.actions,
        social: widget.social,
        onEdited: context.read<MovieReviewsCubit>().takeEdited,
        onDeleted: () => Navigator.of(context).maybePop(),
      ),
    );
    final tag = widget.heroTag;
    final count = _comments?.length ?? take.commentCount;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _withCover(
                film,
                tag == null
                    ? header
                    : Hero(
                        tag: tag,
                        flightShuttleBuilder: takeHeroFlightShuttle,
                        child: header,
                      ),
              ),
              const SizedBox(height: 22),
              Semantics(
                header: true,
                child: Text(
                  l10n.topicCommentsHeading(count),
                  style: TextStyle(
                    color: LuxeColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _commentsSection(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _commentsSection(AppLocalizations l10n) {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(
          color: LuxeColors.accent,
          backgroundColor: LuxeColors.surface2,
        ),
      );
    }
    final comments = _comments;
    if (comments == null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              l10n.reviewCommentsFailed,
              style: TextStyle(color: LuxeColors.muted, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _retryComments,
            child: Text(l10n.homeSectionErrorRetry),
          ),
        ],
      );
    }
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            l10n.reviewBeFirstComment,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LuxeColors.muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      );
    }
    return CommentThread(
      comments: comments,
      onReply: _startReply,
      onVote: _voteComment,
      showReviewStance: true,
    );
  }

  Widget _composerBar(AppLocalizations l10n, Take take) {
    return Container(
      decoration: BoxDecoration(
        color: themed(const Color(0xF20E0F12), const Color(0xF2F2EEE6)),
        border: Border(top: BorderSide(color: LuxeColors.hair)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommentComposer(
                    mentionFriends: _mentionFriends,
                    controller: _input,
                    focusNode: _inputFocus,
                    sending: _sending,
                    onSend: _send,
                    replyingTo: _replyTo?.authorName,
                    onCancelReply: _cancelReply,
                  ),
                  if (_sendFailed)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        l10n.reviewCommentFailed,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
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

class _Missing extends StatelessWidget {
  const _Missing({required this.loading, required this.failed});

  final bool loading;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: loading
          ? Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(
                color: LuxeColors.accent,
                backgroundColor: LuxeColors.surface2,
              ),
            )
          : Text(
              failed ? l10n.reviewTakesFailed : l10n.reviewTakesEmpty,
              style: TextStyle(color: LuxeColors.muted, fontSize: 14),
            ),
    );
  }
}

/// The review itself: author and time, their feelings, the take on its
/// skin, a photo, the film, and its heart.
class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({
    required this.take,
    required this.menu,
  });

  final Take take;
  final Widget menu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final createdAt = take.createdAt;
    final feelings = take.authorFeelings;
    final plain = take.skin == TakeSkin.normal;

    final quote = TranslatableText(
      text: take.body,
      format: l10n.reviewQuote,
      style: TextStyle(
        color: LuxeColors.text,
        fontSize: 19,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      linkStyle: TextStyle(color: LuxeColors.muted, fontSize: 12.5),
    );

    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LuxeColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: LuxeColors.hair),
          boxShadow: const [
            BoxShadow(
              color: Color(0x59000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LuxeColors.accent,
                  ),
                  child: TakeAvatar(
                    name: take.authorName,
                    url: take.authorAvatarUrl,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        take.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: LuxeColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (createdAt != null)
                        Text(
                          take.edited
                              ? '${relativeTakeTime(context, createdAt)} · ${l10n.takeEdited}'
                              : relativeTakeTime(context, createdAt),
                          style: TextStyle(
                            color: LuxeColors.muted,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (take.isMostHelpful) _TopPill(label: l10n.reviewMostHelpful),
                menu,
              ],
            ),
            if (feelings.isNotEmpty) ...[
              const SizedBox(height: 12),
              Semantics(
                label: l10n.filmPersonFeelings(
                  feelings.map((f) => reactionLabel(l10n, f)).join(', '),
                ),
                excludeSemantics: true,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final feeling in feelings)
                      FeelingChip(feeling: feeling, tag: true),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            SpoilerShield(
              hidden: take.spoiler,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: take.spoiler ? 96 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (plain)
                      Container(
                        padding: const EdgeInsetsDirectional.only(start: 14),
                        decoration: BoxDecoration(
                          border: BorderDirectional(
                            start:
                                BorderSide(color: LuxeColors.accent, width: 3),
                          ),
                        ),
                        child: quote,
                      )
                    else
                      TakeSkinBackground(
                        skin: take.skin,
                        padding: const EdgeInsets.all(16),
                        child: quote,
                      ),
                    if (take.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: TakePhoto(url: take.imageUrl!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: LuxeColors.hair),
            const SizedBox(height: 12),
            Row(
              children: [
                GameCounter(
                  icon: BootstrapIcons.chat,
                  count: take.commentCount,
                ),
                const Spacer(),
                if (take.isMine)
                  Text(
                    l10n.reviewYourTake,
                    style: TextStyle(
                      color: LuxeColors.muted,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TakeHeart(
                take: take,
                reviews: context.read<MovieReviewsCubit>().repository,
                onChanged: context.read<MovieReviewsCubit>().takeChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the three reactions to a review: icon, label and count, filled
/// when the viewer picked it.
class _TopPill extends StatelessWidget {
  const _TopPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: LuxeColors.accent.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LuxeColors.accent.withValues(alpha: .45)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: LuxeColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
