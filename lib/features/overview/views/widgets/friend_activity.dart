import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/avatar_frame.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../film_reviews/data/api_review_repository.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../../film_reviews/domain/film_reaction.dart';
import '../../../film_reviews/domain/movie_review_summary.dart';
import '../../../film_reviews/domain/take.dart';
import '../../../film_reviews/presentation/reaction_labels.dart';
import '../../../film_reviews/presentation/open_take.dart';
import '../../../home/views/widgets/take_summary_card.dart' show absoluteApiUrl;
import '../../../profile/views/profile_screen.dart';
import '../../data/friend_story_seen_store.dart';
import 'overview_panel.dart';

class FriendActivity extends StatefulWidget {
  const FriendActivity({
    super.key,
    required this.movieId,
    this.repository,
    this.embedded = false,
    this.seenStore,
  });

  final String movieId;
  final ReviewRepository? repository;

  /// True when the caller draws the title and card around it (film page).
  final bool embedded;

  /// Remembers which friends were opened; the device store by default.
  final FriendStorySeenStore? seenStore;

  @override
  State<FriendActivity> createState() => _FriendActivityState();
}

class _FriendActivityState extends State<FriendActivity> {
  late final ReviewRepository _repository =
      widget.repository ?? ApiReviewRepository();
  late final Future<List<FriendFilmActivity>> _future =
      _repository.fetchFriendActivity(widget.movieId);
  late final FriendStorySeenStore _seenStore =
      widget.seenStore ?? const PrefsFriendStorySeenStore();
  Set<String> _seen = const {};

  @override
  void initState() {
    super.initState();
    _seenStore.load().then((seen) {
      if (mounted) setState(() => _seen = seen);
    });
  }

  String _keyFor(FriendStoryGroup friend) =>
      friendStoryKey(widget.movieId, friend.userId, friend.updatedAt);

  void _open(FriendStoryGroup activity) {
    final key = _keyFor(activity);
    if (activity.hasTake && !_seen.contains(key)) {
      setState(() => _seen = {..._seen, key});
      _seenStore.markSeen(key);
    }
    final takeId = activity.takeId;
    if (takeId != null) {
      // Takes open on the same page as topics.
      openFilmTake(
        context,
        widget.movieId,
        takeId,
        reviews: widget.repository,
      );
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProfileScreen(userId: activity.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final body = FutureBuilder<List<FriendFilmActivity>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return LinearProgressIndicator(
            color: AppColors.accentGlow,
            backgroundColor: AppColors.surfaceRaised,
          );
        }
        if (snapshot.hasError) {
          return Text(
            l10n.findDetailsErrorTitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          );
        }
        // One bubble per friend, however many feelings they picked.
        final items = FriendStoryGroup.group(
          snapshot.data ?? const <FriendFilmActivity>[],
        );
        if (items.isEmpty) return const _NoFriendActivity();
        // Like stories: a row of friends, unseen ones ringed in blue.
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) SizedBox(width: tokens.spaceMd),
                FriendStory(
                  friend: items[i],
                  seen: _seen.contains(_keyFor(items[i])),
                  onTap: () => _open(items[i]),
                ),
              ],
            ],
          ),
        );
      },
    );
    if (widget.embedded) return body;

    return OverviewPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.overviewActivityTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          body,
        ],
      ),
    );
  }
}

