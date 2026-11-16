import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../angel_bird/angel_bird_host.dart';
import '../../../angel_bird/hold_gesture.dart';
import '../../../debate/presentation/debate_waiting_page.dart';
import '../../../overview/views/widgets/overview_panel.dart';
import '../../domain/take.dart';
import '../../domain/vote_kind.dart';
import 'comment_thread.dart';
import 'take_photo.dart';
import 'translatable_text.dart';
import '../reaction_labels.dart';
import '../state/movie_reviews_cubit.dart';

class TakeCard extends StatefulWidget {
  const TakeCard({
    super.key,
    required this.take,
    required this.isMostHelpful,
    this.isHighlighted = false,
    this.expandComments = false,
    this.showBody = true,
  });

  final Take take;
  final bool isMostHelpful;
  final bool isHighlighted;
  final bool expandComments;
  final bool showBody;

  @override
  State<TakeCard> createState() => _TakeCardState();
}

class _TakeCardState extends State<TakeCard> {
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  late bool _commentsOpen = widget.expandComments;
  late bool _commentsLoading = widget.expandComments;
  bool _sending = false;
  bool _commentFailed = false;
  List<TakeComment>? _comments;
  TakeComment? _replyTo;

  @override
  void initState() {
    super.initState();
    if (widget.expandComments) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadComments();
      });
    }
    if (widget.isHighlighted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Scrollable.ensureVisible(
          context,
          alignment: 0.1,
          duration: const Duration(milliseconds: 300),
        );
      });
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  Future<void> _toggleComments() async {
    setState(() => _commentsOpen = !_commentsOpen);
    if (_commentsOpen && _comments == null) await _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _commentsLoading = true);
    final comments =
        await context.read<MovieReviewsCubit>().loadComments(widget.take.id);
    if (!mounted) return;
    setState(() {
      _commentsLoading = false;
      _comments = comments;
    });
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty) {
      _inputFocus.requestFocus();
      return;
    }
    setState(() {
      _sending = true;
      _commentFailed = false;
    });
    final comment = await context
        .read<MovieReviewsCubit>()
        .postComment(widget.take.id, body, parentId: _replyTo?.id);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (comment == null) {
        _commentFailed = true;
        return;
      }
      _comments = [...?_comments, comment];
      _replyTo = null;
      _input.clear();
    });
  }

  void _startReply(TakeComment comment) {
    setState(() => _replyTo = comment);
    _inputFocus.requestFocus();
  }

  void _cancelReply() => setState(() => _replyTo = null);

  Future<void> _vote(VoteKind kind) async {
    final ok =
        await context.read<MovieReviewsCubit>().setVote(widget.take.id, kind);
    if (!mounted || ok) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(context.l10n.reviewVoteFailed)),
    );
  }

  void _summonBird() {
    final l10n = context.l10n;
    final cubit = context.read<MovieReviewsCubit>();
    final take = widget.take;
    AngelBirdHost.summon(
      context,
      BirdRequest(
        question: l10n.angelBirdReviewQuestion,
        pickPrompt: l10n.angelBirdPickPerson,
        emptyMessage: l10n.angelBirdNoPeople,
        failedMessage: l10n.angelBirdPeopleFailed,
        load: () => _participants(cubit, take),
      ),
    );
  }

  Future<List<BirdOption>> _participants(
    MovieReviewsCubit cubit,
    Take take,
  ) async {
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
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final take = widget.take;
    final initial =
        take.authorName.isEmpty ? '?' : take.authorName[0].toUpperCase();

    final content = BirdHoldRegion(
      onHold: _summonBird,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showBody) ...[
            if (widget.isMostHelpful) ...[
              Text(
                l10n.reviewMostHelpful,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.accentGlow,
                ),
              ),
              SizedBox(height: tokens.spaceXs),
            ],
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.accent,
                  child: Text(
                    initial,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spaceSm),
                Flexible(
                  child: Text(
                    take.authorName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spaceSm),
                OverviewChip(
                  leading: take.reaction == null
                      ? null
                      : reactionIcon(take.reaction!),
                  label: take.reaction == null
                      ? takeBadgeLabel(l10n, take)
                      : reactionLabel(l10n, take.reaction!),
                ),
              ],
            ),
            SizedBox(height: tokens.spaceSm),
            if (take.imageUrl != null) ...[
              TakePhoto(url: take.imageUrl!),
              SizedBox(height: tokens.spaceSm),
            ],
            Container(
              width: double.infinity,
              padding: EdgeInsetsDirectional.only(
                start: tokens.spaceMd,
                top: tokens.spaceXs,
                bottom: tokens.spaceXs,
              ),
              decoration: const BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(color: AppColors.accentGlow, width: 2),
                ),
              ),
              child: TranslatableText(
                text: take.body,
                format: l10n.reviewQuote,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: tokens.spaceSm),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: tokens.spaceXs,
                  runSpacing: tokens.spaceXs,
                  children: [
                    for (final kind in VoteKind.values)
                      FilterChip(
                        label: Text(
                          '${voteLabel(l10n, kind)} ${take.votesOf(kind)}',
                        ),
                        selected: take.hasVoted(kind),
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        selectedColor: AppColors.accent,
                        backgroundColor: AppColors.surface,
                        disabledColor: AppColors.surface,
                        side: BorderSide(
                          color: take.hasVoted(kind)
                              ? AppColors.accentGlow
                              : AppColors.textMuted.withValues(alpha: 0.35),
                        ),
                        labelStyle: theme.textTheme.labelSmall?.copyWith(
                          color: take.hasVoted(kind)
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        onSelected: take.isMine ? null : (_) => _vote(kind),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: _toggleComments,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: Text(l10n.reviewCommentsButton(take.commentCount)),
            ),
          ),
          if (_commentsOpen) _commentsPanel(l10n, tokens, theme),
        ],
      ),
    );

    if (!widget.isHighlighted) return content;

    return Container(
      key: const ValueKey('highlighted-take'),
      padding: EdgeInsets.all(tokens.spaceSm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(
          color: AppColors.accentGlow,
          width: tokens.borderWidth,
        ),
      ),
      child: content,
    );
  }

  Widget _commentsPanel(
    AppLocalizations l10n,
    AppTokens tokens,
    ThemeData theme,
  ) {
    final comments = _comments;

    return Container(
      padding: EdgeInsets.all(tokens.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_commentsLoading)
            const LinearProgressIndicator(
              color: AppColors.accentGlow,
              backgroundColor: AppColors.surfaceRaised,
            )
          else if (comments == null)
            Text(
              l10n.reviewCommentsFailed,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            CommentThread(comments: comments, onReply: _startReply),
          SizedBox(height: tokens.spaceSm),
          CommentComposer(
            controller: _input,
            focusNode: _inputFocus,
            sending: _sending,
            onSend: _send,
            replyingTo: _replyTo?.authorName,
            onCancelReply: _cancelReply,
          ),
          if (_commentFailed)
            Text(
              l10n.reviewCommentFailed,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
        ],
      ),
    );
  }
}
