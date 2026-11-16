import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/review_stance.dart';
import '../../domain/take.dart';
import '../../domain/topic_vote.dart';
import 'translatable_text.dart';

const _maxIndentDepth = 5;
const _accentText = Color(0xFF8DB8FF);
const _avatarText = Color(0xFFCFD3DE);

class CommentThread extends StatelessWidget {
  const CommentThread({
    super.key,
    required this.comments,
    required this.onReply,
    this.onVote,
    this.showReviewStance = false,
  });

  final List<TakeComment> comments;
  final ValueChanged<TakeComment> onReply;

  /// Shows like and dislike on each comment when set.
  final void Function(TakeComment comment, TopicVote kind)? onVote;
  final bool showReviewStance;

  @override
  Widget build(BuildContext context) {
    final tree = _CommentTree(comments);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final root in tree.roots)
          _CommentNode(
            comment: root,
            tree: tree,
            depth: 0,
            onReply: onReply,
            onVote: onVote,
            showReviewStance: showReviewStance,
          ),
      ],
    );
  }
}

class _CommentTree {
  _CommentTree(List<TakeComment> comments) {
    final ids = {for (final comment in comments) comment.id};
    for (final comment in comments) {
      final parentId = comment.parentId;
      if (parentId != null && ids.contains(parentId)) {
        (_childrenOf[parentId] ??= []).add(comment);
      } else {
        roots.add(comment);
      }
    }
  }

  final roots = <TakeComment>[];
  final _childrenOf = <int, List<TakeComment>>{};

  List<TakeComment> childrenOf(int id) => _childrenOf[id] ?? const [];

  int descendantCount(int id) {
    var total = 0;
    for (final child in childrenOf(id)) {
      total += 1 + descendantCount(child.id);
    }
    return total;
  }
}

class _CommentNode extends StatefulWidget {
  const _CommentNode({
    required this.comment,
    required this.tree,
    required this.depth,
    required this.onReply,
    this.onVote,
    required this.showReviewStance,
  });

  final TakeComment comment;
  final _CommentTree tree;
  final int depth;
  final ValueChanged<TakeComment> onReply;
  final void Function(TakeComment comment, TopicVote kind)? onVote;
  final bool showReviewStance;

  @override
  State<_CommentNode> createState() => _CommentNodeState();
}

class _CommentNodeState extends State<_CommentNode> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final comment = widget.comment;
    final top = widget.depth == 0;
    final children = widget.tree.childrenOf(comment.id);
    final initial =
        comment.authorName.isEmpty ? '?' : comment.authorName[0].toUpperCase();
    final createdAt = comment.createdAt;

    final header = Row(
      children: [
        CircleAvatar(
          radius: top ? 16 : 13,
          backgroundColor: LuxeColors.surface2,
          child: Text(
            initial,
            style: TextStyle(
              color: _avatarText,
              fontSize: top ? 13 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            comment.authorName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: LuxeColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (top && widget.showReviewStance && comment.stance != null) ...[
          const SizedBox(width: 8),
          _StanceChip(
            stance: comment.stance!,
            label: comment.stance == ReviewStance.changedMyMind
                ? l10n.reviewVoteChangedMyMind
                : l10n.reviewVoteDisagreeFair,
          ),
        ],
        if (comment.isWriter) ...[
          const SizedBox(width: 8),
          _WriterChip(label: l10n.reviewWriterBadge),
        ],
        if (createdAt != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _relativeTime(l10n, createdAt),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: LuxeColors.muted, fontSize: 12),
            ),
          ),
        ],
      ],
    );

    final actions = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (widget.onVote != null)
          _CommentVoteRow(
            comment: comment,
            onVote: (kind) => widget.onVote!(comment, kind),
          ),
        _GhostAction(
          icon: Icons.reply_rounded,
          label: l10n.reviewReply,
          onTap: () => widget.onReply(comment),
        ),
      ],
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: TranslatableText(
            text: comment.body,
            style: const TextStyle(
              color: LuxeColors.text,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Transform.translate(offset: const Offset(-8, 0), child: actions),
        if (children.isNotEmpty)
          _RepliesToggle(
            open: !_collapsed,
            label: _collapsed
                ? l10n.reviewShowReplies(
                    widget.tree.descendantCount(comment.id),
                  )
                : l10n.reviewHideReplies,
            onTap: () => setState(() => _collapsed = !_collapsed),
          ),
      ],
    );

    final Widget? repliesBlock;
    if (children.isEmpty || _collapsed) {
      repliesBlock = null;
    } else {
      final replies = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final child in children)
            _CommentNode(
              comment: child,
              tree: widget.tree,
              depth: widget.depth + 1,
              onReply: widget.onReply,
              onVote: widget.onVote,
              showReviewStance: widget.showReviewStance,
            ),
        ],
      );
      repliesBlock = widget.depth < _maxIndentDepth
          ? Container(
              margin: const EdgeInsets.only(top: 10, left: 2),
              padding: const EdgeInsets.only(left: 14),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: LuxeColors.accent.withValues(alpha: .28),
                    width: 2,
                  ),
                ),
              ),
              child: replies,
            )
          : replies;
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        body,
        if (repliesBlock != null) repliesBlock,
      ],
    );

    // Top-level comments are separated by a hairline; replies stay compact.
    return top
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: LuxeColors.hair)),
            ),
            child: content,
          )
        : Padding(padding: const EdgeInsets.only(top: 10), child: content);
  }

  String _relativeTime(AppLocalizations l10n, DateTime createdAt) {
    final elapsed = DateTime.now().difference(createdAt);
    if (elapsed.inMinutes < 1) return l10n.reviewTimeJustNow;
    if (elapsed.inHours < 1) return l10n.reviewTimeMinutes(elapsed.inMinutes);
    if (elapsed.inDays < 1) return l10n.reviewTimeHours(elapsed.inHours);
    return l10n.reviewTimeDays(elapsed.inDays);
  }
}

