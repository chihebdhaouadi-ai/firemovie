import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/avatar_frame.dart';
import '../../../l10n/app_localizations.dart';
import '../../film_reviews/domain/take_tag.dart';
import '../../film_reviews/presentation/widgets/spoiler_shield.dart';
import '../../home/views/widgets/take_summary_card.dart' show relativeTakeTime;
import '../data/friend_story.dart';

/// How long one story item stays up before the next one plays.
const storyItemDuration = Duration(seconds: 5);

/// The sentence that says what the friend made, e.g. "Asked about Dune".
String storyHeadline(AppLocalizations l10n, StoryItem item) {
  final film = item.filmTitle ?? l10n.storyUnknownFilm;
  if (item.kind == StoryKind.comment) return l10n.storyComment(film);
  return switch (item.tag) {
    TakeTag.review => l10n.storyTake(film),
    TakeTag.question => l10n.storyQuestion(film),
    TakeTag.discussion => l10n.storyDiscussion(film),
    TakeTag.hotTake => l10n.storyHotTake(film),
    TakeTag.poll => l10n.storyPoll(film),
    TakeTag.scene => l10n.storyScene(film),
  };
}

/// Full-screen stories: one page per friend (swipe between them), each
/// playing that friend's items one after another. Tap the right side for the
/// next item, the left side for the previous one, hold to pause.
class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
    required this.onOpenItem,
    this.onWatched,
  });

  final List<FriendStory> stories;
  final int initialIndex;

  /// Opens the take an item is about (the viewer pauses meanwhile).
  final Future<void> Function(StoryItem item) onOpenItem;

  /// Called once a friend's story has played to its last item.
  final ValueChanged<FriendStory>? onWatched;

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late final PageController _pages =
      PageController(initialPage: widget.initialIndex);
  late int _page = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _nextFriend() {
    if (_page + 1 >= widget.stories.length) {
      Navigator.of(context).maybePop();
      return;
    }
    _pages.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _previousFriend() {
    if (_page == 0) return;
    _pages.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Light status bar text over the dark story.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          controller: _pages,
          itemCount: widget.stories.length,
          onPageChanged: (page) => setState(() => _page = page),
          itemBuilder: (context, index) => _FriendStoryPage(
            key: ValueKey(widget.stories[index].userId),
            story: widget.stories[index],
            active: index == _page,
            onFinished: _nextFriend,
            onBeforeFirst: _previousFriend,
            onOpenItem: widget.onOpenItem,
            onWatched: widget.onWatched,
          ),
        ),
      ),
    );
  }
}

class _FriendStoryPage extends StatefulWidget {
  const _FriendStoryPage({
    super.key,
    required this.story,
    required this.active,
    required this.onFinished,
    required this.onBeforeFirst,
    required this.onOpenItem,
    this.onWatched,
  });

  final FriendStory story;
  final bool active;
  final VoidCallback onFinished;
  final VoidCallback onBeforeFirst;
  final Future<void> Function(StoryItem item) onOpenItem;
  final ValueChanged<FriendStory>? onWatched;

  @override
  State<_FriendStoryPage> createState() => _FriendStoryPageState();
}

class _FriendStoryPageState extends State<_FriendStoryPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock =
      AnimationController(vsync: this, duration: storyItemDuration)
        ..addStatusListener(_onClock);
  int _index = 0;
  bool _reported = false;

  List<StoryItem> get _items => widget.story.items;

  @override
  void initState() {
    super.initState();
    if (widget.active) _start();
  }

  @override
  void didUpdateWidget(covariant _FriendStoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _start();
    } else if (!widget.active && oldWidget.active) {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _start() {
    // _start runs while the pager builds (initState, didUpdateWidget), and
    // reporting rebuilds the home screen, so report once the frame is done.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reportIfLast();
    });
    _clock.forward(from: 0);
  }

  void _reportIfLast() {
    if (_reported || _index != _items.length - 1) return;
    _reported = true;
    widget.onWatched?.call(widget.story);
  }

  void _onClock(AnimationStatus status) {
    if (status == AnimationStatus.completed) _next();
  }

  void _next() {
    if (_index + 1 >= _items.length) {
      widget.onFinished();
      return;
    }
    setState(() => _index++);
    _start();
  }

  void _previous() {
    if (_index == 0) {
      widget.onBeforeFirst();
      _clock.forward(from: 0);
      return;
    }
    setState(() => _index--);
    _start();
  }

  Future<void> _open() async {
    _clock.stop();
    await widget.onOpenItem(_items[_index]);
    if (mounted && widget.active) _clock.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = _items[_index];
    final poster = item.posterUrl;
    final story = widget.story;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (poster != null && poster.isNotEmpty)
          ExcludeSemantics(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: CachedNetworkImage(
                imageUrl: poster,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xCC000000), Color(0x66000000), Color(0xE6000000)],
            ),
          ),
        ),
        // Tap zones: left third goes back, the rest goes forward; holding
        // anywhere pauses.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final width = MediaQuery.sizeOf(context).width;
            if (details.localPosition.dx < width / 3) {
              _previous();
            } else {
              _next();
            }
          },
          onLongPressStart: (_) => _clock.stop(),
          onLongPressEnd: (_) => _clock.forward(),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProgressBars(
                  count: _items.length,
                  index: _index,
                  clock: _clock,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    AvatarFrame(
                      size: 36,
                      avatarUrl: story.avatarUrl,
                      initial: story.username.isEmpty
                          ? ''
                          : story.username[0].toUpperCase(),
                      framed: false,
                      animate: false,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            relativeTakeTime(context, item.createdAt),
                            style: const TextStyle(
                              color: Color(0xB3FFFFFF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.storyClose,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(BootstrapIcons.x_lg,
                          color: Colors.white, size: 28),
                    ),
                  ],
                ),
                const Spacer(),
                _StoryCard(item: item, headline: storyHeadline(l10n, item)),
                const Spacer(),
                Center(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(160, 48),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _open,
                    icon:
                        const Icon(BootstrapIcons.box_arrow_up_right, size: 18),
                    label: Text(
                      l10n.storyOpen,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One segment per item: past ones full, the current one filling up.
class _ProgressBars extends StatelessWidget {
  const _ProgressBars({
    required this.count,
    required this.index,
    required this.clock,
  });

  final int count;
  final int index;
  final Animation<double> clock;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3,
                  child: i == index
                      ? AnimatedBuilder(
                          animation: clock,
                          builder: (context, _) => LinearProgressIndicator(
                            value: clock.value,
                            backgroundColor: const Color(0x4DFFFFFF),
                            color: Colors.white,
                          ),
                        )
                      : ColoredBox(
                          color: i < index
                              ? Colors.white
                              : const Color(0x4DFFFFFF),
                        ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The item itself: what the friend did, on which film, and their words.
class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.item, required this.headline});

  final StoryItem item;
  final String headline;

  @override
  Widget build(BuildContext context) {
    final poster = item.posterUrl;

    final body = Text(
      item.kind == StoryKind.comment ? item.body : '“${item.body}”',
      textAlign: TextAlign.center,
      maxLines: 10,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (poster != null && poster.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: poster,
              width: 96,
              height: 144,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  const SizedBox(width: 96, height: 144),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xCCFFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: .3,
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SpoilerShield(hidden: item.spoiler, child: body),
        ),
      ],
    );
  }
}
