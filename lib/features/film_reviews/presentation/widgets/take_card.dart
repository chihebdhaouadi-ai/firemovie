import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../overview/views/widgets/overview_panel.dart';
import '../../domain/take.dart';
import '../../domain/vote_kind.dart';
import '../reaction_labels.dart';
import '../state/movie_reviews_cubit.dart';

class TakeCard extends StatefulWidget {
  const TakeCard({super.key, required this.take, required this.isMostHelpful});

  final Take take;
  final bool isMostHelpful;

  @override
  State<TakeCard> createState() => _TakeCardState();
}

class _TakeCardState extends State<TakeCard> {
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  bool _commentsOpen = false;
  bool _commentsLoading = false;
  bool _sending = false;
  bool _commentFailed = false;
  List<TakeComment>? _comments;

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
        .postComment(widget.take.id, body);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (comment == null) {
        _commentFailed = true;
        return;
      }
      _comments = [...?_comments, comment];
      _input.clear();
    });
  }

  Future<void> _vote(VoteKind kind) async {
    final ok =
        await context.read<MovieReviewsCubit>().setVote(widget.take.id, kind);
    if (!mounted || ok) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(context.l10n.reviewVoteFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final take = widget.take;
    final initial = take.authorName.isEmpty
        ? '?'
        : take.authorName[0].toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              backgroundColor: AppColors.surfaceRaised,
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
            OverviewChip(label: reactionChipLabel(l10n, take.reaction)),
          ],
        ),
        SizedBox(height: tokens.spaceSm),
        Text(
          '“${take.body}”',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: tokens.spaceSm),
        Wrap(
          spacing: tokens.spaceSm,
          runSpacing: tokens.spaceSm,
          children: [
            for (final kind in VoteKind.values)
              FilterChip(
                label: Text('${voteLabel(l10n, kind)} ${take.votesOf(kind)}'),
                selected: take.hasVoted(kind),
                showCheckmark: false,
                selectedColor: AppColors.accent,
                backgroundColor: AppColors.surfaceRaised,
                disabledColor: AppColors.surfaceRaised,
                side: BorderSide.none,
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: take.hasVoted(kind)
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                onSelected: take.isMine ? null : (_) => _vote(kind),
              ),
          ],
        ),
        SizedBox(height: tokens.spaceXs),
        TextButton(
          onPressed: _toggleComments,
          child: Text(l10n.reviewCommentsButton(take.commentCount)),
        ),
        if (_commentsOpen) _commentsPanel(l10n, tokens, theme),
      ],
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
            for (final comment in comments) _CommentRow(comment: comment),
          SizedBox(height: tokens.spaceSm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  focusNode: _inputFocus,
                  maxLength: 300,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  buildCounter: (_,
                          {required currentLength,
                          required isFocused,
                          required maxLength}) =>
                      null,
                  decoration: InputDecoration(
                    hintText: l10n.reviewCommentHint,
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surfaceRaised,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: tokens.spaceSm),
              TextButton(
                onPressed: _sending ? null : _send,
                child: Text(l10n.reviewSend),
              ),
            ],
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

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment});

  final TakeComment comment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final initial = comment.authorName.isEmpty
        ? '?'
        : comment.authorName[0].toUpperCase();

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.surfaceRaised,
                child: Text(
                  initial,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: tokens.spaceSm),
              Flexible(
                child: Text(
                  comment.authorName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (comment.isWriter) ...[
                SizedBox(width: tokens.spaceSm),
                OverviewChip(label: l10n.reviewWriterBadge),
              ],
            ],
          ),
          SizedBox(height: tokens.spaceXs),
          Text(
            comment.body,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
