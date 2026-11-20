import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../../film_reviews/domain/take.dart';
import '../../../film_reviews/domain/take_tag.dart';
import '../../../film_reviews/domain/topic_vote.dart';
import '../../../film_reviews/presentation/widgets/comment_thread.dart';
import '../../../film_reviews/presentation/widgets/mention_suggestions.dart';
import '../../../social/data/social_models.dart';
import '../../data/home_models.dart';

Color get _sheetSurface =>
    themed(const Color(0xFF1B1D23), const Color(0xFFE9E4DA));
Color get _sheetLine =>
    themed(const Color(0xFF2A2D36), const Color(0xFFD6CFC2));
Color get _sheetText =>
    themed(const Color(0xFFE8E9EE), const Color(0xFF1A1814));
Color get _sheetMuted =>
    themed(const Color(0xFF8D919D), const Color(0xFF615B50));

Future<void> showExploreThreadSheet(
  BuildContext context, {
  required FeedItem item,
  required ReviewRepository repository,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ExploreThreadSheet(
      item: item,
      repository: repository,
    ),
  );
}

class _ExploreThreadSheet extends StatefulWidget {
  const _ExploreThreadSheet({
    required this.item,
    required this.repository,
  });

  final FeedItem item;
  final ReviewRepository repository;

  @override
  State<_ExploreThreadSheet> createState() => _ExploreThreadSheetState();
}

class _ExploreThreadSheetState extends State<_ExploreThreadSheet> {
  /// Friends offered while typing `@name` in the composer.
  List<SocialUser> _mentionFriends = const [];

  final _input = TextEditingController();
  final _focus = FocusNode();

  List<TakeComment>? _comments;
  TakeComment? _replyTo;
  bool _loading = true;
  bool _sending = false;
  bool _sendFailed = false;

  @override
  void initState() {
    super.initState();
    MentionFriends.load().then((friends) {
      if (mounted) setState(() => _mentionFriends = friends);
    });
    _loadComments();
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      final comments =
          await widget.repository.fetchComments(widget.item.take.id);
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
          if (comment.id == updated.id) updated else comment,
      ];
    });
  }

  Future<void> _voteComment(TakeComment comment, TopicVote kind) async {
    final current = _findComment(comment.id) ?? comment;
    final nextVote = current.myVote == kind ? null : kind;
    _replaceComment(current.withMyVote(nextVote));
    try {
      final updated = await widget.repository.setCommentVote(
        current.id,
        kind,
        active: nextVote != null,
      );
      if (mounted) _replaceComment(updated);
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
    _focus.requestFocus();
  }

  void _cancelReply() => setState(() => _replyTo = null);

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty || _sending || _loading) {
      if (body.isEmpty) _focus.requestFocus();
      return;
    }
    setState(() {
      _sending = true;
      _sendFailed = false;
    });
    try {
      final comment = await widget.repository.postComment(
        widget.item.take.id,
        body: body,
        parentId: _replyTo?.id,
      );
      if (!mounted) return;
      setState(() {
        _comments = [...?_comments, comment];
        _replyTo = null;
        _sending = false;
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
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final commentCount = _comments?.length ?? widget.item.take.commentCount;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Align(
        alignment: AlignmentDirectional.bottomCenter,
        child: SizedBox(
          width: screenWidth > 480 ? 480 : screenWidth,
          child: Material(
            key: const ValueKey('explore-thread-sheet'),
            color: _sheetSurface,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: _sheetLine),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: screenHeight * .78,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.only(top: 10, bottom: 14),
                      decoration: BoxDecoration(
                        color: LuxeColors.muted.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.topicCommentsHeading(commentCount),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: _sheetText,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.take.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _sheetMuted,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: _sheetLine),
                  Expanded(child: _threadContent()),
                  Divider(height: 1, color: _sheetLine),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommentComposer(
                            mentionFriends: _mentionFriends,
                            controller: _input,
                            focusNode: _focus,
                            sending: _sending || _loading,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _threadContent() {
    final l10n = context.l10n;
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: LuxeColors.accent),
      );
    }
    final comments = _comments;
    if (comments == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.reviewCommentsFailed,
              style: TextStyle(color: LuxeColors.muted),
            ),
            TextButton(
              onPressed: _loadComments,
              child: Text(l10n.homeSectionErrorRetry),
            ),
          ],
        ),
      );
    }
    if (comments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.topicBeFirst,
            textAlign: TextAlign.center,
            style: TextStyle(color: LuxeColors.muted, height: 1.5),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: CommentThread(
        comments: comments,
        onReply: _startReply,
        onVote: _voteComment,
        showReviewStance: widget.item.take.tag == TakeTag.review,
      ),
    );
  }
}
