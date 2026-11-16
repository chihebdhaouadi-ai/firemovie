import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/widgets/game_parts.dart';
import '../../../../core/widgets/luxe_chip.dart';
import '../../data/api_review_repository.dart';
import '../../data/review_repository.dart';
import '../../domain/take.dart';
import '../../domain/topic_vote.dart';

/// Like and dislike counters for a question or discussion.
/// Updates the count at once and reverts it if the server rejects the vote.
/// [onChanged] receives the saved take so the parent screens can keep it.
class TopicVoteRow extends StatefulWidget {
  const TopicVoteRow({
    super.key,
    required this.take,
    this.reviews,
    this.onChanged,
    this.luxe = false,
  });

  final Take take;
  final ReviewRepository? reviews;
  final ValueChanged<Take>? onChanged;

  /// Uses the You / Friends / Films button style instead of the game counters.
  final bool luxe;

  @override
  State<TopicVoteRow> createState() => _TopicVoteRowState();
}

class _TopicVoteRowState extends State<TopicVoteRow> {
  late Map<TopicVote, int> _counts = {...widget.take.topicVotes};
  late Set<TopicVote> _mine = {...widget.take.myTopicVotes};

  Future<void> _toggle(TopicVote kind) async {
    final active = !_mine.contains(kind);
    final previousCounts = _counts;
    final previousMine = _mine;
    setState(() => _apply(kind, active));
    try {
      final updated = await (widget.reviews ?? ApiReviewRepository())
          .setTopicVote(widget.take.id, kind, active: active);
      if (!mounted) return;
      setState(() {
        _counts = {...updated.topicVotes};
        _mine = {...updated.myTopicVotes};
      });
      widget.onChanged?.call(updated);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _counts = previousCounts;
        _mine = previousMine;
      });
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(context.l10n.reviewVoteFailed)),
      );
    }
  }

  /// Moves [kind] to the requested state and bumps its count to match.
  /// A like and a dislike cannot both be on: choosing one clears the other.
  void _apply(TopicVote kind, bool active) {
    final count = _counts[kind] ?? 0;
    if (active) {
      final other = kind == TopicVote.like ? TopicVote.dislike : TopicVote.like;
      final otherCount = _counts[other] ?? 0;
      final clearsOther = _mine.contains(other);
      _mine = {..._mine}..remove(other)..add(kind);
      _counts = {
        ..._counts,
        kind: count + 1,
        if (clearsOther) other: otherCount > 0 ? otherCount - 1 : 0,
      };
    } else {
      _mine = {..._mine}..remove(kind);
      _counts = {..._counts, kind: count > 0 ? count - 1 : 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    // Authors cannot vote on their own topic, so the buttons are only shown.
    final enabled = !widget.take.isMine;
    final likeActive = _mine.contains(TopicVote.like);
    final dislikeActive = _mine.contains(TopicVote.dislike);
    final likeTap = enabled ? () => _toggle(TopicVote.like) : null;
    final dislikeTap = enabled ? () => _toggle(TopicVote.dislike) : null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.luxe) ...[
          LuxeCounter(
            icon: Icons.thumb_up_alt_outlined,
            count: _counts[TopicVote.like] ?? 0,
            selected: likeActive,
            onTap: likeTap,
          ),
          const SizedBox(width: 8),
          LuxeCounter(
            icon: Icons.thumb_down_alt_outlined,
            count: _counts[TopicVote.dislike] ?? 0,
            selected: dislikeActive,
            onTap: dislikeTap,
          ),
        ] else ...[
          GameCounter(
            icon: Icons.thumb_up_alt_outlined,
            count: _counts[TopicVote.like] ?? 0,
            active: likeActive,
            onTap: likeTap,
          ),
          const SizedBox(width: 8),
          GameCounter(
            icon: Icons.thumb_down_alt_outlined,
            count: _counts[TopicVote.dislike] ?? 0,
            active: dislikeActive,
            onTap: dislikeTap,
          ),
        ],
      ],
    );
  }
}