class _WriterChip extends StatelessWidget {
  const _WriterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: LuxeColors.accent.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: LuxeColors.accent,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: .6,
        ),
      ),
    );
  }
}

class _StanceChip extends StatelessWidget {
  const _StanceChip({required this.stance, required this.label});

  final ReviewStance stance;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = stance == ReviewStance.changedMyMind
        ? const Color(0xFF62C995)
        : const Color(0xFFE78383);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Quiet text action (icon and label) used under each comment.
class _GhostAction extends StatelessWidget {
  const _GhostAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? LuxeColors.accent : LuxeColors.muted;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: active ? LuxeColors.accent.withValues(alpha: .12) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "View N replies" / "Hide replies" pill with a rotating arrow.
class _RepliesToggle extends StatelessWidget {
  const _RepliesToggle({
    required this.open,
    required this.label,
    required this.onTap,
  });

  final bool open;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsetsDirectional.fromSTEB(8, 5, 12, 5),
          decoration: BoxDecoration(
            color: LuxeColors.accent.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LuxeColors.accent.withValues(alpha: .28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: open ? .5 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: _accentText,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: _accentText,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Like and dislike for one comment. The parent owns the counts and updates them.
class _CommentVoteRow extends StatelessWidget {
  const _CommentVoteRow({required this.comment, required this.onVote});

  final TakeComment comment;
  final ValueChanged<TopicVote> onVote;

  @override
  Widget build(BuildContext context) {
    // Authors cannot vote on their own comment, so the buttons are only shown.
    final enabled = !comment.isMine;
    final liked = comment.myVote == TopicVote.like;
    final disliked = comment.myVote == TopicVote.dislike;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GhostAction(
          icon: Icons.thumb_up_alt_outlined,
          label: '${comment.likes}',
          active: liked,
          onTap: enabled ? () => onVote(TopicVote.like) : null,
        ),
        _GhostAction(
          icon: Icons.thumb_down_alt_outlined,
          label: '${comment.dislikes}',
          active: disliked,
          onTap: enabled ? () => onVote(TopicVote.dislike) : null,
        ),
      ],
    );
  }
}

class CommentComposer extends StatelessWidget {
  const CommentComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.onSend,
    this.replyingTo,
    this.onCancelReply,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final VoidCallback onSend;
  final String? replyingTo;
  final VoidCallback? onCancelReply;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final target = replyingTo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (target != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.reviewReplyingTo(target),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: LuxeColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onCancelReply,
                  child: Tooltip(
                    message: l10n.reviewCancelReply,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: LuxeColors.surface2,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: LuxeColors.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLength: 300,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: const TextStyle(color: LuxeColors.text, fontSize: 15),
                buildCounter: (_,
                        {required currentLength,
                        required isFocused,
                        required maxLength}) =>
                    null,
                decoration: InputDecoration(
                  hintText: l10n.reviewCommentHint,
                  hintStyle: const TextStyle(color: LuxeColors.muted),
                  filled: true,
                  fillColor: LuxeColors.surface,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: LuxeColors.hair),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(
                      color: LuxeColors.accent.withValues(alpha: .6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LuxeColors.accentGradient,
              ),
              child: IconButton(
                tooltip: l10n.reviewSend,
                onPressed: sending ? null : onSend,
                icon: const Icon(
                  Icons.send_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