/// Empty state: a people icon beside the message.
class _NoFriendActivity extends StatelessWidget {
  const _NoFriendActivity();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: tokens.minTouchTarget,
          height: tokens.minTouchTarget,
          decoration: BoxDecoration(
            color: LuxeColors.surface2,
            shape: BoxShape.circle,
          ),
          child: Icon(
            BootstrapIcons.people,
            size: 22,
            color: LuxeColors.muted,
          ),
        ),
        SizedBox(width: tokens.spaceMd),
        Expanded(
          child: Text(
            context.l10n.overviewNoFriendActivity,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: LuxeColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}

/// One friend's activity on a film, merged from the server's rows (one row
/// per feeling): their feelings in order, latest change and their take.
class FriendStoryGroup {
  const FriendStoryGroup({
    required this.userId,
    required this.username,
    required this.feelings,
    required this.updatedAt,
    this.avatarUrl,
    this.takeId,
    this.frame,
  });

  final int userId;
  final String username;
  final String? avatarUrl;

  /// Up to three feelings, each once.
  final List<FilmReaction> feelings;
  final DateTime updatedAt;
  final int? takeId;

  /// Their equipped avatar frame key.
  final String? frame;

  /// Whether the friend wrote a take on the film (not only feelings).
  bool get hasTake => takeId != null;

  /// Merges [items] into one entry per friend, most recent friend first.
  static List<FriendStoryGroup> group(List<FriendFilmActivity> items) {
    final byUser = <int, List<FriendFilmActivity>>{};
    for (final item in items) {
      byUser.putIfAbsent(item.userId, () => []).add(item);
    }
    final groups = [
      for (final rows in byUser.values)
        FriendStoryGroup(
          userId: rows.first.userId,
          username: rows.first.username,
          avatarUrl: rows
              .map((row) => row.avatarUrl)
              .firstWhere((url) => url != null, orElse: () => null),
          feelings: {for (final row in rows) row.reaction}
              .take(MovieReviewSummary.maxFeelings)
              .toList(growable: false),
          updatedAt: rows
              .map((row) => row.updatedAt)
              .reduce((a, b) => a.isAfter(b) ? a : b),
          takeId: rows
              .map((row) => row.takeId)
              .firstWhere((id) => id != null, orElse: () => null),
          frame: rows.first.frame,
        ),
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return groups;
  }
}

/// A friend's feelings as small gradient circles, overlapping a little.
class _FeelingBadges extends StatelessWidget {
  const _FeelingBadges({required this.feelings});

  final List<FilmReaction> feelings;

  static const _size = 22.0;
  static const _step = 14.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size + _step * (feelings.length - 1),
      height: _size,
      child: Stack(
        children: [
          for (var i = 0; i < feelings.length; i++)
            PositionedDirectional(
              start: _step * i,
              child: Container(
                width: _size,
                height: _size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: reactionGradient(feelings[i]),
                  border: Border.all(color: LuxeColors.surface, width: 2),
                ),
                child: Icon(
                  reactionLook(feelings[i]).$1,
                  size: 11,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One friend as a story bubble: picture, what they felt, name below.
/// Friends who shared a take get a blue ring until it is opened and a
/// typing bubble at the top; friends who only reacted get a quiet grey ring.
class FriendStory extends StatelessWidget {
  const FriendStory({
    super.key,
    required this.friend,
    required this.seen,
    required this.onTap,
  });

  final FriendStoryGroup friend;
  final bool seen;
  final VoidCallback onTap;

  /// Room for the frame's ornaments around the photo.
  static const _box = 84.0;
  static const _photo = 50.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activity = friend;
    // Only a shared take is something new to open.
    final fresh = friend.hasTake && !seen;
    final feeling = friend.feelings
        .map((reaction) => reactionLabel(l10n, reaction))
        .join(', ');

    return Semantics(
      button: true,
      label: fresh
          ? l10n.overviewFriendStoryNew(activity.username, feeling)
          : l10n.overviewFriendStorySeen(activity.username, feeling),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: SizedBox(
          width: _box + 4,
          child: Column(
            children: [
              SizedBox.square(
                dimension: _box,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Their own frame (wings, horns, crown…). A blue inner
                    // ring and a moving frame mean a take not opened yet.
                    AvatarFrame(
                      size: _photo,
                      frame: friend.frame,
                      avatarUrl: absoluteApiUrl(activity.avatarUrl),
                      initial: activity.username,
                      backgroundColor: LuxeColors.accentLo,
                      ringWidth: fresh ? 3 : 0,
                      ringColor: LuxeColors.accentHi,
                      animate:
                          fresh && !MediaQuery.disableAnimationsOf(context),
                    ),
                    // Up to three feeling badges at the photo's corner.
                    PositionedDirectional(
                      end: (_box - _photo) / 2 - 10,
                      bottom: (_box - _photo) / 2 - 8,
                      child: _FeelingBadges(feelings: friend.feelings),
                    ),
                    if (friend.hasTake)
                      PositionedDirectional(
                        end: -6,
                        top: -2,
                        child: _TypingBadge(animate: fresh),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                activity.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fresh ? LuxeColors.text : LuxeColors.muted,
                  fontSize: 13,
                  fontWeight: fresh ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Typing" bubble for a friend who shared a take: three dots that bounce
/// while the take is unopened and rest once it is (or with reduced motion).
class _TypingBadge extends StatelessWidget {
  const _TypingBadge({required this.animate});

  final bool animate;

  @override
  Widget build(BuildContext context) {
    final play = animate && !MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      key: const ValueKey('friend-typing-badge'),
      child: Lottie.asset(
        'assets/lottie/typing.json',
        width: 32,
        height: 24,
        animate: play,
        repeat: true,
        // Resting frame shows the three dots level.
        frameRate: FrameRate.max,
      ),
    );
  }
}
