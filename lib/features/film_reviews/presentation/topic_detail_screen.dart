import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/game_parts.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/data/home_models.dart';
import '../../home/views/widgets/film_tile.dart';
import '../../home/views/widgets/take_summary_card.dart';
import '../data/api_review_repository.dart';
import '../data/review_repository.dart';
import '../domain/take.dart';
import '../domain/take_tag.dart';
import '../domain/topic_vote.dart';
import 'widgets/comment_thread.dart';
import 'widgets/take_photo.dart';
import 'widgets/topic_vote_row.dart';

/// A question or discussion on its own page: the question leads, the movie
/// (if any) sits under it, and the comments follow with like and dislike.
class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({
    super.key,
    required this.item,
    this.repository,
    this.onTakeChanged,
  });

  final FeedItem item;
  final ReviewRepository? repository;

  /// Called with the saved take after a like or dislike on the question.
  final ValueChanged<Take>? onTakeChanged;

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  late final ReviewRepository _repository =
      widget.repository ?? ApiReviewRepository();
  final _input = TextEditingController();
  final _inputFocus = FocusNode();

  List<TakeComment>? _comments;
  bool _loading = true;
  bool _sending = false;
  bool _sendFailed = false;
  TakeComment? _replyTo;

  late Take _take = widget.item.take;

  /// Keeps the saved vote on this page and tells the screen that opened it.
  void _takeVoted(Take updated) {
    setState(() => _take = updated);
    widget.onTakeChanged?.call(updated);
  }

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _repository.fetchComments(_take.id);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
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

  /// Moves the viewer's vote to [kind]; tapping the same vote again clears it.
  /// The count changes at once and is reverted if the server rejects it.
  Future<void> _voteComment(TakeComment tapped, TopicVote kind) async {
    final current = _findComment(tapped.id) ?? tapped;
    final vote = current.myVote == kind ? null : kind;
    _replaceComment(current.withMyVote(vote));
    try {
      final updated = await _repository.setCommentVote(
        current.id,
        kind,
        active: vote != null,
      );
      if (!mounted) return;
      _replaceComment(updated);
    } catch (_) {
      if (!mounted) return;
      _replaceComment(current);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(context.l10n.reviewVoteFailed)),
      );
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
    try {
      final comment = await _repository.postComment(
        _take.id,
        body: body,
        parentId: _replyTo?.id,
      );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _comments = [...?_comments, comment];
        _replyTo = null;
        _input.clear();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sendFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final film = widget.item.film;
    final count = _comments?.length ?? _take.commentCount;

    return Scaffold(
      backgroundColor: LuxeColors.bg,
      appBar: AppBar(
        backgroundColor: LuxeColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.topicDetailTitle),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopicHeader(
                  take: _take,
                  film: film.imdbId.isEmpty ? null : film,
                  reviews: widget.repository,
                  onVoteChanged: _takeVoted,
                ),
                const SizedBox(height: 22),
                Text(
                  l10n.topicCommentsHeading(count),
                  style: const TextStyle(
                    color: LuxeColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                _buildComments(l10n),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xF20E0F12),
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
                          style: const TextStyle(
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
      ),
    );
  }

  Widget _buildComments(AppLocalizations l10n) {
    if (_loading) {
      return const Padding(
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
              style: const TextStyle(color: LuxeColors.muted, fontSize: 13),
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
            l10n.topicBeFirst,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
    );
  }
}

/// The question itself: author, tag, large body, photo, movie and counters.
class _TopicHeader extends StatelessWidget {
  const _TopicHeader({
    required this.take,
    required this.film,
    required this.reviews,
    this.onVoteChanged,
  });

  final Take take;
  final Film? film;
  final ReviewRepository? reviews;
  final ValueChanged<Take>? onVoteChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isQuestion = take.tag == TakeTag.question;
    final createdAt = take.createdAt;
    final film = this.film;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
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
                      style: const TextStyle(
                        color: LuxeColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        relativeTakeTime(context, createdAt),
                        style: const TextStyle(
                          color: LuxeColors.muted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              _TagPill(
                label: isQuestion
                    ? l10n.topicTagQuestion
                    : l10n.topicTagDiscussion,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            take.body,
            style: const TextStyle(
              color: LuxeColors.text,
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (take.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: TakePhoto(url: take.imageUrl!),
            ),
          ],
          if (film != null) ...[
            const SizedBox(height: 14),
            _FilmBlock(film: film),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: LuxeColors.hair),
          const SizedBox(height: 12),
          Row(
            children: [
              GameCounter(
                icon: Icons.chat_bubble_outline_rounded,
                count: take.commentCount,
              ),
              const SizedBox(width: 8),
              TopicVoteRow(
                take: take,
                reviews: reviews,
                onChanged: onVoteChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

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
        style: const TextStyle(
          color: LuxeColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _FilmBlock extends StatelessWidget {
  const _FilmBlock({required this.film});

  final Film film;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: LuxeColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LuxeColors.hair),
      ),
      child: Row(
        children: [
          FilmPoster(
            film: film,
            width: 42,
            height: 63,
            radius: 7,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.topicAboutFilm.toUpperCase(),
                  style: const TextStyle(
                    color: LuxeColors.muted,
                    fontSize: 10,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  film.displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: LuxeColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: LuxeColors.muted),
        ],
      ),
    );
  }
}
