import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/motion.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../data/api_review_repository.dart';
import '../../data/review_repository.dart';
import '../../domain/take.dart';
import '../../domain/take_tag.dart';
import '../../domain/topic_vote.dart';
import '../../domain/vote_kind.dart';

/// The heart's red, a little deeper on the light theme.
Color get heartColor => themed(const Color(0xFFFF5C7A), const Color(0xFFD6334F));

/// Reviews keep their hearts as "up" votes, topics as "like" votes, so the
/// server and old counts stay as they are.
bool _isReview(Take take) => take.tag == TakeTag.review;

/// How many hearts [take] has.
int heartCount(Take take) => _isReview(take)
    ? take.votesOf(VoteKind.up)
    : take.topicVotesOf(TopicVote.like);

/// Whether the viewer has given [take] a heart.
bool hasHeart(Take take) => _isReview(take)
    ? take.hasVoted(VoteKind.up)
    : take.myTopicVotes.contains(TopicVote.like);

/// The one reaction on takes and topics: a heart and its count. Tapping
/// fills it at once and saves in the background, going back if the server
/// refuses. Authors see their count but cannot heart their own post.
/// [onChanged] gets the saved take so the screen around can keep it.
class TakeHeart extends StatefulWidget {
  const TakeHeart({
    super.key,
    required this.take,
    this.reviews,
    this.onChanged,
    this.size = 18,
  });

  final Take take;
  final ReviewRepository? reviews;
  final ValueChanged<Take>? onChanged;

  /// The heart icon's size; the count scales with it.
  final double size;

  @override
  State<TakeHeart> createState() => _TakeHeartState();
}

class _TakeHeartState extends State<TakeHeart> {
  late bool _liked = hasHeart(widget.take);
  late int _count = heartCount(widget.take);
  bool _saving = false;

  @override
  void didUpdateWidget(covariant TakeHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A fresher take from the screen wins, unless a tap is still saving.
    if (!_saving && widget.take != oldWidget.take) {
      _liked = hasHeart(widget.take);
      _count = heartCount(widget.take);
    }
  }

  Future<void> _toggle() async {
    if (_saving) return;
    final take = widget.take;
    final liked = !_liked;
    final before = (_liked, _count);
    HapticFeedback.lightImpact();
    setState(() {
      _saving = true;
      _liked = liked;
      _count = (_count + (liked ? 1 : -1)).clamp(0, 1 << 30);
    });
    final reviews = widget.reviews ?? ApiReviewRepository();
    try {
      final updated = _isReview(take)
          ? await reviews.setVote(take.id, VoteKind.up, active: liked)
          : await reviews.setTopicVote(take.id, TopicVote.like, active: liked);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _liked = hasHeart(updated);
        _count = heartCount(updated);
      });
      widget.onChanged?.call(updated);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _liked = before.$1;
        _count = before.$2;
      });
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(context.l10n.reviewVoteFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canTap = !widget.take.isMine;
    final color = _liked ? heartColor : LuxeColors.muted;

    return Tooltip(
      message: l10n.takeHeartLike,
      child: Semantics(
        button: true,
        enabled: canTap,
        selected: _liked,
        label: '${l10n.takeHeartLike}, ${l10n.takeHeartCount(_count)}',
        excludeSemantics: true,
        child: InkResponse(
          key: Key('take-heart-${widget.take.id}'),
          onTap: canTap ? _toggle : null,
          radius: widget.size + 6,
          child: ConstrainedBox(
            // A full finger's reach, even though the heart is small.
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // A small pop when the heart fills.
                  TweenAnimationBuilder<double>(
                    key: ValueKey(_liked),
                    tween: Tween(begin: _liked ? 1.35 : 1, end: 1),
                    duration: motionDuration(
                      context,
                      const Duration(milliseconds: 260),
                    ),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Icon(
                      _liked ? BootstrapIcons.heart_fill : BootstrapIcons.heart,
                      size: widget.size,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_count',
                    style: TextStyle(
                      color: _liked ? heartColor : LuxeColors.text,
                      fontSize: widget.size * .76,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
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
